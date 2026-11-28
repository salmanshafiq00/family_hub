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
import 'package:family_hub/features/notifications/presentation/delivery_admin_screen.dart';
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
    Role role = Role.admin,
    GoRouter? customRouter,
  }) async {
    tester.view
      ..physicalSize = const Size(800, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router =
        customRouter ??
        GoRouter(
          initialLocation: AppRoutes.notificationDelivery,
          routes: [
            GoRoute(
              path: AppRoutes.notificationDelivery,
              builder: (_, _) => const DeliveryAdminScreen(),
            ),
            GoRoute(
              path: AppRoutes.choresSettings,
              builder: (_, _) => const Scaffold(body: Text('CHORES_SETTINGS')),
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
          currentFamilyIdProvider.overrideWithValue('family-1'),
          currentUidProvider.overrideWithValue('user-1'),
          currentActorProvider.overrideWithValue(
            PermissionActor(uid: 'user-1', role: role, isActive: true),
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
    'excludes chore notification types and shows bazar and family types',
    (tester) async {
      await pumpScreen(tester);

      // Chores are excluded
      expect(find.text('Swap request'), findsNothing);
      expect(find.text('Chore assigned'), findsNothing);
      expect(find.text('Chore due'), findsNothing);

      // Bazar and Family types are present
      expect(find.text('Contribution due'), findsOneWidget);
      expect(find.text('Month-end reminder'), findsOneWidget);
      expect(find.text('Family join request'), findsOneWidget);
    },
  );

  testWidgets(
    'shows chore settings link and navigates to chore settings on tap',
    (tester) async {
      await pumpScreen(tester);

      final link = find.text('Open Chore Settings');
      expect(link, findsOneWidget);
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(find.text('CHORES_SETTINGS'), findsOneWidget);
    },
  );

  testWidgets('cards have standard bottom margin', (tester) async {
    await pumpScreen(tester);

    final cards = tester.widgetList<Card>(find.byType(Card));
    expect(cards, isNotEmpty);
    for (final card in cards) {
      expect(card.margin, const EdgeInsets.only(bottom: 12));
    }
  });
}
