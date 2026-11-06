import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';

abstract final class NotificationSettingsValidator {
  static const int maxOffsets = 5;

  static AppFailure? delivery(NotificationDeliverySettings settings) {
    for (final entry in settings.modes.entries) {
      final type = NotificationTypes.byId(entry.key);
      if (type == null) {
        return const Validation('modes', 'unknown_notification_type');
      }
      if (!type.pushCapable && entry.value == DeliveryMode.push) {
        return const Validation('modes', 'type_not_push_capable');
      }
    }
    return null;
  }

  static AppFailure? defaults(NotificationDefaults settings) {
    final timeFailure = _timeSettings(
      offsets: settings.defaultOffsetsMinutes,
      overdueAfterMinutes: settings.overdueAfterMinutes,
      morningSummaryMinutes: settings.morningSummaryMinutes,
      quietStartMinutes: settings.quietStartMinutes,
      quietEndMinutes: settings.quietEndMinutes,
    );
    return timeFailure;
  }

  static AppFailure? memberPrefs(
    MemberNotificationPrefs prefs,
    NotificationDefaults familyDefaults,
  ) {
    final overrides = prefs.reminderOverrides;
    final offsets = overrides.defaultOffsetsMinutesOverride;
    if (offsets != null) {
      final failure = _offsets(offsets);
      if (failure != null) return failure;
    }
    final overdue = overrides.overdueAfterMinutesOverride;
    if (overdue != null && !_minuteRange(overdue, 1, 1440)) {
      return const Validation('overdueAfterMinutes', 'out_of_range');
    }
    final summary = overrides.morningSummaryMinutesOverride;
    if (summary != null && !_minuteRange(summary, 0, 1439)) {
      return const Validation('morningSummaryMinutes', 'out_of_range');
    }
    final start = overrides.quietStartMinutesOverride;
    if (start != null && !_minuteRange(start, 0, 1439)) {
      return const Validation('quietStartMinutes', 'out_of_range');
    }
    final end = overrides.quietEndMinutesOverride;
    if (end != null && !_minuteRange(end, 0, 1439)) {
      return const Validation('quietEndMinutes', 'out_of_range');
    }
    final resolved = prefs.resolve(familyDefaults).quiet;
    if (!resolved.isValid) {
      return const Validation('quiet', 'same_start_and_end');
    }
    return null;
  }

  static AppFailure? _timeSettings({
    required List<int> offsets,
    required int overdueAfterMinutes,
    required int morningSummaryMinutes,
    required int quietStartMinutes,
    required int quietEndMinutes,
  }) {
    final offsetFailure = _offsets(offsets);
    if (offsetFailure != null) return offsetFailure;
    if (!_minuteRange(overdueAfterMinutes, 1, 1440)) {
      return const Validation('overdueAfterMinutes', 'out_of_range');
    }
    if (!_minuteRange(morningSummaryMinutes, 0, 1439)) {
      return const Validation('morningSummaryMinutes', 'out_of_range');
    }
    if (!_minuteRange(quietStartMinutes, 0, 1439)) {
      return const Validation('quietStartMinutes', 'out_of_range');
    }
    if (!_minuteRange(quietEndMinutes, 0, 1439)) {
      return const Validation('quietEndMinutes', 'out_of_range');
    }
    if (quietStartMinutes == quietEndMinutes) {
      return const Validation('quiet', 'same_start_and_end');
    }
    return null;
  }

  static AppFailure? _offsets(List<int> offsets) {
    if (offsets.length > maxOffsets) {
      return const Validation('defaultOffsetsMinutes', 'too_many_offsets');
    }
    if (offsets.any((value) => !_minuteRange(value, 1, 1440))) {
      return const Validation('defaultOffsetsMinutes', 'out_of_range');
    }
    if (offsets.toSet().length != offsets.length) {
      return const Validation('defaultOffsetsMinutes', 'duplicate_offsets');
    }
    return null;
  }

  static bool _minuteRange(int value, int min, int max) =>
      value >= min && value <= max;
}
