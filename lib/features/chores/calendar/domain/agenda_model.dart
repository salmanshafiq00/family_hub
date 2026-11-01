import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary_builder.dart';
import 'package:family_hub/features/chores/calendar/domain/unavailability_overlay.dart';
import 'package:family_hub/features/chores/calendar/domain/week_model.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// One block of the agenda list.
sealed class AgendaEntry {
  const AgendaEntry();
}

/// The pinned block of open chores from days before today.
final class AgendaOverdue extends AgendaEntry {
  const AgendaOverdue({required this.items, required this.total});

  /// The newest [AgendaModel.overdueCap] at most, newest first.
  final List<ChoreItem> items;

  /// All of them; `total > items.length` shows "see all".
  final int total;

  bool get hasMore => total > items.length;
}

/// One day with its chores in deadline order.
final class AgendaDay extends AgendaEntry {
  const AgendaDay({
    required this.dateKey,
    required this.isToday,
    required this.items,
    required this.unavailableMemberIds,
  });

  final DateKey dateKey;
  final bool isToday;
  final List<ChoreItem> items;
  final Set<String> unavailableMemberIds;
}

/// A run of consecutive days with nothing to do, shown as "3 free days".
final class AgendaFreeDays extends AgendaEntry {
  const AgendaFreeDays({required this.from, required this.to});

  final DateKey from;
  final DateKey to;

  int get count => from.daysUntil(to) + 1;
}

/// The agenda list: Overdue pinned first, then today and the following days,
/// empty stretches collapsed (P3-20, Appendix B.2).
final class AgendaModel {
  const AgendaModel({required this.entries});

  /// The most overdue chores listed before "see all".
  static const int overdueCap = 100;

  /// The longest stretch one build covers (guards a runaway range).
  static const int maxDays = 400;

  /// [from]..[to] is the stretch of days to list (the screen starts at today
  /// and extends it by whole weeks). Today is never collapsed, so an empty
  /// "today" is still visible. A chore of a day before [today] that is still
  /// open belongs to the Overdue block, not to its own day.
  factory AgendaModel.build({
    required Iterable<ChoreItem> items,
    required DateKey today,
    required DateKey from,
    required DateKey to,
    CalendarFilters filters = CalendarFilters.none,
    CalendarScope scope = CalendarScope.all,
    String? viewerId,
    AvailabilityIndex availability = AvailabilityIndex.empty,
  }) {
    final builder = DaySummaryBuilder(
      today: today,
      scope: scope,
      viewerId: viewerId,
      filters: filters,
      availability: availability,
      heatMode: HeatMode.off,
    );
    final visible = builder.visibleByDay(items);

    final overdue = <ChoreItem>[
      for (final entry in visible.entries)
        if (entry.key.isBefore(today))
          for (final item in entry.value)
            if (_isLate(item)) item,
    ]..sort(_newestFirst);

    final entries = <AgendaEntry>[];
    if (overdue.isNotEmpty) {
      entries.add(
        AgendaOverdue(
          items: List<ChoreItem>.unmodifiable(overdue.take(overdueCap)),
          total: overdue.length,
        ),
      );
    }

    final last = from.daysUntil(to) >= maxDays ? from.addDays(maxDays - 1) : to;
    DateKey? freeFrom;
    DateKey? freeTo;
    void flushFree() {
      final start = freeFrom;
      final end = freeTo;
      if (start != null && end != null) {
        entries.add(AgendaFreeDays(from: start, to: end));
      }
      freeFrom = null;
      freeTo = null;
    }

    for (var day = from; !day.isAfter(last); day = day.addDays(1)) {
      final isToday = day == today;
      final dayItems = <ChoreItem>[
        for (final item in visible[day] ?? const <ChoreItem>[])
          if (!(day.isBefore(today) && _isLate(item))) item,
      ];
      if (dayItems.isEmpty && !isToday) {
        freeFrom ??= day;
        freeTo = day;
        continue;
      }
      flushFree();
      entries.add(
        AgendaDay(
          dateKey: day,
          isToday: isToday,
          items: List<ChoreItem>.unmodifiable(sortByDeadline(dayItems)),
          unavailableMemberIds: UnavailabilityOverlay.forDay(
            index: availability,
            day: day,
            scope: scope,
            viewerId: viewerId,
            filters: filters,
          ),
        ),
      );
    }
    flushFree();
    return AgendaModel(entries: List<AgendaEntry>.unmodifiable(entries));
  }

  final List<AgendaEntry> entries;

  /// The Overdue block, when there is one.
  AgendaOverdue? get overdue {
    for (final entry in entries) {
      if (entry is AgendaOverdue) return entry;
    }
    return null;
  }

  /// The entry that holds [day], for "jump to today".
  int? indexOfDay(DateKey day) {
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry is AgendaDay && entry.dateKey == day) return i;
      if (entry is AgendaFreeDays &&
          !day.isBefore(entry.from) &&
          !day.isAfter(entry.to)) {
        return i;
      }
    }
    return null;
  }

  /// Open work whose day has passed. The provider already marks a late chore
  /// `overdue`; a chore still `scheduled`/`in progress` on a past day (inside
  /// the grace window) is listed here too, because it is still undone.
  static bool _isLate(ChoreItem item) =>
      item.status == ChoreStatus.overdue || item.status.isOpen;

  static int _newestFirst(ChoreItem a, ChoreItem b) {
    final byDay = b.dateKey.compareTo(a.dateKey);
    if (byDay != 0) return byDay;
    final byDue = b.dueAt.compareTo(a.dueAt);
    return byDue != 0 ? byDue : a.id.compareTo(b.id);
  }
}
