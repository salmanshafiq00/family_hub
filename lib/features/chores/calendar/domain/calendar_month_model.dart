import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/month_matrix.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary_builder.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';

/// The month grid, ready to draw (P3-20, Appendix B).
///
/// Pure: one call turns the month's items into 4–6 weeks of [DaySummary]s.
/// Scope, filters and heat are applied in memory over the month's single
/// listener (D-P3-8), so changing them never reads anything.
final class CalendarMonthModel {
  const CalendarMonthModel({
    required this.month,
    required this.weekStartDay,
    required this.weeks,
    required this.truncated,
  });

  /// [items] must be the month's items with the DERIVED overdue status already
  /// applied (the provider of P3-21 does that from the clock), materialized and
  /// projected merged by id. Items of other months are ignored: a day outside
  /// [month] never carries a marker.
  ///
  /// [truncated] comes from the month listener ("more than the cap exists");
  /// the model only passes it on, so the banner and the grid agree.
  factory CalendarMonthModel.build({
    required MonthKey month,
    required int weekStartDay,
    required Iterable<ChoreItem> items,
    required DateKey today,
    CalendarFilters filters = CalendarFilters.none,
    CalendarScope scope = CalendarScope.all,
    String? viewerId,
    AvailabilityIndex availability = AvailabilityIndex.empty,
    HeatMode heatMode = HeatMode.off,
    bool truncated = false,
  }) {
    final matrix = MonthMatrix.build(month, weekStartDay);
    final builder = DaySummaryBuilder(
      today: today,
      scope: scope,
      viewerId: viewerId,
      filters: filters,
      availability: availability,
      heatMode: heatMode,
    );
    final summaries = builder.build(
      days: matrix.days,
      items: <ChoreItem>[
        for (final item in items)
          if (item.dateKey.monthKey == month) item,
      ],
      isOutside: (day) => !matrix.isInMonth(day),
    );
    return CalendarMonthModel(
      month: month,
      weekStartDay: weekStartDay,
      weeks: List<List<DaySummary>>.unmodifiable(<List<DaySummary>>[
        for (final row in matrix.rows)
          List<DaySummary>.unmodifiable(<DaySummary>[
            for (final day in row) summaries[day]!,
          ]),
      ]),
      truncated: truncated,
    );
  }

  final MonthKey month;
  final int weekStartDay;

  /// 4–6 rows of exactly seven days, in week-start order.
  final List<List<DaySummary>> weeks;

  /// The listener hit its cap, so the grid may be missing chores.
  final bool truncated;

  /// Every cell, row by row.
  List<DaySummary> get days => <DaySummary>[for (final week in weeks) ...week];

  /// The summary of [day], or null when the grid does not show it.
  DaySummary? summaryOf(DateKey day) {
    for (final week in weeks) {
      for (final summary in week) {
        if (summary.dateKey == day) return summary;
      }
    }
    return null;
  }

  /// Chores in the month after scope and filters.
  int get totalInMonth => <int>[
    for (final summary in days)
      if (!summary.isOutsideMonth) summary.total,
  ].fold(0, (sum, value) => sum + value);
}
