import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_validator.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_state.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The page's editor state; auto-disposed with the screen so an abandoned
/// draft never survives a navigation.
final choreSettingsEditorProvider =
    NotifierProvider.autoDispose<
      ChoreSettingsController,
      ChoreSettingsFormState
    >(ChoreSettingsController.new);

/// Holds an immutable draft of [ChoreSettings] (plus the absence policy and the
/// admin-only "members can complete for others" switch) and saves them
/// (P3-17).
///
/// The three values live in three documents, so [save] writes only the ones
/// that changed, one after the other, and stops at the first failure: what was
/// already written stays written and the page keeps the rest as unsaved.
class ChoreSettingsController extends Notifier<ChoreSettingsFormState> {
  @override
  ChoreSettingsFormState build() {
    final settings = ref.read(choreSettingsProvider);
    final policy = ref.read(rotationPolicyProvider);
    final complete = ref
        .read(permissionSettingsProvider)
        .membersCanCompleteForOthers;

    // The first frame can carry the defaults before the listener fires. While
    // nothing is edited the page follows the server; once the user has edits,
    // only the "saved" side moves so the dirty comparison stays honest.
    ref
      ..listen<ChoreSettings>(choreSettingsProvider, (_, next) {
        final dirty = state.draft != state.saved;
        state = state.copyWith(saved: next, draft: dirty ? state.draft : next);
      })
      ..listen<AbsencePolicy>(rotationPolicyProvider, (_, next) {
        final dirty = state.policy != state.savedPolicy;
        state = state.copyWith(
          savedPolicy: next,
          policy: dirty ? state.policy : next,
        );
      })
      ..listen<PermissionSettings>(permissionSettingsProvider, (_, next) {
        final dirty = state.completeForOthers != state.savedCompleteForOthers;
        state = state.copyWith(
          savedCompleteForOthers: next.membersCanCompleteForOthers,
          completeForOthers: dirty
              ? state.completeForOthers
              : next.membersCanCompleteForOthers,
        );
      });

    return ChoreSettingsFormState(
      draft: settings,
      saved: settings,
      policy: policy,
      savedPolicy: policy,
      completeForOthers: complete,
      savedCompleteForOthers: complete,
    );
  }

  // ── Edits ──────────────────────────────────────────────────────────────────

  /// Replaces the draft (every section hands back a whole new value).
  void setDraft(ChoreSettings value) => state = state.copyWith(
    draft: value,
    clearFailure: true,
    justSaved: false,
  );

  void setPolicy(AbsencePolicy value) => state = state.copyWith(
    policy: value,
    clearFailure: true,
    justSaved: false,
  );

  void setCompleteForOthers({required bool value}) => state = state.copyWith(
    completeForOthers: value,
    clearFailure: true,
    justSaved: false,
  );

  /// Puts one section back to the built-in defaults. Nothing is written until
  /// Save, and no template or occurrence is ever deleted by it.
  void resetSection(ChoreSettingsSection section) {
    const d = ChoreSettings.defaults;
    final draft = state.draft;
    switch (section) {
      case ChoreSettingsSection.calendar:
        state = state.copyWith(
          draft: draft.copyWith(
            weekStartDay: d.weekStartDay,
            defaultCalendarView: d.defaultCalendarView,
            defaultScope: d.defaultScope,
            showProjected: d.showProjected,
            projectedMonthsAhead: d.projectedMonthsAhead,
          ),
        );
      case ChoreSettingsSection.generation:
        state = state.copyWith(
          draft: draft.copyWith(
            generationHorizonDays: d.generationHorizonDays,
            overdueGraceMinutes: d.overdueGraceMinutes,
          ),
        );
      case ChoreSettingsSection.catalogs:
        state = state.copyWith(
          draft: draft.copyWith(
            groups: d.groups,
            dueTimePresets: d.dueTimePresets,
            absenceReasons: d.absenceReasons,
          ),
        );
      case ChoreSettingsSection.policies:
        final mayEditPermissions = ref.read(
          canProvider(const PermissionQuery(Permission.editFamilySettings)),
        );
        state = state.copyWith(
          draft: draft.copyWith(
            swapsEnabled: d.swapsEnabled,
            swapExpiryBufferMinutes: d.swapExpiryBufferMinutes,
            absenceNeedsApproval: d.absenceNeedsApproval,
            workloadVisibleToMembers: d.workloadVisibleToMembers,
          ),
          policy: AbsencePolicy.autoAssign,
          completeForOthers: mayEditPermissions
              ? PermissionSettings.defaults.membersCanCompleteForOthers
              : state.completeForOthers,
        );
      case ChoreSettingsSection.houseRules:
        state = state.copyWith(draft: draft.copyWith(houseRules: ''));
    }
    state = state.copyWith(clearFailure: true, justSaved: false);
  }

  /// Throws the edits away and goes back to what the server has.
  void discard() => state = state.copyWith(
    draft: state.saved,
    policy: state.savedPolicy,
    completeForOthers: state.savedCompleteForOthers,
    clearFailure: true,
  );

  // ── Save ───────────────────────────────────────────────────────────────────

  /// Writes every changed part. Returns true when all of them succeeded.
  Future<bool> save() async {
    if (state.saving || !state.isDirty) return false;
    final uid = ref.read(currentUidProvider);
    final familyId = ref.read(currentFamilyIdProvider);
    if (uid == null || familyId == null) {
      state = state.copyWith(failure: const Unknown('no_session'));
      return false;
    }

    final invalid = ChoreSettingsValidator.validate(state.draft);
    if (invalid != null) {
      state = state.copyWith(failure: invalid);
      return false;
    }

    state = state.copyWith(saving: true, clearFailure: true, justSaved: false);
    try {
      if (state.draft != state.saved) {
        final result = await ref.read(updateChoreSettingsProvider)(
          actorUid: uid,
          familyId: familyId,
          settings: state.draft,
        );
        final failure = result.failureOrNull;
        if (failure != null) return _fail(failure);
        state = state.copyWith(saved: state.draft);
      }
      if (state.policy != state.savedPolicy) {
        final result = await ref.read(updateRotationPolicyProvider)(
          actorUid: uid,
          familyId: familyId,
          policy: state.policy,
        );
        final failure = result.failureOrNull;
        if (failure != null) return _fail(failure);
        state = state.copyWith(savedPolicy: state.policy);
      }
      if (state.completeForOthers != state.savedCompleteForOthers) {
        final result = await ref.read(updatePermissionSettingsProvider)(
          actorUid: uid,
          familyId: familyId,
          settings: ref
              .read(permissionSettingsProvider)
              .copyWith(membersCanCompleteForOthers: state.completeForOthers),
        );
        final failure = result.failureOrNull;
        if (failure != null) return _fail(failure);
        state = state.copyWith(savedCompleteForOthers: state.completeForOthers);
      }
      state = state.copyWith(saving: false, justSaved: true);
      return true;
    } on Object catch (error) {
      return _fail(Unknown(error));
    }
  }

  bool _fail(AppFailure failure) {
    state = state.copyWith(saving: false, failure: failure);
    return false;
  }
}
