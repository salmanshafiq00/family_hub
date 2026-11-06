import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kReminderDeviceTimezonePreferenceKey =
    'reminder_device_timezone';

Future<bool> updateReminderDeviceTimezone({
  required SharedPreferences preferences,
  required Future<String> Function() readTimezone,
}) async {
  final timezone = await readTimezone();
  final previousTimezone = preferences.getString(
    kReminderDeviceTimezonePreferenceKey,
  );
  if (timezone == previousTimezone) return false;
  final saved = await preferences.setString(
    kReminderDeviceTimezonePreferenceKey,
    timezone,
  );
  if (!saved) {
    throw StateError('Could not store the current device timezone.');
  }
  return previousTimezone != null;
}

final class ReminderLifecycleObserver extends WidgetsBindingObserver {
  ReminderLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
