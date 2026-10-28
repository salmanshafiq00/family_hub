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
    requestId,
  );

  @override
  String toString() =>
      'OccurrenceEvent($id, ${type.id} on $occurrenceId by $actorId)';
}

/// The deterministic ids the rules can reconstruct from the document.
///
/// Lifecycle events carry the occurrence's `reopenCount` (so a second
/// completion after a reopen is a new event), assignment events carry the new
/// assignee (so a swap to a different person is a new event). The P3-14 use
/// cases generate these once per intent; a retry reuses the same id.
abstract final class OccurrenceEventIds {
  static String transition(OccurrenceEventType type, int reopenCount) =>
      '${type.id}_$reopenCount';

  static String assignment(OccurrenceEventType type, String assigneeId) =>
      '${type.id}_$assigneeId';
}
