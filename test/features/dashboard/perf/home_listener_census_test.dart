import 'dart:async';

import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/theme/theme_builder.dart';
import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/core/utils/money.dart';
import 'package:family_hub/features/activity/domain/activity_entry.dart';
import 'package:family_hub/features/activity/presentation/activity_providers.dart';
import 'package:family_hub/features/bazar/budgets/domain/budget.dart';
import 'package:family_hub/features/bazar/budgets/presentation/budget_providers.dart';
import 'package:family_hub/features/bazar/contributions/domain/contribution.dart';
import 'package:family_hub/features/bazar/contributions/presentation/contribution_providers.dart';
import 'package:family_hub/features/bazar/expenses/domain/expense.dart';
import 'package:family_hub/features/bazar/expenses/presentation/expense_providers.dart';
import 'package:family_hub/features/bazar/fund/domain/fund_transaction.dart';
import 'package:family_hub/features/bazar/fund/presentation/fund_providers.dart';
import 'package:family_hub/features/bazar/items_categories/domain/category.dart';
import 'package:family_hub/features/bazar/items_categories/presentation/catalog_providers.dart';
import 'package:family_hub/features/chores/achievements/domain/default_engagement_settings.dart';
import 'package:family_hub/features/chores/achievements/domain/engagement_settings.dart';
import 'package:family_hub/features/chores/achievements/domain/member_stats.dart';
import 'package:family_hub/features/chores/achievements/presentation/engagement_providers.dart';
import 'package:family_hub/features/chores/availability/domain/member_availability.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_providers.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/dashboard/domain/card_access.dart';
import 'package:family_hub/features/dashboard/domain/card_catalog.dart';
import 'package:family_hub/features/dashboard/domain/dashboard_policy.dart';
import 'package:family_hub/features/dashboard/domain/dashboard_resolver.dart';
import 'package:family_hub/features/dashboard/presentation/dashboard_providers.dart';
import 'package:family_hub/features/dashboard/presentation/home_screen.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/module_flags.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/modules/module_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/listener_census.dart';

/// P4-25 item 2, measured: how many live data listeners one Home holds.
///
/// D-P4-14 promises Home runs on a handful of SHARED month listeners and rule
/// 63 that a card never opens a stream of its own — until now nothing had ever
/// counted them. Every stream a card or the header can ask for is wrapped in a
/// [ListenerCensus] below, and the layout shows the whole catalog at once, so
/// [ListenerCensus.live] is the number of Firestore listeners this screen would
/// hold. A card that watched a stream this file does not know about would use
/// the real provider, whose repository is not overridden, and render as an
/// error card — which the last test refuses.
void main() {
  testWidgets('one subscription per source, however many cards watch it', (
    tester,
  ) async {
    final census = ListenerCensus();
    await _pumpHome(tester, census);

    // The month card, the budget card and the alert card all read the month's
    // expenses; that is still ONE listener (rule 63).
    expect(
      census.opened.values.every((n) => n == 1),
      isTrue,
      reason: census.report,
    );
    expect(census.live, census.opened.length, reason: census.report);
  });

  testWidgets('Home stays inside the documented listener budget', (
    tester,
  ) async {
    final census = ListenerCensus();
    await _pumpHome(tester, census);

    expect(
      census.live,
      lessThanOrEqualTo(kMaxHomeDataListeners),
      reason: census.report,
    );
  });

  testWidgets('a rebuilt Home re-uses every listener', (tester) async {
    final census = ListenerCensus();
    final harness = await _pumpHome(tester, census);
    final onHome = census.live;

    // What the shell actually does on a tab switch: the branch stays mounted,
    // only the widgets rebuild (StatefulShellRoute.indexedStack).
    harness.rebuildHome();
    await tester.pump(const Duration(milliseconds: 200));

    expect(census.live, onHome, reason: census.report);
    expect(
      census.opened.values.every((n) => n == 1),
      isTrue,
      reason: 'a rebuild must not re-subscribe: ${census.report}',
    );
  });

  testWidgets('a cold re-entry re-uses the shared month listeners', (
    tester,
  ) async {
    final census = ListenerCensus();
    final harness = await _pumpHome(tester, census);

    // The harder case the shell does NOT produce: Home fully unmounted and
    // opened again (a deep link back, a re-login). The session-wide streams
    // survive it, so re-entry must not double them.
    harness.leaveHome();
    await tester.pump(const Duration(milliseconds: 200));
    harness.openHome();
    await tester.pump(const Duration(milliseconds: 600));

    for (final shared in _sessionWide) {
      expect(
        census.opened[shared],
        1,
        reason: '$shared re-subscribed: ${census.report}',
      );
    }
    expect(
      census.live,
      lessThanOrEqualTo(kMaxHomeDataListeners),
      reason: census.report,
    );
  });

  testWidgets('a card that renders is a card that reads', (tester) async {
    final census = ListenerCensus();
    await _pumpHome(tester, census);

    // Guards the census itself: if a card ever pulls a stream this file does
    // not count, its data provider throws UnimplementedError and the card
    // shows the error view instead of its content.
    expect(find.byType(ErrorView), findsNothing);
    expect(tester.takeException(), isNull, reason: census.report);
  });
}

