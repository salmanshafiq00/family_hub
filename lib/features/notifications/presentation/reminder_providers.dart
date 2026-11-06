import 'dart:async';

import 'package:family_hub/app/routing/session_phase.dart';
import 'package:family_hub/app/routing/session_providers.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/reminder_scheduler.dart';
import 'package:family_hub/features/notifications/presentation/lifecycle_observer.dart';
import 'package:family_hub/features/notifications/presentation/reminder_diagnostics.dart';
import 'package:family_hub/features/notifications/presentation/reminder_plan_providers.dart';
import 'package:family_hub/features/notifications/presentation/reminder_sync_controller.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/modules/module_providers.dart';
import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:family_hub/features/notifications/presentation/reminder_plan_providers.dart'
    show
        kReminderPlanTickInterval,
        reminderPlanInputProvider,
        reminderPlanProvider,
        reminderTickProvider;

const Duration kReminderSyncDebounce = Duration(seconds: 2);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError(
    'reminderSchedulerProvider must be overridden in bootstrap.dart.',
  ),
);

final reminderDiagnosticsProvider =
    NotifierProvider<ReminderDiagnosticsController, ReminderDiagnostics>(
      ReminderDiagnosticsController.new,
    );

final reminderSyncControllerProvider = Provider<ReminderSyncController>((ref) {
  final diagnostics = ref.read(reminderDiagnosticsProvider.notifier);
  final clock = ref.watch(clockProvider);
  final controller = ReminderSyncController(
    scheduler: ref.watch(reminderSchedulerProvider),
    debounceDuration: kReminderSyncDebounce,
    onError: diagnostics.recordError,
    onSynced: (count) => diagnostics.recordSync(count, clock.nowUtc()),
  );
  ref.onDispose(controller.dispose);
  return controller;
});

final reminderSyncNowProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    if (ref.read(sessionPhaseProvider) != SessionPhase.active) return;
    final plan = ref.read(reminderPlanProvider);
    if (plan.hasValue) {
      await ref.read(reminderSyncControllerProvider).syncNow(plan.requireValue);
    }
  };
});

final reminderLifecycleObserverProvider = Provider<ReminderLifecycleObserver>((
  ref,
) {
  final observer = ReminderLifecycleObserver(
    onResumed: () {
      unawaited(() async {
        try {
          final timezoneChanged = await updateReminderDeviceTimezone(
            preferences: ref.read(sharedPreferencesProvider),
            readTimezone: () async =>
                (await FlutterTimezone.getLocalTimezone()).identifier,
          );
          if (timezoneChanged) ref.invalidate(reminderTickProvider);
        } on Object catch (error, stackTrace) {
          ref
              .read(reminderDiagnosticsProvider.notifier)
              .recordError(error, stackTrace);
        }
        await ref.read(reminderSyncNowProvider)();
      }());
    },
  );
  WidgetsBinding.instance.addObserver(observer);
  ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
  return observer;
});

final reminderOrchestrationProvider = Provider<void>((ref) {
  final controller = ref.watch(reminderSyncControllerProvider);
  String? activeFamilyId;
  bool started = false;
  bool? choresEnabled;
  bool? bazarEnabled;
  var stoppedForInactiveSession = false;
  var disposed = false;

  void syncCurrentPlan() {
    if (!started) return;
    final plan = ref.read(reminderPlanProvider);
    if (plan.hasValue) controller.sync(plan.requireValue);
  }

  Future<void> activate(String familyId) async {
    await controller.stop();
    if (disposed || activeFamilyId != familyId) return;
    final flags = ref.read(moduleFlagsProvider);
    choresEnabled = flags.isEnabled('chores');
    bazarEnabled = flags.isEnabled('bazar');
    if (!choresEnabled!) {
      await controller.cancelCategory(NotificationCategory.chores);
    }
    if (!bazarEnabled!) {
      await controller.cancelCategory(NotificationCategory.bazar);
    }
    if (disposed || activeFamilyId != familyId) return;
    started = true;
    syncCurrentPlan();
  }

  void evaluate() {
    final phase = ref.read(sessionPhaseProvider);
    if (phase == SessionPhase.loading || phase == SessionPhase.failed) return;
    final familyId = ref.read(currentFamilyIdProvider);
    if (phase != SessionPhase.active || familyId == null) {
      if (activeFamilyId != null || !stoppedForInactiveSession) {
        activeFamilyId = null;
        started = false;
        stoppedForInactiveSession = true;
        unawaited(controller.stop());
      }
      return;
    }
    stoppedForInactiveSession = false;
    if (activeFamilyId != familyId) {
      activeFamilyId = familyId;
      started = false;
      unawaited(activate(familyId));
      return;
    }
    if (!started) return;

    final flags = ref.read(moduleFlagsProvider);
    final nextChoresEnabled = flags.isEnabled('chores');
    final nextBazarEnabled = flags.isEnabled('bazar');
    if (choresEnabled == true && !nextChoresEnabled) {
      unawaited(controller.cancelCategory(NotificationCategory.chores));
    }
    if (bazarEnabled == true && !nextBazarEnabled) {
      unawaited(controller.cancelCategory(NotificationCategory.bazar));
    }
    choresEnabled = nextChoresEnabled;
    bazarEnabled = nextBazarEnabled;
    syncCurrentPlan();
  }

  ref
    ..listen(sessionPhaseProvider, (_, _) => evaluate())
    ..listen(currentFamilyIdProvider, (_, _) => evaluate())
    ..listen(moduleFlagsProvider, (_, _) => evaluate())
    ..listen(reminderPlanProvider, (_, _) => syncCurrentPlan());
  evaluate();
  ref.onDispose(() {
    disposed = true;
    unawaited(controller.stop());
  });
});
