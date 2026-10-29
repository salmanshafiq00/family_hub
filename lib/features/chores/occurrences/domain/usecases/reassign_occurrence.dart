import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
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
import 'package:family_hub/features/notifications/domain/inbox_port.dart';

/// Moves one open chore to another member (Appendix C, `reassigned`).
///
/// [AssignOccurrence] (below) is the same use case for an occurrence that
/// nobody owns yet. The reason (3–300) is required and lands on the event that
/// authorises the change, together with the previous owner — so a later
/// "who moved it?" question has its answer even after the document changes.
///
/// The new owner must be an ACTIVE member of the family. The planned owner
/// (`plannedAssigneeId`) is untouched: the rotation still planned the original
/// person, and un-doing a manual assignment is a separate Reassign.
///
/// INTEGRITY write (server required, road map 3.4): moving an assignment while
/// offline would otherwise race a swap acceptance.
class ReassignOccurrence {
  const ReassignOccurrence({
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

  /// The stored document, for [AssignOccurrence] (which only starts when there
  /// is no owner yet).
  Future<Result<ChoreOccurrence?>> readCurrent(
    String familyId,
    String occurrenceId,
  ) => _occurrences.get(familyId, occurrenceId);

  Future<Result<ChoreOccurrence>> call({
    required String familyId,
    required String actorUid,
    required String occurrenceId,
    required String toMemberId,
    required String reason,
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

    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.reassignChore,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<ChoreOccurrence>(denied);

    final blocked = stateFailure(context, OccurrenceAction.reassign);
    if (blocked != null) return Failure<ChoreOccurrence>(blocked);

    final target = await _checkTarget(familyId, toMemberId);
    final targetFailure = target.failureOrNull;
    if (targetFailure != null) return Failure<ChoreOccurrence>(targetFailure);

    final occurrence = context.occurrence;
    if (occurrence.assigneeId == toMemberId) {
      return const Failure<ChoreOccurrence>(Conflict(code: 'already_assigned'));
    }

    final at = _clock.nowUtc();
    final patch = OccurrencePatch(
      occurrenceId: occurrenceId,
      fields: <String, Object?>{
        'assigneeId': toMemberId,
        'assignmentSource': AssignmentSource.reassign.id,
        'needsCover': false,
        'updatedAt': at,
        'updatedBy': actorUid,
      },
    );

    final staged = await OccurrenceActionWriter(_occurrences).stage(
      familyId,
      context,
      at: at,
      integrity: true,
      patch: patch,
      event: NewEvent(
        occurrenceId: occurrenceId,
        type: OccurrenceEventType.reassigned,
        reason: note,
        fromAssigneeId: occurrence.assigneeId,
        toAssigneeId: toMemberId,
      ),
      inbox: _inbox.choreReassigned(
        occurrenceId: occurrenceId,
        toMemberId: toMemberId,
        choreName: occurrence.nameBn,
        dateKey: occurrence.dateKey.toString(),
        byMemberId: actorUid,
      ),
      audit: RequiredAudit(
        type: AuditEventType.choresOccurrenceReassigned,
        reason: note,
        extra: <String, String>{
          if (occurrence.assigneeId != null) 'from': occurrence.assigneeId!,
          'to': toMemberId,
        },
      ),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(applyOccurrencePatch(occurrence, patch));
  }

  /// The new owner must be an active member of THIS family.
  Future<Result<void>> _checkTarget(String familyId, String memberId) async {
    final found = await _families.getMember(familyId, memberId);
    final failure = found.failureOrNull;
    if (failure != null) return Failure<void>(failure);
    final member = found.valueOrNull;
    if (member == null) return const Failure<void>(NotFound(entity: 'member'));
    if (!member.isActive) {
      return const Failure<void>(Conflict(code: 'member_unavailable'));
    }
    return const Success<void>(null);
  }
}