/// The ceiling this test measured on 2026-11-07 for a Home showing every card.
///
/// D-P4-14 aimed at seven (members, templates, month occurrences, month
/// expenses, month contributions, activity, inbox); the six more are what the
/// individual cards read today — budget, categories, fund transactions,
/// contribution plans, availability and the member's own stats. They are one
/// per card, never one per widget, so the number is flat in the family size,
/// but it is still above the plan.
const int kMaxHomeDataListeners = 13;

/// One Home under one container, with a switch that mimics the shell's tabs:
/// the widget goes away, the [ProviderScope] and its container stay.
Future<_Harness> _pumpHome(WidgetTester tester, ListenerCensus census) async {
  tester.view
    ..physicalSize = const Size(1200, 4000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final visible = ValueNotifier<bool>(true);
  final version = ValueNotifier<int>(0);

  await tester.pumpWidget(
    ProviderScope(
      overrides: _homeOverrides(census, prefs),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildThemeData(modernLightSpec),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: ValueListenableBuilder<bool>(
          valueListenable: visible,
          builder: (_, showHome, _) => showHome
              ? ValueListenableBuilder<int>(
                  valueListenable: version,
                  builder: (_, _, _) => const HomeScreen(),
                )
              : const Scaffold(body: SizedBox()),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 600));
  return _Harness(visible, version);
}

/// The sources a cold re-entry must not double: the shared month listeners and
/// the session-wide lists. `recentActivity`, `engagementSettings` and
/// `memberStats` are auto-disposing reads and do re-subscribe — measured.
const List<String> _sessionWide = <String>[
  'members',
  'inbox',
  'monthOccurrences',
  'monthExpenses',
  'monthBudget',
  'contributions',
  'contributionPlans',
  'categories',
  'fundTransactions',
  'availability',
];

final class _Harness {
  _Harness(this._visible, this._version);

  final ValueNotifier<bool> _visible;
  final ValueNotifier<int> _version;

  void leaveHome() => _visible.value = false;
  void openHome() => _visible.value = true;
  void rebuildHome() => _version.value++;
}

/// The whole catalog, so every card is built and counted at once.
List<Override> _homeOverrides(ListenerCensus census, SharedPreferences prefs) {
  final today = DateKey(2026, 10, 24);

  /// A source that behaves like a Firestore listener: it delivers and then
  /// stays open until the reader goes away. A `Stream.value` would close
  /// itself and make the count meaningless.
  Stream<T> counted<T>(String name, T value) => census.track<T>(name, () {
    final controller = StreamController<T>();
    controller.add(value);
    return controller.stream;
  });

  return <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
    flavorProvider.overrideWithValue(Flavor.dev),
    currentFamilyIdProvider.overrideWithValue('f1'),
    currentUidProvider.overrideWithValue('cara'),
    currentActorProvider.overrideWithValue(
      const PermissionActor(uid: 'cara', role: Role.admin, isActive: true),
    ),
    permissionSettingsProvider.overrideWithValue(PermissionSettings.defaults),
    moduleFlagsProvider.overrideWithValue(ModuleFlags.allOn),
    choreSettingsProvider.overrideWithValue(ChoreSettings.defaults),
    familyDateKeysProvider.overrideWithValue(
      FamilyDateKeys(clock: FakeClock(DateTime.utc(2026, 10, 24, 9))),
    ),
    appFormattersProvider.overrideWithValue(
      const AppFormatters(languageCode: 'en', useBanglaDigits: false),
    ),
    // The per-minute tick is a repeating timer, not a Firestore listener.
    nowTickProvider.overrideWith((ref) => const Stream<DateTime>.empty()),
    dashboardPolicyProvider.overrideWith(
      (ref, familyId) =>
          counted<DashboardPolicy>('dashboardPolicy', DashboardPolicy.defaults),
    ),
    dashboardLayoutProvider.overrideWith(
      (ref) => AsyncData<DashboardLayout>(
        DashboardLayout(
          visible: <ResolvedCard>[
            for (final definition in CardCatalog.cards)
              ResolvedCard(
                definition: definition,
                access: CardAccess.on,
                canHide: true,
              ),
          ],
          optionalHidden: const <ResolvedCard>[],
          required: const <ResolvedCard>[],
        ),
      ),
    ),
    membersProvider.overrideWith(
      (ref) => counted<List<Member>>('members', const <Member>[]),
    ),
    templatesStreamProvider.overrideWith(
      (ref) =>
          counted<List<TemplateRecord>>('templates', const <TemplateRecord>[]),
    ),
    dutyGroupsStreamProvider.overrideWith(
      (ref) => counted<List<DutyGroup>>('dutyGroups', const <DutyGroup>[]),
    ),
    availabilityProvider.overrideWith(
      (ref) => counted<List<MemberAvailability>>(
        'availability',
        const <MemberAvailability>[],
      ),
    ),
    generationMarkerProvider.overrideWith(
      (ref) => counted<DateKey?>('generationMarker', today),
    ),
    monthOccurrencesProvider.overrideWith(
      (ref, month) =>
          counted<MonthOccurrences>('monthOccurrences', MonthOccurrences.empty),
    ),
    verifyQueueProvider.overrideWith(
      (ref) => counted<List<ChoreOccurrence>>(
        'verifyQueue',
        const <ChoreOccurrence>[],
      ),
    ),
    monthExpensesProvider.overrideWith(
      (ref, month) =>
          counted<List<Expense>>('monthExpenses', const <Expense>[]),
    ),
    monthBudgetProvider.overrideWith(
      (ref, month) => counted<Budget?>('monthBudget', null),
    ),
    categoriesProvider.overrideWith(
      (ref) => counted<List<Category>>('categories', const <Category>[]),
    ),
    fundTransactionsProvider.overrideWith(
      (ref) => counted<List<FundTransaction>>(
        'fundTransactions',
        const <FundTransaction>[],
      ),
    ),
    contributionPlansProvider.overrideWith(
      (ref, month) => counted<List<ContributionPlan>>(
        'contributionPlans',
        const <ContributionPlan>[],
      ),
    ),
    contributionsProvider.overrideWith(
      (ref, month) =>
          counted<List<Contribution>>('contributions', const <Contribution>[]),
    ),
    recentActivityProvider.overrideWith(
      (ref, limit) => counted<List<ActivityEntry>>(
        'recentActivity',
        const <ActivityEntry>[],
      ),
    ),
    inboxProvider.overrideWith(
      (ref) => counted<List<InboxItem>>('inbox', const <InboxItem>[]),
    ),
    engagementSettingsProvider.overrideWith(
      (ref, familyId) => counted<EngagementSettings>(
        'engagementSettings',
        defaultEngagementSettings(startedOn: today, graceMinutes: 0),
      ),
    ),
    memberStatsProvider.overrideWith(
      (ref, memberId) => counted<MemberStats?>(
        'memberStats',
        MemberStats.empty(startedOn: today),
      ),
    ),
    fundBalanceProvider.overrideWithValue(const Money.paisa(0)),
  ];
}
