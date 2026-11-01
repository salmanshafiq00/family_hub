import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/month_matrix.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary_builder.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/day_part.dart';

/// One day of the week view: its counts and its chores in clock order.
final class WeekDay {
  const WeekDay({
    required this.summary,
    required this.items,
    required this.parts,
  });

  final DaySummary summary;

  /// The visible chores, earliest deadline first.
  final List<ChoreItem> items;

  /// The same chores grouped by part of the day, in clock order.
  final List<(ChoreDayPart, List<ChoreItem>)> parts;

  DateKey get dateKey => summary.dateKey;
}

/// Seven days from the week start, for the week view and the tablet columns.
final class WeekModel {
  const WeekModel({required this.range, required this.days});

  /// [anchor] is any day of the wanted week; the week starts on
  /// [weekStartDay]. The week may cross a month border: unlike the month grid,
  /// every day of it is a real day with its chores.
  factory WeekModel.build({
    required DateKey anchor,
    required int weekStartDay,
    required Iterable<ChoreItem> items,
    required DateKey today,
    CalendarFilters filters = CalendarFilters.none,
    CalendarScope scope = CalendarScope.all,
    String? viewerId,
    AvailabilityIndex availability = AvailabilityIndex.empty,
    HeatMode heatMode = HeatMode.off,
  }) {
    final range = MonthMatrix.weekOf(anchor, weekStartDay);
    final days = <DateKey>[for (var i = 0; i < 7; i++) range.start.addDays(i)];
    final builder = DaySummaryBuilder(
      today: today,
      scope: scope,
      viewerId: viewerId,
      filters: filters,
      availability: availability,
      heatMode: heatMode,
    );
    final inWeek = <ChoreItem>[
      for (final item in items)
        if (range.contains(item.dateKey)) item,
    ];
    final summaries = builder.build(days: days, items: inWeek);
    final visible = builder.visibleByDay(inWeek);
    return WeekModel(
      range: range,
      days: List<WeekDay>.unmodifiable(<WeekDay>[
        for (final day in days)
          _weekDay(summaries[day]!, visible[day] ?? const <ChoreItem>[]),
      ]),
    );
  }

  static WeekDay _weekDay(DaySummary summary, List<ChoreItem> visible) {
    final sorted = sortByDeadline(visible);
    return WeekDay(
      summary: summary,
      items: sorted,
      parts: groupByDayPart(sorted),
    );
  }

  final DateKeyRange range;

  /// Exactly seven days.
  final List<WeekDay> days;

  WeekDay? dayOf(DateKey day) {
    for (final entry in days) {
      if (entry.dateKey == day) return entry;
    }
    return null;
  }
}

/// A copy of [items] ordered by deadline, then id, so two builds of the same
/// data always list chores in the same order.
List<ChoreItem> sortByDeadline(Iterable<ChoreItem> items) =>
    <ChoreItem>[...items]..sort((a, b) {
      final byDue = a.dueAt.compareTo(b.dueAt);
      return byDue != 0 ? byDue : a.id.compareTo(b.id);
    });
