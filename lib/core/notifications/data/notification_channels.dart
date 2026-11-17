import 'dart:io';

import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/notifications/data/notification_platform.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

const MethodChannel _diagnosticsChannel = MethodChannel(
  'com.familyhub/notification_diagnostics',
);

/// `android/app/src/main/res/raw/family_hub_chime.wav` (a short ascending bell).
const String kNotificationSound = 'family_hub_chime';

List<NotificationChannelDefinition> notificationChannels(
  AppLocalizations localizations,
) => <NotificationChannelDefinition>[
  NotificationChannelDefinition(
    id: NotificationChannelId.choresDue,
    name: localizations.notifChannelChoresDue,
    description: localizations.notifChannelChoresDueDescription,
    highImportance: true,
    soundName: kNotificationSound,
  ),
  NotificationChannelDefinition(
    id: NotificationChannelId.choresOverdue,
    name: localizations.notifChannelChoresOverdue,
    description: localizations.notifChannelChoresOverdueDescription,
    highImportance: false,
    soundName: kNotificationSound,
  ),
  NotificationChannelDefinition(
    id: NotificationChannelId.dailySummary,
    name: localizations.notifChannelDailySummary,
    description: localizations.notifChannelDailySummaryDescription,
    highImportance: false,
    soundName: kNotificationSound,
  ),
  NotificationChannelDefinition(
    id: NotificationChannelId.bazar,
    name: localizations.notifChannelBazar,
    description: localizations.notifChannelBazarDescription,
    highImportance: false,
    soundName: kNotificationSound,
  ),
  NotificationChannelDefinition(
    id: NotificationChannelId.family,
    name: localizations.notifChannelFamily,
    description: localizations.notifChannelFamilyDescription,
    highImportance: false,
    soundName: kNotificationSound,
  ),
  NotificationChannelDefinition(
    id: NotificationChannelId.pushEvents,
    name: localizations.notifChannelPushEvents,
    description: localizations.notifChannelPushEventsDescription,
    highImportance: true,
    soundName: kNotificationSound,
  ),
];

NotificationChannelDefinition notificationChannelFor(
  List<NotificationChannelDefinition> channels,
  NotificationChannelId id,
) => channels.firstWhere((channel) => channel.id == id);

final class FlutterLocalNotificationsDriver
    implements LocalNotificationsDriver {
  FlutterLocalNotificationsDriver()
    : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<bool?> initialize(void Function(String? payload) onTap) =>
      _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_family_hub'),
        ),
        onDidReceiveNotificationResponse: (response) => onTap(response.payload),
      );

  @override
  Future<NotificationLaunchDetails?> launchDetails() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null) return null;
    return NotificationLaunchDetails(
      didLaunch: details.didNotificationLaunchApp,
      payload: details.notificationResponse?.payload,
    );
  }

  @override
  Future<void> createChannels(
    List<NotificationChannelDefinition> channels,
  ) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      throw StateError('Android notification channels are unavailable.');
    }
    for (final channel in channels) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          channel.id.id,
          channel.name,
          description: channel.description,
          importance: channel.highImportance
              ? Importance.high
              : Importance.defaultImportance,
          sound: channel.soundName == null
              ? null
              : RawResourceAndroidNotificationSound(channel.soundName!),
          playSound: channel.soundName != null,
        ),
      );
    }
  }

  @override
  Future<List<LocalNotificationRequest>> pending() async =>
      (await _plugin.pendingNotificationRequests())
          .map(
            (request) => LocalNotificationRequest(
              id: request.id,
              title: request.title,
              body: request.body,
              payload: request.payload,
            ),
          )
          .toList(growable: false);

  @override
  Future<void> schedule({
    required PlannedNotification notification,
    required NotificationChannelDefinition channel,
    required tz.TZDateTime scheduledAt,
    required bool exact,
  }) => _plugin.zonedSchedule(
    id: notification.id,
    scheduledDate: scheduledAt,
    notificationDetails: _details(channel),
    androidScheduleMode: exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle,
    title: notification.title,
    body: notification.body,
    payload: notification.payload,
  );

  @override
  Future<void> show({
    required PlannedNotification notification,
    required NotificationChannelDefinition channel,
  }) => _plugin.show(
    id: notification.id,
    title: notification.title,
    body: notification.body,
    notificationDetails: _details(channel),
    payload: notification.payload,
  );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<bool> notificationsEnabled() async {
    final result = await _androidPlugin.areNotificationsEnabled();
    return result ?? false;
  }

  @override
  Future<bool> exactAlarmsAllowed() async {
    final result = await _androidPlugin.canScheduleExactNotifications();
    return result ?? false;
  }

  @override
  Future<bool> requestNotifications() async {
    final result = await _androidPlugin.requestNotificationsPermission();
    return result ?? await notificationsEnabled();
  }

  @override
  Future<bool> requestExactAlarms() async {
    final result = await _androidPlugin.requestExactAlarmsPermission();
    return result ?? await exactAlarmsAllowed();
  }

  @override
  Future<int?> androidSdkVersion() async {
    if (!Platform.isAndroid) return null;
    return _diagnosticsChannel.invokeMethod<int>('androidSdkVersion');
  }

  AndroidFlutterLocalNotificationsPlugin get _androidPlugin {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) {
      throw UnsupportedError('Notification permissions require Android.');
    }
    return android;
  }

  static NotificationDetails _details(NotificationChannelDefinition channel) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.highImportance
              ? Importance.high
              : Importance.defaultImportance,
          priority: channel.highImportance
              ? Priority.high
              : Priority.defaultPriority,
          icon: 'ic_stat_family_hub',
          playSound: channel.soundName != null,
          sound: channel.soundName == null
              ? null
              : RawResourceAndroidNotificationSound(channel.soundName!),
        ),
      );
}
