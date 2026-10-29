import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/firebase/audit_writer.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_event_mappers.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_mappers.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// Stages an [OccurrenceWritePlan] as ONE Firestore batch.
///
/// Split out of `FirestoreOccurrenceRepository` so the repository stays a file
/// about reads and ports, and the write staging (creates, restores, replans,
/// dotted-key patches, lifecycle events, inbox rows, audit entries) has exactly
/// one implementation.  A plan is plain data, so this class never decides
/// anything: the state machine lives in the use cases and the rules (P3-11).
abstract final class OccurrenceWriteStager {
  /// Stages every operation of [plan] on [batch].
  static void stage(
    BatchContext batch,
    String familyId,
    OccurrenceWritePlan plan,
  ) {
    final meta = BaseDocumentMetadata(
      createdAt: plan.at,
      createdBy: plan.actorId,
      updatedAt: plan.at,
      updatedBy: plan.actorId,
    );
    final docs = _Docs(familyId);

    for (final draft in plan.creates) {
      final occurrence = draft.toOccurrence();
      batch.set(
        docs.occurrence(occurrence.id),
        OccurrenceMappers.toMap(occurrence, meta),
      );
    }
    for (final draft in plan.restores) {
      batch.update(
        docs.occurrence(draft.id),
        OccurrenceMappers.restoreMap(
          draft.toOccurrence(),
          actorId: plan.actorId,
          at: plan.at,
        ),
      );
    }
    for (final replan in plan.replans) {
      batch.update(
        docs.occurrence(replan.occurrenceId),
        OccurrenceMappers.replanMap(replan, actorId: plan.actorId, at: plan.at),
      );
    }
    for (final patch in plan.patches) {
      if (patch.isEmpty) continue;
      batch.update(
        docs.occurrence(patch.occurrenceId),
        OccurrenceMappers.patchMap(patch, actorId: plan.actorId, at: plan.at),
      );
    }
    for (final event in plan.events) {
      batch.set(
        docs.event(event.occurrenceId, event.id),
        OccurrenceEventMappers.toMap(_event(event, plan), meta),
      );
    }
    for (final item in plan.inbox) {
      batch.set(docs.inbox(_rowId('inb_', item.id)), <String, dynamic>{
        'toMemberId': item.toMemberId,
        'type': item.type,
        'refType': item.refType,
        'refId': item.refId,
        'params': item.params,
        'readAt': null,
        'archivedAt': null,
        ...BaseMapper.metadataToMap(meta),
      });
    }
    for (final audit in plan.audits) {
      AuditWriter.write(
        batch,
        familyId,
        AuditEvent(
          id: _rowId('aud_', audit.id),
          type: audit.type,
          actorId: plan.actorId,
          refType: audit.refType,
          refId: audit.refId,
          at: plan.at,
          params: audit.params,
        ),
      );
    }
  }

  static OccurrenceEvent _event(NewEvent event, OccurrenceWritePlan plan) =>
      OccurrenceEvent(
        id: event.id,
        occurrenceId: event.occurrenceId,
        type: event.type,
        actorId: plan.actorId,
        at: plan.at,
        fromAssigneeId: event.fromAssigneeId,
        toAssigneeId: event.toAssigneeId,
        reason: event.reason,
        prevCompletedAt: event.prevCompletedAt,
        redoSubtaskIds: event.redoSubtaskIds,
        requestId: event.requestId,
      );

  /// The document id of an audit or inbox row: the intent's id, generated once
  /// by the use case that built the plan (B-10). Restaging the SAME plan (a
  /// retry) therefore writes the same path, never a second row.
  static String _rowId(String prefix, String id) {
    if (id.isEmpty) {
      throw StateError(
        'An audit/inbox id is generated once per intent; got an empty id.',
      );
    }
    return '$prefix$id';
  }
}

/// The one place the staged paths are built (they mirror the rules).
final class _Docs {
  const _Docs(this._familyId);

  final String _familyId;

  String occurrence(String id) =>
      FirestorePaths.choreOccurrenceDoc(_familyId, id);

  String event(String occurrenceId, String eventId) =>
      FirestorePaths.occurrenceEventDoc(_familyId, occurrenceId, eventId);

  String inbox(String id) => FirestorePaths.inboxDoc(_familyId, id);
}
