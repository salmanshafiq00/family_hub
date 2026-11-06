import 'dart:async';

import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_scheduler.dart';

final class ReminderSyncController {
  ReminderSyncController({
    required this.scheduler,
    required this.onError,
    required this.onSynced,
    this.debounceDuration = const Duration(seconds: 2),
  });

  final ReminderScheduler scheduler;
  final void Function(Object error, StackTrace stackTrace) onError;
  final void Function(int pendingCount) onSynced;
  final Duration debounceDuration;

  Timer? _timer;
  Future<void>? _inFlight;
  List<PlannedNotification> _latestPlan = const <PlannedNotification>[];
  String? _lastPlanHash;
  bool _rerun = false;
  bool _disposed = false;

  void sync(List<PlannedNotification> plan) {
    _ensureActive();
    _latestPlan = _validatedPlan(plan);
    _timer?.cancel();
    _timer = Timer(debounceDuration, () {
      _timer = null;
      unawaited(_runLatest());
    });
  }

  Future<void> syncNow(List<PlannedNotification> plan) {
    _ensureActive();
    _latestPlan = _validatedPlan(plan);
    _timer?.cancel();
    _timer = null;
    return _runLatest();
  }

  Future<void> flush() {
    _ensureActive();
    _timer?.cancel();
    _timer = null;
    return _runLatest();
  }

  Future<void> stop() async {
    if (_disposed) return;
    _timer?.cancel();
    _timer = null;
    _latestPlan = const <PlannedNotification>[];
    await _runLatest();
    try {
      await scheduler.cancelAll();
      _lastPlanHash = null;
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  Future<void> cancelCategory(NotificationCategory category) async {
    _ensureActive();
    _timer?.cancel();
    _timer = null;
    try {
      await scheduler.cancelAll(category: category);
      _lastPlanHash = null;
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _runLatest() {
    final running = _inFlight;
    if (running != null) {
      _rerun = true;
      return running;
    }
    final run = _drain();
    _inFlight = run;
    return run;
  }

  Future<void> _drain() async {
    try {
      do {
        _rerun = false;
        await _syncPlan(_latestPlan);
      } while (_rerun);
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _syncPlan(List<PlannedNotification> plan) async {
    final planHash = _hashPlan(plan);
    if (planHash == _lastPlanHash) return;
    try {
      final pending = await scheduler.pending();
      if (planHash != _hashPlan(_latestPlan)) {
        _rerun = true;
        return;
      }
      final pendingById = <int, PlannedNotification>{
        for (final item in pending) item.id: item,
      };
      final desiredById = <int, PlannedNotification>{
        for (final item in plan) item.id: item,
      };
      final toCancel = <int>[
        for (final entry in pendingById.entries)
          if (!desiredById.containsKey(entry.key) ||
              _contentHash(entry.value) !=
                  _contentHash(desiredById[entry.key]!))
            entry.key,
      ];
      if (toCancel.isNotEmpty) await scheduler.cancel(toCancel);
      if (planHash != _hashPlan(_latestPlan)) {
        _rerun = true;
        return;
      }

      for (final notification in plan) {
        final old = pendingById[notification.id];
        if (old == null || _contentHash(old) != _contentHash(notification)) {
          await scheduler.schedule(notification);
        }
      }
      _lastPlanHash = planHash;
      onSynced(plan.length);
    } on Object catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  static List<PlannedNotification> _validatedPlan(
    List<PlannedNotification> plan,
  ) {
    final ids = <int>{};
    for (final notification in plan) {
      if (!ids.add(notification.id)) {
        throw ArgumentError.value(
          notification.id,
          'plan',
          'Notification ids must be unique.',
        );
      }
    }
    return List<PlannedNotification>.unmodifiable(plan);
  }

  static String _hashPlan(List<PlannedNotification> plan) {
    final entries = plan.map(_contentHash).toList()..sort();
    return entries.join('\n');
  }

  static String _contentHash(PlannedNotification notification) => <String>[
    notification.id.toString(),
    notification.kind.name,
    notification.scheduledAt.toUtc().microsecondsSinceEpoch.toString(),
    notification.title,
    notification.body,
    notification.payload,
    notification.refId,
    notification.channelId.id,
  ].map(Uri.encodeComponent).join('|');

  void _ensureActive() {
    if (_disposed) {
      throw StateError('ReminderSyncController has been disposed.');
    }
  }
}
