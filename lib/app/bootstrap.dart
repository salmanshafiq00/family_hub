import 'dart:async';
import 'dart:developer' as developer;

import 'package:family_hub/app/app.dart';
import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/theme/theme_controller.dart';
import 'package:family_hub/core/firebase/cache_wipe.dart';
import 'package:family_hub/core/firebase/firebase_bootstrap.dart';
import 'package:family_hub/features/activity/data/firestore_activity_repository.dart';
import 'package:family_hub/features/activity/presentation/activity_providers.dart';
import 'package:family_hub/features/auth/data/firebase_auth_repository.dart';
import 'package:family_hub/features/auth/presentation/auth_providers.dart';
import 'package:family_hub/features/dashboard/data/firestore_dashboard_policy_repository.dart';
import 'package:family_hub/features/dashboard/data/firestore_dashboard_pref_sync.dart';
import 'package:family_hub/features/dashboard/data/local_dashboard_prefs_store.dart';
import 'package:family_hub/features/dashboard/presentation/dashboard_providers.dart';
import 'package:family_hub/features/bazar/advances/data/firestore_advance_repository.dart';
import 'package:family_hub/features/bazar/advances/presentation/advance_providers.dart';
import 'package:family_hub/features/bazar/budgets/data/firestore_budget_repository.dart';
import 'package:family_hub/features/bazar/budgets/presentation/budget_providers.dart';
import 'package:family_hub/features/bazar/contributions/data/firestore_contribution_repository.dart';
import 'package:family_hub/features/bazar/contributions/presentation/contribution_providers.dart';
import 'package:family_hub/features/bazar/expenses/data/firestore_expense_repository.dart';
import 'package:family_hub/features/bazar/expenses/presentation/expense_providers.dart';
import 'package:family_hub/features/bazar/fund/data/firestore_fund_repository.dart';
import 'package:family_hub/features/bazar/fund/presentation/fund_providers.dart';
import 'package:family_hub/features/bazar/items_categories/data/default_catalog_seeder.dart';
import 'package:family_hub/features/bazar/items_categories/data/firestore_catalog_repository.dart';
import 'package:family_hub/features/bazar/items_categories/presentation/catalog_providers.dart';
import 'package:family_hub/features/bazar/settings/data/firestore_bazar_settings_repository.dart';
import 'package:family_hub/features/bazar/settings/presentation/bazar_settings_providers.dart';
import 'package:family_hub/features/chores/availability/data/firestore_availability_repository.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_providers.dart';
import 'package:family_hub/features/chores/comments/data/firestore_comment_repository.dart';
import 'package:family_hub/features/chores/comments/presentation/comment_providers.dart';
import 'package:family_hub/features/chores/duty_groups/data/firestore_duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/presentation/inbox_port_provider.dart';
import 'package:family_hub/features/chores/presentation/chores_inbox_port.dart';
import 'package:family_hub/features/chores/swaps/data/firestore_swap_repository.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_providers.dart';
import 'package:family_hub/features/notifications/data/firestore_inbox_repository.dart';
import 'package:family_hub/features/notifications/data/firestore_notification_pref_sync.dart';
import 'package:family_hub/features/notifications/data/local_notification_prefs_store.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/features/notifications/data/firestore_delivery_repository.dart';
import 'package:family_hub/features/notifications/data/firestore_notification_defaults_repository.dart';
import 'package:family_hub/features/notifications/presentation/notification_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/data/firestore_occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/templates/data/firestore_chore_template_repository.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/core/firebase/sync_status.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/core/localization/locale_controller.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/family/data/firestore_family_repository.dart';
import 'package:family_hub/features/family/data/firestore_membership_repository.dart';
import 'package:family_hub/features/family/domain/family_seeder.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/membership_providers.dart';
import 'package:family_hub/features/onboarding/data/firestore_profile_repository.dart';
import 'package:family_hub/features/settings/data/firestore_account_repository.dart';
import 'package:family_hub/features/settings/data/firestore_preference_sync.dart';
import 'package:family_hub/features/settings/presentation/account_providers.dart';
import 'package:family_hub/features/onboarding/presentation/profile_providers.dart';
import 'package:family_hub/modules/module_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _logError(Object error, StackTrace? stack) {
  developer.log(
    'Uncaught error',
    name: 'family_hub',
    error: error,
    stackTrace: stack,
    level: 1000,
  );
}

