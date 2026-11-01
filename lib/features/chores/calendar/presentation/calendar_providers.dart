import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/month_matrix.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_index_provider.dart';
import 'package:family_hub/features/chores/calendar/domain/agenda_model.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_month_model.dart';
import 'package:family_hub/features/chores/calendar/domain/week_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_items_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_prefs.dart';
import 'package:family_hub/features/chores/calendar/presentation/month_items.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:family_hub/features/chores/calendar/presentation/calendar_focus.dart';
export 'package:family_hub/features/chores/calendar/presentation/calendar_items_providers.dart';
export 'package:family_hub/features/chores/calendar/presentation/calendar_prefs.dart';
export 'package:family_hub/features/chores/calendar/presentation/month_items.dart';

// ── Preference views (each notifies only when ITS value changes) ─────────────

final calendarViewProvider = Provider<CalendarView>(
  (ref) => ref.watch(calendarPrefsProvider.select((p) => p.view)),
);

final calendarScopeProvider = Provider<CalendarScope>(
  (ref) => ref.watch(calendarPrefsProvider.select((p) => p.scope)),
);

final calendarDensityProvider = Provider<Density>(
  (ref) => ref.watch(calendarPrefsProvider.select((p) => p.density)),
);

final calendarMarkerStyleProvider = Provider<MarkerStyle>(
  (ref) => ref.watch(calendarPrefsProvider.select((p) => p.markerStyle)),
);

final calendarHeatModeProvider = Provider<HeatMode>(
  (ref) => ref.watch(calendarPrefsProvider.select((p) => p.heatMode)),
);

/// The free-text search of the filter sheet. Session state only: a stale search
/// that hides chores after a restart would look like missing data.
final calendarQueryProvider = NotifierProvider<CalendarQueryController, String>(
  CalendarQueryController.new,
);

class CalendarQueryController extends Notifier<String> {
  @override
  String build() {
    ref.watch(currentFamilyIdProvider);
    return '';
  }

  void change(String query) => state = query;

  void clear() => state = '';
}

/// The stored filters plus the session's search text.
final calendarFiltersProvider = Provider<CalendarFilters>((ref) {
  final stored = ref.watch(calendarPrefsProvider.select((p) => p.filters));
  final query = ref.watch(calendarQueryProvider);
  return query.isEmpty ? stored : stored.copyWith(query: query);
});

final _weekStartDayProvider = Provider<int>(
  (ref) => ref.watch(choreSettingsProvider.select((s) => s.weekStartDay)),
);

// ── Models ───────────────────────────────────────────────────────────────────

/// The month grid of [month], scope and filters applied (P3-20 model over the
/// P3-21 items).
///
/// It watches `monthItemsProvider`, never the minute ticker: when the clock
/// ticks and no chore changes, `monthItemsProvider` produces an equal value and
/// this provider does not rebuild.
final calendarMonthModelProvider = Provider.autoDispose
    .family<AsyncValue<CalendarMonthModel>, MonthKey>((ref, month) {
      final items = ref.watch(monthItemsProvider(month));
      final weekStart = ref.watch(_weekStartDayProvider);
      final today = ref.watch(todayKeyProvider);
      final scope = ref.watch(calendarScopeProvider);
      final filters = ref.watch(calendarFiltersProvider);
      final heat = ref.watch(calendarHeatModeProvider);
      final viewer = ref.watch(currentUidProvider);
      final availability = ref.watch(availabilityIndexProvider);
      return mapAsync<MonthItems, CalendarMonthModel>(
        items,
        (value) => CalendarMonthModel.build(
          month: month,
          weekStartDay: weekStart,
          items: value.items,
          today: today,
          filters: filters,
          scope: scope,
          viewerId: viewer,
          availability: availability,
          heatMode: heat,
          truncated: value.truncated,
        ),
      );
    });

/// The week that contains [anchor] (any day of it). A week may cross a month
/// border, so it reads both months' items (two listeners at most).
final weekModelProvider = Provider.autoDispose
    .family<AsyncValue<WeekModel>, DateKey>((ref, anchor) {
      final weekStart = ref.watch(_weekStartDayProvider);
      final range = MonthMatrix.weekOf(anchor, weekStart);
      final months = <MonthKey>{range.start.monthKey, range.end.monthKey};
      final items = combineMonths(<AsyncValue<MonthItems>>[
        for (final month in months) ref.watch(monthItemsProvider(month)),
      ]);
      final today = ref.watch(todayKeyProvider);
      final scope = ref.watch(calendarScopeProvider);
      final filters = ref.watch(calendarFiltersProvider);
      final heat = ref.watch(calendarHeatModeProvider);
      final viewer = ref.watch(currentUidProvider);
      final availability = ref.watch(availabilityIndexProvider);
      return mapAsync<MonthItems, WeekModel>(
        items,
        (value) => WeekModel.build(
          anchor: anchor,
          weekStartDay: weekStart,
          items: value.items,
          today: today,
          filters: filters,
          scope: scope,
          viewerId: viewer,
          availability: availability,
          heatMode: heat,
        ),
      );
    });

/// The agenda: from today for [weeks] whole weeks (1 … 57, the model caps the
/// range at 400 days), plus the open chores of the PREVIOUS month in the
/// Overdue block. An older overdue chore is out of reach on purpose: reading
/// every past month would cost a listener each.
final agendaModelProvider = Provider.autoDispose
    .family<AsyncValue<AgendaModel>, int>((ref, weeks) {
      final today = ref.watch(todayKeyProvider);
      final length = weeks.clamp(1, AgendaModel.maxDays ~/ 7).toInt() * 7;
      final to = today.addDays(length - 1);

      final months = <MonthKey>[];
      for (
        var month = today.monthKey.addMonths(-1);
        month.compareTo(to.monthKey) <= 0;
        month = month.addMonths(1)
      ) {
        months.add(month);
      }
      final items = combineMonths(<AsyncValue<MonthItems>>[
        for (final month in months) ref.watch(monthItemsProvider(month)),
      ]);
      final scope = ref.watch(calendarScopeProvider);
      final filters = ref.watch(calendarFiltersProvider);
      final viewer = ref.watch(currentUidProvider);
      final availability = ref.watch(availabilityIndexProvider);
      return mapAsync<MonthItems, AgendaModel>(
        items,
        (value) => AgendaModel.build(
          items: value.items,
          today: today,
          from: today,
          to: to,
          filters: filters,
          scope: scope,
          viewerId: viewer,
          availability: availability,
        ),
      );
    });
