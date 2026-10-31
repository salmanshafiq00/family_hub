import 'package:family_hub/core/errors/app_failure.dart';

/// How the last duty-group action ended.
enum DutyGroupStatus {
  idle,

  /// The change is stored and the dates are planned.
  saved,

  /// Nothing was stored; [DutyGroupFormState.failure] says why.
  failed,

  /// The change IS stored, but planning the dates failed (retry, never undo).
  planningFailed,
}

/// The state of the duty-group editor and its sheets (P3-18).
final class DutyGroupFormState {
  const DutyGroupFormState({
    this.saving = false,
    this.status = DutyGroupStatus.idle,
    this.failure,
    this.planningFailure,
  });

  final bool saving;
  final DutyGroupStatus status;
  final AppFailure? failure;
  final AppFailure? planningFailure;

  /// The manager must confirm switching off a group chores still use.
  bool get needsDeactivateConfirm => switch (failure) {
    Conflict(code: 'last_group_in_use') => true,
    _ => false,
  };

  DutyGroupFormState copyWith({
    bool? saving,
    DutyGroupStatus? status,
    AppFailure? failure,
    AppFailure? planningFailure,
    bool clearFailure = false,
    bool clearPlanningFailure = false,
  }) => DutyGroupFormState(
    saving: saving ?? this.saving,
    status: status ?? this.status,
    failure: clearFailure ? null : (failure ?? this.failure),
    planningFailure: clearPlanningFailure
        ? null
        : (planningFailure ?? this.planningFailure),
  );
}
