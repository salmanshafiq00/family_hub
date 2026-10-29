import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// What one "Reopen" decided: which steps must be done again (B-04).
///
/// Reopening a chore with steps used to clear only `completedAt/By`, while the
/// ticks stayed — so `effectiveStatus` still said **completed** and the screen
/// showed nothing.  The decision is now explicit and travels in the SAME patch
/// as the ticks it removes, so the derived status can never disagree with it:
///
/// * [redoSubtaskIds] — the steps to do again (all ticked ones by default),
///   stored on the document and on the `reopened` event;
/// * [clearedSubtaskIds] — the ticks the patch removes, beside the completion
///   and verification pair.
final class ReopenPlan {
  const ReopenPlan({
    required this.redoSubtaskIds,
    required this.clearedSubtaskIds,
  });

  final List<String> redoSubtaskIds;
  final List<String> clearedSubtaskIds;

  bool get clearsAnything => clearedSubtaskIds.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is ReopenPlan &&
      other.redoSubtaskIds.length == redoSubtaskIds.length &&
      other.redoSubtaskIds.toSet().containsAll(redoSubtaskIds) &&
      other.clearedSubtaskIds.length == clearedSubtaskIds.length &&
      other.clearedSubtaskIds.toSet().containsAll(clearedSubtaskIds);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(redoSubtaskIds),
    Object.hashAllUnordered(clearedSubtaskIds),
  );

  @override
  String toString() =>
      'ReopenPlan(redo: $redoSubtaskIds, cleared: $clearedSubtaskIds)';
}

/// The reopen rule of road map Appendix C, as one pure function.
///
/// [requested] is the checklist the person confirmed (null = "all of them").
/// Only CURRENT subtasks count: a stale tick left by a replan is already
/// ignored by [effectiveStatus], so it needs no decision.  Asking to redo a step
/// the chore does not have is refused (`concurrent_edit`) instead of being
/// silently dropped — the snapshot changed under the screen.
abstract final class OccurrenceReopen {
  /// The steps a person may tick in the reopen sheet: the ones done right now.
  static List<String> redoCandidates(ChoreOccurrence occurrence) => <String>[
    for (final subtask in occurrence.subtasks)
      if (occurrence.subtaskDone.containsKey(subtask.id)) subtask.id,
  ];

  /// The steps the reopen will untick, or the failure that stops it.
  static Result<ReopenPlan> plan(
    ChoreOccurrence occurrence, {
    List<String>? requested,
  }) {
    if (effectiveStatus(occurrence) == ChoreStatus.verified) {
      return const Failure<ReopenPlan>(Conflict(code: 'already_verified'));
    }
    final ticked = redoCandidates(occurrence);
    if (requested == null) {
      return Success<ReopenPlan>(
        ReopenPlan(redoSubtaskIds: ticked, clearedSubtaskIds: ticked),
      );
    }
    final wanted = <String>{...requested};
    final known = <String>{for (final subtask in occurrence.subtasks) subtask.id};
    if (wanted.difference(known).isNotEmpty) {
      return const Failure<ReopenPlan>(Conflict(code: 'concurrent_edit'));
    }
    final planned = <String>[
      for (final subtask in occurrence.subtasks)
        if (wanted.contains(subtask.id)) subtask.id,
    ];
    final cleared = <String>[
      for (final step in planned)
        if (occurrence.subtaskDone.containsKey(step)) step,
    ];
    return Success<ReopenPlan>(
      ReopenPlan(redoSubtaskIds: planned, clearedSubtaskIds: cleared),
    );
  }
}
