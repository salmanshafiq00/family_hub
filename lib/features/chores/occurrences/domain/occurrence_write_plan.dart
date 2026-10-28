/// The lifecycle event types (`choreOccurrences/{id}/events`).
///
/// Subtask ticks and the initial rotation assignment write NO event: the
/// document itself shows them. This is the closed list the P3-13 rules mirror.
enum OccurrenceEventType {
  covered('covered'),
  swapped('swapped'),
  reassigned('reassigned'),
  completed('completed'),
  uncompleted('uncompleted'),
  verified('verified'),
  reopened('reopened'),
  exception('exception'),
  skipped('skipped'),
  unskipped('unskipped');

  const OccurrenceEventType(this.id);

  final String id;
}

/// One dotted-key change to one occurrence.
///
/// Keys are Firestore dotted paths (`subtaskDone.step_1`, `status`,
/// `completedAt`, …) and the plan touches ONLY the keys it names, so two
/// devices editing different subtasks never overwrite each other. A key in
/// [removedFields] is deleted (Firestore `FieldValue.delete`), which is how an
/// untick and a cleared `completedAt` are expressed.
final class OccurrencePatch {
  const OccurrencePatch({
    required this.occurrenceId,
    this.fields = const <String, Object?>{},
    this.removedFields = const <String>{},
  });

  final String occurrenceId;
  final Map<String, Object?> fields;
  final Set<String> removedFields;

  bool get isEmpty => fields.isEmpty && removedFields.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is OccurrencePatch &&
      other.occurrenceId == occurrenceId &&
      _sameFields(other.fields, fields) &&
      other.removedFields.length == removedFields.length &&
      other.removedFields.containsAll(removedFields);

  @override
  int get hashCode => Object.hash(
    occurrenceId,
    Object.hashAllUnordered(<int>[
      for (final entry in fields.entries) Object.hash(entry.key, entry.value),
    ]),
    Object.hashAllUnordered(removedFields),
  );

  static bool _sameFields(Map<String, Object?> a, Map<String, Object?> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() =>
      'OccurrencePatch($occurrenceId, ${fields.length} fields, '
      '${removedFields.length} removed)';
}

/// A lifecycle event to append in the same batch as its patch.
final class NewEvent {
  const NewEvent({
    required this.occurrenceId,
    required this.type,
    this.fromAssigneeId,
    this.toAssigneeId,
    this.reason,
    this.prevCompletedAt,
    this.requestId,
  });

  final String occurrenceId;
  final OccurrenceEventType type;
  final String? fromAssigneeId;
  final String? toAssigneeId;

  /// Required for `reassigned`, `reopened`, `exception`, `skipped` (3–300).
  final String? reason;
  final DateTime? prevCompletedAt;
  final String? requestId;

  @override
  String toString() => 'NewEvent(${type.id} on $occurrenceId)';
}

/// An inbox row for another member (the real notification port arrives in
/// P3-26; the plan only carries the data so the write stays one batch).
final class NewInboxItem {
  const NewInboxItem({
    required this.toMemberId,
    required this.type,
    required this.refType,
    required this.refId,
    this.params = const <String, String>{},
  });

  final String toMemberId;

  /// One of `swap_request, swap_result, needs_cover, chore_reopened,
  /// comment_attention, verification_needed, absence_decision`.
  final String type;
  final String refType;
  final String refId;
  final Map<String, String> params;

  @override
  String toString() => 'NewInboxItem($type to $toMemberId)';
}

/// One audit/activity entry. The repository stamps the id, actor and time from
/// the plan, so the domain never needs a clock or an id generator.
final class NewAudit {
  const NewAudit({
    required this.type,
    required this.refId,
    this.params = const <String, String>{},
  });

  /// A key of `AuditEventType` (for example `chores.occurrence_completed`).
  final String type;

  /// The occurrence id.
  final String refId;
  final Map<String, String> params;

  @override
  String toString() => 'NewAudit($type, $refId)';
}

/// Everything ONE action writes, in ONE batch (road map 3.4).
///
/// The plan is plain data: the use cases build it, the P3-13 repository turns
/// it into a Firestore batch. Nothing here knows Firestore, which is what lets
/// the whole state machine be tested without an emulator.
final class OccurrenceWritePlan {
  const OccurrenceWritePlan({
    required this.actorId,
    required this.at,
    this.patches = const <OccurrencePatch>[],
    this.events = const <NewEvent>[],
    this.inbox = const <NewInboxItem>[],
    this.audits = const <NewAudit>[],
  });

  /// The real actor: `updatedBy`, the event `actorId` and the audit actor.
  final String actorId;

  /// The client clock instant of the action.
  final DateTime at;

  final List<OccurrencePatch> patches;
  final List<NewEvent> events;
  final List<NewInboxItem> inbox;
  final List<NewAudit> audits;

  bool get isEmpty =>
      patches.isEmpty && events.isEmpty && inbox.isEmpty && audits.isEmpty;

  @override
  String toString() =>
      'OccurrenceWritePlan(${patches.length} patches, '
      '${events.length} events, ${inbox.length} inbox, '
      '${audits.length} audits)';
}
