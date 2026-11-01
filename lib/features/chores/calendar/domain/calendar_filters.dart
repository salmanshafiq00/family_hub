import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/search_text.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';

/// "Mine / Family" and the filter sheet (Appendix B.4), as ONE pure value.
///
/// Every field narrows the list; an empty set means "no restriction". Applying
/// it never reads anything but the items given, so switching scope or filters
/// costs no extra Firestore read (D-P3-8, CLAUDE.md rule 37).
final class CalendarFilters {
  const CalendarFilters({
    this.groupIds = const <String>{},
    this.statuses = const <ChoreStatus>{},
    this.memberIds = const <String>{},
    this.onlyNeedsAttention = false,
    this.query = '',
  });

  static const CalendarFilters none = CalendarFilters();

  final Set<String> groupIds;
  final Set<ChoreStatus> statuses;

  /// Assignees to show; an unassigned chore never matches a non-empty set.
  final Set<String> memberIds;
  final bool onlyNeedsAttention;

  /// Free text matched against the Bangla and English name.
  final String query;

  bool get isEmpty =>
      groupIds.isEmpty &&
      statuses.isEmpty &&
      memberIds.isEmpty &&
      !onlyNeedsAttention &&
      normalizeBn(query).isEmpty;

  /// How many filters are on (the badge on the filter button).
  int get activeCount =>
      (groupIds.isEmpty ? 0 : 1) +
      (statuses.isEmpty ? 0 : 1) +
      (memberIds.isEmpty ? 0 : 1) +
      (onlyNeedsAttention ? 1 : 0) +
      (normalizeBn(query).isEmpty ? 0 : 1);

  bool matches(ChoreItem item) {
    if (groupIds.isNotEmpty && !groupIds.contains(item.groupId)) return false;
    if (statuses.isNotEmpty && !statuses.contains(item.status)) return false;
    if (memberIds.isNotEmpty && !memberIds.contains(item.assigneeId)) {
      return false;
    }
    if (onlyNeedsAttention && !item.has(ChoreFlag.needsAttention)) {
      return false;
    }
    final needle = normalizeBn(query);
    if (needle.isEmpty) return true;
    return normalizeBn(item.nameBn).contains(needle) ||
        normalizeBn(item.nameEn ?? '').contains(needle);
  }

  /// The items that match, in the order given.
  List<ChoreItem> apply(Iterable<ChoreItem> items) => <ChoreItem>[
    for (final item in items)
      if (matches(item)) item,
  ];

  CalendarFilters copyWith({
    Set<String>? groupIds,
    Set<ChoreStatus>? statuses,
    Set<String>? memberIds,
    bool? onlyNeedsAttention,
    String? query,
  }) => CalendarFilters(
    groupIds: groupIds ?? this.groupIds,
    statuses: statuses ?? this.statuses,
    memberIds: memberIds ?? this.memberIds,
    onlyNeedsAttention: onlyNeedsAttention ?? this.onlyNeedsAttention,
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) =>
      other is CalendarFilters &&
      other.groupIds.length == groupIds.length &&
      other.groupIds.containsAll(groupIds) &&
      other.statuses.length == statuses.length &&
      other.statuses.containsAll(statuses) &&
      other.memberIds.length == memberIds.length &&
      other.memberIds.containsAll(memberIds) &&
      other.onlyNeedsAttention == onlyNeedsAttention &&
      other.query == query;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(groupIds),
    Object.hashAllUnordered(statuses),
    Object.hashAllUnordered(memberIds),
    onlyNeedsAttention,
    query,
  );
}

/// True when [item] belongs in [scope] for [viewerId].
///
/// "Mine" is the current assignee (a cover counts for whoever covers), the same
/// rule as the Today screen's `mineOnly`.
bool inScope(CalendarScope scope, String? viewerId, ChoreItem item) =>
    switch (scope) {
      CalendarScopeKind.all => true,
      CalendarScopeKind.mine => viewerId != null && item.assigneeId == viewerId,
    };
