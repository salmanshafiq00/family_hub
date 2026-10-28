import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/core/permissions/permission_settings.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_generator.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_id.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_state_machine.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
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
      isAssignee:
          occurrence.assigneeId != null && occurrence.assigneeId == member.uid,
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
Future<Result<OccurrenceContext>> loadOccurrenceContext({
  required OccurrenceRepository occurrences,
  required TemplateRepository templates,
  required FamilyRepository families,
  required FamilyDateKeys dateKeys,
  required String familyId,
  required String occurrenceId,
  required String actorUid,
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
  final settings = loadedSettings.valueOrNull ?? PermissionSettings.defaults;

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
        settings: settings,
      ),
    );
  }

  final roster = await families.getMembers(familyId);
  final rosterFailure = roster.failureOrNull;
  if (rosterFailure != null) return Failure<OccurrenceContext>(rosterFailure);
  final projected = await _draftFor(
    occurrenceId: occurrenceId,
    templates: templates,
    familyId: familyId,
    dateKeys: dateKeys,
    members: roster.valueOrNull ?? const <Member>[],
  );
  final draftFailure = projected.failureOrNull;
  if (draftFailure != null) {
    return Failure<OccurrenceContext>(draftFailure);
  }
  final draft = projected.valueOrNull;
  if (draft == null) {
    return const Failure<OccurrenceContext>(NotFound(entity: 'occurrence'));
  }
  return Success<OccurrenceContext>(
    OccurrenceContext.build(
      occurrence: draft.toOccurrence(),
      member: member,
      settings: settings,
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
  required List<Member> members,
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
    dutyGroups: const [],
    // The roster decides whether a planned owner is ACTIVE (D-P3-12); an empty
    // list would make every rotation/fixed draft look unassigned.
    members: members,
    range: DateKeyRange(parsed.dateKey, parsed.dateKey),
    dateKeys: dateKeys,
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
AppFailure? stateFailure(
  OccurrenceContext context,
  OccurrenceAction action,
) {
  final status = effectiveStatus(context.occurrence);
  if (OccurrenceStateMachine.can(status, action, context.actor)) return null;
  return switch (action) {
    OccurrenceAction.verify => context.actor.isCompleter
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
