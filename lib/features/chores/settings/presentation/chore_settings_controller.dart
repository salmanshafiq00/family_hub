import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_validator.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_state.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:family_hub/features/notifications/presentation/notification_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'chore_settings_controller_parts.dart';

/// The page's editor state; auto-disposed with the screen so an abandoned
/// draft never survives a navigation.
final choreSettingsEditorProvider =
    NotifierProvider.autoDispose<
      ChoreSettingsController,
      ChoreSettingsFormState
    >(ChoreSettingsController.new);

/// Holds an immutable draft of [ChoreSettings] (plus the absence policy, the
/// admin-only "members can complete for others" switch, chore reminder
/// defaults, and chore notification delivery modes) and saves them (P3-17).
///
/// The values live in separate documents, so [save] writes only the ones
/// that changed, one after the other, and stops at the first failure: what was
/// already written stays written and the page keeps the rest as unsaved.
class ChoreSettingsController extends Notifier<ChoreSettingsFormState>
    with ChoreSettingsResetMixin {
  @override
  ChoreSettingsFormState build() {
    final settings = ref.read(choreSettingsProvider);
    final policy = ref.read(rotationPolicyProvider);
    final complete = ref
        .read(permissionSettingsProvider)
        .membersCanCompleteForOthers;
    final familyId = ref.read(currentFamilyIdProvider);
    final defaultsAsync = familyId == null
        ? null
        : ref.read(familyDefaultsProvider(familyId));
    final notificationDefaults =
        defaultsAsync?.asData?.value ?? NotificationDefaults.defaults;
    final deliveryAsync = familyId == null
        ? null
        : ref.read(deliveryPolicyProvider(familyId));
    final deliverySettings =
        deliveryAsync?.asData?.value ?? NotificationDeliverySettings.defaults();

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

    if (familyId != null) {
      ref
        ..listen<AsyncValue<NotificationDefaults>>(
          familyDefaultsProvider(familyId),
          (_, next) {
            final nextDefaults = next.asData?.value;
            if (nextDefaults != null) {
              final dirty =
                  state.notificationDefaults != state.savedNotificationDefaults;
              state = state.copyWith(
                savedNotificationDefaults: nextDefaults,
                notificationDefaults: dirty
                    ? state.notificationDefaults
                    : nextDefaults,
              );
            }
          },
        )
        ..listen<AsyncValue<NotificationDeliverySettings>>(
          deliveryPolicyProvider(familyId),
          (_, next) {
            final nextDelivery = next.asData?.value;
            if (nextDelivery != null) {
              final dirty = state.isSectionDirty(ChoreSettingsSection.delivery);
              state = state.copyWith(
                savedDeliverySettings: nextDelivery,
                deliverySettings: dirty ? state.deliverySettings : nextDelivery,
              );
            }
          },
        );
    }

    return ChoreSettingsFormState(
      draft: settings,
      saved: settings,
      policy: policy,
      savedPolicy: policy,
      completeForOthers: complete,
      savedCompleteForOthers: complete,
      notificationDefaults: notificationDefaults,
      savedNotificationDefaults: notificationDefaults,
      deliverySettings: deliverySettings,
      savedDeliverySettings: deliverySettings,
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

  void setNotificationDefaults(NotificationDefaults value) =>
      state = state.copyWith(
        notificationDefaults: value,
        clearFailure: true,
        justSaved: false,
      );

  void setDeliverySettings(NotificationDeliverySettings value) => state = state
      .copyWith(deliverySettings: value, clearFailure: true, justSaved: false);

  /// Throws the edits away and goes back to what the server has.
  void discard() => state = state.copyWith(
    draft: state.saved,
    policy: state.savedPolicy,
    completeForOthers: state.savedCompleteForOthers,
    notificationDefaults: state.savedNotificationDefaults,
    deliverySettings: state.savedDeliverySettings,
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
      if (state.notificationDefaults != state.savedNotificationDefaults) {
        final result = await ref.read(updateNotificationDefaultsProvider)(
          actorUid: uid,
          familyId: familyId,
          settings: state.notificationDefaults,
        );
        final failure = result.failureOrNull;
        if (failure != null) return _fail(failure);
        state = state.copyWith(
          savedNotificationDefaults: state.notificationDefaults,
        );
      }
      if (state.isSectionDirty(ChoreSettingsSection.delivery)) {
        final result = await ref.read(updateNotificationDeliveryProvider)(
          actorUid: uid,
          familyId: familyId,
          settings: state.deliverySettings,
        );
        final failure = result.failureOrNull;
        if (failure != null) return _fail(failure);
        state = state.copyWith(savedDeliverySettings: state.deliverySettings);
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
