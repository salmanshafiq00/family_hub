import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';

final class NotificationDefaults {
  factory NotificationDefaults({
    bool enabled = true,
    bool chores = true,
    bool bazar = true,
    bool family = true,
    List<int> defaultOffsetsMinutes =
        ReminderSettings.recommendedOffsetsMinutes,
    bool overdueEnabled = false,
    int overdueAfterMinutes = ReminderSettings.defaultOverdueAfterMinutes,
    bool morningSummaryEnabled = true,
    int morningSummaryMinutes = ReminderSettings.defaultMorningSummaryMinutes,
    bool quietEnabled = true,
    int quietStartMinutes = ReminderSettings.defaultQuietStartMinutes,
    int quietEndMinutes = ReminderSettings.defaultQuietEndMinutes,
  }) => NotificationDefaults._(
    enabled: enabled,
    chores: chores,
    bazar: bazar,
    family: family,
    defaultOffsetsMinutes: defaultOffsetsMinutes,
    overdueEnabled: overdueEnabled,
    overdueAfterMinutes: overdueAfterMinutes,
    morningSummaryEnabled: morningSummaryEnabled,
    morningSummaryMinutes: morningSummaryMinutes,
    quietEnabled: quietEnabled,
    quietStartMinutes: quietStartMinutes,
    quietEndMinutes: quietEndMinutes,
  );

  NotificationDefaults._({
    required this.enabled,
    required this.chores,
    required this.bazar,
    required this.family,
    required List<int> defaultOffsetsMinutes,
    required this.overdueEnabled,
    required this.overdueAfterMinutes,
    required this.morningSummaryEnabled,
    required this.morningSummaryMinutes,
    required this.quietEnabled,
    required this.quietStartMinutes,
    required this.quietEndMinutes,
  }) : defaultOffsetsMinutes = List<int>.unmodifiable(defaultOffsetsMinutes);

  static final NotificationDefaults defaults = NotificationDefaults();

  final bool enabled;
  final bool chores;
  final bool bazar;
  final bool family;
  final List<int> defaultOffsetsMinutes;
  final bool overdueEnabled;
  final int overdueAfterMinutes;
  final bool morningSummaryEnabled;
  final int morningSummaryMinutes;
  final bool quietEnabled;
  final int quietStartMinutes;
  final int quietEndMinutes;

  ReminderSettings toReminderSettings() => ReminderSettings(
    globalEnabled: enabled,
    choresEnabled: chores,
    bazarEnabled: bazar,
    familyEnabled: family,
    defaultOffsetsMinutes: defaultOffsetsMinutes,
    atDue: true,
    overdueEnabled: overdueEnabled,
    overdueAfterMinutes: overdueAfterMinutes,
    morningSummaryEnabled: morningSummaryEnabled,
    morningSummaryMinutes: morningSummaryMinutes,
    quietEnabled: quietEnabled,
    quietStartMinutes: quietStartMinutes,
    quietEndMinutes: quietEndMinutes,
  );

  NotificationDefaults copyWith({
    bool? enabled,
    bool? chores,
    bool? bazar,
    bool? family,
    List<int>? defaultOffsetsMinutes,
    bool? overdueEnabled,
    int? overdueAfterMinutes,
    bool? morningSummaryEnabled,
    int? morningSummaryMinutes,
    bool? quietEnabled,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) => NotificationDefaults(
    enabled: enabled ?? this.enabled,
    chores: chores ?? this.chores,
    bazar: bazar ?? this.bazar,
    family: family ?? this.family,
    defaultOffsetsMinutes: defaultOffsetsMinutes ?? this.defaultOffsetsMinutes,
    overdueEnabled: overdueEnabled ?? this.overdueEnabled,
    overdueAfterMinutes: overdueAfterMinutes ?? this.overdueAfterMinutes,
    morningSummaryEnabled: morningSummaryEnabled ?? this.morningSummaryEnabled,
    morningSummaryMinutes: morningSummaryMinutes ?? this.morningSummaryMinutes,
    quietEnabled: quietEnabled ?? this.quietEnabled,
    quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
    quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
  );

  @override
  bool operator ==(Object other) =>
      other is NotificationDefaults &&
      other.enabled == enabled &&
      other.chores == chores &&
      other.bazar == bazar &&
      other.family == family &&
      _sameList(other.defaultOffsetsMinutes, defaultOffsetsMinutes) &&
      other.overdueEnabled == overdueEnabled &&
      other.overdueAfterMinutes == overdueAfterMinutes &&
      other.morningSummaryEnabled == morningSummaryEnabled &&
      other.morningSummaryMinutes == morningSummaryMinutes &&
      other.quietEnabled == quietEnabled &&
      other.quietStartMinutes == quietStartMinutes &&
      other.quietEndMinutes == quietEndMinutes;

  @override
  int get hashCode => Object.hash(
    enabled,
    chores,
    bazar,
    family,
    Object.hashAll(defaultOffsetsMinutes),
    overdueEnabled,
    overdueAfterMinutes,
    morningSummaryEnabled,
    morningSummaryMinutes,
    quietEnabled,
    quietStartMinutes,
    quietEndMinutes,
  );
}

abstract interface class NotificationDefaultsRepository {
  Stream<NotificationDefaults> watch(String familyId);

  Future<Result<void>> save(
    String familyId,
    NotificationDefaults settings,
    AuditEvent event,
  );
}

bool _sameList(List<int> left, List<int> right) =>
    left.length == right.length &&
    Iterable<int>.generate(left.length).every((i) => left[i] == right[i]);
