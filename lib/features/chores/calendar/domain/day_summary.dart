import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/marker_policy.dart';
import 'package:family_hub/features/chores/calendar/domain/member_load.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// The compact date-cell and selected-day summary, computed once.
///
/// A day outside the shown month carries NO chores, counts or member loads
/// (D-P3-8): the grid dims it and costs no extra read.
final class DaySummary {
  const DaySummary({
    required this.dateKey,
    this.isToday = false,
    this.isPast = false,
    this.isOutsideMonth = false,
    this.total = 0,
    this.counts = const <ChoreStatus, int>{},
    this.byMember = const <MemberLoad>[],
    this.mineCount = 0,
    this.unavailableMemberIds = const <String>{},
    this.hasNeedsCover = false,
    this.hasNeedsAttention = false,
    this.hasProjectedOnly = false,
  });

  /// An empty, dimmed cell of a neighbouring month.
  const DaySummary.outside(
    DateKey dateKey, {
    bool isToday = false,
    bool isPast = false,
  }) : this(
         dateKey: dateKey,
         isToday: isToday,
         isPast: isPast,
         isOutsideMonth: true,
       );

  /// The summary of [dateKey] for the chores that survived scope and filters.
  ///
  /// [mineCount] counts the viewer's own chores among chores that passed the
  /// filters (scope aside), so family scope can still describe their work.
  factory DaySummary.of({
    required DateKey dateKey,
    required bool isToday,
    required bool isPast,
    required List<ChoreItem> visible,
    required String? viewerId,
    required int mineCount,
    required Set<String> unavailableMemberIds,
  }) {
    final counts = <ChoreStatus, int>{};
    final byMember = <String?, int>{};
    var needsCover = false;
    var needsAttention = false;
    var projected = 0;
    for (final item in visible) {
      counts[item.status] = (counts[item.status] ?? 0) + 1;
      byMember[item.assigneeId] = (byMember[item.assigneeId] ?? 0) + 1;
      needsCover = needsCover || item.has(ChoreFlag.needsCover);
      needsAttention = needsAttention || item.has(ChoreFlag.needsAttention);
      if (item.isProjected) projected++;
    }
    final memberLoads = <MemberLoad>[
      for (final entry in byMember.entries)
        MemberLoad(memberId: entry.key, count: entry.value),
    ]..sort((a, b) => _compareMembers(a, b, viewerId));
    return DaySummary(
      dateKey: dateKey,
      isToday: isToday,
      isPast: isPast,
      total: visible.length,
      counts: Map<ChoreStatus, int>.unmodifiable(counts),
      byMember: List<MemberLoad>.unmodifiable(memberLoads),
      mineCount: mineCount,
      unavailableMemberIds: Set<String>.unmodifiable(unavailableMemberIds),
      hasNeedsCover: needsCover,
      hasNeedsAttention: needsAttention,
      hasProjectedOnly: visible.isNotEmpty && projected == visible.length,
    );
  }

  final DateKey dateKey;
  final bool isToday;
  final bool isPast;
  final bool isOutsideMonth;

  /// Chores after scope and filters.
  final int total;

  /// [total] split by display status (absent key = zero).
  final Map<ChoreStatus, int> counts;

  /// Chores grouped by assignee. The unassigned bucket has a null id.
  final List<MemberLoad> byMember;

  /// The viewer's own chores that passed the filters.
  final int mineCount;

  /// Members away that day, for the selected-day details and cell label.
  final Set<String> unavailableMemberIds;

  /// Some chore of the day has nobody to do it.
  final bool hasNeedsCover;

  /// Some comment on a chore of the day asks for attention.
  final bool hasNeedsAttention;

  /// Every chore of the day is only planned (not written yet).
  final bool hasProjectedOnly;

  bool get isEmpty => total == 0;

  int get doneCount =>
      countOf(ChoreStatus.completed) + countOf(ChoreStatus.verified);

  int get openCount =>
      countOf(ChoreStatus.scheduled) +
      countOf(ChoreStatus.inProgress) +
      countOf(ChoreStatus.overdue);

  int get skippedCount => countOf(ChoreStatus.skipped);

  ChoreStatus? get mostUrgent {
    ChoreStatus? mostUrgent;
    for (final entry in counts.entries) {
      if (entry.value > 0 &&
          (mostUrgent == null ||
              MarkerPolicy.urgencyRank(entry.key) <
                  MarkerPolicy.urgencyRank(mostUrgent))) {
        mostUrgent = entry.key;
      }
    }
    return mostUrgent;
  }

  int countOf(ChoreStatus status) => counts[status] ?? 0;

  @override
  bool operator ==(Object other) =>
      other is DaySummary &&
      other.dateKey == dateKey &&
      other.isToday == isToday &&
      other.isPast == isPast &&
      other.isOutsideMonth == isOutsideMonth &&
      other.total == total &&
      _sameCounts(other.counts, counts) &&
      _sameMemberLoads(other.byMember, byMember) &&
      other.mineCount == mineCount &&
      other.unavailableMemberIds.length == unavailableMemberIds.length &&
      other.unavailableMemberIds.containsAll(unavailableMemberIds) &&
      other.hasNeedsCover == hasNeedsCover &&
      other.hasNeedsAttention == hasNeedsAttention &&
      other.hasProjectedOnly == hasProjectedOnly;

  @override
  int get hashCode => Object.hash(
    dateKey,
    isToday,
    isPast,
    isOutsideMonth,
    total,
    Object.hashAllUnordered(
      counts.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    Object.hashAll(byMember),
    mineCount,
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

  static bool _sameMemberLoads(List<MemberLoad> a, List<MemberLoad> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _compareMembers(MemberLoad a, MemberLoad b, String? viewerId) {
    final aIsViewer = viewerId != null && a.memberId == viewerId;
    final bIsViewer = viewerId != null && b.memberId == viewerId;
    if (aIsViewer != bIsViewer) return aIsViewer ? -1 : 1;
    if (a.memberId == null) return b.memberId == null ? 0 : 1;
    if (b.memberId == null) return -1;
    return a.memberId!.compareTo(b.memberId!);
  }

  @override
  String toString() => 'DaySummary($dateKey, total: $total)';
}
