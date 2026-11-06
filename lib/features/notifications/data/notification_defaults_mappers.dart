import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';

abstract final class NotificationDefaultsMappers {
  static NotificationDefaults fromMap(Map<String, dynamic>? map) {
    if (map == null) return NotificationDefaults.defaults;
    final base = NotificationDefaults.defaults;
    final offsets =
        _offsets(map['defaultOffsetsMinutes']) ?? base.defaultOffsetsMinutes;
    var start = _minute(map['quietStartMinutes']) ?? base.quietStartMinutes;
    var end = _minute(map['quietEndMinutes']) ?? base.quietEndMinutes;
    if (start == end) {
      start = base.quietStartMinutes;
      end = base.quietEndMinutes;
    }

    return NotificationDefaults(
      enabled: _bool(map['enabled']) ?? base.enabled,
      chores: _bool(map['chores']) ?? base.chores,
      bazar: _bool(map['bazar']) ?? base.bazar,
      family: _bool(map['family']) ?? base.family,
      defaultOffsetsMinutes: offsets,
      overdueEnabled: _bool(map['overdueEnabled']) ?? base.overdueEnabled,
      overdueAfterMinutes:
          _bounded(map['overdueAfterMinutes'], 1, 1440) ??
          base.overdueAfterMinutes,
      morningSummaryEnabled:
          _bool(map['morningSummaryEnabled']) ?? base.morningSummaryEnabled,
      morningSummaryMinutes:
          _bounded(map['morningSummaryMinutes'], 0, 1439) ??
          base.morningSummaryMinutes,
      quietEnabled: _bool(map['quietEnabled']) ?? base.quietEnabled,
      quietStartMinutes: start,
      quietEndMinutes: end,
    );
  }

  static Map<String, dynamic> toMap(
    NotificationDefaults settings,
    BaseDocumentMetadata metadata,
  ) => <String, dynamic>{
    'enabled': settings.enabled,
    'chores': settings.chores,
    'bazar': settings.bazar,
    'family': settings.family,
    'defaultOffsetsMinutes': settings.defaultOffsetsMinutes,
    'overdueEnabled': settings.overdueEnabled,
    'overdueAfterMinutes': settings.overdueAfterMinutes,
    'morningSummaryEnabled': settings.morningSummaryEnabled,
    'morningSummaryMinutes': settings.morningSummaryMinutes,
    'quietEnabled': settings.quietEnabled,
    'quietStartMinutes': settings.quietStartMinutes,
    'quietEndMinutes': settings.quietEndMinutes,
    ...BaseMapper.metadataToMap(metadata),
  };

  static MemberNotificationPrefs memberPrefsFromMap(Map<String, dynamic>? map) {
    if (map == null) return MemberNotificationPrefs.defaults;
    var quietStart = _bounded(map['quietStartMinutes'], 0, 1439);
    var quietEnd = _bounded(map['quietEndMinutes'], 0, 1439);
    if (quietStart != null && quietStart == quietEnd) {
      quietStart = null;
      quietEnd = null;
    }
    return MemberNotificationPrefs(
      pushEnabled: _bool(map['pushEnabled']) ?? true,
      reminderOverrides: ReminderSettings(
        globalEnabled: _bool(map['enabled']),
        choresEnabled: _bool(map['chores']),
        bazarEnabled: _bool(map['bazar']),
        familyEnabled: _bool(map['family']),
        defaultOffsetsMinutes: _offsets(map['defaultOffsetsMinutes']),
        overdueEnabled: _bool(map['overdueEnabled']),
        overdueAfterMinutes: _bounded(map['overdueAfterMinutes'], 1, 1440),
        morningSummaryEnabled: _bool(map['morningSummaryEnabled']),
        morningSummaryMinutes: _bounded(map['morningSummaryMinutes'], 0, 1439),
        quietEnabled: _bool(map['quietEnabled']),
        quietStartMinutes: quietStart,
        quietEndMinutes: quietEnd,
      ),
    );
  }

  static Map<String, Object> memberPrefsToMap(MemberNotificationPrefs prefs) {
    final reminders = prefs.reminderOverrides;
    return <String, Object>{
      'pushEnabled': prefs.pushEnabled,
      if (reminders.globalEnabledOverride != null)
        'enabled': reminders.globalEnabledOverride!,
      if (reminders.choresEnabledOverride != null)
        'chores': reminders.choresEnabledOverride!,
      if (reminders.bazarEnabledOverride != null)
        'bazar': reminders.bazarEnabledOverride!,
      if (reminders.familyEnabledOverride != null)
        'family': reminders.familyEnabledOverride!,
      if (reminders.defaultOffsetsMinutesOverride != null)
        'defaultOffsetsMinutes': reminders.defaultOffsetsMinutesOverride!,
      if (reminders.overdueEnabledOverride != null)
        'overdueEnabled': reminders.overdueEnabledOverride!,
      if (reminders.overdueAfterMinutesOverride != null)
        'overdueAfterMinutes': reminders.overdueAfterMinutesOverride!,
      if (reminders.morningSummaryEnabledOverride != null)
        'morningSummaryEnabled': reminders.morningSummaryEnabledOverride!,
      if (reminders.morningSummaryMinutesOverride != null)
        'morningSummaryMinutes': reminders.morningSummaryMinutesOverride!,
      if (reminders.quietEnabledOverride != null)
        'quietEnabled': reminders.quietEnabledOverride!,
      if (reminders.quietStartMinutesOverride != null)
        'quietStartMinutes': reminders.quietStartMinutesOverride!,
      if (reminders.quietEndMinutesOverride != null)
        'quietEndMinutes': reminders.quietEndMinutesOverride!,
    };
  }

  static bool? _bool(Object? value) => value is bool ? value : null;

  static int? _minute(Object? value) => _bounded(value, 0, 1439);

  static int? _bounded(Object? value, int min, int max) =>
      value is int && value >= min && value <= max ? value : null;

  static List<int>? _offsets(Object? value) {
    if (value is! List || value.length > 5) return null;
    final result = <int>[];
    for (final item in value) {
      if (item is! int || item < 1 || item > 1440) return null;
      result.add(item);
    }
    if (result.toSet().length != result.length) return null;
    return List<int>.unmodifiable(result);
  }
}
