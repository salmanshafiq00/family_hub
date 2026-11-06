import 'package:family_hub/features/notifications/presentation/lifecycle_observer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('stores the initial device timezone without reporting a change', () async {
    final preferences = await SharedPreferences.getInstance();

    final changed = await updateReminderDeviceTimezone(
      preferences: preferences,
      readTimezone: () async => 'Asia/Dhaka',
    );

    expect(changed, isFalse);
    expect(
      preferences.getString(kReminderDeviceTimezonePreferenceKey),
      'Asia/Dhaka',
    );
  });

  test('reports and stores a changed device timezone', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      kReminderDeviceTimezonePreferenceKey,
      'Asia/Dhaka',
    );

    final changed = await updateReminderDeviceTimezone(
      preferences: preferences,
      readTimezone: () async => 'Europe/London',
    );

    expect(changed, isTrue);
    expect(
      preferences.getString(kReminderDeviceTimezonePreferenceKey),
      'Europe/London',
    );
  });

  test('does not report an unchanged device timezone', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      kReminderDeviceTimezonePreferenceKey,
      'Asia/Dhaka',
    );

    final changed = await updateReminderDeviceTimezone(
      preferences: preferences,
      readTimezone: () async => 'Asia/Dhaka',
    );

    expect(changed, isFalse);
  });

  test('propagates timezone read failures', () async {
    final preferences = await SharedPreferences.getInstance();

    await expectLater(
      updateReminderDeviceTimezone(
        preferences: preferences,
        readTimezone: () async => throw StateError('timezone unavailable'),
      ),
      throwsStateError,
    );
  });
}
