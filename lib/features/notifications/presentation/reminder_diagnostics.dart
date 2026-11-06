import 'dart:developer' as developer;

import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ReminderDiagnostics {
  const ReminderDiagnostics({
    this.lastError,
    this.lastStackTrace,
    this.pendingCount = 0,
    this.lastSyncAt,
  });

  final String? lastError;
  final StackTrace? lastStackTrace;
  final int pendingCount;
  final DateTime? lastSyncAt;

  ReminderDiagnostics copyWith({
    String? lastError,
    StackTrace? lastStackTrace,
    int? pendingCount,
    DateTime? lastSyncAt,
    bool clearError = false,
  }) => ReminderDiagnostics(
    lastError: clearError ? null : (lastError ?? this.lastError),
    lastStackTrace: clearError ? null : (lastStackTrace ?? this.lastStackTrace),
    pendingCount: pendingCount ?? this.pendingCount,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
  );
}

final class ReminderDiagnosticsController
    extends Notifier<ReminderDiagnostics> {
  @override
  ReminderDiagnostics build() => const ReminderDiagnostics();

  void recordError(Object error, StackTrace stackTrace) {
    developer.log(
      'Reminder synchronization failed',
      name: 'family_hub',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    state = state.copyWith(
      lastError: error.toString(),
      lastStackTrace: stackTrace,
    );
  }

  void recordSync(int pendingCount, DateTime at) {
    state = state.copyWith(
      pendingCount: pendingCount,
      lastSyncAt: at,
      clearError: true,
    );
  }
}

final class UnavailableReminderScheduler implements ReminderScheduler {
  const UnavailableReminderScheduler();

  StateError _unavailable() =>
      StateError('The platform reminder adapter is not installed yet (P4-13).');

  @override
  Future<List<PlannedNotification>> pending() async => throw _unavailable();

  @override
  Future<void> schedule(PlannedNotification notification) async =>
      throw _unavailable();

  @override
  Future<void> cancel(List<int> ids) async => throw _unavailable();

  @override
  Future<void> cancelAll({NotificationCategory? category}) async =>
      throw _unavailable();

  @override
  Future<NotificationPermissionState> permissions() async =>
      throw _unavailable();
}
