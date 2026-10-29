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
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Marks somebody else's completed chore as verified (Appendix C).
///
/// Refused with `self_verification` when the actor completed it, with
/// `verification_not_required` when the snapshot says the chore does not need a
/// check, and with `not_completed` otherwise. The `verified` event is written in
/// the same batch, because the P3-13 rules prove it with `getAfter`.
///
/// Permission: `verifyChore(completer)` — the family switch AND the template
/// switch. EVERYDAY write.
class VerifyOccurrence {
  const VerifyOccurrence({
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

    final occurrence = context.occurrence;
    if (context.actor.isCompleter &&
        context.actor.uid == occurrence.completedBy) {
      return const Failure<ChoreOccurrence>(
        Conflict(code: 'self_verification'),
      );
    }
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.verifyChore,
      ownerId: occurrence.completedBy,
      template: permissionTemplateFor(occurrence.verification),
    );
    final denied = permitted.failureOrNull;
    if (denied != null) {
      return Failure<ChoreOccurrence>(
        occurrence.verification == VerificationMode.off
            ? const Conflict(code: 'verification_not_required')
            : denied,
      );
    }
    if (effectiveStatus(occurrence) == ChoreStatus.verified) {
      return const Failure<ChoreOccurrence>(Conflict(code: 'already_verified'));
    }
    final blocked = stateFailure(context, OccurrenceAction.verify);
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    final at = _clock.nowUtc();
    final patch = OccurrencePatch(
      occurrenceId: occurrenceId,
      fields: <String, Object?>{
        'status': OccurrenceStatus.verified.id,
        'verifiedAt': at,
        'verifiedBy': actorUid,
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
        type: OccurrenceEventType.verified,
      ),
      audit: const RequiredAudit(type: AuditEventType.choresOccurrenceVerified),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(applyOccurrencePatch(occurrence, patch));
  }
}
