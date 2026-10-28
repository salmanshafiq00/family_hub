import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/reassign_occurrence.dart';

/// Assigns an occurrence that has NO owner yet (a manual template, or a cover
/// that fell through).
///
/// Same permission (`reassignChore`), reason and event as [ReassignOccurrence];
/// the only difference is the state it starts from, so the whole transition
/// (validation, permission, target check, event, audit) is shared instead of
/// copied.
class AssignOccurrence {
  const AssignOccurrence({required this._reassign});

  final ReassignOccurrence _reassign;

  Future<Result<ChoreOccurrence>> call({
    required String familyId,
    required String actorUid,
    required String occurrenceId,
    required String toMemberId,
    required String reason,
  }) async {
    final current = await _reassign.readCurrent(familyId, occurrenceId);
    final readFailure = current.failureOrNull;
    if (readFailure != null) return Failure<ChoreOccurrence>(readFailure);
    if (current.valueOrNull?.assigneeId != null) {
      return const Failure<ChoreOccurrence>(Conflict(code: 'already_assigned'));
    }
    return _reassign(
      familyId: familyId,
      actorUid: actorUid,
      occurrenceId: occurrenceId,
      toMemberId: toMemberId,
      reason: reason,
    );
  }
}
