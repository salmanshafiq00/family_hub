import 'package:family_hub/features/chores/availability/presentation/availability_index_provider.dart';
import 'package:family_hub/features/chores/calendar/domain/agenda_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How far the agenda reaches from today, in whole weeks (P3-23). The person
/// extends it with "Show earlier / later weeks".
final class AgendaWindow {
  const AgendaWindow({this.weeksBack = 1, this.weeksAhead = 4});

  /// 8 + 48 weeks = 392 days, inside the model's 400-day cap.
  static const int maxBack = 8;
  static const int maxAhead = 48;

  /// A filtered agenda reaches at least this far back, so a chore that has been
  /// overdue for weeks is in the list without tapping "Show earlier weeks".
  static const int filteringWeeksBack = 4;

  final int weeksBack;
  final int weeksAhead;

  /// The same window, widened to at least [weeks] weeks back.
  AgendaWindow atLeastBack(int weeks) => weeksBack >= weeks
      ? this
      : AgendaWindow(
          weeksBack: weeks.clamp(1, maxBack).toInt(),
          weeksAhead: weeksAhead,
        );

  AgendaWindow earlier() => AgendaWindow(
    weeksBack: (weeksBack + 2).clamp(1, maxBack).toInt(),
    weeksAhead: weeksAhead,
  );

  AgendaWindow later() => AgendaWindow(
    weeksBack: weeksBack,
    weeksAhead: (weeksAhead + 4).clamp(1, maxAhead).toInt(),
  );

  bool get canGoEarlier => weeksBack < maxBack;
  bool get canGoLater => weeksAhead < maxAhead;

  @override
  bool operator ==(Object other) =>
      other is AgendaWindow &&
      other.weeksBack == weeksBack &&
      other.weeksAhead == weeksAhead;

  @override
  int get hashCode => Object.hash(weeksBack, weeksAhead);
}

/// The agenda around today: [AgendaWindow.weeksBack] weeks before, the days up
/// to [AgendaWindow.weeksAhead] weeks after, and today's overdue chores in the
/// pinned block (an earlier day's chore stays under its own date).
///
/// Reads one month listener per month in the window (retained 60 s); scope and
/// filters never start a read.
final agendaWindowModelProvider = Provider.autoDispose
    .family<AsyncValue<AgendaModel>, AgendaWindow>((ref, window) {
      final today = ref.watch(todayKeyProvider);
      final from = today.addDays(-7 * window.weeksBack);
      final to = today.addDays(7 * window.weeksAhead - 1);
      var first = today.monthKey.addMonths(-1);
      if (from.monthKey.compareTo(first) < 0) first = from.monthKey;

      final months = <MonthKey>[];
      for (
        var month = first;
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
          from: from,
          to: to,
          filters: filters,
          scope: scope,
          viewerId: viewer,
          availability: availability,
        ),
      );
    });
