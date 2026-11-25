import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:family_hub/core/notifications/data/notification_platform.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/notifications/data/notification_channels.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/notification_tap_router.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_scheduler.dart';
import 'package:family_hub/core/utils/time_zones.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

final class LocalNotificationsScheduler implements ReminderScheduler {
  LocalNotificationsScheduler({
    required SharedPreferences preferences,
    required this.tapRouter,
    required String applicationId,
    LocalNotificationsDriver? driver,
    AndroidSettingsIntents? settingsIntents,
  }) : _metadataStore = LocalReminderMetadataStore(preferences),
       _driver = driver ?? FlutterLocalNotificationsDriver(),
       _settingsIntents =
           settingsIntents ??
           _AndroidSettingsIntents(applicationId: applicationId);

  final LocalReminderMetadataStore _metadataStore;
  final NotificationTapRouter tapRouter;
  final LocalNotificationsDriver _driver;
  final AndroidSettingsIntents _settingsIntents;
  List<NotificationChannelDefinition> _channels =
      const <NotificationChannelDefinition>[];
  bool _initialized = false;
  String? _lastError;
  final Completer<void> _ready = Completer<void>();

  Future<void> initialize({required AppLocalizations localizations}) async {
    try {
      ensureTimeZonesInitialized();
      _channels = notificationChannels(localizations);
      final initialized = await _driver.initialize(tapRouter.route);
      if (initialized == false) {
        throw StateError('The local notification plugin did not initialize.');
      }
      await _driver.createChannels(_channels);
      _initialized = true;
      final launch = await _driver.launchDetails();
      if (launch?.didLaunch == true) tapRouter.route(launch?.payload);
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  @override
  Future<List<PlannedNotification>> pending() async {
    await _ensureInitialized();
    return _guard(() async {
      final requests = await _driver.pending();
      return List<PlannedNotification>.unmodifiable(
        requests.map(_metadataStore.restore),
      );
    });
  }

  @override
  Future<void> schedule(PlannedNotification notification) async {
    await _ensureInitialized();
    await _guard(() async {
      final channel = _channel(notification.channelId);
      await _metadataStore.save(notification);
      await _driver.schedule(
        notification: notification,
        channel: channel,
        scheduledAt: tz.TZDateTime.from(
          notification.scheduledAt.toUtc(),
          tz.getLocation(notification.familyTimezone),
        ),
        exact: await _driver.exactAlarmsAllowed(),
      );
    });
  }

  @override
  Future<void> showNow(PlannedNotification notification) async {
    await _ensureInitialized();
    await _guard(
      () => _driver.show(
        notification: notification,
        channel: _channel(notification.channelId),
      ),
    );
  }

  @override
  Future<void> cancel(List<int> ids) async {
    await _ensureInitialized();
    await _guard(() async {
      for (final id in ids) {
        await _driver.cancel(id);
        await _metadataStore.remove(id);
      }
    });
  }

  @override
  Future<void> cancelAll({NotificationCategory? category}) async {
    await _ensureInitialized();
    if (category != null) {
      final ids = (await pending())
          .where((notification) => _belongsTo(notification, category))
          .map((notification) => notification.id)
          .toList();
      await cancel(ids);
      return;
    }

    await _guard(() async {
      await _driver.cancelAll();
      await _metadataStore.clearAll();
    });
  }

  @override
  Future<NotificationPermissionState> permissions() async {
    await _ensureInitialized();
    return _guard(
      () async => NotificationPermissionState(
        granted: await _driver.notificationsEnabled(),
        exactAlarmsAllowed: await _driver.exactAlarmsAllowed(),
      ),
    );
  }

  @override
  Future<bool> requestNotifications() async {
    await _ensureInitialized();
    return _guard(_driver.requestNotifications);
  }

  @override
  Future<bool> requestExactAlarms() async {
    await _ensureInitialized();
    return _guard(_driver.requestExactAlarms);
  }

  @override
  Future<void> openBatterySettings() =>
      _guard(_settingsIntents.openBatterySettings);

  @override
  Future<void> openExactAlarmSettings() =>
      _guard(_settingsIntents.openExactAlarmSettings);

  @override
  Future<ReminderPlatformDiagnostics> diagnostics() async {
    NotificationPermissionState? permissionState;
    List<PlannedNotification>? scheduled;
    int? sdkVersion;
    try {
      await _ensureInitialized();
      permissionState = await permissions();
      scheduled = await pending();
      sdkVersion = await _guard(_driver.androidSdkVersion);
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
    }
    final times = scheduled?.map((item) => item.scheduledAt).toList() ?? [];
    times.sort();
    return ReminderPlatformDiagnostics(
      permissions:
          permissionState ??
          const NotificationPermissionState(
            granted: false,
            exactAlarmsAllowed: false,
          ),
      pendingCount: scheduled?.length,
      nextFireAt: times.isEmpty ? null : times.first,
      lastError: _lastError,
      androidSdkVersion: sdkVersion,
    );
  }

  NotificationChannelDefinition _channel(NotificationChannelId id) =>
      notificationChannelFor(_channels, id);

  static bool _belongsTo(
    PlannedNotification notification,
    NotificationCategory category,
  ) => switch (category) {
    NotificationCategory.chores =>
      notification.channelId == NotificationChannelId.choresDue ||
          notification.channelId == NotificationChannelId.choresOverdue ||
          notification.channelId == NotificationChannelId.dailySummary,
    NotificationCategory.bazar =>
      notification.channelId == NotificationChannelId.bazar,
    NotificationCategory.family =>
      notification.channelId == NotificationChannelId.family,
  };

  Future<void> _ensureInitialized() async {
    // Setup now runs after the first frame; callers wait for it instead of failing.
    await _ready.future.timeout(const Duration(seconds: 20), onTimeout: () {});
    if (!_initialized) {
      throw StateError(
        _lastError ?? 'The local notification adapter is not initialized.',
      );
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      _lastError = null;
      return result;
    } on Object catch (error, stackTrace) {
      _recordError(error, stackTrace);
      rethrow;
    }
  }

  void _recordError(Object error, StackTrace stackTrace) {
    _lastError = error.toString();
    developer.log(
      'Local notification adapter failed',
      name: 'family_hub.notifications',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }
}

final class _AndroidSettingsIntents implements AndroidSettingsIntents {
  const _AndroidSettingsIntents({required this.applicationId});

  final String applicationId;

  @override
  Future<void> openBatterySettings() {
    _ensureAndroid();
    return const AndroidIntent(
      action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
    ).launch();
  }

  @override
  Future<void> openExactAlarmSettings() {
    _ensureAndroid();
    return AndroidIntent(
      action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      data: 'package:$applicationId',
    ).launch();
  }

  static void _ensureAndroid() {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Android settings are unavailable on this device.',
      );
    }
  }
}
