import 'package:family_hub/core/notifications/domain/notification_id_factory.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_plan_input.dart';
import 'package:family_hub/core/notifications/domain/reminder_precedence.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/time_zones.dart';
import 'package:timezone/timezone.dart' as tz;

export 'package:family_hub/core/notifications/domain/reminder_plan_input.dart'
    show
        BazarReminderInput,
        PlanInput,
        PlannableChore,
        PlannableChoreStatus,
        ReminderTexts,
        kMaxPlannedNotifications,
        kReminderPastToleranceSeconds,
        kReminderWindowDays,
        kQuietStaleAfterDueHours;

part 'reminder_planner_parts.dart';

abstract final class ReminderPlanner {
  static List<PlannedNotification> plan(PlanInput input) {
    final now = input.now.toUtc();
    final windowEnd = now.add(Duration(days: input.windowDays));
    final location = _location(input.familyTz);
    final candidates = <ReminderCandidate>[];
    final eligibleItems = <PlannableChore>[];

    for (final item in input.items) {
      if (!_eligible(item, input.viewerId, now)) continue;
      eligibleItems.add(item);
      if (item.dueAt.toUtc().isAfter(windowEnd)) continue;
      if (item.dueAt.toUtc().isBefore(now.subtract(const Duration(days: 1)))) {
        continue;
      }

      final precedence = ReminderPrecedence.resolve(
        settings: input.settings,
        category: NotificationCategory.chores,
        templateConfig: input.templateIndex[item.templateId],
      );
      if (!precedence.fires) continue;

      final choreName = input.texts.choreName(item.nameBn, item.nameEn);
      final dueAt = item.dueAt.toUtc();
      if (precedence.atDue) {
        if (item.dueMinutes == null) {
          final nudgeAt = _atMinutes(
            DateKey.fromInstant(dueAt, timezone: input.familyTz),
            ReminderSettings.eveningNudgeMinutes,
            location,
          );
          _addIfNormal(
            input,
            candidates,
            notificationTypeId: 'evening_nudge',
            candidate: ReminderCandidate(
              kind: PlannedNotificationKind.nudge,
              at: nudgeAt,
              refId: item.id,
              discriminator: 'nudge',
              title: input.texts.nudgeTitle(),
              body: input.texts.nudgeBody(1),
              payload: '/chores/occurrence/${item.id}',
              channelId: NotificationChannelId.choresOverdue,
              dueAt: dueAt,
            ),
          );
        } else {
          _addIfNormal(
            input,
            candidates,
            notificationTypeId: 'chore_due',
            candidate: ReminderCandidate(
              kind: PlannedNotificationKind.due,
              at: dueAt,
              refId: item.id,
              discriminator: 'due',
              title: input.texts.dueTitle(choreName),
              body: input.texts.dueBody(
                choreName,
                input.texts.formatTime(dueAt, input.familyTz),
              ),
              payload: '/chores/occurrence/${item.id}',
              channelId: NotificationChannelId.choresDue,
              dueAt: dueAt,
            ),
          );
        }
      }

      for (final offset in precedence.offsetsMinutes) {
        final at = dueAt.subtract(Duration(minutes: offset));
        _addIfNormal(
          input,
          candidates,
          notificationTypeId: 'chore_due',
          candidate: ReminderCandidate(
            kind: PlannedNotificationKind.before,
            at: at,
            refId: item.id,
            discriminator: 'before_$offset',
            title: input.texts.beforeTitle(choreName),
            body: input.texts.beforeBody(
              choreName,
              offset,
              input.texts.formatTime(dueAt, input.familyTz),
            ),
            payload: '/chores/occurrence/${item.id}',
            channelId: NotificationChannelId.choresDue,
            dueAt: dueAt,
          ),
        );
      }

      if (precedence.overdue) {
        final at = dueAt.add(Duration(minutes: precedence.overdueAfterMinutes));
        _addIfNormal(
          input,
          candidates,
          notificationTypeId: 'chore_overdue',
          candidate: ReminderCandidate(
            kind: PlannedNotificationKind.overdue,
            at: at,
            refId: item.id,
            discriminator: 'overdue',
            title: input.texts.overdueTitle(choreName),
            body: input.texts.overdueBody(choreName),
            payload: '/chores/occurrence/${item.id}',
            channelId: NotificationChannelId.choresOverdue,
            dueAt: dueAt,
          ),
        );
      }
    }

    _addSummaries(input, eligibleItems, now, windowEnd, location, candidates);
    _addBazarReminders(input, now, windowEnd, location, candidates);

    final prepared = <ReminderCandidate>[];
    for (final candidate in candidates) {
      final moved = _moveOutOfQuietHours(
        candidate.at,
        input.settings.quiet,
        location,
      );
      if (moved.isAfter(candidate.at) &&
          candidate.dueAt != null &&
          moved.isAfter(
            candidate.dueAt!.add(
              const Duration(hours: kQuietStaleAfterDueHours),
            ),
          )) {
        continue;
      }
      if (moved.isBefore(
        now.add(const Duration(seconds: kReminderPastToleranceSeconds)),
      )) {
        continue;
      }
      if (moved.isAfter(windowEnd)) continue;
      prepared.add(
        ReminderCandidate(
          kind: candidate.kind,
          at: moved,
          refId: candidate.refId,
          discriminator: candidate.discriminator,
          title: candidate.title,
          body: candidate.body,
          payload: candidate.payload,
          channelId: candidate.channelId,
          dueAt: candidate.dueAt,
        ),
      );
    }

    prepared.sort((left, right) {
      final byTime = left.at.compareTo(right.at);
      return byTime != 0 ? byTime : left.stableKey.compareTo(right.stableKey);
    });

    final usedIds = <int>{};
    return List<PlannedNotification>.unmodifiable(
      prepared.take(kMaxPlannedNotifications).map((candidate) {
        final id = NotificationIdFactory.unique(
          kind: candidate.kind.name,
          refId: candidate.refId,
          discriminator: candidate.discriminator,
          usedIds: usedIds,
        );
        return PlannedNotification(
          id: id,
          kind: candidate.kind,
          scheduledAt: candidate.at,
          title: candidate.title,
          body: candidate.body,
          payload: candidate.payload,
          refId: candidate.refId,
          channelId: candidate.channelId,
        );
      }),
    );
  }
}