/// Single entry point for both flavors. Runs the app inside a ProviderScope
/// with zone, framework and platform error handlers that log uncaught errors.
///
/// [SharedPreferences] is loaded **before** [runApp] so that the theme
/// controller can read persisted values synchronously on the first frame —
/// no flash of the wrong theme.
///
/// Firebase is initialized with the flavor's options and Firestore offline
/// persistence enabled. Passing `--dart-define=USE_EMULATOR=true` connects
/// Auth and Firestore to local emulators.
Future<void> bootstrap(Flavor flavor) async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _logError(error, stack);
      return true;
    };

    // Pre-load SharedPreferences so ThemeController.build() can read it
    // synchronously — avoids a one-frame flash of the wrong theme.  It is
    // loaded BEFORE Firebase so a pending cache wipe (H9) can run first.
    final prefs = await SharedPreferences.getInstance();

    // Initialize Firebase and configure Firestore persistence + emulators;
    // clears the previous user's cached data when a sign-out asked for it.
    await initializeFirebase(flavor: flavor, prefs: prefs);

    // Built once and shared: the repository is stateless apart from the
    // FirebaseAuth handle, and one instance keeps the auth stream single.
    final authRepository = FirebaseAuthRepository();

    // Firestore-backed repositories (Step 9).
    const clock = SystemClock();
    final tx = FirestoreTxRunner();
    final profiles = FirestoreProfileRepository(tx: tx, clock: clock);
    final memberships = FirestoreMembershipRepository();
    final families = FirestoreFamilyRepository(tx: tx, clock: clock);
    final catalog = FirestoreCatalogRepository(tx: tx, clock: clock);
    final bazarSettings = FirestoreBazarSettingsRepository(
      tx: tx,
      clock: clock,
    );
    final expenses = FirestoreExpenseRepository(tx: tx, clock: clock);
    final budgets = FirestoreBudgetRepository(tx: tx);
    final funds = FirestoreFundRepository(tx: tx);
    final advances = FirestoreAdvanceRepository(tx: tx);
    final contributions = FirestoreContributionRepository(tx: tx);
    final choreTemplates = FirestoreChoreTemplateRepository(
      tx: tx,
      clock: clock,
    );
    final dutyGroups = FirestoreDutyGroupRepository(tx: tx, clock: clock);
    final occurrences = FirestoreOccurrenceRepository(tx: tx, clock: clock);
    final comments = FirestoreCommentRepository(tx: tx);
    final availability = FirestoreAvailabilityRepository(tx: tx);
    final swaps = FirestoreSwapRepository(tx: tx);
    final inbox = FirestoreInboxRepository(tx: tx);
    final activity = FirestoreActivityRepository();
    final notificationDelivery = FirestoreDeliveryRepository(
      tx: tx,
      clock: clock,
    );
    final notificationDefaults = FirestoreNotificationDefaultsRepository(
      tx: tx,
      clock: clock,
    );
    final notificationPrefsStore = LocalNotificationPrefsStore(prefs);
    final notificationPrefsSync = FirestoreNotificationPrefSync();
    final dashboardPolicies = FirestoreDashboardPolicyRepository(
      tx: tx,
      clock: clock,
    );
    final dashboardPrefsSync = FirestoreDashboardPrefSync();
    final dashboardPrefsStore = LocalDashboardPrefsStore(prefs);

    runApp(
      ProviderScope(
        overrides: [
          flavorProvider.overrideWithValue(flavor),
          pendingWriteCounterProvider.overrideWithValue(tx.pendingWrites),
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepository),
          afterSignOutProvider.overrideWithValue(
            () => CacheWipe.request(prefs),
          ),
          accountRepositoryProvider.overrideWithValue(
            FirestoreAccountRepository(tx: tx, clock: clock),
          ),
          profileRepositoryProvider.overrideWithValue(profiles),
          userProfileRepositoryProvider.overrideWithValue(profiles),
          membershipRepositoryProvider.overrideWithValue(memberships),
          moduleFlagsRepositoryProvider.overrideWithValue(memberships),
          familyRepositoryProvider.overrideWithValue(families),
          familySeedersProvider.overrideWithValue(const <FamilySeeder>[
            DefaultCatalogSeeder(),
          ]),
          catalogRepositoryProvider.overrideWithValue(catalog),
          bazarSettingsRepositoryProvider.overrideWithValue(bazarSettings),
          expenseRepositoryProvider.overrideWithValue(expenses),
          budgetRepositoryProvider.overrideWithValue(budgets),
          fundRepositoryProvider.overrideWithValue(funds),
          fundOpeningLedgerProvider.overrideWithValue(funds),
          advanceRepositoryProvider.overrideWithValue(advances),
          contributionRepositoryProvider.overrideWithValue(contributions),
          templateRepositoryProvider.overrideWithValue(choreTemplates),
          dutyGroupRepositoryProvider.overrideWithValue(dutyGroups),
          // One object serves both ports (occurrences + the generation marker).
          occurrenceRepositoryProvider.overrideWithValue(occurrences),
          generationMarkerRepositoryProvider.overrideWithValue(occurrences),
          commentRepositoryProvider.overrideWithValue(comments),
          availabilityRepositoryProvider.overrideWithValue(availability),
          swapRepositoryProvider.overrideWithValue(swaps),
          inboxRepositoryProvider.overrideWithValue(inbox),
          activityRepositoryProvider.overrideWithValue(activity),
          notificationDeliveryRepositoryProvider.overrideWithValue(
            notificationDelivery,
          ),
          notificationDefaultsRepositoryProvider.overrideWithValue(
            notificationDefaults,
          ),
          memberNotificationPrefsStoreProvider.overrideWithValue(
            notificationPrefsStore,
          ),
          notificationPreferenceSyncProvider.overrideWithValue(
            notificationPrefsSync,
          ),
          dashboardPolicyRepositoryProvider.overrideWithValue(
            dashboardPolicies,
          ),
          dashboardPrefsSyncProvider.overrideWithValue(dashboardPrefsSync),
          dashboardPrefsStoreProvider.overrideWithValue(dashboardPrefsStore),
          inboxPortProvider.overrideWithValue(const ChoresInboxPort()),
          themePreferenceSyncProvider.overrideWithValue(
            FirestoreThemePreferenceSync(),
          ),
          localePreferenceSyncProvider.overrideWithValue(
            FirestoreLocalePreferenceSync(),
          ),
        ],
        child: const FamilyHubApp(),
      ),
    );
  }, _logError);
}
