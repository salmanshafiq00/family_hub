import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_precedence.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/core/utils/date_key.dart';

const int kReminderWindowDays = 7;
const int kMaxPlannedNotifications = 60;
const int kReminderPastToleranceSeconds = 5;
const int kQuietStaleAfterDueHours = 6;

enum PlannableChoreStatus {
  scheduled,
  inProgress,
  completed,
  verified,
  skipped,
}

final class PlannableChore {
  const PlannableChore({
    required this.id,
    required this.templateId,
    required this.dueAt,
    required this.status,
    required this.assigneeId,
    required this.nameBn,
    this.nameEn,
    this.dueMinutes,
    this.categoryHint,
    this.isProjected = false,
    this.isUnavailable = false,
  });

  final String id;
  final String templateId;
  final DateTime dueAt;
  final PlannableChoreStatus status;
  final String? assigneeId;
  final String nameBn;
  final String? nameEn;
  final int? dueMinutes;
  final String? categoryHint;
  final bool isProjected;
  final bool isUnavailable;

  bool get isOpen =>
      status == PlannableChoreStatus.scheduled ||
      status == PlannableChoreStatus.inProgress;
}

final class BazarReminderInput {
  const BazarReminderInput({
    this.contributionDueDay = 5,
    this.unpaidThisMonth = false,
    this.canCloseMonth = false,
    this.monthEndKey,
  });

  final int contributionDueDay;
  final bool unpaidThisMonth;
  final bool canCloseMonth;
  final DateKey? monthEndKey;
}

abstract interface class ReminderTexts {
  String formatTime(DateTime instant, String familyTimezone);

  String choreName(String nameBn, String? nameEn);

  String dueTitle(String choreName);

  String dueBody(String choreName, String time);

  String beforeTitle(String choreName);

  String beforeBody(String choreName, int offsetMinutes, String time);

  String overdueTitle(String choreName);

  String overdueBody(String choreName);

  String nudgeTitle();

  String nudgeBody(int remainingCount);

  String summaryTitle();

  String summaryBody(int choreCount);

  String contributionDueTitle();

  String contributionDueBody();

  String monthEndTitle();

  String monthEndBody();
}

final class PlanInput {
  PlanInput({
    required this.now,
    required this.viewerId,
    required List<PlannableChore> items,
    required Map<String, TemplateReminderConfig> templateIndex,
    required this.settings,
    required this.familyTz,
    required this.texts,
    this.windowDays = kReminderWindowDays,
    this.bazar = const BazarReminderInput(),
    Map<String, DeliveryMode> effectiveModes = const <String, DeliveryMode>{},
  }) : items = List<PlannableChore>.unmodifiable(items),
       templateIndex = Map<String, TemplateReminderConfig>.unmodifiable(
         templateIndex,
       ),
       effectiveModes = Map<String, DeliveryMode>.unmodifiable(effectiveModes) {
    if (windowDays < 1 || windowDays > kReminderWindowDays) {
      throw RangeError.range(windowDays, 1, kReminderWindowDays, 'windowDays');
    }
    if (viewerId.isEmpty) throw ArgumentError.value(viewerId, 'viewerId');
  }

  final DateTime now;
  final int windowDays;
  final String viewerId;
  final List<PlannableChore> items;
  final Map<String, TemplateReminderConfig> templateIndex;
  final ReminderSettings settings;
  final BazarReminderInput bazar;
  final String familyTz;
  final ReminderTexts texts;
  final Map<String, DeliveryMode> effectiveModes;
}

final class ReminderCandidate {
  const ReminderCandidate({
    required this.kind,
    required this.at,
    required this.refId,
    required this.discriminator,
    required this.title,
    required this.body,
    required this.payload,
    required this.channelId,
    this.dueAt,
  });

  final PlannedNotificationKind kind;
  final DateTime at;
  final String refId;
  final String discriminator;
  final String title;
  final String body;
  final String payload;
  final NotificationChannelId channelId;
  final DateTime? dueAt;

  String get stableKey => '${kind.index}|$refId|$discriminator';
}
