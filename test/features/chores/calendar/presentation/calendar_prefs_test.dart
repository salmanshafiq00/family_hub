import 'dart:convert';

import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_prefs.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A settings value a test can change while the container lives.
class _SettingsHolder extends Notifier<ChoreSettings> {
  @override
  ChoreSettings build() => ChoreSettings.defaults;

  void change(ChoreSettings value) => state = value;
}

final _holder = NotifierProvider<_SettingsHolder, ChoreSettings>(
  _SettingsHolder.new,
);

/// P3-21: the local calendar preferences.
void main() {
  const fallback = CalendarPrefs(
    view: CalendarViewKind.agenda,
    scope: CalendarScopeKind.mine,
    showProjected: true,
  );

  group('CalendarPrefs encoding', () {
    test('round-trips every field', () {
      final prefs = fallback.copyWith(
        view: CalendarViewKind.month,
        scope: CalendarScopeKind.all,
        showProjected: false,
        density: Density.compact,
        markerStyle: MarkerStyle.dots,
        heatMode: HeatMode.workload,
        filters: const CalendarFilters(
          groupIds: <String>{'kitchen'},
          statuses: <ChoreStatus>{ChoreStatus.overdue},
          memberIds: <String>{'cara'},
          onlyNeedsAttention: true,
          query: 'must not be stored',
        ),
      );

      final back = CalendarPrefs.decode(
        jsonEncode(prefs.toJson()),
        fallback: fallback,
      );

      expect(back, prefs);
      expect(back!.filters.query, isEmpty);
    });

    test('a damaged or foreign value gives null (family defaults apply)', () {
      expect(CalendarPrefs.decode(null, fallback: fallback), isNull);
      expect(CalendarPrefs.decode('', fallback: fallback), isNull);
      expect(CalendarPrefs.decode('{oops', fallback: fallback), isNull);
      expect(CalendarPrefs.decode('[1,2]', fallback: fallback), isNull);
    });

    test('a missing field keeps the fallback, an unknown status is dropped', () {
      final back = CalendarPrefs.decode(
        '{"v":1,"view":"month","statuses":["overdue","martian"]}',
        fallback: fallback,
      )!;

      expect(back.view, CalendarViewKind.month);
      expect(back.scope, CalendarScopeKind.mine);
      expect(back.showProjected, isTrue);
      expect(back.filters.statuses, <ChoreStatus>{ChoreStatus.overdue});
    });
  });

  group('CalendarPrefsController', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer make({String? familyId = 'f1'}) {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentFamilyIdProvider.overrideWithValue(familyId),
          choreSettingsProvider.overrideWith((ref) => ref.watch(_holder)),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('starts from the family settings and follows them until changed', () {
      final container = make();
      container.listen(calendarPrefsProvider, (_, _) {});

      expect(container.read(calendarPrefsProvider).view, CalendarViewKind.agenda);
      expect(container.read(calendarUsesFamilyDefaultsProvider), isTrue);

      container
          .read(_holder.notifier)
          .change(
            ChoreSettings.defaults.copyWith(
              defaultCalendarView: CalendarViewKind.week,
              defaultScope: CalendarScopeKind.all,
            ),
          );

      final now = container.read(calendarPrefsProvider);
      expect(now.view, CalendarViewKind.week);
      expect(now.scope, CalendarScopeKind.all);
    });

    test('a change is stored and a later settings change never overwrites it',
        () async {
      final container = make();
      container.listen(calendarPrefsProvider, (_, _) {});

      await container
          .read(calendarPrefsProvider.notifier)
          .setView(CalendarViewKind.month);
      expect(container.read(calendarUsesFamilyDefaultsProvider), isFalse);

      container
          .read(_holder.notifier)
          .change(
            ChoreSettings.defaults.copyWith(
              defaultCalendarView: CalendarViewKind.week,
              defaultScope: CalendarScopeKind.all,
              showProjected: false,
            ),
          );

      final now = container.read(calendarPrefsProvider);
      expect(now.view, CalendarViewKind.month);
      // The snapshot taken at the first change also froze the other fields.
      expect(now.scope, CalendarScopeKind.mine);
      expect(now.showProjected, isTrue);
    });

    test('a new container restores what was stored', () async {
      final first = make();
      first.listen(calendarPrefsProvider, (_, _) {});
      final notifier = first.read(calendarPrefsProvider.notifier);
      await notifier.setHeatMode(HeatMode.workload);
      await notifier.toggleScope();

      final second = make();
      second.listen(calendarPrefsProvider, (_, _) {});
      final restored = second.read(calendarPrefsProvider);

      expect(restored.heatMode, HeatMode.workload);
      expect(restored.scope, CalendarScopeKind.all);
    });

    test('each family has its own key', () async {
      final a = make(familyId: 'fa');
      a.listen(calendarPrefsProvider, (_, _) {});
      await a
          .read(calendarPrefsProvider.notifier)
          .setDensity(Density.compact);

      final b = make(familyId: 'fb');
      b.listen(calendarPrefsProvider, (_, _) {});

      expect(b.read(calendarPrefsProvider).density, Density.comfortable);
      expect(prefs.containsKey(calendarPrefsKey('fa')), isTrue);
      expect(prefs.containsKey(calendarPrefsKey('fb')), isFalse);
    });

    test('useFamilyDefaults forgets the stored snapshot', () async {
      final container = make();
      container.listen(calendarPrefsProvider, (_, _) {});
      final notifier = container.read(calendarPrefsProvider.notifier);
      await notifier.setView(CalendarViewKind.month);

      await notifier.useFamilyDefaults();

      expect(
        container.read(calendarPrefsProvider).view,
        CalendarViewKind.agenda,
      );
      expect(prefs.containsKey(calendarPrefsKey('f1')), isFalse);
      expect(container.read(calendarUsesFamilyDefaultsProvider), isTrue);
    });

    test('without a family nothing is written', () async {
      final container = make(familyId: null);
      container.listen(calendarPrefsProvider, (_, _) {});

      await container
          .read(calendarPrefsProvider.notifier)
          .setView(CalendarViewKind.week);

      expect(container.read(calendarPrefsProvider).view, CalendarViewKind.week);
      expect(prefs.getKeys(), isEmpty);
    });
  });
}
