import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';

/// Maps a chore failure to localized text (road map 3.6).
///
/// The domain returns stable codes (`Conflict('required_subtasks_open')`), never
/// copy; this is the ONE place a screen turns one into a sentence. Every code of
/// road map 3.6 has a `choresFailure_*` key in both ARBs, and an unknown code
/// falls back to the generic message — a raw code is never shown (CLAUDE.md
/// rule 9).
extension ChoresFailureMessages on AppLocalizations {
  String choresFailureMessage(AppFailure failure) => switch (failure) {
    Validation(field: _, code: final code) => _validation(code),
    Conflict(code: final code) => _conflict(code),
    NotFound() => choresFailure_not_found,
    PermissionDenied() => choresFailure_permission_denied,
    Network() => choresFailure_network,
    Unknown() ||
    InvalidCredentials() ||
    UserNotFound() ||
    EmailAlreadyInUse() ||
    WeakPassword() ||
    TooManyRequests() ||
    UserDisabled() ||
    RequiresRecentLogin() ||
    InvalidEmail() ||
    NoCurrentUser() => choresFailure_unknown,
  };

  String _validation(String code) => switch (code) {
    'required' => choresFailure_required,
    'too_long' => choresFailure_too_long,
    'invalid_time' => choresFailure_invalid_time,
    'invalid_recurrence' => choresFailure_invalid_recurrence,
    'no_dates' => choresFailure_no_dates,
    'invalid_range' => choresFailure_invalid_range,
    'invalid_date' => choresFailure_invalid_date,
    'too_many_subtasks' => choresFailure_too_many_subtasks,
    'too_many_slots' => choresFailure_too_many_slots,
    'duplicate_slot' => choresFailure_duplicate_slot,
    'too_many_items' => choresFailure_too_many_items,
    'duplicate_id' => choresFailure_duplicate_id,
    'reason_required' => choresFailure_reason_required,
    'reason_too_short' => choresFailure_reason_too_short,
    'member_required' => choresFailure_member_required,
    'invalid_rotation' => choresFailure_invalid_rotation,
    'too_few_members' => choresFailure_too_few_members,
    'invalid_horizon' => choresFailure_invalid_horizon,
    'invalid_week_start' => choresFailure_invalid_week_start,
    'invalid_minutes' => choresFailure_invalid_minutes,
    _ => choresFailure_unknown,
  };

  String _conflict(String? code) => switch (code) {
    'not_assigned_to_you' => choresFailure_not_assigned_to_you,
    'already_completed' => choresFailure_already_completed,
    'not_completed' => choresFailure_not_completed,
    'required_subtasks_open' => choresFailure_required_subtasks_open,
    'self_verification' => choresFailure_self_verification,
    'verification_not_required' => choresFailure_verification_not_required,
    'already_verified' => choresFailure_already_verified,
    'verified_requires_manager' => choresFailure_verified_requires_manager,
    'occurrence_started' => choresFailure_occurrence_started,
    'already_skipped' => choresFailure_already_skipped,
    'not_skipped' => choresFailure_not_skipped,
    'swap_not_pending' => choresFailure_swap_not_pending,
    'swap_expired' => choresFailure_swap_expired,
    'swaps_disabled' => choresFailure_swaps_disabled,
    'cover_not_needed' => choresFailure_cover_not_needed,
    'availability_overlap' => choresFailure_availability_overlap,
    'member_unavailable' => choresFailure_member_unavailable,
    'template_paused' => choresFailure_template_paused,
    'rotation_member_inactive' => choresFailure_rotation_member_inactive,
    'range_too_large' => choresFailure_range_too_large,
    'starter_pack_applied' => choresFailure_starter_pack_applied,
    'occurrence_deleted' => choresFailure_occurrence_deleted,
    'concurrent_edit' => choresFailure_concurrent_edit,
    'last_group_in_use' => choresFailure_last_group_in_use,
    'not_a_recipient' => choresFailure_not_a_recipient,
    // The two codes P3-14 adds on top of road map 3.6.
    'already_assigned' => choresFailure_cover_not_needed,
    _ => choresFailure_unknown,
  };
}
