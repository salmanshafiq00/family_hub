import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';

final class NotificationPermissionState {
  const NotificationPermissionState({
    required this.granted,
    required this.exactAlarmsAllowed,
  });

  final bool granted;
  final bool exactAlarmsAllowed;
}

abstract interface class ReminderScheduler {
  Future<List<PlannedNotification>> pending();

  Future<void> schedule(PlannedNotification notification);

  Future<void> cancel(List<int> ids);

  Future<void> cancelAll({NotificationCategory? category});

  Future<NotificationPermissionState> permissions();
}
