import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/preference_sync.dart';
import 'package:family_hub/app/push_hook.dart';
import 'package:family_hub/app/router.dart';
import 'package:family_hub/app/routing/session_phase.dart';
import 'package:family_hub/app/routing/session_providers.dart';
import 'package:family_hub/app/theme/theme_builder.dart';
import 'package:family_hub/app/theme/theme_controller.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/achievements/presentation/celebration_orchestration.dart';
import 'package:family_hub/features/chores/achievements/presentation/engagement_providers.dart';
import 'package:family_hub/features/notifications/presentation/inbox_foreground_bridge_provider.dart';
import 'package:family_hub/features/notifications/presentation/reminder_providers.dart';
import 'package:family_hub/modules/module_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The root widget: theme, locale and the guarded router.
///
/// The app-open occurrence generation and its failure message are started by
/// `ChoresGenerationHook`, which wraps the shell.
///
/// The `GoRouter` is created once by [routerProvider] (it used to be built
/// inside `build`, which threw away the navigation stack on every theme or
/// language change).  Which screen is shown is decided entirely by the router's
/// redirect rules; this widget holds no navigation logic.
class FamilyHubApp extends ConsumerWidget {
  const FamilyHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flavor = ref.watch(flavorProvider);
    final prefs = ref.watch(themeControllerProvider);
    final localePrefs = ref.watch(localeControllerProvider);
    final specs = resolveThemeSpecs(prefs);
    final router = ref.watch(routerProvider);
    final phase = ref.watch(sessionPhaseProvider);
    final moduleFlags = ref.watch(moduleFlagsProvider);
    // A pending tap is replayed when the tap router attaches; doing that before
    // the session is ready would send it into a redirect gate and lose it.
    if (phase == SessionPhase.active) {
      ref
          .watch(notificationTapRouterProvider)
          .attach(
            navigate: (route) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => router.go(route),
              );
              // A tap arrives between frames; without this the callback above
              // waits for some unrelated frame to happen (or forever).
              WidgetsBinding.instance.ensureVisualUpdate();
            },
            choresEnabled: moduleFlags.isEnabled('chores'),
            bazarEnabled: moduleFlags.isEnabled('bazar'),
          );
    }
    // Side effect only: sync theme/language with the account.
    ref.watch(preferenceSyncProvider);
    ref.watch(dashboardPreferenceSyncProvider);
    ref.watch(reminderOrchestrationProvider);
    ref.watch(reminderLifecycleObserverProvider);
    ref.watch(pushOrchestrationProvider);
    ref.watch(foregroundNotificationBridgeProvider);
    ref.watch(statsSyncOrchestrationProvider);
    ref.watch(celebrationOrchestrationProvider);

    return MaterialApp.router(
      title: flavor.label,
      debugShowCheckedModeBanner: false,
      theme: buildThemeData(specs.light),
      darkTheme: buildThemeData(specs.dark),
      themeMode: prefs.themeMode,
      locale: localePrefs.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
