import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart'
    show isOverdueItem;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The items of one month (or of several months, merged), ready for the
/// calendar models: stored and projected chores in ONE list, the status already
/// the one a screen shows (overdue applied from the clock).
///
/// It has value equality on purpose. The clock ticks every minute, so the
/// provider that builds this value runs every minute; equal output stops that
/// rebuild before it reaches the month model, which therefore does not depend
/// on the wall clock (roadmap P3-21, CLAUDE rule 52).
final class MonthItems {
  MonthItems({required List<ChoreItem> items, required this.truncated})
    : items = List<ChoreItem>.unmodifiable(items);

  static final MonthItems empty = MonthItems(
    items: const <ChoreItem>[],
    truncated: false,
  );

  /// In `dateKey`, due time, slot, id order.
  final List<ChoreItem> items;

  /// True when the month listener hit its cap: chores may be missing.
  final bool truncated;

  @override
  bool operator ==(Object other) {
    if (other is! MonthItems || other.truncated != truncated) return false;
    if (other.items.length != items.length) return false;
    for (var i = 0; i < items.length; i++) {
      if (other.items[i] != items[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(truncated, Object.hashAll(items));

  @override
  String toString() => 'MonthItems(${items.length}, truncated: $truncated)';
}

/// The calendar order: the day, then the due time, then the slot, then the id
/// (so two chores with the same time never swap places between rebuilds).
int compareChoreItems(ChoreItem a, ChoreItem b) {
  final byDate = a.dateKey.compareTo(b.dateKey);
  if (byDate != 0) return byDate;
  final byDue = a.dueAt.compareTo(b.dueAt);
  if (byDue != 0) return byDue;
  final bySlot = (a.slotKey ?? '').compareTo(b.slotKey ?? '');
  if (bySlot != 0) return bySlot;
  return a.id.compareTo(b.id);
}

/// [item] with the status a screen shows: open and past its deadline plus
/// [graceMinutes] means [ChoreStatus.overdue] (never stored, Appendix C).
ChoreItem withDisplayStatus(ChoreItem item, DateTime now, int graceMinutes) =>
    isOverdueItem(item, now, graceMinutes)
    ? item.copyWith(status: ChoreStatus.overdue)
    : item;

/// Maps the data of [source]; loading and error carry over unchanged.
///
/// A value that exists wins over an error (a listener that failed AFTER its
/// first snapshot keeps showing what it has, rule 48).
AsyncValue<R> mapAsync<T, R>(AsyncValue<T> source, R Function(T value) map) {
  if (source.hasValue) return AsyncData<R>(map(source.requireValue));
  final error = source.error;
  if (error != null) {
    return AsyncError<R>(error, source.stackTrace ?? StackTrace.empty);
  }
  return AsyncLoading<R>();
}

/// Merges several months into one list, or reports the first month that is
/// still loading / has failed with nothing to show.
AsyncValue<MonthItems> combineMonths(List<AsyncValue<MonthItems>> months) {
  for (final month in months) {
    if (!month.hasValue) {
      return mapAsync<MonthItems, MonthItems>(month, (value) => value);
    }
  }
  final merged = <ChoreItem>[
    for (final month in months) ...month.requireValue.items,
  ]..sort(compareChoreItems);
  return AsyncData<MonthItems>(
    MonthItems(
      items: merged,
      truncated: months.any((month) => month.requireValue.truncated),
    ),
  );
}
