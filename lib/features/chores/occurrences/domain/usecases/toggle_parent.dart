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
import 'package:family_hub/features/chores/occurrences/domain/subtask_sync.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action_writer.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_patch_apply.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// The parent checkbox of one chore (P3-14, Appendix C).
///
/// Checking ticks every open subtask and completes; unchecking is "undo
/// completion": every subtask is unticked, the completion is cleared, the
/// status returns to `scheduled` and an `uncompleted` event keeps the original
/// `completedAt`. A chore without subtasks uses this box as its only control.
///
/// Completing with an open REQUIRED step is refused with
/// `required_subtasks_open` unless a manager recorded an exception first.
/// Permission is the same as [ToggleSubtask].
///
/// EVERYDAY write.
class ToggleParent {
  const ToggleParent({
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

    final before = effectiveStatus(context.occurrence);
    final checking = before != ChoreStatus.completed;
    final blocked = stateFailure(
      context,
      checking ? OccurrenceAction.checkParent : OccurrenceAction.uncheckParent,
    );
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    // Checking the parent ticks EVERY step, so an all-optional chore completes
    // without an exception; only a REQUIRED step that is still open needs one
    // (SubtaskSync refuses it otherwise).
    final occurrence = context.occurrence;
    final required = occurrence.subtasks.where((subtask) => subtask.required);
    final openRequired = required.where(
      (subtask) => !occurrence.subtaskDone.containsKey(subtask.id),
    );
    if (checking && openRequired.isNotEmpty && occurrence.exception == null) {
      return const Failure<ChoreOccurrence>(
        Conflict(code: 'required_subtasks_open'),
      );
    }

    final at = _clock.nowUtc();
    final patch = SubtaskSync.toggleParent(
      occurrence: context.occurrence,
      actorId: actorUid,
      at: at,
    );
    final patchFailure = patch.failureOrNull;
    if (patchFailure != null) return Failure<ChoreOccurrence>(patchFailure);
    final change = patch.valueOrNull!;

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: false,
      patch: change,
      event: checking ? null : _uncompleted(context),
      audit: RequiredAudit(
        type: checking
            ? AuditEventType.choresOccurrenceCompleted
            : AuditEventType.choresOccurrenceUncompleted,
      ),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(
      applyOccurrencePatch(context.occurrence, change),
    );
  }

  static NewEvent _uncompleted(OccurrenceContext context) => NewEvent(
    occurrenceId: context.occurrence.id,
    type: OccurrenceEventType.uncompleted,
    prevCompletedAt: context.occurrence.completedAt,
  );
}
