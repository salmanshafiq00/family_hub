import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:family_hub/features/notifications/domain/notification_settings_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delivery settings reject unknown ids and push for scheduled types', () {
    expect(
      NotificationSettingsValidator.delivery(
        NotificationDeliverySettings(
          modes: const <String, DeliveryMode>{
            'not_a_type': DeliveryMode.normal,
          },
        ),
      ),
      const Validation('modes', 'unknown_notification_type'),
    );
    expect(
      NotificationSettingsValidator.delivery(
        NotificationDeliverySettings(
          modes: const <String, DeliveryMode>{
            'morning_summary': DeliveryMode.push,
          },
        ),
      ),
      const Validation('modes', 'type_not_push_capable'),
    );
    expect(
      NotificationSettingsValidator.delivery(
        NotificationDeliverySettings.defaults(),
      ),
      isNull,
    );
  });

  test('family defaults validate offsets and quiet-hour boundaries', () {
    expect(
      NotificationSettingsValidator.defaults(
        NotificationDefaults(defaultOffsetsMinutes: <int>[30, 30]),
      ),
      const Validation('defaultOffsetsMinutes', 'duplicate_offsets'),
    );
    expect(
      NotificationSettingsValidator.defaults(
        NotificationDefaults(quietStartMinutes: 500, quietEndMinutes: 500),
      ),
      const Validation('quiet', 'same_start_and_end'),
    );
    expect(
      NotificationSettingsValidator.defaults(
        NotificationDefaults(overdueAfterMinutes: 1441),
      ),
      const Validation('overdueAfterMinutes', 'out_of_range'),
    );
  });

  test('member quiet hours are validated after family inheritance', () {
    final result = NotificationSettingsValidator.memberPrefs(
      MemberNotificationPrefs(
        reminderOverrides: ReminderSettings(quietStartMinutes: 400),
      ),
      NotificationDefaults(quietEndMinutes: 400),
    );

    expect(result, const Validation('quiet', 'same_start_and_end'));
  });

  test(
    'editing one member override preserves inheritance for other fields',
    () {
      final inherited =
          MemberNotificationPrefs(
            reminderOverrides: ReminderSettings().copyWith(quietEnabled: false),
          ).resolve(
            NotificationDefaults(
              chores: false,
              defaultOffsetsMinutes: <int>[15],
            ),
          );

      expect(inherited.quiet.enabled, isFalse);
      expect(inherited.choresEnabled, isFalse);
      expect(inherited.defaultOffsetsMinutes, <int>[15]);
    },
  );
}
