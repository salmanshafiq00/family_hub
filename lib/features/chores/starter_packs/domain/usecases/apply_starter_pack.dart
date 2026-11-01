import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_validator.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/occurrences/domain/generation_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/regenerate_range.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack_outcome.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack_plan.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/chores/templates/domain/template_validator.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Applies a [StarterPack] to one family (road map P3-19).
///
/// INTEGRITY: the settings write carries the `chores.starter_pack_applied`
/// audit entry and is server-required, so an offline apply fails before
/// anything is written. Order: permission → selection/rotation validation →
/// read → plan → settings (and audit) → duty group → templates → regenerate.
///
/// Every id is deterministic (`tpl_<seedKey>`, `duty_<pack id>`) and every
/// merge is "add only": a second run skips what exists and returns
/// `Conflict('starter_pack_applied')` only when nothing new would be created.
/// Family edits are never overwritten.
class ApplyStarterPack {
  const ApplyStarterPack({
    required this._settings,
    required this._templates,
    required this._dutyGroups,
    required this._markers,
    required this._regenerate,
    required this._families,
    required this._dateKeys,
    required this._clock,
    required this._newId,
  });

  final ChoreSettingsRepository _settings;
  final TemplateRepository _templates;
  final DutyGroupRepository _dutyGroups;
  final GenerationMarkerRepository _markers;
  final RegenerateRange _regenerate;
  final FamilyRepository _families;
  final FamilyDateKeys _dateKeys;
  final Clock _clock;
  final IdGenerator _newId;

