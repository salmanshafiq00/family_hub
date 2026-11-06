import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';

final class MemberNotificationPrefs {
  factory MemberNotificationPrefs({
    bool pushEnabled = true,
    ReminderSettings? reminderOverrides,
  }) => MemberNotificationPrefs._(
    pushEnabled: pushEnabled,
    reminderOverrides: reminderOverrides ?? ReminderSettings(),
  );

  const MemberNotificationPrefs._({
    required this.pushEnabled,
    required this.reminderOverrides,
  });

  static final MemberNotificationPrefs defaults = MemberNotificationPrefs();

  final bool pushEnabled;

  /// Nullable fields in this value represent "inherit from family".
  final ReminderSettings reminderOverrides;

  ReminderSettings resolve(NotificationDefaults familyDefaults) =>
      reminderOverrides.inheritFrom(familyDefaults.toReminderSettings());

  MemberNotificationPrefs copyWith({
    bool? pushEnabled,
    ReminderSettings? reminderOverrides,
  }) => MemberNotificationPrefs(
    pushEnabled: pushEnabled ?? this.pushEnabled,
    reminderOverrides: reminderOverrides ?? this.reminderOverrides,
  );

  @override
  bool operator ==(Object other) =>
      other is MemberNotificationPrefs &&
      other.pushEnabled == pushEnabled &&
      other.reminderOverrides == reminderOverrides;

  @override
  int get hashCode => Object.hash(pushEnabled, reminderOverrides);
}

abstract interface class MemberNotificationPrefsStore {
  MemberNotificationPrefs load(String uid);

  Future<Result<void>> save(String uid, MemberNotificationPrefs prefs);
}

abstract interface class NotificationPreferenceSync {
  Future<Result<void>> push(String uid, MemberNotificationPrefs prefs);
}
