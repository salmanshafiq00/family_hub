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

/// Brings the stored occurrences of one or all templates back in line with
/// their templates (P3-12, D-P3-23).
///
/// It creates the missing documents, RESTORES a soft-deleted one whose day
/// matches again (a resumed template), and soft-deletes the unstarted future
/// documents that no longer match. It never touches history: a started,
/// completed, verified or skipped document, or one with a comment or an
/// exception, is left alone even when its template changed.
///
/// INTEGRITY write, because a silent offline run would let two devices write
/// different plans for the same deterministic ids.
class RegenerateRange {
  const RegenerateRange({
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
    required DateKey from,
    required DateKey to,
    String? templateId,
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
    if (from.isAfter(to)) {
      return const Failure<GenerationOutcome>(
        Validation('range', 'invalid_range'),
      );
    }

    final listed = await _templates.list(familyId);
    final listFailure = listed.failureOrNull;
    if (listFailure != null) return Failure<GenerationOutcome>(listFailure);
    final all = <ChoreTemplate>[
      for (final record in listed.valueOrNull ?? const <TemplateRecord>[])
        record.template,
    ];
    final affected = templateId == null
        ? all
        : <ChoreTemplate>[
            for (final template in all)
              if (template.id == templateId) template,
          ];
    if (templateId != null && affected.isEmpty) {
      return const Failure<GenerationOutcome>(NotFound(entity: 'template'));
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

    final existing = await _occurrences.listRange(familyId, from: from, to: to);
    final existingFailure = existing.failureOrNull;
    if (existingFailure != null) {
      return Failure<GenerationOutcome>(existingFailure);
    }
    final current = existing.valueOrNull ?? const <ChoreOccurrence>[];

    final drafts = OccurrenceGenerator.drafts(
      templates: <ChoreTemplate>[
        for (final template in affected)
          if (template.isGenerating) template,
      ],
      dutyGroups: groups.valueOrNull ?? const [],
      members: members.valueOrNull ?? const [],
      range: DateKeyRange(from, to),
      dateKeys: _dateKeys,
      availabilityIndex: availabilityIndex,
      policy: policy.valueOrNull ?? AbsencePolicy.askCover,
    );

    final byId = <String, ChoreOccurrence>{
      for (final occurrence in current) occurrence.id: occurrence,
    };
    final matchingIds = <String>{};
    final creates = <OccurrenceDraft>[];
    final restores = <OccurrenceDraft>[];
    for (final draft in drafts) {
      matchingIds.add(draft.id);
      final stored = byId[draft.id];
      if (stored == null) {
        creates.add(draft);
      } else if (stored.isDeleted) {
        restores.add(draft);
      }
    }

    final affectedIds = <String>{for (final template in affected) template.id};
    // A restored document must not be soft-deleted again in the same run
    // (B-06: `listRange` still returns it with its old `deletedAt`).
    final restoredIds = <String>{for (final draft in restores) draft.id};
    final removals = <OccurrencePatch>[];
    final at = _clock.nowUtc();
    for (final occurrence in current) {
      if (!affectedIds.contains(occurrence.templateId)) continue;
      if (occurrence.isDeleted) continue;
      if (restoredIds.contains(occurrence.id)) continue;
      if (matchingIds.contains(occurrence.id)) continue;
      if (!isUnstartedOnOrAfter(occurrence, from)) continue;
      removals.add(
        OccurrencePatch(
          occurrenceId: occurrence.id,
          fields: <String, Object?>{'deletedAt': at, 'deletedBy': actorUid},
        ),
      );
    }

    var outcome = GenerationOutcome.none;
    for (final stage in <Future<Result<_Staged>> Function()>[
      () => _stageDrafts(
        familyId: familyId,
        actorUid: actorUid,
        at: at,
        drafts: creates,
        from: from,
        to: to,
      ),
      () => _stageDrafts(
        familyId: familyId,
        actorUid: actorUid,
        at: at,
        drafts: restores,
        from: from,
        to: to,
        restore: true,
      ),
      () => _stageRemovals(
        familyId: familyId,
        actorUid: actorUid,
        at: at,
        patches: removals,
        from: from,
        to: to,
      ),
    ]) {
      final staged = await stage();
      final failure = staged.failureOrNull;
      if (failure != null) return Failure<GenerationOutcome>(failure);
      final value = staged.valueOrNull!;
      outcome = GenerationOutcome(
        created: outcome.created + value.created,
        restored: outcome.restored + value.restored,
        removed: outcome.removed + value.removed,
        chunks: outcome.chunks + value.chunks,
      );
    }
    return Success<GenerationOutcome>(outcome);
  }

  Future<Result<_Staged>> _stageDrafts({
    required String familyId,
    required String actorUid,
    required DateTime at,
    required List<OccurrenceDraft> drafts,
    required DateKey from,
    required DateKey to,
    bool restore = false,
  }) async {
    var count = 0;
    var chunks = 0;
    for (final chunk in chunksOf(drafts)) {
      final plan = OccurrenceWritePlan(
        actorId: actorUid,
        at: at,
        creates: restore ? const <OccurrenceDraft>[] : chunk,
        restores: restore ? chunk : const <OccurrenceDraft>[],
        audits: <NewAudit>[_audit(familyId, from, to, chunk.length)],
      );
      final staged = await _occurrences.stageIntegrity(familyId, plan);
      final failure = staged.failureOrNull;
      if (failure != null) return Failure<_Staged>(failure);
      count += chunk.length;
      chunks++;
    }
    return Success<_Staged>(
      _Staged(
        created: restore ? 0 : count,
        restored: restore ? count : 0,
        chunks: chunks,
      ),
    );
  }

  Future<Result<_Staged>> _stageRemovals({
    required String familyId,
    required String actorUid,
    required DateTime at,
    required List<OccurrencePatch> patches,
    required DateKey from,
    required DateKey to,
  }) async {
    var count = 0;
    var chunks = 0;
    for (final chunk in chunksOf(patches)) {
      final plan = OccurrenceWritePlan(
        actorId: actorUid,
        at: at,
        patches: chunk,
        audits: <NewAudit>[_audit(familyId, from, to, chunk.length)],
      );
      final staged = await _occurrences.stageIntegrity(familyId, plan);
      final failure = staged.failureOrNull;
      if (failure != null) return Failure<_Staged>(failure);
      count += chunk.length;
      chunks++;
    }
    return Success<_Staged>(_Staged(removed: count, chunks: chunks));
  }

  NewAudit _audit(String familyId, DateKey from, DateKey to, int count) =>
      NewAudit(
        type: AuditEventType.choresOccurrencesGenerated,
        refType: AuditRefType.choreSettings,
        refId: familyId,
        params: <String, String>{
          'from': from.toString(),
          'to': to.toString(),
          'count': '$count',
        },
      );
}

final class _Staged {
  const _Staged({
    this.created = 0,
    this.restored = 0,
    this.removed = 0,
    this.chunks = 0,
  });

  final int created;
  final int restored;
  final int removed;
  final int chunks;
}
