import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/domain/heat_calculator.dart';
import 'package:family_hub/features/chores/calendar/domain/unavailability_overlay.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';

/// Turns a list of items into one [DaySummary] per day, for the month grid and
/// the week strip alike, so the two can never count a day differently.
///
/// Order of operations (the same everywhere): FILTERS first, then SCOPE. The
/// heat tint is computed from the chores that are visible after both, over the
/// days that are inside the shown range.
final class DaySummaryBuilder {
  const DaySummaryBuilder({
    required this.today,
    required this.scope,
    required this.viewerId,
    required this.filters,
    required this.availability,
    required this.heatMode,
  });

  final DateKey today;
  final CalendarScope scope;
  final String? viewerId;
  final CalendarFilters filters;
  final AvailabilityIndex availability;
  final HeatMode heatMode;

  /// The visible items of each day (after filters and scope), the input of
  /// every view that lists chores.
  Map<DateKey, List<ChoreItem>> visibleByDay(Iterable<ChoreItem> items) {
    final byDay = <DateKey, List<ChoreItem>>{};
    for (final item in items) {
      if (!filters.matches(item)) continue;
      if (!inScope(scope, viewerId, item)) continue;
      (byDay[item.dateKey] ??= <ChoreItem>[]).add(item);
    }
    return byDay;
  }

  /// One summary for each of [days]. A day for which [isOutside] is true gets
  /// the empty, dimmed summary and is left out of the heat scale.
  Map<DateKey, DaySummary> build({
    required Iterable<DateKey> days,
    required Iterable<ChoreItem> items,
    bool Function(DateKey day)? isOutside,
  }) {
    final wanted = <DateKey>{for (final day in days) day};
    final visible = visibleByDay(items);
    final mine = <DateKey, int>{};
    for (final item in items) {
      if (!wanted.contains(item.dateKey) || !filters.matches(item)) continue;
      if (viewerId != null && item.assigneeId == viewerId) {
        mine[item.dateKey] = (mine[item.dateKey] ?? 0) + 1;
      }
    }

    bool outside(DateKey day) => isOutside != null && isOutside(day);
    final heat = heatMode == HeatMode.off
        ? const <DateKey, int>{}
        : HeatCalculator.levels(<DateKey, int>{
            for (final day in wanted)
              if (!outside(day))
                day: HeatCalculator.workloadOf(
                  visible[day] ?? const <ChoreItem>[],
                ),
          });

    return <DateKey, DaySummary>{
      for (final day in days)
        day: outside(day)
            ? DaySummary.outside(day, isToday: day == today)
            : DaySummary.of(
                dateKey: day,
                isToday: day == today,
                visible: visible[day] ?? const <ChoreItem>[],
                mineCount: mine[day] ?? 0,
                heatLevel: heat[day] ?? 0,
                unavailableMemberIds: UnavailabilityOverlay.forDay(
                  index: availability,
                  day: day,
                  scope: scope,
                  viewerId: viewerId,
                  filters: filters,
                ),
              ),
    };
  }
}
