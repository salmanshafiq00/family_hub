import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/group_planning.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_change_request.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_form_state.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/domain/template_enums.dart';
import 'package:family_hub/features/chores/templates/domain/template_saved.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:family_hub/features/chores/duty_groups/presentation/duty_group_form_state.dart';

final dutyGroupControllerProvider =
    NotifierProvider.autoDispose<DutyGroupController, DutyGroupFormState>(
      DutyGroupController.new,
    );

/// Runs the duty-group use cases for the screens (P3-18).
///
/// Screens never call a use case (rule 33). Order of every action: use case
/// first (the change is stored or refused), planning second. A planning
/// failure never undoes the stored change: it is reported and [retryPlanning]
/// repeats only the planning.
class DutyGroupController extends Notifier<DutyGroupFormState> {
  /// What [retryPlanning] repeats.
  Future<AppFailure?> Function()? _pendingPlan;

  @override
  DutyGroupFormState build() => const DutyGroupFormState();

  /// Creates a group with its first rotation version. Returns it on success.
  Future<DutyGroup?> create({
    required String nameBn,
    String? nameEn,
    int? colorIndex,
    required Result<Rotation> rotation,
  }) async {
    if (state.saving) return null;
    final built = rotation.valueOrNull;
    if (built == null) {
      _failed(rotation.failureOrNull ?? const Unknown('no_rotation'));
      return null;
    }
    final session = _session();
    if (session == null) {
      _failed(const Unknown('no_session'));
      return null;
    }
    _begin();
    final result = await ref.read(createDutyGroupProvider)(
      actorUid: session.uid,
      familyId: session.familyId,
      nameBn: nameBn,
      nameEn: nameEn,
      colorIndex: colorIndex,
      rotation: built,
    );
    final failure = result.failureOrNull;
    if (failure != null) {
      _failed(failure);
      return null;
    }
    state = const DutyGroupFormState(status: DutyGroupStatus.saved);
    return result.valueOrNull;
  }

  /// Edits name, colour and the active switch. With [confirmDeactivate] the
  /// manager has agreed to switch off a group that chores still use.
  Future<bool> update({
    required String groupId,
    required String nameBn,
    String? nameEn,
    int? colorIndex,
    required bool active,
    bool confirmDeactivate = false,
  }) async {
    if (state.saving) return false;
    final session = _session();
    if (session == null) {
      _failed(const Unknown('no_session'));
      return false;
    }
    _begin();
    final result = await ref.read(updateDutyGroupProvider)(
      actorUid: session.uid,
      familyId: session.familyId,
      groupId: groupId,
      nameBn: nameBn,
      nameEn: nameEn,
      colorIndex: colorIndex,
      active: active,
      confirmDeactivate: confirmDeactivate,
    );
    final failure = result.failureOrNull;
    if (failure != null) {
      _failed(failure);
      return false;
    }
    state = const DutyGroupFormState(status: DutyGroupStatus.saved);
    return true;
  }

  /// Stores one rotation change, then re-plans the group's chores from the day
  /// it takes effect.
  Future<DutyGroupStatus> changeRotation(
    String groupId,
    RotationChangeRequest request,
  ) async {
    if (state.saving) return state.status;
    final session = _session();
    if (session == null) return _failed(const Unknown('no_session'));
    _begin();
    final result = await ref.read(changeRotationProvider)(
      actorUid: session.uid,
      familyId: session.familyId,
      groupId: groupId,
      change: request.change,
      effectiveFrom: request.effectiveFrom,
      memberId: request.memberId,
      members: request.members,
      startsWith: request.startsWith,
    );
    final failure = result.failureOrNull;
    if (failure != null) return _failed(failure);

    final stored = result.valueOrNull!;
    final boundary = stored.rotation.versions.last.from;
    return _plan(() => _planGroup(stored.id, boundary));
  }

