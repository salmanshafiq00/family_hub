import 'dart:async';

import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/agenda_model.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../support/in_memory_chores_backend.dart';
import '../../chores_test_helpers.dart';

/// Counts how many month listeners were STARTED (a scope switch must add none).
class _CountingBackend extends InMemoryOccurrenceBackend {
  int subscriptions = 0;

  @override
  Stream<List<ChoreOccurrence>> watchRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) {
    subscriptions++;
    return super.watchRange(familyId, from: from, to: to);
  }
}

/// P3-21: calendar preferences, projection, merge and the three models.
///
/// "Today" is Saturday 2026-10-24 15:00 Asia/Dhaka (the fixture clock).
void main() {
  const familyId = ChoresFixture.familyId;
  late ChoresFixture fixture;
  late _CountingBackend backend;
  late SharedPreferences prefs;

  setUp(() async {
    fixture = ChoresFixture();
    backend = _CountingBackend();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer make({
    ChoreSettings? settings,
    Duration? retention,
    Stream<DateTime>? ticks,
    String uid = 'cara',
  }) {
    if (settings != null) fixture.settings.settings = settings;
    final container = ProviderContainer(
      overrides: [
        occurrenceRepositoryProvider.overrideWithValue(backend),
        generationMarkerRepositoryProvider.overrideWithValue(backend),
        dutyGroupRepositoryProvider.overrideWithValue(
          fixture.chores.dutyGroups,
        ),
        templateRepositoryProvider.overrideWithValue(fixture.chores),
        choreSettingsRepositoryProvider.overrideWithValue(fixture.settings),
        currentFamilyIdProvider.overrideWithValue(familyId),
        currentUidProvider.overrideWithValue(uid),
        familyRepositoryProvider.overrideWithValue(fixture.families),
        clockProvider.overrideWithValue(fixture.clock),
        sharedPreferencesProvider.overrideWithValue(prefs),
        nowTickProvider.overrideWith(
          (ref) => ticks ?? const Stream<DateTime>.empty(),
        ),
        if (retention != null)
          monthRetentionProvider.overrideWithValue(retention),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  Future<void> settle(ProviderContainer container) async {
    for (var i = 0; i < 6; i++) {
      await container.pump();
      await Future<void>.delayed(Duration.zero);
    }
  }

  void seed(ChoreOccurrence occurrence) {
    (backend.occurrences[familyId] ??=
            <String, ChoreOccurrence>{})[occurrence.id] =
        occurrence;
  }

  void seedTemplate({String id = 'tpl_1'}) {
    (fixture.chores.templates[familyId] ??=
        <String, ChoreTemplate>{})[id] = ChoreTemplate(
      id: id,
      active: true,
      draft: aTemplate(startDate: DateKey(2026, 10, 1)),
    );
  }

  final october = MonthKey(2026, 10);

  group('projection and merge', () {
    test('a stored chore wins over the planned one of the same id', () async {
      seedTemplate();
      seed(
        anOccurrence(
          id: 'tpl_1_20261026',
          dateKey: DateKey(2026, 10, 26),
          assigneeId: 'dave',
        ),
      );
      final container = make();
      container.listen(monthItemsProvider(october), (_, _) {});
      await settle(container);

      final items = container.read(monthItemsProvider(october)).value!.items;

      // 24 .. 31 October: one stored + seven planned. Nothing before today.
      expect(items, hasLength(8));
      expect(items.first.dateKey, DateKey(2026, 10, 24));
      final stored = items.singleWhere((i) => i.id == 'tpl_1_20261026');
      expect(stored.isProjected, isFalse);
      expect(stored.assigneeId, 'dave');
      expect(items.where((i) => i.isProjected), hasLength(7));
      expect(items.map((i) => i.id).toSet(), hasLength(8));
    });

    test('planned chores stop at the end of the projected months', () async {
      seedTemplate();
      final container = make(
        settings: ChoreSettings.defaults.copyWith(projectedMonthsAhead: 1),
      );
      for (final month in <MonthKey>[
        MonthKey(2026, 9),
        MonthKey(2026, 11),
        MonthKey(2026, 12),
      ]) {
        container.listen(monthItemsProvider(month), (_, _) {});
      }
      await settle(container);

      int count(MonthKey m) =>
          container.read(monthItemsProvider(m)).value!.items.length;
      expect(count(MonthKey(2026, 9)), 0);
      expect(count(MonthKey(2026, 11)), 30);
      expect(count(MonthKey(2026, 12)), 0);
    });

    test('the person can switch planned chores off', () async {
      seedTemplate();
      final container = make();
      container.listen(monthItemsProvider(october), (_, _) {});
      await settle(container);
      expect(container.read(monthItemsProvider(october)).value!.items, isNotEmpty);

      await container
          .read(calendarPrefsProvider.notifier)
          .setShowProjected(value: false);
      await settle(container);

      expect(container.read(monthItemsProvider(october)).value!.items, isEmpty);
    });

    test('projectedItemProvider finds a planned chore by id', () async {
      seedTemplate();
      final container = make();
      container.listen(projectedItemsProvider(october), (_, _) {});
      await settle(container);

      expect(container.read(projectedItemProvider('tpl_1_20261026')), isNotNull);
      expect(container.read(projectedItemProvider('nope_20261026')), isNull);
      expect(occurrenceMonthOf('tpl_dishes_20261105_noon'), MonthKey(2026, 11));
      expect(occurrenceMonthOf('garbage'), isNull);
    });
  });

  group('scope, filters and prefs cost no reads', () {
    test('switching scope and filters adds no listener', () async {
      seed(anOccurrence(id: 'tpl_1_20261027', dateKey: DateKey(2026, 10, 27)));
      seed(
        anOccurrence(
          id: 'tpl_2_20261027',
          templateId: 'tpl_2',
          dateKey: DateKey(2026, 10, 27),
          assigneeId: 'dave',
        ),
      );
      final container = make();
      container.listen(calendarMonthModelProvider(october), (_, _) {});
      await settle(container);
      final day = DateKey(2026, 10, 27);

      expect(backend.subscriptions, 1);
      final mine = container.read(calendarMonthModelProvider(october)).value!;
      expect(mine.summaryOf(day)!.total, 1);

      final prefsController = container.read(calendarPrefsProvider.notifier);
      await prefsController.toggleScope();
      await settle(container);

      final all = container.read(calendarMonthModelProvider(october)).value!;
      expect(all.summaryOf(day)!.total, 2);
      expect(backend.subscriptions, 1);

      container.read(calendarQueryProvider.notifier).change('zzz-no-match');
      await settle(container);
      final none = container.read(calendarMonthModelProvider(october)).value!;
      expect(none.summaryOf(day)!.total, 0);
      expect(backend.subscriptions, 1);
    });

    test('density does not rebuild the month model', () async {
      final container = make();
      var builds = 0;
      container.listen(calendarMonthModelProvider(october), (_, _) => builds++);
      await settle(container);
      final base = builds;

      await container
          .read(calendarPrefsProvider.notifier)
          .setDensity(Density.compact);
      await settle(container);

      expect(builds, base);
    });

    test('the week start decides the first cell', () async {
      final saturday = make(
        settings: ChoreSettings.defaults.copyWith(weekStartDay: 6),
      );
      saturday.listen(calendarMonthModelProvider(october), (_, _) {});
      final sunday = make(
        settings: ChoreSettings.defaults.copyWith(weekStartDay: 7),
      );
      sunday.listen(calendarMonthModelProvider(october), (_, _) {});
      await settle(saturday);
      await settle(sunday);

      expect(
        saturday.read(calendarMonthModelProvider(october)).value!.days.first
            .dateKey,
        DateKey(2026, 9, 26),
      );
      expect(
        sunday.read(calendarMonthModelProvider(october)).value!.days.first
            .dateKey,
        DateKey(2026, 9, 27),
      );
    });
  });

  group('the clock', () {
    test('a tick that changes nothing does not rebuild the model', () async {
      seed(
        anOccurrence(
          id: 'tpl_1_20261026',
          dateKey: DateKey(2026, 10, 26),
        ),
      );
      final ticks = StreamController<DateTime>.broadcast();
      addTearDown(ticks.close);
      final container = make(ticks: ticks.stream);
      var builds = 0;
      container.listen(calendarMonthModelProvider(october), (_, _) => builds++);
      await settle(container);
      final base = builds;

      ticks.add(DateTime.utc(2026, 10, 24, 9, 1));
      await settle(container);

      expect(builds, base);
    });

    test('a tick past a deadline marks the chore overdue', () async {
      seed(
        anOccurrence(
          id: 'tpl_1_20261024',
          dueAt: DateTime.utc(2026, 10, 24, 10),
        ),
      );
      final ticks = StreamController<DateTime>.broadcast();
      addTearDown(ticks.close);
      final container = make(ticks: ticks.stream);
      container.listen(calendarMonthModelProvider(october), (_, _) {});
      await settle(container);
      final day = DateKey(2026, 10, 24);
      expect(
        container
            .read(calendarMonthModelProvider(october))
            .value!
            .summaryOf(day)!
            .counts[ChoreStatus.overdue],
        anyOf(isNull, 0),
      );

      ticks.add(DateTime.utc(2026, 10, 24, 10, 5));
      await settle(container);

      expect(
        container
            .read(calendarMonthModelProvider(october))
            .value!
            .summaryOf(day)!
            .counts[ChoreStatus.overdue],
        1,
      );
    });
  });

  group('listener lifetime', () {
    test('a left month is kept for the retention, then released', () async {
      final container = make(retention: const Duration(milliseconds: 150));
      final september = MonthKey(2026, 9);

      final first = container.listen(monthItemsProvider(september), (_, _) {});
      await settle(container);
      expect(backend.subscriptions, 1);
      first.close();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await settle(container);
      expect(backend.activeRangeListeners, 1);

      // Coming back inside the window re-uses the listener.
      final again = container.listen(monthItemsProvider(september), (_, _) {});
      await settle(container);
      expect(backend.subscriptions, 1);
      again.close();

      await Future<void>.delayed(const Duration(milliseconds: 400));
      await settle(container);
      expect(backend.activeRangeListeners, 0);
    });
  });

  group('truncation', () {
    test('the cap is passed through to the items and the model', () async {
      for (var i = 0; i <= kMaxOccurrencesPerMonth; i++) {
        seed(
          anOccurrence(
            id: 'tpl_${i}_20261027',
            templateId: 'tpl_$i',
            dateKey: DateKey(2026, 10, 27),
          ),
        );
      }
      final container = make();
      container.listen(calendarMonthModelProvider(october), (_, _) {});
      await settle(container);

      final items = container.read(monthItemsProvider(october)).value!;
      expect(items.truncated, isTrue);
      expect(items.items, hasLength(kMaxOccurrencesPerMonth));
      expect(
        container.read(calendarMonthModelProvider(october)).value!.truncated,
        isTrue,
      );
    });
  });

  group('week and agenda', () {
    test('a week that crosses a month border reads both months', () async {
      seed(anOccurrence(id: 'tpl_1_20261031', dateKey: DateKey(2026, 10, 31)));
      seed(
        anOccurrence(
          id: 'tpl_1_20261101',
          dateKey: DateKey(2026, 11, 1),
        ),
      );
      final container = make(
        settings: ChoreSettings.defaults.copyWith(weekStartDay: 1),
      );
      final anchor = DateKey(2026, 10, 29);
      container.listen(weekModelProvider(anchor), (_, _) {});
      await settle(container);

      final week = container.read(weekModelProvider(anchor)).value!;
      expect(week.days[5].summary.total, 1);
      expect(week.days[6].summary.total, 1);
      expect(backend.subscriptions, 2);
    });

    test('the agenda pins an open chore of last month as overdue', () async {
      seed(
        anOccurrence(
          id: 'tpl_1_20260930',
          dateKey: DateKey(2026, 9, 30),
        ),
      );
      final container = make();
      container.listen(agendaModelProvider(2), (_, _) {});
      await settle(container);

      final agenda = container.read(agendaModelProvider(2)).value!;
      final first = agenda.entries.first;
      expect(first, isA<AgendaOverdue>());
      expect((first as AgendaOverdue).items.single.id, 'tpl_1_20260930');
    });
  });

  group('focus', () {
    test('selecting a day in another month moves the focused month', () {
      final container = make();
      container.listen(calendarFocusProvider, (_, _) {});
      final focus = container.read(calendarFocusProvider.notifier);

      expect(container.read(focusedMonthProvider), october);
      expect(container.read(selectedDayProvider), DateKey(2026, 10, 24));

      focus.selectDay(DateKey(2026, 11, 3));
      expect(container.read(focusedMonthProvider), MonthKey(2026, 11));
      expect(container.read(selectedDayProvider), DateKey(2026, 11, 3));
    });

    test('browsing months keeps the selected day inside the shown month', () {
      final container = make();
      container.listen(calendarFocusProvider, (_, _) {});
      final focus = container.read(calendarFocusProvider.notifier)
        ..selectDay(DateKey(2026, 11, 3))
        ..showMonth(MonthKey(2026, 12));
      expect(container.read(selectedDayProvider), DateKey(2026, 12, 1));

      focus.showMonth(october);
      expect(container.read(selectedDayProvider), DateKey(2026, 10, 24));

      focus
        ..shiftMonth(1)
        ..goToToday();
      expect(container.read(focusedMonthProvider), october);
      expect(container.read(selectedDayProvider), DateKey(2026, 10, 24));
    });
  });
}
