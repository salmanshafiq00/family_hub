import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// One stored lifecycle event (`choreOccurrences/{id}/events/{eventId}`).
///
/// Events are append-only history: they are never updated or deleted. The
/// document is written in the SAME batch as the occurrence change it explains,
/// so the timeline can never disagree with the state.
///
/// The event id is deterministic ([OccurrenceEventIds]) because the P3-13 rules
/// prove "the event exists in this batch" with `getAfter`, which needs a path.
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

  /// The steps a `reopened` event asked to redo (B-04); empty otherwise.
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
      other.redoSubtaskIds.length == redoSubtaskIds.length &&
      other.redoSubtaskIds.toSet().containsAll(redoSubtaskIds) &&
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
    Object.hashAllUnordered(redoSubtaskIds),
    requestId,
  );

  @override
  String toString() =>
      'OccurrenceEvent($id, ${type.id} on $occurrenceId by $actorId)';
}

/// The id of one lifecycle event (B-05).
///
/// Every event gets a UNIQUE random id, generated once per user intent and
/// reused by a retry of that same intent (CLAUDE.md rule 15).  The earlier
/// scheme (`<type>_<reopenCount>`, `<type>_<assignee>`) collided on the second
/// occurrence of a transition — untick → complete → untick, skip → unskip →
/// skip, reassign A→B→A→B — and, because events are create-only, rejected the
/// whole batch.  The rules no longer reconstruct the path: the patch names the
/// event with `lastEventId` and they check that document with `getAfter`.
///
/// Shape `<type>_<token>`: the type is readable in a log or a console, the
/// token keeps it unique (`^[a-z0-9]{8,20}$`, mirrored by the rules).
abstract final class OccurrenceEventIds {
  static String of(OccurrenceEventType type, String token) =>
      '${type.id}_$token';
}
