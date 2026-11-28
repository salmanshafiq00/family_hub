import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';

/// The parts of the settings page that have their own "Reset to defaults".
enum ChoreSettingsSection {
  calendar,
  generation,
  catalogs,
  policies,
  houseRules,
  reminders,
  delivery,
}

/// What the chore settings page holds while it is open (P3-17).
///
/// [draft], [policy], [completeForOthers], [notificationDefaults] and
/// [deliverySettings] are what the user is editing; the `saved*` fields are what
/// the server has, so "unsaved changes" is one value comparison per field.
final class ChoreSettingsFormState {
  const ChoreSettingsFormState({
    required this.draft,
    required this.saved,
    required this.policy,
    required this.savedPolicy,
    required this.completeForOthers,
    required this.savedCompleteForOthers,
    required this.notificationDefaults,
    required this.savedNotificationDefaults,
    required this.deliverySettings,
    required this.savedDeliverySettings,
    this.saving = false,
    this.failure,
    this.justSaved = false,
  });

  final ChoreSettings draft;
  final ChoreSettings saved;
  final AbsencePolicy policy;
  final AbsencePolicy savedPolicy;
  final bool completeForOthers;
  final bool savedCompleteForOthers;
  final NotificationDefaults notificationDefaults;
  final NotificationDefaults savedNotificationDefaults;
  final NotificationDeliverySettings deliverySettings;
  final NotificationDeliverySettings savedDeliverySettings;
  final bool saving;

  /// The last save failure; shown inline, never rolled into a silent retry.
  final AppFailure? failure;

  /// True right after a successful save (a snackbar shows once).
  final bool justSaved;

  bool isSectionDirty(ChoreSettingsSection section) {
    switch (section) {
      case ChoreSettingsSection.calendar:
        return draft.weekStartDay != saved.weekStartDay ||
            draft.defaultCalendarView != saved.defaultCalendarView ||
            draft.defaultScope != saved.defaultScope ||
            draft.showProjected != saved.showProjected ||
            draft.projectedMonthsAhead != saved.projectedMonthsAhead;
      case ChoreSettingsSection.generation:
        return draft.generationHorizonDays != saved.generationHorizonDays ||
            draft.overdueGraceMinutes != saved.overdueGraceMinutes;
      case ChoreSettingsSection.catalogs:
        return !_sameList(draft.groups, saved.groups) ||
            !_sameList(draft.dueTimePresets, saved.dueTimePresets) ||
            !_sameList(draft.absenceReasons, saved.absenceReasons);
      case ChoreSettingsSection.policies:
        return policy != savedPolicy ||
            completeForOthers != savedCompleteForOthers ||
            draft.swapsEnabled != saved.swapsEnabled ||
            draft.swapExpiryBufferMinutes != saved.swapExpiryBufferMinutes ||
            draft.absenceNeedsApproval != saved.absenceNeedsApproval ||
            draft.workloadVisibleToMembers != saved.workloadVisibleToMembers;
      case ChoreSettingsSection.houseRules:
        return draft.houseRules != saved.houseRules;
      case ChoreSettingsSection.reminders:
        return notificationDefaults.chores !=
                savedNotificationDefaults.chores ||
            !_sameList(
              notificationDefaults.defaultOffsetsMinutes,
              savedNotificationDefaults.defaultOffsetsMinutes,
            ) ||
            notificationDefaults.overdueEnabled !=
                savedNotificationDefaults.overdueEnabled ||
            notificationDefaults.overdueAfterMinutes !=
                savedNotificationDefaults.overdueAfterMinutes ||
            notificationDefaults.morningSummaryEnabled !=
                savedNotificationDefaults.morningSummaryEnabled ||
            notificationDefaults.morningSummaryMinutes !=
                savedNotificationDefaults.morningSummaryMinutes;
      case ChoreSettingsSection.delivery:
        for (final type in NotificationTypes.all) {
          if (type.category == NotificationCategory.chores) {
            final currentMode =
                deliverySettings.modes[type.id] ?? type.recommendedMode;
            final savedMode =
                savedDeliverySettings.modes[type.id] ?? type.recommendedMode;
            if (currentMode != savedMode) return true;
          }
        }
        return false;
    }
  }

  static bool _sameList<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool get isDirty =>
      draft != saved ||
      policy != savedPolicy ||
      completeForOthers != savedCompleteForOthers ||
      isSectionDirty(ChoreSettingsSection.reminders) ||
      isSectionDirty(ChoreSettingsSection.delivery);

  /// True when the failure is "no connection": the page shows the dedicated
  /// "needs internet" text because settings writes need the server.
  bool get needsInternet => failure is Network;

  ChoreSettingsFormState copyWith({
    ChoreSettings? draft,
    ChoreSettings? saved,
    AbsencePolicy? policy,
    AbsencePolicy? savedPolicy,
    bool? completeForOthers,
    bool? savedCompleteForOthers,
    NotificationDefaults? notificationDefaults,
    NotificationDefaults? savedNotificationDefaults,
    NotificationDeliverySettings? deliverySettings,
    NotificationDeliverySettings? savedDeliverySettings,
    bool? saving,
    AppFailure? failure,
    bool? justSaved,
    bool clearFailure = false,
  }) => ChoreSettingsFormState(
    draft: draft ?? this.draft,
    saved: saved ?? this.saved,
    policy: policy ?? this.policy,
    savedPolicy: savedPolicy ?? this.savedPolicy,
    completeForOthers: completeForOthers ?? this.completeForOthers,
    savedCompleteForOthers:
        savedCompleteForOthers ?? this.savedCompleteForOthers,
    notificationDefaults: notificationDefaults ?? this.notificationDefaults,
    savedNotificationDefaults:
        savedNotificationDefaults ?? this.savedNotificationDefaults,
    deliverySettings: deliverySettings ?? this.deliverySettings,
    savedDeliverySettings: savedDeliverySettings ?? this.savedDeliverySettings,
    saving: saving ?? this.saving,
    failure: clearFailure ? null : (failure ?? this.failure),
    justSaved: justSaved ?? this.justSaved,
  );
}
