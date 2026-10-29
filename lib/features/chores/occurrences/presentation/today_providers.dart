import 'dart:async';

import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/verify_queue_filter.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A minute ticker, watched ONLY by screens that show "overdue" (road map 3.5).
///
/// It emits once a minute while at least one screen listens and stops as soon as
/// the last one goes away (`autoDispose`), so a backgrounded calendar never
/// wakes the phone. The month model does NOT watch it: a list rebuild must not
/// depend on the wall clock.
final nowTickProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield ref.watch(clockProvider).nowUtc();
  yield* Stream<DateTime>.periodic(
    const Duration(minutes: 1),
    (_) => ref.read(clockProvider).nowUtc(),
  );
});

/// The current instant, from the ticker when it runs and from the clock before.
final nowProvider = Provider<DateTime>((ref) {
  final tick = ref.watch(nowTickProvider).value;
  return tick ?? ref.watch(clockProvider).nowUtc();
});

/// Today's [ChoreItem]s for one day, with the status a screen shows.
///
/// Reads the ONE month listener of that day's month (D-P3-8): no extra query,
/// and "mine / family" is a filter over the same list. Soft-deleted documents
/// never reach here (filtered once in `MonthOccurrences`).
final dayItemsProvider = Provider.family<List<ChoreItem>, DateKey>((ref, day) {
  final month = ref.watch(monthOccurrencesProvider(day.monthKey));
  final grace = ref.watch(choreSettingsProvider).overdueGraceMinutes;
  final now = ref.watch(nowProvider);
  final documents = month.value?.items ?? const <ChoreOccurrence>[];
  return <ChoreItem>[
    for (final occurrence in documents)
      if (occurrence.dateKey == day)
        ChoreItem.fromOccurrence(occurrence)
            ._withOverdue(occurrence, now, grace),
  ]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
});

/// Today's items, whichever day the family zone says it is.
final todayItemsProvider = Provider<List<ChoreItem>>(
  (ref) =>
      ref.watch(dayItemsProvider(ref.watch(familyDateKeysProvider).today())),
);

/// The items assigned to [memberId] (or nobody, when [memberId] is null).
List<ChoreItem> mineOnly(List<ChoreItem> items, String? memberId) =>
    <ChoreItem>[
      for (final item in items)
        if (item.assigneeId != null && item.assigneeId == memberId) item,
    ];

/// Open items whose deadline (plus grace) has passed, oldest deadline first.
final overdueItemsProvider = Provider<List<ChoreItem>>((ref) {
  final now = ref.watch(nowProvider);
  final grace = ref.watch(choreSettingsProvider).overdueGraceMinutes;
  return <ChoreItem>[
    for (final item in ref.watch(todayItemsProvider))
      if (isOverdueItem(item, now, grace)) item,
  ]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
});

/// "Overdue" for a [ChoreItem]: still open and past `dueAt` + grace.
bool isOverdueItem(ChoreItem item, DateTime now, int graceMinutes) =>
    item.status.isOpen &&
    now.isAfter(item.dueAt.add(Duration(minutes: graceMinutes)));

/// How far through today's chores the family (or one member) is.
final class TodayProgress {
  const TodayProgress({required this.done, required this.total});

  static const TodayProgress empty = TodayProgress(done: 0, total: 0);

  final int done;
  final int total;

  /// True when there is something to celebrate (and something to show).
  bool get isComplete => total > 0 && done >= total;
}

/// Progress of one day; the dashboard (P3-29) and Today share it, so their
/// numbers can never disagree.
final todayProgressProvider = Provider<TodayProgress>((ref) {
  final items = ref.watch(todayItemsProvider);
  var done = 0;
  for (final item in items) {
    if (item.status == ChoreStatus.completed ||
        item.status == ChoreStatus.verified) {
      done++;
    }
  }
  return TodayProgress(done: done, total: items.length);
});

/// One [ChoreItem] for an id, from the month listener when the month is loaded,
/// else from the single-document listener (a deep link into an old month).
final occurrenceItemProvider = Provider.family<ChoreItem?, String>((ref, id) {
  final document = ref.watch(occurrenceProvider(id)).value;
  final month = document == null
      ? null
      : ref.watch(monthOccurrencesProvider(document.monthKey)).value;
  final now = ref.watch(nowProvider);
  final grace = ref.watch(choreSettingsProvider).overdueGraceMinutes;
  final fromMonth = month?.items.where((o) => o.id == id).firstOrNull;
  final occurrence = fromMonth ?? document;
  if (occurrence == null) return null;
  return ChoreItem.fromOccurrence(occurrence)
      ._withOverdue(occurrence, now, grace);
});

/// The manager's verification queue (B-03): only chores whose snapshot requires
/// a check, whose DERIVED status is completed and that the viewer did not
/// complete themselves - see `verifiableOccurrences`.
final verifyItemsProvider = Provider<List<ChoreItem>>((ref) {
  final uid = ref.watch(currentUidProvider);
  final now = ref.watch(nowProvider);
  final grace = ref.watch(choreSettingsProvider).overdueGraceMinutes;
  final documents =
      ref.watch(verifyQueueProvider).value ?? const <ChoreOccurrence>[];
  return <ChoreItem>[
    for (final occurrence in verifiableOccurrences(documents, viewerUid: uid))
      ChoreItem.fromOccurrence(occurrence)._withOverdue(occurrence, now, grace),
  ]..sort((a, b) => a.dueAt.compareTo(b.dueAt));
});

/// How many chores wait for a check (a badge, capped by the query limit).
final verifyQueueCountProvider = Provider<int>(
  (ref) => ref.watch(verifyItemsProvider).length.clamp(0, kMaxVerifyQueue),
);

/// The smallest extension needed to show "overdue" on a [ChoreItem].
///
/// `ChoreItem` stores the DERIVED status; `overdue` is the one state that needs
/// the clock, so it is applied here (never stored, never in a domain model that
/// the calendar shares across days).
extension OverdueItem on ChoreItem {
  ChoreItem _withOverdue(
    ChoreOccurrence occurrence,
    DateTime now,
    int graceMinutes,
  ) {
    if (!isOverdue(occurrence, now, graceMinutes)) return this;
    return ChoreItem(
      id: id,
      templateId: templateId,
      templateRev: templateRev,
      dateKey: dateKey,
      monthKey: monthKey,
      dueAt: dueAt,
      nameBn: nameBn,
      subtasks: subtasks,
      status: ChoreStatus.overdue,
      flags: flags,
      progress: progress,
      isProjected: isProjected,
      slotKey: slotKey,
      dueMinutes: dueMinutes,
      nameEn: nameEn,
      groupId: groupId,
      instructions: instructions,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      verification: verification,
      assigneeId: assigneeId,
      plannedAssigneeId: plannedAssigneeId,
    );
  }
}
