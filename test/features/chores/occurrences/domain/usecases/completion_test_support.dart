import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
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
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';

import '../../../chores_test_helpers.dart';

/// P3-14: every completion use case, wired to one [ChoresFixture].
///
/// It keeps the use-case constructors out of each test, so a test is only about
/// the behaviour: who may act, which code comes back, what the plan wrote.
class CompletionUseCases {
  CompletionUseCases(this.fixture);

  final ChoresFixture fixture;

  ToggleSubtask get toggleSubtask => ToggleSubtask(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  ToggleParent get toggleParent => ToggleParent(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  CompleteOccurrence get complete => CompleteOccurrence(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  UncompleteOccurrence get uncomplete => UncompleteOccurrence(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  VerifyOccurrence get verify => VerifyOccurrence(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  ReopenOccurrence get reopen => ReopenOccurrence(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
    inbox: inbox,
  );

  RecordCompletionException get recordException => RecordCompletionException(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  SkipOccurrence get skip => SkipOccurrence(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  UnskipOccurrence get unskip => UnskipOccurrence(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  ReassignOccurrence get reassign => ReassignOccurrence(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
    inbox: inbox,
  );

  RepairStatus get repair => RepairStatus(
    occurrences: fixture.occurrences,
    templates: fixture.chores,
    families: fixture.families,
    dutyGroups: fixture.chores.dutyGroups,
    settings: fixture.settings,
    dateKeys: fixture.dateKeys,
    clock: fixture.clock,
  );

  /// The inbox the reopen/reassign use cases write through.
  final RecordingInboxPort inbox = RecordingInboxPort();
}

/// An [InboxPort] that builds the real rows and remembers them, so a test can
/// assert the notification a flow WOULD send (P3-26 replaces it in the app).
class RecordingInboxPort implements InboxPort {
  /// One entry per row, as `type -> recipient`.
  final List<String> sent = <String>[];

  @override
  NewInboxItem? choreReopened({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String actorId,
  }) => _record(
    InboxType.choreReopened,
    toMemberId,
    occurrenceId,
    <String, String>{'name': choreName, 'date': dateKey, 'by': actorId},
  );

  @override
  NewInboxItem? verificationNeeded({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String completedBy,
  }) => _record(
    InboxType.verificationNeeded,
    toMemberId,
    occurrenceId,
    <String, String>{'name': choreName, 'date': dateKey, 'by': completedBy},
  );

  @override
  NewInboxItem? choreReassigned({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String byMemberId,
  }) => _record(
    InboxType.swapResult,
    toMemberId,
    occurrenceId,
    <String, String>{'name': choreName, 'date': dateKey, 'by': byMemberId},
  );

  NewInboxItem _record(
    String type,
    String toMemberId,
    String occurrenceId,
    Map<String, String> params,
  ) {
    sent.add('$type -> $toMemberId');
    return choreInboxItem(
      type: type,
      toMemberId: toMemberId,
      occurrenceId: occurrenceId,
      params: params,
    );
  }
}

/// Seeds one stored occurrence for the fixture family.
ChoreOccurrence seedOccurrence(
  ChoresFixture fixture,
  ChoreOccurrence occurrence,
) {
  (fixture.occurrences.occurrences[ChoresFixture.familyId] ??=
          <String, ChoreOccurrence>{})[occurrence.id] =
      occurrence;
  return occurrence;
}

/// Seeds the template a projected item is derived from (daily, 09:00, manual).
void seedTemplate(ChoresFixture fixture, ChoreTemplate template) {
  (fixture.chores.templates[ChoresFixture.familyId] ??=
          <String, ChoreTemplate>{})[template.id] =
      template;
}

/// The template matching `anOccurrence()`'s snapshot: id `tpl_1`, daily, 09:00.
ChoreTemplate matchingTemplate({
  String id = 'tpl_1',
  bool active = true,
  DateKey? startDate,
}) => wrapTemplate(
  aTemplate(startDate: startDate),
  id: id,
  active: active,
);

/// Wraps a draft in the template a projected item is generated from.
ChoreTemplate wrapTemplate(
  TemplateDraft draft, {
  String id = 'tpl_1',
  bool active = true,
}) => ChoreTemplate(id: id, draft: draft, active: active);

/// Today's date key on the fixture clock (2026-10-24).
DateKey get fixtureToday => DateKey(2026, 10, 24);
