import 'dart:async';

import 'package:family_hub/core/notifications/data/notification_platform.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:timezone/timezone.dart' as tz;

final class FakeLocalNotificationsDriver implements LocalNotificationsDriver {
  final Map<int, LocalNotificationRequest> requests =
      <int, LocalNotificationRequest>{};
  final List<NotificationChannelDefinition> channels =
      <NotificationChannelDefinition>[];
  final List<({int id, tz.TZDateTime at, bool exact, String channelId})>
  schedules = [];
  final List<int> cancelled = <int>[];
  int initializeCalls = 0;
  int permissionRequests = 0;
  int exactAlarmRequests = 0;
  int showCalls = 0;
  bool notificationsEnabledResult = true;
  bool exactAlarmsAllowedResult = true;
  bool requestNotificationsResult = true;
  bool requestExactAlarmsResult = true;
  bool failInitialize = false;
  Completer<void>? initializeGate;
  int? sdkVersion = 35;
  NotificationLaunchDetails? launch;
  void Function(String? payload)? onTap;

  @override
  Future<bool?> initialize(void Function(String? payload) callback) async {
    initializeCalls++;
    onTap = callback;
    final gate = initializeGate;
    if (gate != null) await gate.future;
    if (failInitialize) throw StateError('plugin init failed');
    return true;
  }

  @override
  Future<NotificationLaunchDetails?> launchDetails() async => launch;

  @override
  Future<void> createChannels(List<NotificationChannelDefinition> value) async {
    channels
      ..clear()
      ..addAll(value);
  }

  @override
  Future<List<LocalNotificationRequest>> pending() async =>
      List<LocalNotificationRequest>.unmodifiable(requests.values);

  @override
  Future<void> schedule({
    required PlannedNotification notification,
    required NotificationChannelDefinition channel,
    required tz.TZDateTime scheduledAt,
    required bool exact,
  }) async {
    schedules.add((
      id: notification.id,
      at: scheduledAt,
      exact: exact,
      channelId: channel.id.id,
    ));
    requests[notification.id] = LocalNotificationRequest(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      payload: notification.payload,
    );
  }

  @override
  Future<void> show({
    required PlannedNotification notification,
    required NotificationChannelDefinition channel,
  }) async {
    showCalls++;
  }

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    requests.remove(id);
  }

  @override
  Future<void> cancelAll() async => requests.clear();

  @override
  Future<bool> notificationsEnabled() async => notificationsEnabledResult;

  @override
  Future<bool> exactAlarmsAllowed() async => exactAlarmsAllowedResult;

  @override
  Future<bool> requestNotifications() async {
    permissionRequests++;
    return requestNotificationsResult;
  }

  @override
  Future<bool> requestExactAlarms() async {
    exactAlarmRequests++;
    return requestExactAlarmsResult;
  }

  @override
  Future<int?> androidSdkVersion() async => sdkVersion;
}

final class FakeAndroidSettingsIntents implements AndroidSettingsIntents {
  int batterySettingsCalls = 0;
  int exactAlarmSettingsCalls = 0;

  @override
  Future<void> openBatterySettings() async {
    batterySettingsCalls++;
  }

  @override
  Future<void> openExactAlarmSettings() async {
    exactAlarmSettingsCalls++;
  }
}
