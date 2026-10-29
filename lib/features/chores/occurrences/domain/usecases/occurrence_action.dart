import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/core/permissions/permission_settings.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_generator.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_id.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_state_machine.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/member.dart';

/// What one action needs to know about the occurrence and the actor, loaded
/// once from the current state (P3-14).
///
/// Every completion use case starts here, so "the document is missing but a
/// template still implies it" is materialized the same way everywhere (D-P3-6)
/// and the [OccurrenceActor] value the state machine sees can never differ
/// between two actions on the same occurrence.
final class OccurrenceContext {
  const OccurrenceContext({
    required this.occurrence,
    required this.actor,
    required this.member,
    this.draft,
  });

  /// The stored document, or the generator's draft for a PROJECTED item.
  final ChoreOccurrence occurrence;

  /// The pure actor value of [OccurrenceStateMachine].
  final OccurrenceActor actor;

  /// The acting member document (names for the audit params).
  final Member member;

  /// The create to stage with the action; null when the document exists.
  final OccurrenceDraft? draft;

  bool get isProjected => draft != null;

  /// Builds the context from an occurrence, a member and the family switches.
  factory OccurrenceContext.build({
    required ChoreOccurrence occurrence,
    required Member member,
    required PermissionSettings settings,
    OccurrenceDraft? draft,
  }) => OccurrenceContext(
    occurrence: occurrence,
    draft: draft,
    member: member,
    actor: OccurrenceActor(
      uid: member.uid,
      isManager:
          settings.isModuleEnabled(PermissionModule.chores) &&
          member.permissionActor.isManager,
      // A chore nobody owns yet counts its PLANNED owner as the assignee: the
      // rotation already decided whose turn it is (D-P3-12). Without this a
      // projected item with `assigneeId == null` would only accept a manager.
      isAssignee:
          (occurrence.assigneeId ?? occurrence.plannedAssigneeId) == member.uid,
      canCompleteForOthers: settings.membersCanCompleteForOthers,
      isCompleter:
          occurrence.completedBy != null &&
          occurrence.completedBy == member.uid,
    ),
  );
}

PermissionTemplate permissionTemplateFor(VerificationMode mode) =>
    PermissionTemplate(verificationEnabled: mode == VerificationMode.required);

/// Loads the occurrence an action is about.
///
/// Order: the stored document (`get`), else the template's current snapshot for
/// that exact id (a projected day, D-P3-6), else `NotFound`.
///
/// The projected draft is built with the SAME inputs `EnsureOccurrences` uses
/// (duty groups, absence policy, roster, availability), so the owner of a
/// projected day and the owner of the document the first action materializes
/// can never differ (B-08).
Future<Result<OccurrenceContext>> loadOccurrenceContext({
  required OccurrenceRepository occurrences,
  required TemplateRepository templates,
  required FamilyRepository families,
  required DutyGroupRepository dutyGroups,
  required ChoreSettingsRepository choreSettings,
  required FamilyDateKeys dateKeys,
  required String familyId,
  required String occurrenceId,
  required String actorUid,
  AvailabilityIndex availabilityIndex = AvailabilityIndex.empty,
}) async {
  final loadedMember = await families.getMember(familyId, actorUid);
  final memberFailure = loadedMember.failureOrNull;
  if (memberFailure != null) {
    return Failure<OccurrenceContext>(memberFailure);
  }
  final member = loadedMember.valueOrNull;
  if (member == null) {
    return const Failure<OccurrenceContext>(NotFound(entity: 'member'));
  }

  final loadedSettings = await families.getPermissionSettings(familyId);
  final settingsFailure = loadedSettings.failureOrNull;
  if (settingsFailure != null) {
    return Failure<OccurrenceContext>(settingsFailure);
  }
  final permissions = loadedSettings.valueOrNull ?? PermissionSettings.defaults;

  final stored = await occurrences.get(familyId, occurrenceId);
  final readFailure = stored.failureOrNull;
  if (readFailure != null) return Failure<OccurrenceContext>(readFailure);
  final document = stored.valueOrNull;
  if (document != null) {
    if (document.isDeleted) {
      return const Failure<OccurrenceContext>(
        Conflict(code: 'occurrence_deleted'),
      );
    }
    return Success<OccurrenceContext>(
      OccurrenceContext.build(
        occurrence: document,
        member: member,
        settings: permissions,
      ),
    );
  }

  final roster = await families.getMembers(familyId);
  final rosterFailure = roster.failureOrNull;
  if (rosterFailure != null) return Failure<OccurrenceContext>(rosterFailure);
  final loadedGroups = await dutyGroups.list(familyId);
  final groupsFailure = loadedGroups.failureOrNull;
  if (groupsFailure != null) {
    return Failure<OccurrenceContext>(groupsFailure);
  }
  final loadedPolicy = await choreSettings.getAbsencePolicy(familyId);
  final policyFailure = loadedPolicy.failureOrNull;
  if (policyFailure != null) {
    return Failure<OccurrenceContext>(policyFailure);
  }
  final projected = await _draftFor(
    occurrenceId: occurrenceId,
    templates: templates,
    familyId: familyId,
    dateKeys: dateKeys,
    dutyGroups: loadedGroups.valueOrNull ?? const <DutyGroup>[],
    policy: loadedPolicy.valueOrNull ?? AbsencePolicy.askCover,
    members: roster.valueOrNull ?? const <Member>[],
    availabilityIndex: availabilityIndex,
  );
  final draftFailure = projected.failureOrNull;
  if (draftFailure != null) {
    return Failure<OccurrenceContext>(draftFailure);
  }
  final draft = projected.valueOrNull;
  if (draft == null) {
    return const Failure<OccurrenceContext>(NotFound(entity: 'occurrence'));
  }
  // A projected item that an approved absence already covers is UNASSIGNED
  // (D-P3-12) and counts as "somebody else's": the state machine only accepts a
  // manager until a cover/assignment gives it an owner.
  return Success<OccurrenceContext>(
    OccurrenceContext.build(
      occurrence: draft.toOccurrence(),
      member: member,
      settings: permissions,
      draft: draft,
    ),
  );
}

