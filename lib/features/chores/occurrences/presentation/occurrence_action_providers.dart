import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/assign_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/complete_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/record_completion_exception.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/reassign_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/reopen_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/repair_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/skip_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/toggle_parent.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/toggle_subtask.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/uncomplete_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/unskip_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/verify_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/presentation/inbox_port_provider.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One provider per P3-14 use case.
///
/// A screen reads the provider and calls it; it never touches a repository and
/// never resets a provider by hand (the action providers are `autoDispose` by
/// convention, H10). The listeners push the new state back, so a screen only
/// needs the returned `Result` for its message.
final toggleSubtaskProvider = Provider<ToggleSubtask>(
  (ref) => ToggleSubtask(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final toggleParentProvider = Provider<ToggleParent>(
  (ref) => ToggleParent(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final completeOccurrenceProvider = Provider<CompleteOccurrence>(
  (ref) => CompleteOccurrence(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final uncompleteOccurrenceProvider = Provider<UncompleteOccurrence>(
  (ref) => UncompleteOccurrence(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final verifyOccurrenceProvider = Provider<VerifyOccurrence>(
  (ref) => VerifyOccurrence(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final reopenOccurrenceProvider = Provider<ReopenOccurrence>(
  (ref) => ReopenOccurrence(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
    inbox: ref.watch(inboxPortProvider),
  ),
);

final recordCompletionExceptionProvider = Provider<RecordCompletionException>(
  (ref) => RecordCompletionException(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final skipOccurrenceProvider = Provider<SkipOccurrence>(
  (ref) => SkipOccurrence(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final unskipOccurrenceProvider = Provider<UnskipOccurrence>(
  (ref) => UnskipOccurrence(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

final reassignOccurrenceProvider = Provider<ReassignOccurrence>(
  (ref) => ReassignOccurrence(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
    inbox: ref.watch(inboxPortProvider),
  ),
);

final assignOccurrenceProvider = Provider<AssignOccurrence>(
  (ref) => AssignOccurrence(reassign: ref.watch(reassignOccurrenceProvider)),
);

final repairStatusProvider = Provider<RepairStatus>(
  (ref) => RepairStatus(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);
