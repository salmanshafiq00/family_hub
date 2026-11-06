import 'dart:async';

import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/features/notifications/presentation/reminder_sync_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_reminder_scheduler.dart';

void main() {
  test(
    'schedules new ids, replaces changed content, and cancels stale ids',
    () async {
      final scheduler = FakeReminderScheduler();
      final errors = <Object>[];
      final controller = ReminderSyncController(
        scheduler: scheduler,
        onError: (error, _) => errors.add(error),
        onSynced: (_) {},
        debounceDuration: Duration.zero,
      );
      addTearDown(controller.dispose);
      final first = _notification(id: 1, title: 'First');
      final second = _notification(id: 2);

      await controller.syncNow(<PlannedNotification>[first, second]);
      await controller.syncNow(<PlannedNotification>[
        _notification(id: 1, title: 'Updated'),
      ]);

      expect(scheduler.cancelledIds, <int>[1, 2]);
      expect(scheduler.scheduled, <PlannedNotification>[
        first,
        second,
        _notification(id: 1, title: 'Updated'),
      ]);
      expect(errors, isEmpty);
    },
  );

  test('same plan and resume do not issue extra scheduler calls', () async {
    final scheduler = FakeReminderScheduler();
    final controller = ReminderSyncController(
      scheduler: scheduler,
      onError: (_, _) {},
      onSynced: (_) {},
    );
    addTearDown(controller.dispose);
    final plan = <PlannedNotification>[_notification(id: 1)];

    await controller.syncNow(plan);
    await controller.syncNow(plan);

    expect(scheduler.pendingCalls, 1);
    expect(scheduler.scheduled, hasLength(1));
  });

  test('debounce coalesces rapid plan changes to the latest plan', () async {
    final scheduler = FakeReminderScheduler();
    final controller = ReminderSyncController(
      scheduler: scheduler,
      onError: (_, _) {},
      onSynced: (_) {},
      debounceDuration: const Duration(minutes: 1),
    );
    addTearDown(controller.dispose);

    for (var id = 0; id < 10; id++) {
      controller.sync(<PlannedNotification>[_notification(id: id)]);
    }
    await controller.flush();

    expect(scheduler.pendingCalls, 1);
    expect(scheduler.scheduled.single.id, 9);
  });

  test(
    'single-flight sync discards a plan superseded during pending read',
    () async {
      final scheduler = FakeReminderScheduler();
      final gate = Completer<void>();
      scheduler.beforePending = () => gate.future;
      final controller = ReminderSyncController(
        scheduler: scheduler,
        onError: (_, _) {},
        onSynced: (_) {},
      );
      addTearDown(controller.dispose);

      final first = controller.syncNow(<PlannedNotification>[
        _notification(id: 1),
      ]);
      final latest = controller.syncNow(<PlannedNotification>[
        _notification(id: 2),
      ]);
      gate.complete();
      await Future.wait(<Future<void>>[first, latest]);

      expect(scheduler.scheduled.map((item) => item.id), <int>[2]);
      expect(scheduler.pendingCalls, 2);
    },
  );

  test('stop cancels every category', () async {
    final scheduler = FakeReminderScheduler();
    final controller = ReminderSyncController(
      scheduler: scheduler,
      onError: (_, _) {},
      onSynced: (_) {},
    );
    addTearDown(controller.dispose);
    await controller.syncNow(<PlannedNotification>[
      _notification(id: 1),
      _notification(id: 2, bazar: true),
    ]);

    await controller.stop();

    expect(scheduler.cancelledAll.last, isNull);
    expect(await scheduler.pending(), isEmpty);
  });

  test(
    'scheduler failures are reported without escaping the controller',
    () async {
      final scheduler = FakeReminderScheduler()..failOnPending = true;
      final errors = <Object>[];
      final controller = ReminderSyncController(
        scheduler: scheduler,
        onError: (error, _) => errors.add(error),
        onSynced: (_) {},
      );
      addTearDown(controller.dispose);

      await controller.syncNow(<PlannedNotification>[_notification(id: 1)]);

      expect(errors, hasLength(1));
      expect(errors.single, isA<StateError>());
      expect(scheduler.scheduled, isEmpty);
    },
  );
}

PlannedNotification _notification({
  required int id,
  String title = 'Reminder',
  bool bazar = false,
}) => PlannedNotification(
  id: id,
  kind: bazar
      ? PlannedNotificationKind.contributionDue
      : PlannedNotificationKind.due,
  scheduledAt: DateTime.utc(2026, 11, 6, 12),
  title: title,
  body: 'Body',
  payload: bazar ? '/bazar/fund' : '/chores/today',
  refId: '$id',
  channelId: bazar
      ? NotificationChannelId.bazar
      : NotificationChannelId.choresDue,
);
