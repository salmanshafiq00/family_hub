import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_state_machine.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action_writer.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_patch_apply.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Lets a manager finish a chore whose required steps could not all be done
/// (Appendix C, `exception`).
///
/// It records the note + author on the occurrence and writes the `exception`
/// event with the same note; the completion itself is a separate action
/// (`CompleteOccurrence`/`ToggleParent`), which then accepts the open steps.
/// Only an occurrence WITHOUT an exception may receive one — a correction is a
/// new note after a reopen, never an overwrite of history.
///
/// Permission: `manageChoreOccurrences`. EVERYDAY write.
class RecordCompletionException {
  const RecordCompletionException({
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
    required String note,
  }) async {
    final validated = requireReason(note);
    final invalid = validated.failureOrNull;
    if (invalid != null) return Failure<ChoreOccurrence>(invalid);
    final reason = validated.valueOrNull!;

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

    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.manageChoreOccurrences,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<ChoreOccurrence>(denied);

    final blocked = stateFailure(context, OccurrenceAction.recordException);
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    final at = _clock.nowUtc();
    final patch = OccurrencePatch(
      occurrenceId: occurrenceId,
      fields: <String, Object?>{
        'exception': <String, Object?>{
          'note': reason,
          'by': actorUid,
          'at': at,
        },
        'updatedAt': at,
        'updatedBy': actorUid,
      },
    );

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: false,
      patch: patch,
      event: NewEvent(
        occurrenceId: occurrenceId,
        type: OccurrenceEventType.exception,
        reason: reason,
      ),
      audit: RequiredAudit(
        type: AuditEventType.choresOccurrenceException,
        reason: reason,
      ),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(
      applyOccurrencePatch(context.occurrence, patch),
    );
  }
}
