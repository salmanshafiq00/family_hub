import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_reopen.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_state_machine.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action_writer.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_patch_apply.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';

/// Reopens a finished chore because something was wrong (Appendix C).
///
/// * a COMPLETED chore: any active member who may comment (`commentOnChore`);
/// * a VERIFIED chore: a manager only (`verified_requires_manager`).
///
/// The reason (3–300 characters) is required (D-P3-17), the original
/// `completedAt` moves to the `reopened` event, `reopenCount` grows by one, and
/// the assignee gets an inbox row through [InboxPort] (a no-op until P3-26).
///
/// B-04: reopening a chore WITH steps also says which steps to do again
/// ([redoSubtaskIds], all ticked ones by default) and UNTICKS them in the same
/// patch.  Without that the ticks stayed and the derived status still said
/// `completed`, so the button did nothing a person could see.
///
/// EVERYDAY write.
class ReopenOccurrence {
  const ReopenOccurrence({
    required this._occurrences,
    required this._templates,
    required this._families,
    required this._dateKeys,
    required this._clock,
    this._inbox = const NoopInboxPort(),
  });

  final OccurrenceRepository _occurrences;
  final TemplateRepository _templates;
  final FamilyRepository _families;
  final FamilyDateKeys _dateKeys;
  final Clock _clock;
  final InboxPort _inbox;

  /// One id per user intent (B-05): a retry reuses it, a second reopen gets a
  /// new one, so a create-only event can never collide.
  String _ids() => randomId();



  Future<Result<ChoreOccurrence>> call({
    required String familyId,
    required String actorUid,
    required String occurrenceId,
    required String reason,
    List<String>? redoSubtaskIds,
  }) async {
    final validated = requireReason(reason);
    final invalid = validated.failureOrNull;
    if (invalid != null) return Failure<ChoreOccurrence>(invalid);
    final note = validated.valueOrNull!;

    final loaded = await loadOccurrenceContext(
      occurrences: _occurrences,
      templates: _templates,
      families: _families,
      dateKeys: _dateKeys,
      familyId: familyId,
      occurrenceId: occurrenceId,
      actorUid: actorUid,
    );
    final loadFailure = loaded.failureOrNull;
    if (loadFailure != null) return Failure<ChoreOccurrence>(loadFailure);
    final context = loaded.valueOrNull!;
    final occurrence = context.occurrence;
    final status = effectiveStatus(occurrence);

    if (status == ChoreStatus.verified) {
      final manager = await requirePermission(
        _families,
        familyId: familyId,
        actorUid: actorUid,
        permission: Permission.manageChoreOccurrences,
      );
      final denied = manager.failureOrNull;
      if (denied != null) {
        return const Failure<ChoreOccurrence>(
          Conflict(code: 'verified_requires_manager'),
        );
      }
    } else {
      final commenter = await requirePermission(
        _families,
        familyId: familyId,
        actorUid: actorUid,
        permission: Permission.commentOnChore,
      );
      final denied = commenter.failureOrNull;
      if (denied != null) return Failure<ChoreOccurrence>(denied);
    }

    final blocked = stateFailure(context, OccurrenceAction.reopen);
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    final decided = OccurrenceReopen.plan(
      occurrence,
      requested: redoSubtaskIds,
    );
    final decisionFailure = decided.failureOrNull;
    if (decisionFailure != null) {
      return Failure<ChoreOccurrence>(decisionFailure);
    }
    final plan = decided.valueOrNull!;

    final at = _clock.nowUtc();
    final nextReopenCount = occurrence.reopenCount + 1;
    final patch = OccurrencePatch(
      occurrenceId: occurrenceId,
      fields: <String, Object?>{
        // The reopened chore is OPEN: `in_progress` even when the last tick was
        // just cleared (a `scheduled` chore would look like it never started).
        'status': OccurrenceStatus.inProgress.id,
        'reopenCount': nextReopenCount,
        'redoSubtaskIds': plan.redoSubtaskIds,
        'updatedAt': at,
        'updatedBy': actorUid,
      },
      removedFields: <String>{
        'completedAt',
        'completedBy',
        'verifiedAt',
        'verifiedBy',
        for (final step in plan.clearedSubtaskIds) 'subtaskDone.$step',
      },
    );
    final assignee = occurrence.assigneeId;

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: false,
      patch: patch,
      event: NewEvent(
        id: OccurrenceEventIds.of(OccurrenceEventType.reopened, _ids()),
        occurrenceId: occurrenceId,
        type: OccurrenceEventType.reopened,
        reason: note,
        prevCompletedAt: occurrence.completedAt,
        redoSubtaskIds: plan.redoSubtaskIds,
      ),
      inbox: assignee == null
          ? null
          : _inbox.choreReopened(
              occurrenceId: occurrenceId,
              toMemberId: assignee,
              choreName: occurrence.nameBn,
              dateKey: occurrence.dateKey.toString(),
              actorId: actorUid,
            ),
      audit: RequiredAudit(
        type: AuditEventType.choresOccurrenceReopened,
        reason: note,
        extra: const <String, String>{'prev': 'completed'},
      ),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(applyOccurrencePatch(occurrence, patch));
  }
}
