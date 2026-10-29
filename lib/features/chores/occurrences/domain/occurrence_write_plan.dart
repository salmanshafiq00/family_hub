import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';

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

  /// Tolerant read: an unknown event written by a newer build is ignored.
  static OccurrenceEventType? fromId(Object? id) {
    for (final type in values) {
      if (type.id == id) return type;
    }
    return null;
  }
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

  /// The same patch with one more written field (`lastEventId`, B-05).
  OccurrencePatch withField(String key, Object? value) => OccurrencePatch(
    occurrenceId: occurrenceId,
    fields: <String, Object?>{...fields, key: value},
    removedFields: removedFields,
  );

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
    this.id = '',
    required this.occurrenceId,
    required this.type,
    this.fromAssigneeId,
    this.toAssigneeId,
    this.reason,
    this.prevCompletedAt,
    this.redoSubtaskIds = const <String>[],
    this.requestId,
  });

  /// Unique event id, generated ONCE per user intent (B-05). Leave it empty and
  /// `OccurrenceActionWriter` fills it and records it as the patch's
  /// `lastEventId`, which is how the rules find the event.
  final String id;
  final String occurrenceId;
  final OccurrenceEventType type;
  final String? fromAssigneeId;
  final String? toAssigneeId;

  /// Required for `reassigned`, `reopened`, `exception`, `skipped` (3–300).
  final String? reason;
  final DateTime? prevCompletedAt;

  /// The steps a `reopened` event sent back to "not done" (B-04).
  final List<String> redoSubtaskIds;
  final String? requestId;

  NewEvent withId(String newId) => NewEvent(
    id: newId,
    occurrenceId: occurrenceId,
    type: type,
    fromAssigneeId: fromAssigneeId,
    toAssigneeId: toAssigneeId,
    reason: reason,
    prevCompletedAt: prevCompletedAt,
    redoSubtaskIds: redoSubtaskIds,
    requestId: requestId,
  );

  @override
  String toString() => 'NewEvent(${type.id} on $occurrenceId)';
}

/// An inbox row for another member (the real notification port arrives in
/// P3-26; the plan only carries the data so the write stays one batch).
final class NewInboxItem {
  const NewInboxItem({
    this.id = '',
    required this.toMemberId,
    required this.type,
    required this.refType,
    required this.refId,
    this.params = const <String, String>{},
  });

  /// The row's id, generated ONCE per intent (B-10). The stager writes
  /// `inb_$id`, so staging the same intent twice writes one row, never two.
  final String id;
  final String toMemberId;

  /// One of `swap_request, swap_result, needs_cover, chore_reopened,
  /// comment_attention, verification_needed, absence_decision`.
  final String type;
  final String refType;
  final String refId;
  final Map<String, String> params;

  NewInboxItem withId(String newId) => NewInboxItem(
    id: newId,
    toMemberId: toMemberId,
    type: type,
    refType: refType,
    refId: refId,
    params: params,
  );

  @override
  String toString() => 'NewInboxItem($type to $toMemberId)';
}

/// One audit/activity entry. The repository stamps the actor and time from the
/// plan, so the domain never needs a clock.
final class NewAudit {
  const NewAudit({
    this.id = '',
    required this.type,
    required this.refId,
    this.refType = AuditRefType.occurrence,
    this.params = const <String, String>{},
  });

  /// The row's id, generated ONCE per intent (B-10). The stager writes
  /// `aud_$id`, so staging the same intent twice writes one entry, never two.
  final String id;

  /// A key of `AuditEventType` (for example `chores.occurrence_completed`).
  final String type;

  /// The occurrence id, or the family/template id for a bulk event.
  final String refId;

  /// A key of `AuditRefType`; `occurrence` for the everyday actions.
  final String refType;
  final Map<String, String> params;

  NewAudit withId(String newId) => NewAudit(
    id: newId,
    type: type,
    refId: refId,
    refType: refType,
    params: params,
  );

  @override
  String toString() => 'NewAudit($type, $refType/$refId)';
}

/// A snapshot refresh of one existing occurrence (P3-12 replan).
///
/// The repository writes the draft's snapshot fields and `templateRev`; the
/// planned owner is replaced ONLY when [recomputeAssignment] is true, because a
/// manual assignment, a cover, a swap or a reassign is a human decision that a
/// template edit must never undo (D-P3-23).
final class OccurrenceReplan {
  const OccurrenceReplan({
    required this.occurrenceId,
    required this.draft,
    this.recomputeAssignment = true,
  });

  final String occurrenceId;
  final OccurrenceDraft draft;
  final bool recomputeAssignment;

  @override
  bool operator ==(Object other) =>
      other is OccurrenceReplan &&
      other.occurrenceId == occurrenceId &&
      other.draft == draft &&
      other.recomputeAssignment == recomputeAssignment;

  @override
  int get hashCode => Object.hash(occurrenceId, draft, recomputeAssignment);

  @override
  String toString() =>
      'OccurrenceReplan($occurrenceId, assignment: $recomputeAssignment)';
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
    this.creates = const <OccurrenceDraft>[],
    this.restores = const <OccurrenceDraft>[],
    this.replans = const <OccurrenceReplan>[],
    this.patches = const <OccurrencePatch>[],
    this.events = const <NewEvent>[],
    this.inbox = const <NewInboxItem>[],
    this.audits = const <NewAudit>[],
  });

  /// The real actor: `updatedBy`, the event `actorId` and the audit actor.
  final String actorId;

  /// The client clock instant of the action.
  final DateTime at;

  /// New documents (generation, materializing a projected item).
  final List<OccurrenceDraft> creates;

  /// Soft-deleted documents that match again (a resumed template).
  final List<OccurrenceDraft> restores;

  /// Snapshot refreshes of existing documents (template edit).
  final List<OccurrenceReplan> replans;

  final List<OccurrencePatch> patches;
  final List<NewEvent> events;
  final List<NewInboxItem> inbox;
  final List<NewAudit> audits;

  bool get isEmpty =>
      creates.isEmpty &&
      restores.isEmpty &&
      replans.isEmpty &&
      patches.isEmpty &&
      events.isEmpty &&
      inbox.isEmpty &&
      audits.isEmpty;

  @override
  String toString() =>
      'OccurrenceWritePlan(${creates.length} creates, '
      '${restores.length} restores, ${replans.length} replans, '
      '${patches.length} patches, ${events.length} events, '
      '${inbox.length} inbox, ${audits.length} audits)';
}
