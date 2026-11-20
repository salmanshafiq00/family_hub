import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/theme_builder.dart';
import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/chores/chores_entries.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_home_screen.dart';
import 'package:family_hub/features/chores/presentation/chores_manage_screen.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chores_test_helpers.dart';

PermissionActor _actor(Role role) =>
    PermissionActor(uid: 'u1', role: role, isActive: true);

final _badge = Provider<int>((ref) => 3);

final _entries = <ChoresEntry>[
  ChoresEntry(
    id: 'open',
    icon: Icons.list_alt_outlined,
    title: (l10n) => l10n.choresManageTitle,
    subtitle: (l10n) => l10n.choresEmptyMessage,
    route: '/chores/open',
    badge: _badge,
  ),
  ChoresEntry(
    id: 'managers-only',
    icon: Icons.tune_outlined,
    title: (l10n) => l10n.choresManageAction,
    route: '/chores/managers-only',
    requires: Permission.manageChoreTemplates,
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  required Role role,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
  Widget home = const ChoresHomeScreen(),
  List<ChoresEntry>? entries,
  bool withTemplate = false,
}) async {
  tester.view
    ..physicalSize = const Size(320, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final fixture = ChoresFixture();
  if (withTemplate) {
    fixture.chores.templates[ChoresFixture.familyId] = <String, ChoreTemplate>{
      'template-1': ChoreTemplate(id: 'template-1', draft: aTemplate()),
    };
  }

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => home),
      GoRoute(
        path: AppRoutes.choresManage,
        builder: (context, state) => ChoresManageScreen(entries: entries),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Formatting follows the stored language preference, not the
        // MaterialApp locale, so the test pins it to the locale it renders.
        appFormattersProvider.overrideWithValue(
          AppFormatters(
            languageCode: locale.languageCode,
            useBanglaDigits: locale.languageCode == 'bn',
          ),
        ),
        currentActorProvider.overrideWithValue(_actor(role)),
        permissionSettingsProvider.overrideWithValue(
          PermissionSettings.defaults,
        ),
        // The Chores tab now reads the chore providers (P3-22); an empty
        // family keeps the first-run empty state.
        occurrenceRepositoryProvider.overrideWithValue(fixture.occurrences),
        generationMarkerRepositoryProvider.overrideWithValue(
          fixture.occurrences,
        ),
        dutyGroupRepositoryProvider.overrideWithValue(
          fixture.chores.dutyGroups,
        ),
        templateRepositoryProvider.overrideWithValue(fixture.chores),
        choreSettingsRepositoryProvider.overrideWithValue(fixture.settings),
        familyRepositoryProvider.overrideWithValue(fixture.families),
        currentFamilyIdProvider.overrideWithValue(ChoresFixture.familyId),
        currentUidProvider.overrideWithValue('u1'),
        clockProvider.overrideWithValue(fixture.clock),
        nowTickProvider.overrideWith((ref) => const Stream<DateTime>.empty()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: buildThemeData(appThemes.first),
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 250));
}

void main() {
  group('ChoresHomeScreen', () {
    testWidgets('a manager sees the empty state and the Manage action', (
      tester,
    ) async {
      await _pump(tester, role: Role.moderator);

      expect(find.text('No chores yet'), findsOneWidget);
      expect(find.text('Manage'), findsOneWidget);
    });

    testWidgets('Manage opens the hub', (tester) async {
      await _pump(tester, role: Role.admin, entries: const []);

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(find.text('Manage chores'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('a plain member gets no Manage action', (tester) async {
      await _pump(tester, role: Role.member);

      expect(find.text('No chores yet'), findsOneWidget);
      expect(find.text('Manage'), findsNothing);
    });

    testWidgets('a member gets the Today shortcut only in the app bar', (
      tester,
    ) async {
      await _pump(tester, role: Role.member, withTemplate: true);

      expect(find.byKey(const Key('chores_open_today')), findsOneWidget);
      // Every member can reach their own absences from the app bar.
      expect(find.byKey(const Key('chores_open_absence')), findsOneWidget);
      expect(find.byKey(const Key('chores_fab_today')), findsNothing);
      expect(find.byKey(const Key('chores_fab_new')), findsNothing);
    });

    testWidgets('Bangla copy is shown for the bn locale', (tester) async {
      await _pump(tester, role: Role.admin, locale: const Locale('bn'));

      expect(find.text('কোনো কাজ নেই'), findsOneWidget);
      expect(find.text('পরিচালনা'), findsOneWidget);
    });

    for (final locale in const [Locale('bn'), Locale('en')]) {
      testWidgets('no overflow at text scale 2.0 (${locale.languageCode})', (
        tester,
      ) async {
        await _pump(tester, role: Role.admin, locale: locale, textScale: 2);

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('ChoresManageScreen', () {
    Future<void> pumpHub(
      WidgetTester tester, {
      required Role role,
      Locale locale = const Locale('en'),
      double textScale = 1.0,
      List<ChoresEntry>? entries,
    }) async {
      await _pump(
        tester,
        role: role,
        locale: locale,
        textScale: textScale,
        home: ChoresManageScreen(entries: entries),
      );
    }

    testWidgets('no entries shows the friendly empty state', (tester) async {
      await pumpHub(tester, role: Role.admin, entries: const []);

      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('a manager sees every tile and the badge count', (
      tester,
    ) async {
      await pumpHub(tester, role: Role.moderator, entries: _entries);

      expect(find.text('Manage chores'), findsWidgets);
      expect(find.text('Manage'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('a member does not see a tile that needs a permission', (
      tester,
    ) async {
      await pumpHub(tester, role: Role.member, entries: _entries);

      expect(find.text('Manage'), findsNothing);
      expect(
        find.text('Chores will show up here once they are added.'),
        findsOneWidget,
      );
    });

    testWidgets('the badge digits follow the Bangla locale', (tester) async {
      await pumpHub(
        tester,
        role: Role.admin,
        locale: const Locale('bn'),
        entries: _entries,
      );

      expect(find.text('৩'), findsOneWidget);
    });

    for (final locale in const [Locale('bn'), Locale('en')]) {
      testWidgets('no overflow at text scale 2.0 (${locale.languageCode})', (
        tester,
      ) async {
        await pumpHub(
          tester,
          role: Role.admin,
          locale: locale,
          textScale: 2,
          entries: _entries,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