  Future<Result<StarterPackOutcome>> call({
    required String actorUid,
    required String familyId,
    required Set<String> selectedSeedKeys,
    StarterRotationConfig? rotation,
    String? houseRules,
    bool addHouseRules = true,
    StarterPack pack = familyPdfPack,
  }) async {
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.manageChoreTemplates,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<StarterPackOutcome>(denied);

    if (selectedSeedKeys.isEmpty) {
      return const Failure<StarterPackOutcome>(
        Validation('templates', 'required'),
      );
    }
    final selected = <StarterTemplate>[];
    for (final seedKey in selectedSeedKeys) {
      final template = pack.templateBySeedKey(seedKey);
      if (template == null) {
        return const Failure<StarterPackOutcome>(
          Validation('templates', 'invalid_recurrence'),
        );
      }
      selected.add(template);
    }
    final rotationError = StarterPackPlanner.validateRotation(rotation);
    if (rotationError != null) return Failure<StarterPackOutcome>(rotationError);

    final readSettings = await _settings.get(familyId);
    final settingsFailure = readSettings.failureOrNull;
    if (settingsFailure != null) {
      return Failure<StarterPackOutcome>(settingsFailure);
    }
    final current = readSettings.valueOrNull ?? ChoreSettings.defaults;

    final listed = await _templates.list(familyId);
    final listFailure = listed.failureOrNull;
    if (listFailure != null) return Failure<StarterPackOutcome>(listFailure);
    final stored = <ChoreTemplate>[
      for (final record in listed.valueOrNull ?? const <TemplateRecord>[])
        record.template,
    ];

    final readGroups = await _dutyGroups.list(familyId);
    final groupsFailure = readGroups.failureOrNull;
    if (groupsFailure != null) return Failure<StarterPackOutcome>(groupsFailure);
    final storedGroups = readGroups.valueOrNull ?? const <DutyGroup>[];

    final plan = StarterPackPlanner.plan(
      pack: pack,
      current: current,
      storedTemplates: stored,
      storedGroups: storedGroups,
      selected: selected,
      rotation: rotation,
      houseRules: houseRules,
      addHouseRules: addHouseRules,
    );
    if (plan.nothingNew) {
      return const Failure<StarterPackOutcome>(
        Conflict(code: 'starter_pack_applied'),
      );
    }

    final today = _dateKeys.today();

    // The settings write is the server probe AND the single audit entry for
    // the whole application (road map 3.4: INTEGRITY).
    final settingsAudit = AuditEvent(
      id: _newId(),
      type: AuditEventType.choresStarterPackApplied,
      actorId: actorUid,
      refType: AuditRefType.choreSettings,
      refId: familyId,
      at: _clock.nowUtc(),
      params: <String, String>{
        'templates': '${plan.toCreate.length}',
        'groups':
            '${plan.catalogGroupsAdded + (plan.createDutyGroup ? 1 : 0)}',
      },
    );
    final savedSettings = await _settings.save(
      familyId,
      current.copyWith(
        groups: plan.groups,
        dueTimePresets: plan.dueTimePresets,
        houseRules: plan.houseRulesAdded ? plan.houseRules : null,
      ),
      settingsAudit,
    );
    final settingsWriteFailure = savedSettings.failureOrNull;
    if (settingsWriteFailure != null) {
      return Failure<StarterPackOutcome>(settingsWriteFailure);
    }

    // ── The duty group the chosen rotation points at ────────────────────────
    var dutyGroupsCreated = 0;
    final rotationTarget = rotation == null ? null : plan.dutyGroupId;
    if (plan.createDutyGroup) {
      final group = DutyGroup(
        id: plan.dutyGroupId,
        nameBn: pack.dutyGroup?.nameBn ?? pack.titleKey,
        nameEn: pack.dutyGroup?.nameEn,
        colorIndex: pack.dutyGroup?.colorIndex,
        rotation: _rotationOf(rotation!, today, current.weekStartDay),
        sortOrder: _nextOrder(storedGroups.map((group) => group.sortOrder)),
      );
      final invalid = DutyGroupValidator.validate(group);
      if (invalid != null) return Failure<StarterPackOutcome>(invalid);
      final written = await _dutyGroups.saveRotation(
        familyId,
        group,
        AuditEvent(
          id: _newId(),
          type: AuditEventType.choresDutyGroupCreated,
          actorId: actorUid,
          refType: AuditRefType.dutyGroup,
          refId: group.id,
          at: _clock.nowUtc(),
          params: <String, String>{'name': group.nameBn},
        ),
      );
      final writeFailure = written.failureOrNull;
      if (writeFailure != null) return Failure<StarterPackOutcome>(writeFailure);
      dutyGroupsCreated = 1;
    }

    // ── Templates, with deterministic ids ───────────────────────────────────
    var templatesCreated = 0;
    var nextTemplateOrder = _nextOrder(
      stored.map((template) => template.sortOrder),
    );
    for (final starter in plan.toCreate) {
      final draft = starter.toDraft(
        startDate: today,
        dutyGroupId: rotationTarget,
      );
      final invalid = TemplateValidator.validate(draft);
      if (invalid != null) return Failure<StarterPackOutcome>(invalid);
      final template = ChoreTemplate(
        id: starter.templateId,
        draft: draft,
        revision: 1,
        sortOrder: nextTemplateOrder++,
        builtIn: true,
        seedKey: starter.seedKey,
      );
      final written = await _templates.save(
        familyId,
        template,
        AuditEvent(
          id: _newId(),
          type: AuditEventType.choresTemplateCreated,
          actorId: actorUid,
          refType: AuditRefType.choreTemplate,
          refId: template.id,
          at: _clock.nowUtc(),
          params: <String, String>{'name': starter.nameBn},
        ),
      );
      final writeFailure = written.failureOrNull;
      if (writeFailure != null) return Failure<StarterPackOutcome>(writeFailure);
      templatesCreated++;
    }

    // ── Today → marker (or the horizon while the marker is behind) ──────────
    AppFailure? generationFailure;
    GenerationOutcome? generation;
    final markerResult = await _markers.readThrough(familyId);
    final markerFailure = markerResult.failureOrNull;
    if (markerFailure != null) {
      generationFailure = markerFailure;
    } else {
      final marker = markerResult.valueOrNull;
      final to = marker != null && !marker.isBefore(today)
          ? marker
          : today.addDays(current.generationHorizonDays);
      final regenerated = await _regenerate(
        familyId: familyId,
        actorUid: actorUid,
        from: today,
        to: to,
      );
      generationFailure = regenerated.failureOrNull;
      generation = regenerated.valueOrNull;
    }

    return Success<StarterPackOutcome>(
      StarterPackOutcome(
        templatesCreated: templatesCreated,
        templatesSkipped: plan.templatesSkipped,
        catalogGroupsAdded: plan.catalogGroupsAdded,
        catalogPresetsAdded: plan.catalogPresetsAdded,
        dutyGroupsCreated: dutyGroupsCreated,
        houseRulesAdded: plan.houseRulesAdded,
        generation: generation,
        generationFailure: generationFailure,
      ),
    );
  }

  static Rotation _rotationOf(
    StarterRotationConfig config,
    DateKey today,
    int weekStartDay,
  ) => Rotation(
    versions: <RotationVersion>[
      RotationVersion(
        from: today,
        members: config.memberIds,
        anchorDate: today,
        anchorIndex: config.memberIds.indexOf(config.firstMemberId),
        cycleUnit: config.cycleUnit,
        weekStartDay: weekStartDay,
      ),
    ],
  );

  /// `max + 1`, or 0 for an empty list.
  static int _nextOrder(Iterable<int> orders) {
    var next = 0;
    for (final order in orders) {
      if (order >= next) next = order + 1;
    }
    return next;
  }
}
