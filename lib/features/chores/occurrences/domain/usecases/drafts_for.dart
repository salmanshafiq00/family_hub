import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_generator.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';

/// The ONE place that loads what [OccurrenceGenerator] needs and builds the
/// drafts for [range] (B-08, C-9).
///
/// `EnsureOccurrences` (persisted generation) and the projected-item path of
/// every completion use case both call it, so a projected day, a materialized
/// day and the calendar projection can never disagree about who is on duty:
/// the duty groups, the absence policy and the member roster are loaded the
/// same way everywhere.
///
/// [availabilityIndex] is empty until the availability feature (P3-26) supplies
/// a real one; callers that already hold one pass it in.
Future<Result<List<OccurrenceDraft>>> draftsFor({
  required String familyId,
  required List<ChoreTemplate> templates,
  required DateKeyRange range,
  required DutyGroupRepository dutyGroups,
  required ChoreSettingsRepository settings,
  required FamilyRepository families,
  required FamilyDateKeys dateKeys,
  AvailabilityIndex availabilityIndex = AvailabilityIndex.empty,
}) async {
  final policy = await settings.getAbsencePolicy(familyId);
  final policyFailure = policy.failureOrNull;
  if (policyFailure != null) {
    return Failure<List<OccurrenceDraft>>(policyFailure);
  }

  final groups = await dutyGroups.list(familyId);
  final groupsFailure = groups.failureOrNull;
  if (groupsFailure != null) {
    return Failure<List<OccurrenceDraft>>(groupsFailure);
  }

  // The roster decides whether a planned owner is ACTIVE (D-P3-12); an empty
  // list would make every rotation/fixed draft look unassigned.
  final members = await families.getMembers(familyId);
  final membersFailure = members.failureOrNull;
  if (membersFailure != null) {
    return Failure<List<OccurrenceDraft>>(membersFailure);
  }

  return Success<List<OccurrenceDraft>>(
    OccurrenceGenerator.drafts(
      templates: templates,
      dutyGroups: groups.valueOrNull ?? const [],
      members: members.valueOrNull ?? const [],
      range: range,
      dateKeys: dateKeys,
      availabilityIndex: availabilityIndex,
      policy: policy.valueOrNull ?? AbsencePolicy.autoAssign,
    ),
  );
}
