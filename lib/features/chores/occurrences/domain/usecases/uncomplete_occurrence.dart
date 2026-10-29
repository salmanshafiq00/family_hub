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

/// Undoes a completion ("Complete" tapped twice, or the undo of a swipe).
///
/// The chore returns to `in_progress` — its ticks are kept, because undoing a
/// COMPLETION is not the same as unticking every step — and an `uncompleted`
/// event keeps the original `completedAt`. A VERIFIED chore is frozen: a manager
/// must reopen it instead (`already_verified`).
///
/// Permission: the same as completing it. EVERYDAY write.
class UncompleteOccurrence {
  const UncompleteOccurrence({
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

    // "Not completed" is the more useful answer than the generic state code.
    if (effectiveStatus(context.occurrence) != ChoreStatus.completed) {
      return const Failure<ChoreOccurrence>(Conflict(code: 'not_completed'));
    }
    final blocked = stateFailure(context, OccurrenceAction.uncheckParent);
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    final at = _clock.nowUtc();
    final patch = OccurrencePatch(
      occurrenceId: occurrenceId,
      fields: <String, Object?>{
        'status': OccurrenceStatus.inProgress.id,
        'updatedAt': at,
        'updatedBy': actorUid,
      },
      removedFields: const <String>{'completedAt', 'completedBy'},
    );

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: false,
      patch: patch,
      event: NewEvent(
        occurrenceId: occurrenceId,
        type: OccurrenceEventType.uncompleted,
        prevCompletedAt: context.occurrence.completedAt,
      ),
      audit: const RequiredAudit(
        type: AuditEventType.choresOccurrenceUncompleted,
      ),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(
      applyOccurrencePatch(context.occurrence, patch),
    );
  }
}
