import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/marker_policy.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// Everything one day cell (and the day panel header) needs, computed once.
///
/// A day outside the shown month carries NO chores, counts or markers
/// (D-P3-8): the grid dims it and costs no extra read.
final class DaySummary {
  const DaySummary({
    required this.dateKey,
    this.isToday = false,
    this.isOutsideMonth = false,
    this.total = 0,
    this.counts = const <ChoreStatus, int>{},
    this.markers = MarkerPick.none,
    this.mineCount = 0,
    this.heatLevel = 0,
    this.unavailableMemberIds = const <String>{},
    this.hasNeedsCover = false,
    this.hasNeedsAttention = false,
    this.hasProjectedOnly = false,
  });

  /// An empty, dimmed cell of a neighbouring month.
  const DaySummary.outside(DateKey dateKey, {bool isToday = false})
    : this(dateKey: dateKey, isToday: isToday, isOutsideMonth: true);

  /// The summary of [dateKey] for the chores that survived scope and filters.
  ///
  /// [mineCount] counts the viewer's own chores among the chores that passed
  /// the FILTERS (scope aside), so in "Family" scope a ring can still mark the
  /// days that hold something of mine.
  factory DaySummary.of({
    required DateKey dateKey,
    required bool isToday,
    required List<ChoreItem> visible,
    required int mineCount,
    required int heatLevel,
    required Set<String> unavailableMemberIds,
  }) {
    final counts = <ChoreStatus, int>{};
    var needsCover = false;
    var needsAttention = false;
    var projected = 0;
    for (final item in visible) {
      counts[item.status] = (counts[item.status] ?? 0) + 1;
      needsCover = needsCover || item.has(ChoreFlag.needsCover);
      needsAttention = needsAttention || item.has(ChoreFlag.needsAttention);
      if (item.isProjected) projected++;
    }
    return DaySummary(
      dateKey: dateKey,
      isToday: isToday,
      total: visible.length,
      counts: Map<ChoreStatus, int>.unmodifiable(counts),
      markers: MarkerPolicy.pick(visible),
      mineCount: mineCount,
      heatLevel: heatLevel,
      unavailableMemberIds: Set<String>.unmodifiable(unavailableMemberIds),
      hasNeedsCover: needsCover,
      hasNeedsAttention: needsAttention,
      hasProjectedOnly: visible.isNotEmpty && projected == visible.length,
    );
  }

  final DateKey dateKey;
  final bool isToday;
  final bool isOutsideMonth;

  /// Chores after scope and filters.
  final int total;

  /// [total] split by display status (absent key = zero).
  final Map<ChoreStatus, int> counts;

  /// The glyphs and the "+N" of the cell.
  final MarkerPick markers;

  /// The viewer's own chores that passed the filters.
  final int mineCount;

  /// 0 (no tint) … 4, from [HeatCalculator]; always 0 when heat is off.
  final int heatLevel;

  /// Members away that day, for the hatch and the day panel strip.
  final Set<String> unavailableMemberIds;

  /// Some chore of the day has nobody to do it.
  final bool hasNeedsCover;

  /// Some comment on a chore of the day asks for attention.
  final bool hasNeedsAttention;

  /// Every chore of the day is only planned (not written yet): drawn hatched.
  final bool hasProjectedOnly;

  bool get isEmpty => total == 0;

  int countOf(ChoreStatus status) => counts[status] ?? 0;

  @override
  bool operator ==(Object other) =>
      other is DaySummary &&
      other.dateKey == dateKey &&
      other.isToday == isToday &&
      other.isOutsideMonth == isOutsideMonth &&
      other.total == total &&
      _sameCounts(other.counts, counts) &&
      other.markers == markers &&
      other.mineCount == mineCount &&
      other.heatLevel == heatLevel &&
      other.unavailableMemberIds.length == unavailableMemberIds.length &&
      other.unavailableMemberIds.containsAll(unavailableMemberIds) &&
      other.hasNeedsCover == hasNeedsCover &&
      other.hasNeedsAttention == hasNeedsAttention &&
      other.hasProjectedOnly == hasProjectedOnly;

  @override
  int get hashCode => Object.hash(
    dateKey,
    isToday,
    isOutsideMonth,
    total,
    Object.hashAllUnordered(
      counts.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    markers,
    mineCount,
    heatLevel,
    Object.hashAllUnordered(unavailableMemberIds),
    hasNeedsCover,
    hasNeedsAttention,
    hasProjectedOnly,
  );

  static bool _sameCounts(Map<ChoreStatus, int> a, Map<ChoreStatus, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  String toString() => 'DaySummary($dateKey, total: $total)';
}
