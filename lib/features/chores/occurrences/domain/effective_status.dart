import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// What a screen shows for one occurrence (P3-11).
///
/// The truth is DERIVED, never the stored `status` field: [effectiveStatus] is
/// the only function that decides whether a chore is completed, and the stored
/// value is a cache the detail screen repairs when it opens (D-P3-9).
///
/// Priority order (road map P3-11):
/// 1. a skip reason or a stored `skipped` ⇒ [ChoreStatus.skipped];
/// 2. a verification timestamp ⇒ [ChoreStatus.verified];
/// 3. every member of the required set is ticked ⇒ [ChoreStatus.completed]
///    (a task without subtasks is completed by `completedAt`; a task finished
///    through an exception is completed by `completedAt` + `exception`);
/// 4. at least one current tick ⇒ [ChoreStatus.inProgress];
/// 5. otherwise [ChoreStatus.scheduled].
///
/// A stale `completedAt` whose required ticks were removed is IGNORED: the
/// occurrence is open again until it is repaired, never shown as completed.
ChoreStatus effectiveStatus(ChoreOccurrence occurrence) {
  if (occurrence.status == OccurrenceStatus.skipped ||
      occurrence.skipReason != null) {
    return ChoreStatus.skipped;
  }
  if (occurrence.verifiedAt != null) return ChoreStatus.verified;
  if (_countsAsCompleted(occurrence)) return ChoreStatus.completed;

  final hasTick = occurrence.subtasks.any(
    (subtask) => occurrence.subtaskDone.containsKey(subtask.id),
  );
  return hasTick ? ChoreStatus.inProgress : ChoreStatus.scheduled;
}

/// True when [now] is past `dueAt` + [graceMinutes] and the chore is still
/// open. Never stored, never auto-completed (Appendix C).
bool isOverdue(ChoreOccurrence occurrence, DateTime now, int graceMinutes) {
  if (!effectiveStatus(occurrence).isOpen) return false;
  final deadline = occurrence.dueAt.add(Duration(minutes: graceMinutes));
  return now.isAfter(deadline);
}

bool _countsAsCompleted(ChoreOccurrence occurrence) {
  if (occurrence.subtasks.isEmpty) return occurrence.completedAt != null;

  final required = occurrence.requiredSubtasks;
  final allTicked = required.every(
    (subtask) => occurrence.subtaskDone.containsKey(subtask.id),
  );
  if (allTicked) return true;

  // A manager may finish a chore with an open required step by recording an
  // exception; the exception alone (no completion) leaves the chore open.
  return occurrence.completedAt != null && occurrence.exception != null;
}
