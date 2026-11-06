import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_reminder_scheduler.dart';

void main() {
  test(
    'fake scheduler records, lists, and cancels planned reminders',
    () async {
      final scheduler = FakeReminderScheduler();
      final notification = PlannedNotification(
        id: 1,
        kind: PlannedNotificationKind.due,
        scheduledAt: DateTime.utc(2026, 11, 2, 6),
        title: 'title',
        body: 'body',
        payload: '/chores/today',
        refId: 'item',
        channelId: NotificationChannelId.choresDue,
      );

      await scheduler.schedule(notification);
      expect(await scheduler.pending(), <PlannedNotification>[notification]);
      expect(
        await scheduler.permissions(),
        const NotificationPermissionState(
          granted: true,
          exactAlarmsAllowed: true,
        ),
      );

      await scheduler.cancel(<int>[notification.id]);
      expect(await scheduler.pending(), isEmpty);
      expect(scheduler.cancelledIds, <int>[notification.id]);
    },
  );

  test('fake scheduler records category cancellation', () async {
    final scheduler = FakeReminderScheduler();
    final notification = PlannedNotification(
      id: 1,
      kind: PlannedNotificationKind.summary,
      scheduledAt: DateTime.utc(2026, 11, 2, 6),
      title: 'title',
      body: 'body',
      payload: '/chores/today',
      refId: '2026-11-02',
      channelId: NotificationChannelId.dailySummary,
    );
    await scheduler.schedule(notification);

    await scheduler.cancelAll(category: NotificationCategory.chores);

    expect(await scheduler.pending(), isEmpty);
    expect(scheduler.cancelledAll, <NotificationCategory?>[
      NotificationCategory.chores,
    ]);
  });
}
