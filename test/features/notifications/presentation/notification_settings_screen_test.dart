import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/theme_builder.dart';
import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/presentation/notification_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/in_memory_notification_backend.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester, {
    required Role role,
    GoRouter? customRouter,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router =
        customRouter ??
        GoRouter(
          initialLocation: AppRoutes.notificationSettings,
          routes: [
            GoRoute(
              path: AppRoutes.notificationSettings,
              builder: (_, _) => const NotificationSettingsScreen(),
            ),
            GoRoute(
              path: AppRoutes.choresSettings,
              builder: (_, _) => const Scaffold(body: Text('CHORES_SETTINGS')),
            ),
            GoRoute(
              path: AppRoutes.remindersHelp,
              builder: (_, _) => const Scaffold(body: Text('HELP')),
            ),
            GoRoute(
              path: AppRoutes.notificationDelivery,
              builder: (_, _) => const Scaffold(body: Text('DELIVERY')),
            ),
          ],
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          appFormattersProvider.overrideWithValue(
            const AppFormatters(languageCode: 'en', useBanglaDigits: false),
          ),
          currentFamilyIdProvider.overrideWithValue('fam_1'),
          currentUidProvider.overrideWithValue('user_1'),
          currentActorProvider.overrideWithValue(
            PermissionActor(uid: 'user_1', role: role, isActive: true),
          ),
          permissionSettingsProvider.overrideWithValue(
            PermissionSettings.defaults,
          ),
          ...notificationTestOverrides(),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: buildThemeData(modernLightSpec),
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'manager sees chore settings link and tapping navigates to chore settings',
    (tester) async {
      await pumpScreen(tester, role: Role.admin);
      final link = find.byKey(
        const ValueKey<String>('notification_chores_settings_link'),
      );
      final scrollable = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      );
      await tester.scrollUntilVisible(link, 300, scrollable: scrollable.first);
      expect(link, findsOneWidget);

      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(find.text('CHORES_SETTINGS'), findsOneWidget);
    },
  );

  testWidgets('plain member does not see chore settings link', (tester) async {
    await pumpScreen(tester, role: Role.member);

    final link = find.byKey(
      const ValueKey<String>('notification_chores_settings_link'),
    );
    expect(link, findsNothing);
  });
}
