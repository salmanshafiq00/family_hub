import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/generation_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_generator.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Refreshes the future unstarted occurrences of one template after an edit
/// (P3-12, D-P3-23).
///
/// The snapshot (name, subtasks, instructions, difficulty, verification,
/// `templateRev`) and `dueAt` are replaced. The planned owner is recomputed ONLY
/// when the stored `assignmentSource` is `rotation` or `fixed`: a manual
/// assignment, a cover, a swap or a reassign is a human decision and survives
/// the edit.
///
/// INTEGRITY write, for the same reason as generation: a queued offline replan
/// could overwrite a newer document on the server.
class ReplanOccurrences {
  const ReplanOccurrences({
    required this._occurrences,
    required this._templates,
    required this._dutyGroups,
    required this._settings,
    required this._families,
    required this._dateKeys,
    required this._clock,
  });

  final OccurrenceRepository _occurrences;
  final TemplateRepository _templates;
  final DutyGroupRepository _dutyGroups;
  final ChoreSettingsRepository _settings;
  final FamilyRepository _families;
  final FamilyDateKeys _dateKeys;
  final Clock _clock;

  Future<Result<GenerationOutcome>> call({
    required String familyId,
    required String actorUid,
    required String templateId,
    required DateKey from,
    AvailabilityIndex availabilityIndex = AvailabilityIndex.empty,
  }) async {
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.manageChoreTemplates,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<GenerationOutcome>(denied);

    final found = await _templates.get(familyId, templateId);
    final readFailure = found.failureOrNull;
    if (readFailure != null) return Failure<GenerationOutcome>(readFailure);
    final template = found.valueOrNull?.template;
    if (template == null) {
      return const Failure<GenerationOutcome>(NotFound(entity: 'template'));
    }

    final listed = await _occurrences.listByTemplate(
      familyId,
      templateId,
      from: from,
    );
    final listFailure = listed.failureOrNull;
    if (listFailure != null) return Failure<GenerationOutcome>(listFailure);
    final unstarted = <ChoreOccurrence>[
      for (final occurrence in listed.valueOrNull ?? const <ChoreOccurrence>[])
        if (isUnstartedOnOrAfter(occurrence, from)) occurrence,
    ];
    if (unstarted.isEmpty || !template.isGenerating) {
      return const Success<GenerationOutcome>(GenerationOutcome.none);
    }

    final groups = await _dutyGroups.list(familyId);
    final groupsFailure = groups.failureOrNull;
    if (groupsFailure != null) return Failure<GenerationOutcome>(groupsFailure);
    final members = await _families.getMembers(familyId);
    final membersFailure = members.failureOrNull;
    if (membersFailure != null) {
      return Failure<GenerationOutcome>(membersFailure);
    }
    final policy = await _settings.getAbsencePolicy(familyId);
    final policyFailure = policy.failureOrNull;
    if (policyFailure != null) return Failure<GenerationOutcome>(policyFailure);

    final last = unstarted
        .map((occurrence) => occurrence.dateKey)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final drafts = OccurrenceGenerator.drafts(
      templates: <ChoreTemplate>[template],
      dutyGroups: groups.valueOrNull ?? const [],
      members: members.valueOrNull ?? const [],
      range: DateKeyRange(from, last),
      dateKeys: _dateKeys,
      availabilityIndex: availabilityIndex,
      policy: policy.valueOrNull ?? AbsencePolicy.askCover,
    );
    final byId = <String, OccurrenceDraft>{
      for (final draft in drafts) draft.id: draft,
    };

    final replans = <OccurrenceReplan>[];
    for (final occurrence in unstarted) {
      final draft = byId[occurrence.id];
      if (draft == null) continue;
      final source = occurrence.assignmentSource;
      replans.add(
        OccurrenceReplan(
          occurrenceId: occurrence.id,
          draft: draft,
          recomputeAssignment:
              source == AssignmentSource.rotation ||
              source == AssignmentSource.fixed,
        ),
      );
    }

    final at = _clock.nowUtc();
    var replanned = 0;
    var chunks = 0;
    for (final chunk in chunksOf(replans)) {
      final plan = OccurrenceWritePlan(
        actorId: actorUid,
        at: at,
        replans: chunk,
        audits: <NewAudit>[
          NewAudit(
            type: AuditEventType.choresOccurrencesReplanned,
            refType: AuditRefType.choreTemplate,
            refId: templateId,
            params: <String, String>{
              'name': template.draft.nameBn,
              'from': from.toString(),
              'count': '${chunk.length}',
            },
          ),
        ],
      );
      final staged = await _occurrences.stageIntegrity(familyId, plan);
      final failure = staged.failureOrNull;
      if (failure != null) return Failure<GenerationOutcome>(failure);
      replanned += chunk.length;
      chunks++;
    }

    return Success<GenerationOutcome>(
      GenerationOutcome(replanned: replanned, chunks: chunks),
    );
  }
}
