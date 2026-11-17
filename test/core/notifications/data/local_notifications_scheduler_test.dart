import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/notifications/data/local_notifications_scheduler.dart';
import 'package:family_hub/core/notifications/data/notification_platform.dart';
import 'package:family_hub/core/notifications/domain/notification_tap_router.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_local_notifications_driver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initializes channels without requesting runtime permissions', () async {
    final driver = FakeLocalNotificationsDriver();
    final scheduler = await _scheduler(driver);

    expect(driver.initializeCalls, 1);
    expect(driver.channels.map((channel) => channel.id.id), <String>[
      'chores_due_v2',
      'chores_overdue_v2',
      'daily_summary_v2',
      'bazar_v2',
      'family_v2',
      'push_events_v2',
    ]);
    expect(
      driver.channels.every(
        (channel) => channel.soundName == 'family_hub_chime',
      ),
      isTrue,
    );
    expect(driver.channels.first.highImportance, isTrue);
    expect(driver.channels.last.highImportance, isTrue);
    expect(
      driver.channels
          .where((channel) => channel.id.id != 'push_events_v2')
          .skip(1)
          .every((channel) => !channel.highImportance),
      isTrue,
    );
    expect(driver.permissionRequests, 0);
    expect(driver.exactAlarmRequests, 0);

    await scheduler.cancelAll();
  });

  test(
    'scheduling preserves the instant and metadata across adapter restarts',
    () async {
      final driver = FakeLocalNotificationsDriver();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final scheduler = await _scheduler(driver, preferences: preferences);
      final notification = _notification(familyTimezone: 'Asia/Dhaka');

      await scheduler.schedule(notification);

      final schedule = driver.schedules.single;
      expect(schedule.at.location.name, 'Asia/Dhaka');
      expect(schedule.at.toUtc(), notification.scheduledAt);
      expect(schedule.exact, isTrue);
      expect(schedule.channelId, 'chores_due_v2');
      final restarted = await _scheduler(driver, preferences: preferences);
      expect(await restarted.pending(), <PlannedNotification>[notification]);
    },
  );

  test('uses inexact mode when exact alarm access is unavailable', () async {
    final driver = FakeLocalNotificationsDriver()
      ..exactAlarmsAllowedResult = false;
    final scheduler = await _scheduler(driver);

    await scheduler.schedule(_notification());

    expect(driver.schedules.single.exact, isFalse);
  });

  test('category cancellation preserves other categories', () async {
    final driver = FakeLocalNotificationsDriver();
    final scheduler = await _scheduler(driver);
    await scheduler.schedule(_notification(id: 1));
    await scheduler.schedule(_notification(id: 2, bazar: true));

    await scheduler.cancelAll(category: NotificationCategory.chores);

    expect(driver.cancelled, <int>[1]);
    expect((await scheduler.pending()).map((item) => item.id), <int>[2]);
  });

  test(
    'exposes explicit permission, immediate, settings, and diagnostics APIs',
    () async {
      final driver = FakeLocalNotificationsDriver()
        ..requestNotificationsResult = false
        ..requestExactAlarmsResult = false
        ..notificationsEnabledResult = false
        ..exactAlarmsAllowedResult = false;
      final settingsIntents = FakeAndroidSettingsIntents();
      final scheduler = await _scheduler(
        driver,
        settingsIntents: settingsIntents,
      );

      expect(await scheduler.requestNotifications(), isFalse);
      expect(await scheduler.requestExactAlarms(), isFalse);
      await scheduler.showNow(_notification());
      await scheduler.openBatterySettings();
      await scheduler.openExactAlarmSettings();
      final diagnostics = await scheduler.diagnostics();

      expect(driver.showCalls, 1);
      expect(driver.permissionRequests, 1);
      expect(driver.exactAlarmRequests, 1);
      expect(settingsIntents.batterySettingsCalls, 1);
      expect(settingsIntents.exactAlarmSettingsCalls, 1);
      expect(diagnostics.permissions.granted, isFalse);
      expect(diagnostics.permissions.exactAlarmsAllowed, isFalse);
      expect(diagnostics.pendingCount, 0);
      expect(diagnostics.androidSdkVersion, 35);
    },
  );

  test(
    'keeps startup usable and exposes adapter initialization failures',
    () async {
      final driver = FakeLocalNotificationsDriver()..failInitialize = true;
      final scheduler = await _scheduler(driver);

      final diagnostics = await scheduler.diagnostics();

      expect(diagnostics.lastError, contains('plugin init failed'));
      expect(diagnostics.pendingCount, isNull);
      await expectLater(scheduler.pending(), throwsStateError);
    },
  );

  test('routes a cold-start tap after the app router attaches', () async {
    final driver = FakeLocalNotificationsDriver()
      ..launch = const NotificationLaunchDetails(
        didLaunch: true,
        payload: '/chores/today',
      );
    final tapRouter = NotificationTapRouter();
    await _scheduler(driver, tapRouter: tapRouter);
    final routes = <String>[];

    tapRouter.attach(
      navigate: routes.add,
      choresEnabled: true,
      bazarEnabled: true,
    );

    expect(routes, <String>['/chores/today']);
  });
}

Future<LocalNotificationsScheduler> _scheduler(
  FakeLocalNotificationsDriver driver, {
  NotificationTapRouter? tapRouter,
  SharedPreferences? preferences,
  FakeAndroidSettingsIntents? settingsIntents,
}) async {
  if (preferences == null) {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  }
  final resolvedPreferences =
      preferences ?? await SharedPreferences.getInstance();
  final scheduler = LocalNotificationsScheduler(
    preferences: resolvedPreferences,
    tapRouter: tapRouter ?? NotificationTapRouter(),
    applicationId: 'com.familyhub.family_hub',
    driver: driver,
    settingsIntents: settingsIntents ?? FakeAndroidSettingsIntents(),
  );
  await scheduler.initialize(
    localizations: lookupAppLocalizations(const Locale('en')),
  );
  return scheduler;
}

PlannedNotification _notification({
  int id = 1,
  bool bazar = false,
  String familyTimezone = 'Asia/Dhaka',
}) => PlannedNotification(
  id: id,
  kind: bazar
      ? PlannedNotificationKind.contributionDue
      : PlannedNotificationKind.due,
  scheduledAt: DateTime.utc(2026, 11, 6, 12),
  title: 'Reminder',
  body: 'Body',
  payload: bazar ? '/bazar/fund' : '/chores/today',
  refId: '$id',
  channelId: bazar
      ? NotificationChannelId.bazar
      : NotificationChannelId.choresDue,
  familyTimezone: familyTimezone,
);
