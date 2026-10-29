import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_state_machine.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action_writer.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_patch_apply.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
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
/// B-04: a chore with steps is only open again when steps are UNTICKED (its
/// completion is derived from the ticks), so the same patch removes the ticks of
/// the steps to redo — by default every required step, or the ids passed in
/// `redoSubtaskIds`. Choosing only optional steps would change nothing visible
/// and is refused with `Validation('redoSubtaskIds', 'pick_required_step')`.
///
/// EVERYDAY write.
class ReopenOccurrence {
  const ReopenOccurrence({
    required this._occurrences,
    required this._templates,
    required this._families,
    required this._dutyGroups,
    required this._settings,
    required this._dateKeys,
    required this._clock,
    this._inbox = const NoopInboxPort(),
  });

  final OccurrenceRepository _occurrences;
  final TemplateRepository _templates;
  final FamilyRepository _families;
  final DutyGroupRepository _dutyGroups;
  final ChoreSettingsRepository _settings;
  final FamilyDateKeys _dateKeys;
  final Clock _clock;
  final InboxPort _inbox;

  Future<Result<ChoreOccurrence>> call({
    required String familyId,
    required String actorUid,
    required String occurrenceId,
    required String reason,
    Set<String>? redoSubtaskIds,
  }) async {
    final validated = requireReason(reason);
    final invalid = validated.failureOrNull;
    if (invalid != null) return Failure<ChoreOccurrence>(invalid);
    final note = validated.valueOrNull!;

    final loaded = await loadOccurrenceContext(
      occurrences: _occurrences,
      templates: _templates,
      families: _families,
      dutyGroups: _dutyGroups,
      choreSettings: _settings,
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

    final redo = _stepsToRedo(occurrence, redoSubtaskIds);
    final at = _clock.nowUtc();
    final nextReopenCount = occurrence.reopenCount + 1;
    final patch = OccurrencePatch(
      occurrenceId: occurrenceId,
      fields: <String, Object?>{
        'status': OccurrenceStatus.inProgress.id,
        'reopenCount': nextReopenCount,
        'updatedAt': at,
        'updatedBy': actorUid,
      },
      removedFields: <String>{
        'completedAt',
        'completedBy',
        'verifiedAt',
        'verifiedBy',
        for (final id in redo) 'subtaskDone.$id',
      },
    );
    if (occurrence.subtasks.isNotEmpty &&
        effectiveStatus(applyOccurrencePatch(occurrence, patch)) ==
            ChoreStatus.completed) {
      // The chosen steps leave every required step ticked: it would still read
      // as completed, so the reopen would do nothing the person can see.
      return const Failure<ChoreOccurrence>(
        Validation('redoSubtaskIds', 'pick_required_step'),
      );
    }
    final assignee = occurrence.assigneeId;

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: false,
      patch: patch,
      event: NewEvent(
        occurrenceId: occurrenceId,
        type: OccurrenceEventType.reopened,
        reason: note,
        prevCompletedAt: occurrence.completedAt,
        redoSubtaskIds: redo,
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

  /// The ticked steps a reopen clears: [chosen] (only ids that exist and are
  /// ticked), else every ticked required step.
  static List<String> _stepsToRedo(
    ChoreOccurrence occurrence,
    Set<String>? chosen,
  ) {
    final candidates = chosen == null
        ? occurrence.requiredSubtasks.map((subtask) => subtask.id)
        : occurrence.subtasks
              .map((subtask) => subtask.id)
              .where(chosen.contains);
    return <String>[
      for (final id in candidates)
        if (occurrence.subtaskDone.containsKey(id)) id,
    ];
  }
}