  /// Puts a chore on the group's rota by editing the TEMPLATE's
  /// `assignee.dutyGroupId` (the one place rotation data lives), then
  /// re-plans that chore, including its unstarted upcoming days.
  Future<DutyGroupStatus> addTemplate(String groupId, String templateId) async {
    if (state.saving) return state.status;
    final session = _session();
    if (session == null) return _failed(const Unknown('no_session'));
    final template = ref.read(templateProvider(templateId));
    if (template == null) {
      return _failed(const NotFound(entity: 'template'));
    }
    _begin();
    final draft = template.draft.copyWith(
      assignee: template.draft.assignee.copyWith(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: groupId,
        clearFixedMember: true,
        clearRotation: true,
      ),
    );
    final result = await ref.read(updateTemplateProvider)(
      actorUid: session.uid,
      familyId: session.familyId,
      templateId: templateId,
      draft: draft,
      replanScope: ReplanScope.includeUpcoming,
    );
    final failure = result.failureOrNull;
    if (failure != null) return _failed(failure);
    final today = ref.read(familyDateKeysProvider).today();
    return _plan(() => _planTemplate(templateId, from: today, replan: true));
  }

  /// Repeats the planning of the last stored change.
  Future<DutyGroupStatus> retryPlanning() async {
    final pending = _pendingPlan;
    if (state.saving || pending == null) return state.status;
    state = state.copyWith(saving: true, clearPlanningFailure: true);
    return _plan(pending);
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  ({String uid, String familyId})? _session() {
    final uid = ref.read(currentUidProvider);
    final familyId = ref.read(currentFamilyIdProvider);
    if (uid == null || familyId == null) return null;
    return (uid: uid, familyId: familyId);
  }

  void _begin() {
    _pendingPlan = null;
    state = const DutyGroupFormState(saving: true);
  }

  DutyGroupStatus _failed(AppFailure failure) {
    state = DutyGroupFormState(
      status: DutyGroupStatus.failed,
      failure: failure,
    );
    return DutyGroupStatus.failed;
  }

  Future<DutyGroupStatus> _plan(Future<AppFailure?> Function() run) async {
    _pendingPlan = run;
    final AppFailure? failure;
    try {
      failure = await run();
    } on Object catch (error) {
      return _planningFailed(Unknown(error));
    }
    if (failure != null) return _planningFailed(failure);
    _pendingPlan = null;
    state = const DutyGroupFormState(status: DutyGroupStatus.saved);
    return DutyGroupStatus.saved;
  }

  DutyGroupStatus _planningFailed(AppFailure failure) {
    state = DutyGroupFormState(
      status: DutyGroupStatus.planningFailed,
      planningFailure: failure,
    );
    return DutyGroupStatus.planningFailed;
  }

  /// Regenerates every generating chore of the group from [from].
  Future<AppFailure?> _planGroup(String groupId, DateKey from) async {
    final templates = ref.read(dutyGroupTemplatesProvider(groupId));
    for (final template in templates) {
      if (!template.isGenerating) continue;
      final failure = await _planTemplate(template.id, from: from);
      if (failure != null) return failure;
    }
    return null;
  }

  Future<AppFailure?> _planTemplate(
    String templateId, {
    required DateKey from,
    bool replan = false,
  }) async {
    final session = _session();
    if (session == null) return const Unknown('no_session');
    final today = ref.read(familyDateKeysProvider).today();
    final range = planningRange(
      today: today,
      effectiveFrom: from,
      marker: ref.read(generationThroughProvider),
      horizonDays: ref.read(choreSettingsProvider).generationHorizonDays,
    );
    if (range == null) return null;

    final regenerated = await ref.read(regenerateRangeProvider)(
      familyId: session.familyId,
      actorUid: session.uid,
      from: range.from,
      to: range.to,
      templateId: templateId,
    );
    final regenerateFailure = regenerated.failureOrNull;
    if (regenerateFailure != null) return regenerateFailure;
    if (!replan) return null;

    final replanned = await ref.read(replanOccurrencesProvider)(
      familyId: session.familyId,
      actorUid: session.uid,
      templateId: templateId,
      from: range.from,
    );
    return replanned.failureOrNull;
  }
}
