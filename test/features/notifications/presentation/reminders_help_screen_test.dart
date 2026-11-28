import 'dart:async';

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
import 'package:family_hub/features/notifications/presentation/reminders_help_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('tapping notification settings button pops when canPop is true', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(800, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: AppRoutes.notificationSettings,
      routes: [
        GoRoute(
          path: AppRoutes.notificationSettings,
          builder: (_, _) => Scaffold(
            body: TextButton(
              onPressed: () {},
              child: const Text('NOTIFICATION_SETTINGS'),
            ),
          ),
          routes: [
            GoRoute(
              path: 'help',
              builder: (_, _) => const RemindersHelpScreen(),
            ),
          ],
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
            const PermissionActor(
              uid: 'user_1',
              role: Role.admin,
              isActive: true,
            ),
          ),
          permissionSettingsProvider.overrideWithValue(
            PermissionSettings.defaults,
          ),
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

    // Push the help route so canPop is true
    unawaited(router.push('${AppRoutes.notificationSettings}/help'));
    await tester.pumpAndSettle();

    expect(find.byType(RemindersHelpScreen), findsOneWidget);

    final button = find.widgetWithText(
      TextButton,
      'Notifications and reminders',
    );
    expect(button, findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(RemindersHelpScreen), findsNothing);
    expect(find.text('NOTIFICATION_SETTINGS'), findsOneWidget);
  });
}
