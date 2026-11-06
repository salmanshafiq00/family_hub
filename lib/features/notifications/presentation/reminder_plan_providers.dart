import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/locale_controller.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_planner.dart';
import 'package:family_hub/core/notifications/domain/reminder_precedence.dart';
import 'package:family_hub/features/notifications/presentation/reminder_texts.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/bazar/contributions/domain/contribution_status.dart';
import 'package:family_hub/features/bazar/contributions/presentation/contribution_providers.dart';
import 'package:family_hub/features/bazar/presentation/bazar_reminder_input.dart';
import 'package:family_hub/features/bazar/settings/presentation/bazar_settings_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_items_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/month_items.dart';
import 'package:family_hub/features/chores/presentation/plannable_chore_mapper.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/presentation/notification_providers.dart';
import 'package:family_hub/modules/module_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Duration kReminderPlanTickInterval = Duration(minutes: 15);

final reminderTickProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return _reminderTicks(clock);
});

Stream<DateTime> _reminderTicks(Clock clock) async* {
  while (true) {
    yield clock.nowUtc();
    await Future<void>.delayed(kReminderPlanTickInterval);
  }
}

final reminderPlanInputProvider = Provider<AsyncValue<PlanInput?>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  final viewerId = ref.watch(currentUidProvider);
  if (familyId == null || viewerId == null) {
    return const AsyncData<PlanInput?>(null);
  }

  final clock = ref.watch(clockProvider);
  final now = ref.watch(reminderTickProvider).value ?? clock.nowUtc();
  final dateKeys = ref.watch(familyDateKeysProvider);
  final today = dateKeys.dateKeyOf(now);
  final currentMonth = today.monthKey;
  final windowEndMonth = dateKeys.monthKeyOf(
    now.add(const Duration(days: kReminderWindowDays)),
  );
  final monthValues = <AsyncValue<MonthItems>>[
    ref.watch(monthItemsProvider(currentMonth)),
    if (windowEndMonth != currentMonth)
      ref.watch(monthItemsProvider(currentMonth.addMonths(1))),
  ];
  final combinedMonths = combineMonths(monthValues);
  if (!combinedMonths.hasValue) {
    final error = combinedMonths.error;
    return error == null
        ? const AsyncLoading<PlanInput?>()
        : AsyncError<PlanInput?>(
            error,
            combinedMonths.stackTrace ?? StackTrace.empty,
          );
  }

  final reminderSettings = ref.watch(reminderSettingsProvider);
  if (!reminderSettings.hasValue) {
    final error = reminderSettings.error;
    return error == null
        ? const AsyncLoading<PlanInput?>()
        : AsyncError<PlanInput?>(
            error,
            reminderSettings.stackTrace ?? StackTrace.empty,
          );
  }

  final moduleFlags = ref.watch(moduleFlagsProvider);
  final choresEnabled = moduleFlags.isEnabled('chores');
  final bazarEnabled = moduleFlags.isEnabled('bazar');
  final settings = reminderSettings.requireValue.copyWith(
    choresEnabled: reminderSettings.requireValue.choresEnabled && choresEnabled,
    bazarEnabled: reminderSettings.requireValue.bazarEnabled && bazarEnabled,
  );
  final modes = <String, DeliveryMode>{};
  for (final type in NotificationTypes.all) {
    final effective = ref.watch(effectiveModeProvider(type.id));
    if (!effective.hasValue) {
      final error = effective.error;
      return error == null
          ? const AsyncLoading<PlanInput?>()
          : AsyncError<PlanInput?>(
              error,
              effective.stackTrace ?? StackTrace.empty,
            );
    }
    modes[type.id] = effective.requireValue.mode;
  }

  final familyTimezone = ref.watch(familyTimezoneProvider);
  final bazarSettings = ref.watch(bazarSettingsProvider);
  final statuses = <MemberContributionStatus>[];
  if (bazarEnabled) {
    final plans = ref.watch(contributionPlansProvider(currentMonth));
    final contributions = ref.watch(contributionsProvider(currentMonth));
    if (!plans.hasValue) {
      final error = plans.error;
      return error == null
          ? const AsyncLoading<PlanInput?>()
          : AsyncError<PlanInput?>(error, plans.stackTrace ?? StackTrace.empty);
    }
    if (!contributions.hasValue) {
      final error = contributions.error;
      return error == null
          ? const AsyncLoading<PlanInput?>()
          : AsyncError<PlanInput?>(
              error,
              contributions.stackTrace ?? StackTrace.empty,
            );
    }
    statuses.addAll(ref.watch(contributionStatusProvider(currentMonth)));
  }
  final canCloseMonth = bazarEnabled
      ? ref.watch(
          canProvider(const PermissionQuery(Permission.closeBazarMonth)),
        )
      : false;
  final bazarInput = buildBazarReminderInput(
    now: now,
    familyTimezone: familyTimezone,
    viewerId: viewerId,
    settings: bazarSettings,
    contributionStatuses: statuses,
    canCloseMonth: canCloseMonth,
    enabled: bazarEnabled,
  );
  final templateIndex = <String, TemplateReminderConfig>{
    for (final entry in ref.watch(templateIndexProvider).entries)
      entry.key: TemplateReminderConfig(
        enabled: entry.value.draft.reminders.enabled,
        atDue: entry.value.draft.reminders.atDue,
        offsetsMinutes: entry.value.draft.reminders.offsetsMinutes,
        overdueEnabled: entry.value.draft.reminders.overdueEnabled,
        overdueAfterMinutes: entry.value.draft.reminders.overdueAfterMinutes,
      ),
  };
  final locale = ref.watch(localeControllerProvider);
  final texts = LocalizedReminderTexts(
    localizations: lookupAppLocalizations(locale.locale),
    useBanglaDigits: locale.useBanglaDigits,
  );

  return AsyncData<PlanInput?>(
    PlanInput(
      now: now,
      viewerId: viewerId,
      items: choresEnabled
          ? <PlannableChore>[
              for (final item in combinedMonths.requireValue.items)
                PlannableChoreMapper.fromItem(item),
            ]
          : const <PlannableChore>[],
      templateIndex: templateIndex,
      settings: settings,
      bazar: bazarInput,
      familyTz: familyTimezone,
      texts: texts,
      effectiveModes: modes,
    ),
  );
});

final reminderPlanProvider = Provider<AsyncValue<List<PlannedNotification>>>(
  (ref) => ref
      .watch(reminderPlanInputProvider)
      .whenData(
        (input) => input == null
            ? const <PlannedNotification>[]
            : ReminderPlanner.plan(input),
      ),
);