/// One draft for the requested id, when the template still implies it.
Future<Result<OccurrenceDraft?>> _draftFor({
  required String occurrenceId,
  required TemplateRepository templates,
  required String familyId,
  required FamilyDateKeys dateKeys,
  required List<DutyGroup> dutyGroups,
  required AbsencePolicy policy,
  required List<Member> members,
  required AvailabilityIndex availabilityIndex,
}) async {
  final parsed = OccurrenceId.parse(occurrenceId).valueOrNull;
  if (parsed == null) return const Success<OccurrenceDraft?>(null);

  final found = await templates.get(familyId, parsed.templateId);
  final failure = found.failureOrNull;
  if (failure != null) return Failure<OccurrenceDraft?>(failure);
  final template = found.valueOrNull?.template;
  if (template == null) return const Success<OccurrenceDraft?>(null);

  final drafts = OccurrenceGenerator.drafts(
    templates: <ChoreTemplate>[template],
    dutyGroups: dutyGroups,
    // The roster decides whether a planned owner is ACTIVE (D-P3-12); an empty
    // list would make every rotation/fixed draft look unassigned.
    members: members,
    range: DateKeyRange(parsed.dateKey, parsed.dateKey),
    dateKeys: dateKeys,
    availabilityIndex: availabilityIndex,
    policy: policy,
  );
  for (final draft in drafts) {
    if (draft.id == occurrenceId) return Success<OccurrenceDraft?>(draft);
  }
  return const Success<OccurrenceDraft?>(null);
}

/// A failure when the Appendix C table forbids [action], else null.
///
/// The use case has already checked the permission; this only turns a
/// "not allowed in this state" into the stable code the UI localizes.
AppFailure? stateFailure(OccurrenceContext context, OccurrenceAction action) {
  final status = effectiveStatus(context.occurrence);
  if (OccurrenceStateMachine.can(status, action, context.actor)) return null;
  return switch (action) {
    OccurrenceAction.verify =>
      context.actor.isCompleter
          ? const Conflict(code: 'self_verification')
          : const Conflict(code: 'not_completed'),
    OccurrenceAction.reopen =>
      status == ChoreStatus.verified
          ? const Conflict(code: 'verified_requires_manager')
          : const Conflict(code: 'not_completed'),
    OccurrenceAction.unskip => const Conflict(code: 'not_skipped'),
    OccurrenceAction.tickSubtask ||
    OccurrenceAction.untickSubtask ||
    OccurrenceAction.checkParent ||
    OccurrenceAction.uncheckParent =>
      status == ChoreStatus.skipped
          ? const Conflict(code: 'already_skipped')
          : status == ChoreStatus.verified
          ? const Conflict(code: 'already_verified')
          : const Conflict(code: 'not_assigned_to_you'),
    _ => const Conflict(code: 'not_assigned_to_you'),
  };
}

/// A trimmed, validated reason (D-P3-17: 3-300 characters).
Result<String> requireReason(String? raw) {
  final reason = raw?.trim() ?? '';
  if (reason.length < 3) {
    return const Failure<String>(Validation('reason', 'reason_required'));
  }
  if (reason.length > 300) {
    return const Failure<String>(Validation('reason', 'too_long'));
  }
  return Success<String>(reason);
}
