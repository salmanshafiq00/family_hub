import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';

enum ReminderPrecedenceReason {
  globalOff,
  categoryOff,
  templateOff,
  templateNoTimings,
  ok,
}

final class TemplateReminderConfig {
  TemplateReminderConfig({
    required this.enabled,
    this.atDue = true,
    List<int> offsetsMinutes = const <int>[],
    this.overdueEnabled = false,
    this.overdueAfterMinutes = ReminderSettings.defaultOverdueAfterMinutes,
  }) : offsetsMinutes = List<int>.unmodifiable(offsetsMinutes);

  final bool enabled;
  final bool atDue;
  final List<int> offsetsMinutes;
  final bool overdueEnabled;
  final int overdueAfterMinutes;

  @override
  bool operator ==(Object other) =>
      other is TemplateReminderConfig &&
      other.enabled == enabled &&
      other.atDue == atDue &&
      _sameOffsets(other.offsetsMinutes, offsetsMinutes) &&
      other.overdueEnabled == overdueEnabled &&
      other.overdueAfterMinutes == overdueAfterMinutes;

  @override
  int get hashCode => Object.hash(
    enabled,
    atDue,
    Object.hashAll(offsetsMinutes),
    overdueEnabled,
    overdueAfterMinutes,
  );
}

final class ReminderPrecedenceResult {
  ReminderPrecedenceResult({
    required this.fires,
    required this.atDue,
    required List<int> offsetsMinutes,
    required this.overdue,
    required this.overdueAfterMinutes,
    required this.reason,
  }) : offsetsMinutes = List<int>.unmodifiable(offsetsMinutes);

  final bool fires;
  final bool atDue;
  final List<int> offsetsMinutes;
  final bool overdue;
  final int overdueAfterMinutes;
  final ReminderPrecedenceReason reason;
}

abstract final class ReminderPrecedence {
  static ReminderPrecedenceResult resolve({
    required ReminderSettings settings,
    required NotificationCategory category,
    TemplateReminderConfig? templateConfig,
  }) {
    final config = templateConfig;
    final atDue = config?.atDue ?? settings.atDue;
    final offsets = config?.offsetsMinutes ?? settings.defaultOffsetsMinutes;
    final overdue = config?.overdueEnabled ?? settings.overdueEnabled;
    final overdueAfter =
        config?.overdueAfterMinutes ?? settings.overdueAfterMinutes;

    ReminderPrecedenceReason? reason;
    if (!settings.globalEnabled) {
      reason = ReminderPrecedenceReason.globalOff;
    } else if (!settings.categoryEnabled(category)) {
      reason = ReminderPrecedenceReason.categoryOff;
    } else if (config != null && !config.enabled) {
      reason = ReminderPrecedenceReason.templateOff;
    } else if (!atDue && offsets.isEmpty && !overdue) {
      reason = ReminderPrecedenceReason.templateNoTimings;
    }

    return ReminderPrecedenceResult(
      fires: reason == null,
      atDue: atDue,
      offsetsMinutes: offsets,
      overdue: overdue,
      overdueAfterMinutes: overdueAfter,
      reason: reason ?? ReminderPrecedenceReason.ok,
    );
  }
}

bool _sameOffsets(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}
