part of 'chore_settings_controller.dart';

/// Reset logic split from [ChoreSettingsController] to preserve file size limits.
mixin ChoreSettingsResetMixin on Notifier<ChoreSettingsFormState> {
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
      case ChoreSettingsSection.reminders:
        final d = NotificationDefaults.defaults;
        state = state.copyWith(
          notificationDefaults: state.notificationDefaults.copyWith(
            chores: d.chores,
            defaultOffsetsMinutes: d.defaultOffsetsMinutes,
            overdueEnabled: d.overdueEnabled,
            overdueAfterMinutes: d.overdueAfterMinutes,
            morningSummaryEnabled: d.morningSummaryEnabled,
            morningSummaryMinutes: d.morningSummaryMinutes,
          ),
        );
      case ChoreSettingsSection.delivery:
        final resetModes = Map<String, DeliveryMode>.from(
          state.deliverySettings.modes,
        );
        for (final type in NotificationTypes.all) {
          if (type.category == NotificationCategory.chores) {
            resetModes[type.id] = type.pushCapable
                ? type.recommendedMode
                : DeliveryMode.normal;
          }
        }
        state = state.copyWith(
          deliverySettings: state.deliverySettings.copyWith(modes: resetModes),
        );
    }
    state = state.copyWith(clearFailure: true, justSaved: false);
  }
}
