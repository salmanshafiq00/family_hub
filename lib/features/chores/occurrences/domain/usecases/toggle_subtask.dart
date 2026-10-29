import 'package:family_hub/core/audit/audit_event_type.dart';
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

/// Ticks (or unticks) ONE subtask of a chore (P3-14, Appendix C).
///
/// Permission: `completeOwnChore(assignee)` for the assignee, else
/// `completeChoreForOthers` (an unassigned occurrence is always "somebody
/// else's", D-P3-14). The patch touches only `subtaskDone.<id>` plus the status
/// cache, so two phones ticking different boxes merge instead of overwriting
/// (D-P3-9).
///
/// Completing the last required step writes an `occurrence_completed` audit; an
/// untick that demotes a completed chore writes the `uncompleted` event that
/// keeps its original `completedAt`, so the history is never rewritten.
///
/// EVERYDAY write: it queues offline and the global banner shows it.
class ToggleSubtask {
  const ToggleSubtask({
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
    required String subtaskId,
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

    final blocked = stateFailure(context, OccurrenceAction.tickSubtask);
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    final at = _clock.nowUtc();
    final patch = SubtaskSync.toggleSubtask(
      occurrence: context.occurrence,
      subtaskId: subtaskId,
      actorId: actorUid,
      at: at,
    );
    final patchFailure = patch.failureOrNull;
    if (patchFailure != null) return Failure<ChoreOccurrence>(patchFailure);
    final change = patch.valueOrNull!;

    final before = effectiveStatus(context.occurrence);
    final updated = applyOccurrencePatch(context.occurrence, change);
    final after = effectiveStatus(updated);
    final completed =
        before != ChoreStatus.completed && after == ChoreStatus.completed;
    final demoted =
        before == ChoreStatus.completed && after != ChoreStatus.completed;

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: false,
      patch: change,
      event: demoted ? _uncompleted(context) : null,
      audit: completed
          ? const RequiredAudit(type: AuditEventType.choresOccurrenceCompleted)
          : demoted
          ? const RequiredAudit(
              type: AuditEventType.choresOccurrenceUncompleted,
            )
          : null,
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(updated);
  }

  /// The history entry an untick leaves behind (Appendix C: preserve the
  /// original completion).
  static NewEvent _uncompleted(OccurrenceContext context) => NewEvent(
    occurrenceId: context.occurrence.id,
    type: OccurrenceEventType.uncompleted,
    prevCompletedAt: context.occurrence.completedAt,
  );
}
