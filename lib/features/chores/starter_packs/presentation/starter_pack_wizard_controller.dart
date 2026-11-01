import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_pack_providers.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_pack_wizard_state.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the wizard's choices and runs [ApplyStarterPack] (P3-19).
///
/// Auto-disposed with its screen: an abandoned wizard never keeps the family's
/// half-made selection alive. Applying twice is safe even when the first run
/// was interrupted, because the use case's ids are deterministic.
final starterPackWizardProvider = NotifierProvider.autoDispose<
  StarterPackWizardController,
  StarterPackWizardState
>(StarterPackWizardController.new);

class StarterPackWizardController extends Notifier<StarterPackWizardState> {
  @override
  StarterPackWizardState build() {
    final pack = familyPdfPack;
    final active = _activeMemberIds();
    final bangla = ref.watch(appFormattersProvider).languageCode == 'bn';
    final rules = bangla ? pack.houseRulesBn : pack.houseRulesEn;
    return StarterPackWizardState(
      step: StarterPackWizardStep.pick,
      selectedSeedKeys: <String>{
        for (final template in pack.highConfidence) template.seedKey,
      },
      houseRules: rules,
      addHouseRules: rules.trim().isNotEmpty,
      useRotation: active.length >= 2,
      rotationMemberIds: active,
      firstMemberId: active.isEmpty ? null : active.first,
      cycleUnit: CycleUnit.week,
    );
  }

  /// The active roster, capped at the rotation limit (12).
  List<String> _activeMemberIds() => <String>[
    for (final member in ref
        .read(dutyRosterProvider)
        .take(TemplateLimits.maxRotationMembers))
      member.uid,
  ];

  // ── Step 1: pick ────────────────────────────────────────────────────────────

  void toggleTemplate(String seedKey) {
    final selected = <String>{...state.selectedSeedKeys};
    if (!selected.remove(seedKey)) selected.add(seedKey);
    state = state.copyWith(selectedSeedKeys: selected, clearFailure: true);
  }

  void setAllTemplates(bool selected) {
    state = state.copyWith(
      selectedSeedKeys: selected
          ? <String>{for (final t in familyPdfPack.templates) t.seedKey}
          : <String>{},
      clearFailure: true,
    );
  }

  // ── Step 2: review ──────────────────────────────────────────────────────────

  void setAddHouseRules(bool value) =>
      state = state.copyWith(addHouseRules: value, clearFailure: true);

  void setHouseRules(String value) =>
      state = state.copyWith(houseRules: value, clearFailure: true);

  // ── Step 3: who does what ───────────────────────────────────────────────────

  void setUseRotation(bool value) {
    if (value && state.rotationMemberIds.length < 2) {
      state = state.copyWith(
        failure: const Validation('members', 'too_few_members'),
      );
      return;
    }
    state = state.copyWith(useRotation: value, clearFailure: true);
  }

  void toggleRotationMember(String uid) {
    final ids = <String>[...state.rotationMemberIds];
    if (ids.contains(uid)) {
      ids.remove(uid);
    } else if (ids.length >= TemplateLimits.maxRotationMembers) {
      state = state.copyWith(
        failure: const Validation('members', 'too_many_items'),
      );
      return;
    } else {
      ids.add(uid);
    }
    final first = ids.contains(state.firstMemberId)
        ? state.firstMemberId
        : (ids.isEmpty ? null : ids.first);
    state = state.copyWith(
      rotationMemberIds: ids,
      firstMemberId: first,
      clearFailure: true,
    );
  }

  void setFirstMember(String uid) {
    if (!state.rotationMemberIds.contains(uid)) return;
    state = state.copyWith(firstMemberId: uid, clearFailure: true);
  }

  void setCycleUnit(CycleUnit unit) =>
      state = state.copyWith(cycleUnit: unit, clearFailure: true);

  // ── Navigation ──────────────────────────────────────────────────────────────

  void nextStep() {
    switch (state.step) {
      case StarterPackWizardStep.pick:
        if (state.selectedSeedKeys.isEmpty) {
          state = state.copyWith(
            failure: const Validation('templates', 'required'),
          );
          return;
        }
        state = state.copyWith(
          step: StarterPackWizardStep.review,
          clearFailure: true,
        );
      case StarterPackWizardStep.review:
        _ensureRotationMembers();
        state = state.copyWith(
          step: StarterPackWizardStep.who,
          clearFailure: true,
        );
      case StarterPackWizardStep.who:
        return;
    }
  }

  /// The roster may have been empty on the first frame; fill it when the user
  /// actually reaches step 3 instead of resetting their earlier choices.
  void _ensureRotationMembers() {
    if (state.rotationMemberIds.isNotEmpty) return;
    final active = _activeMemberIds();
    if (active.isEmpty) return;
    state = state.copyWith(
      rotationMemberIds: active,
      useRotation: active.length >= 2,
      firstMemberId: active.first,
    );
  }

  void back() {
    switch (state.step) {
      case StarterPackWizardStep.pick:
        return;
      case StarterPackWizardStep.review:
        state = state.copyWith(
          step: StarterPackWizardStep.pick,
          clearFailure: true,
        );
      case StarterPackWizardStep.who:
        state = state.copyWith(
          step: StarterPackWizardStep.review,
          clearFailure: true,
        );
    }
  }

  // ── Apply ───────────────────────────────────────────────────────────────────

  Future<void> apply() async {
    if (state.applying || state.done) return;
    final uid = ref.read(currentUidProvider);
    final familyId = ref.read(currentFamilyIdProvider);
    if (uid == null || familyId == null) {
      state = state.copyWith(
        failure: const Unknown('no_session'),
        applying: false,
      );
      return;
    }
    if (state.selectedSeedKeys.isEmpty) {
      state = state.copyWith(
        failure: const Validation('templates', 'required'),
      );
      return;
    }
    if (state.useRotation && state.rotationMemberIds.length < 2) {
      state = state.copyWith(
        failure: const Validation('members', 'too_few_members'),
      );
      return;
    }
    final first = state.firstMemberId ?? state.rotationMemberIds.first;

    state = state.copyWith(
      applying: true,
      clearFailure: true,
      clearOutcome: true,
    );
    try {
      final result = await ref.read(applyStarterPackProvider)(
        actorUid: uid,
        familyId: familyId,
        selectedSeedKeys: state.selectedSeedKeys,
        rotation: state.useRotation
            ? StarterRotationConfig(
                memberIds: state.rotationMemberIds,
                firstMemberId: first,
                cycleUnit: state.cycleUnit,
              )
            : null,
        houseRules: state.houseRules,
        addHouseRules: state.addHouseRules,
      );
      final failure = result.failureOrNull;
      if (failure != null) {
        state = state.copyWith(applying: false, failure: failure);
        return;
      }
      state = state.copyWith(
        applying: false,
        outcome: result.valueOrNull,
        clearFailure: true,
      );
    } on Object catch (error) {
      state = state.copyWith(applying: false, failure: Unknown(error));
    }
  }
}
