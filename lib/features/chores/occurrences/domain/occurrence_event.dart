import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// One stored lifecycle event (`choreOccurrences/{id}/events/{eventId}`).
///
/// Events are append-only history: they are never updated or deleted. The
/// document is written in the SAME batch as the occurrence change it explains,
/// so the timeline can never disagree with the state.
///
/// The event id is UNIQUE per user intent (B-05, generated once by
/// `OccurrenceActionWriter`) and the occurrence names it in `lastEventId`, so the
/// P3-13 rules can prove "this event was created in this batch" with
/// `getAfter`. The old `type_reopenCount` / `type_assignee` scheme collided on
/// the second identical transition (complete-untick-complete-untick, skip-
/// unskip-skip, A-B-A reassign), and events are create-only.
final class OccurrenceEvent {
  const OccurrenceEvent({
    required this.id,
    required this.occurrenceId,
    required this.type,
    required this.actorId,
    required this.at,
    this.fromAssigneeId,
    this.toAssigneeId,
    this.reason,
    this.prevCompletedAt,
    this.redoSubtaskIds = const <String>[],
    this.requestId,
  });

  final String id;
  final String occurrenceId;
  final OccurrenceEventType type;
  final String actorId;

  /// The client instant of the action (the server time is the document's
  /// `createdAt` metadata, written from the same plan).
  final DateTime at;

  final String? fromAssigneeId;
  final String? toAssigneeId;
  final String? reason;

  /// The completion this reopen cleared, so the history keeps it.
  final DateTime? prevCompletedAt;

  /// The steps a reopen sent back to "not done" (B-04), so the timeline can
  /// say which ones to do again.
  final List<String> redoSubtaskIds;

  /// The accepted swap/cover request that authorised an assignee change.
  final String? requestId;

  @override
  bool operator ==(Object other) =>
      other is OccurrenceEvent &&
      other.id == id &&
      other.occurrenceId == occurrenceId &&
      other.type == type &&
      other.actorId == actorId &&
      other.at == at &&
      other.fromAssigneeId == fromAssigneeId &&
      other.toAssigneeId == toAssigneeId &&
      other.reason == reason &&
      other.prevCompletedAt == prevCompletedAt &&
      _sameList(other.redoSubtaskIds, redoSubtaskIds) &&
      other.requestId == requestId;

  @override
  int get hashCode => Object.hash(
    id,
    occurrenceId,
    type,
    actorId,
    at,
    fromAssigneeId,
    toAssigneeId,
    reason,
    prevCompletedAt,
    Object.hashAll(redoSubtaskIds),
    requestId,
  );

  static bool _sameList(List<String> a, List<String> b) =>
      a.length == b.length && a.toSet().containsAll(b);

  @override
  String toString() =>
      'OccurrenceEvent($id, ${type.id} on $occurrenceId by $actorId)';
}
