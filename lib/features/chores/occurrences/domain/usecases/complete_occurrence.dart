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

/// Completes a chore in one action (P3-14).
///
/// Unlike [ToggleParent] this does NOT tick the subtasks: it records the
/// completion with the REAL actor (`completedBy`, D-P3-14), which is what "done
/// by Dave for Cara" means, and it refuses with
/// `Conflict('required_subtasks_open')` while a required step is open and no
/// exception exists (Appendix C).
///
/// Permission: `completeOwnChore` for the assignee, else
/// `completeChoreForOthers`. EVERYDAY write.
class CompleteOccurrence {
  const CompleteOccurrence({
    required this._occurrences,
    required this._templates,
    required this._families,
    required this._dutyGroups,
    required this._settings,
    required this._dateKeys,
    required this._clock,
  });

  final OccurrenceRepository _occurrences;
  final TemplateRepository _templates;
  final FamilyRepository _families;
  final DutyGroupRepository _dutyGroups;
  final ChoreSettingsRepository _settings;
  final FamilyDateKeys _dateKeys;
  final Clock _clock;

  Future<Result<ChoreOccurrence>> call({
    required String familyId,
    required String actorUid,
    required String occurrenceId,
  }) async {
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

    final assignee = context.occurrence.assigneeId;
    final own = assignee != null && assignee == actorUid;
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: own
          ? Permission.completeOwnChore
          : Permission.completeChoreForOthers,
      ownerId: assignee,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<ChoreOccurrence>(denied);

    // Completing a COMPLETED chore is not an error to shout about: the ticks may
    // already have finished it (a parent box that fired twice, a retried tap),
    // so the call is idempotent and simply answers the current document.
    if (effectiveStatus(context.occurrence) == ChoreStatus.completed) {
      return Success<ChoreOccurrence>(context.occurrence);
    }
    final blocked = stateFailure(context, OccurrenceAction.checkParent);
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    final occurrence = context.occurrence;
    // Only a step marked REQUIRED can block a one-tap completion.
    final openRequired = occurrence.subtasks.where(
      (subtask) =>
          subtask.required && !occurrence.subtaskDone.containsKey(subtask.id),
    );
    if (openRequired.isNotEmpty && occurrence.exception == null) {
      return const Failure<ChoreOccurrence>(
        Conflict(code: 'required_subtasks_open'),
      );
    }

    final at = _clock.nowUtc();
    final fields = <String, Object?>{
      'status': OccurrenceStatus.completed.id,
      'completedAt': at,
      'completedBy': actorUid,
    };
    // A chore whose steps are all OPTIONAL is completed by checking the parent:
    // the steps it lists are ticked by this same completion (D-P3-9: the derived
    // status reads `completed` from the ticks, so the boxes stay truthful).
    if (!occurrence.subtasks.any((subtask) => subtask.required)) {
      for (final subtask in occurrence.subtasks) {
        if (occurrence.subtaskDone.containsKey(subtask.id)) continue;
        fields['subtaskDone.${subtask.id}'] = SubtaskDone(
          at: at,
          by: actorUid,
        ).toMap();
      }
    }
    final patch = OccurrencePatch(occurrenceId: occurrenceId, fields: fields);
    final forOther = !own;

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: false,
      patch: patch,
      audit: RequiredAudit(
        type: AuditEventType.choresOccurrenceCompleted,
        byMemberId: forOther ? actorUid : null,
      ),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(applyOccurrencePatch(occurrence, patch));
  }
}
