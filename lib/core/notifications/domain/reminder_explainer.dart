import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/reminder_planner.dart';
import 'package:family_hub/core/notifications/domain/reminder_precedence.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';

enum ReminderExplanationReason {
  deliveredAsPush,
  globalOff,
  categoryOff,
  templateOff,
  templateNoTimings,
  notAssigned,
  notOpen,
  unavailable,
  projectedPast,
  noUpcomingReminder,
}

final class ReminderExplanation {
  ReminderExplanation({
    required this.willFire,
    required this.nextAt,
    required List<ReminderExplanationReason> reasons,
  }) : reasons = List<ReminderExplanationReason>.unmodifiable(reasons);

  final bool willFire;
  final DateTime? nextAt;
  final List<ReminderExplanationReason> reasons;
}

abstract final class ReminderExplainer {
  static ReminderExplanation explain({
    required PlannableChore item,
    required ReminderSettings settings,
    required DateTime now,
    required String familyTz,
    required ReminderTexts texts,
    required String viewerId,
    Map<String, TemplateReminderConfig> templateIndex =
        const <String, TemplateReminderConfig>{},
    Map<String, DeliveryMode> effectiveModes = const <String, DeliveryMode>{},
  }) {
    if (item.assigneeId != viewerId) {
      return _notFiring(ReminderExplanationReason.notAssigned);
    }
    if (!item.isOpen) return _notFiring(ReminderExplanationReason.notOpen);
    if (item.isUnavailable) {
      return _notFiring(ReminderExplanationReason.unavailable);
    }
    if (item.isProjected && item.dueAt.toUtc().isBefore(now.toUtc())) {
      return _notFiring(ReminderExplanationReason.projectedPast);
    }

    final config = templateIndex[item.templateId];
    final precedence = ReminderPrecedence.resolve(
      settings: settings,
      category: NotificationCategory.chores,
      templateConfig: config,
    );
    if (!precedence.fires) {
      return _notFiring(_reasonFor(precedence.reason));
    }

    final relevantTypeIds = <String>{
      if (precedence.atDue)
        if (item.dueMinutes == null) 'evening_nudge' else 'chore_due',
      if (precedence.offsetsMinutes.isNotEmpty) 'chore_due',
      if (precedence.overdue) 'chore_overdue',
    };
    if (relevantTypeIds.any((id) => effectiveModes[id] == DeliveryMode.push)) {
      return ReminderExplanation(
        willFire: true,
        nextAt: null,
        reasons: const <ReminderExplanationReason>[
          ReminderExplanationReason.deliveredAsPush,
        ],
      );
    }

    final plan = ReminderPlanner.plan(
      PlanInput(
        now: now,
        viewerId: viewerId,
        items: <PlannableChore>[item],
        templateIndex: templateIndex,
        settings: settings,
        familyTz: familyTz,
        texts: texts,
        effectiveModes: effectiveModes,
      ),
    );
    final itemNotifications =
        plan.where((notification) => notification.refId == item.id).toList()
          ..sort(
            (left, right) => left.scheduledAt.compareTo(right.scheduledAt),
          );
    if (itemNotifications.isEmpty) {
      return _notFiring(ReminderExplanationReason.noUpcomingReminder);
    }
    return ReminderExplanation(
      willFire: true,
      nextAt: itemNotifications.first.scheduledAt,
      reasons: const <ReminderExplanationReason>[],
    );
  }

  static ReminderExplanation _notFiring(ReminderExplanationReason reason) =>
      ReminderExplanation(
        willFire: false,
        nextAt: null,
        reasons: <ReminderExplanationReason>[reason],
      );

  static ReminderExplanationReason _reasonFor(
    ReminderPrecedenceReason reason,
  ) => switch (reason) {
    ReminderPrecedenceReason.globalOff => ReminderExplanationReason.globalOff,
    ReminderPrecedenceReason.categoryOff =>
      ReminderExplanationReason.categoryOff,
    ReminderPrecedenceReason.templateOff =>
      ReminderExplanationReason.templateOff,
    ReminderPrecedenceReason.templateNoTimings =>
      ReminderExplanationReason.templateNoTimings,
    ReminderPrecedenceReason.ok => ReminderExplanationReason.noUpcomingReminder,
  };
}
