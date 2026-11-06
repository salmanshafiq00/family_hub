import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_scheduler.dart';

final class FakeReminderScheduler implements ReminderScheduler {
  final Map<int, PlannedNotification> _pending = <int, PlannedNotification>{};
  final List<PlannedNotification> scheduled = <PlannedNotification>[];
  final List<int> cancelledIds = <int>[];
  final List<NotificationCategory?> cancelledAll = <NotificationCategory?>[];
  NotificationPermissionState permissionState =
      const NotificationPermissionState(
        granted: true,
        exactAlarmsAllowed: true,
      );

  @override
  Future<List<PlannedNotification>> pending() async =>
      List<PlannedNotification>.unmodifiable(_pending.values);

  @override
  Future<void> schedule(PlannedNotification notification) async {
    scheduled.add(notification);
    _pending[notification.id] = notification;
  }

  @override
  Future<void> cancel(List<int> ids) async {
    cancelledIds.addAll(ids);
    for (final id in ids) {
      _pending.remove(id);
    }
  }

  @override
  Future<void> cancelAll({NotificationCategory? category}) async {
    cancelledAll.add(category);
    if (category == null) {
      _pending.clear();
      return;
    }
    final channels = switch (category) {
      NotificationCategory.chores => <NotificationChannelId>{
        NotificationChannelId.choresDue,
        NotificationChannelId.choresOverdue,
        NotificationChannelId.dailySummary,
      },
      NotificationCategory.bazar => <NotificationChannelId>{
        NotificationChannelId.bazar,
      },
      NotificationCategory.family => <NotificationChannelId>{
        NotificationChannelId.family,
      },
    };
    _pending.removeWhere(
      (_, notification) => channels.contains(notification.channelId),
    );
  }

  @override
  Future<NotificationPermissionState> permissions() async => permissionState;
}
