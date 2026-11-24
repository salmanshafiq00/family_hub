import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/availability/domain/availability_repository.dart';
import 'package:family_hub/features/chores/availability/domain/member_availability.dart';
import 'package:family_hub/features/chores/duty_groups/domain/cover_picker.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/reassign_occurrence.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_plan_helpers.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_rules.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';

/// Shares out the chores of members who are away (policy `auto_assign`).
///
/// For every stored, unstarted chore from today on whose owner is unavailable
/// that day it picks another available, active member, the chore's own duty
/// group first, then anybody in the family, fewest chores first, and moves the
/// chore with [ReassignOccurrence]. The planned owner stays on the chore, so the
/// rotation is NOT shifted for anybody (D-P3-12). A chore nobody can take stays
/// with its owner and shows on the Needs cover list.
///
/// Only a member who may reassign chores can run it (the Firestore rules say
/// the same); for anybody else it quietly does nothing. Unless [force] is set it
/// also does nothing when the family's policy is not `auto_assign`. Running it
/// twice is harmless: a chore that was moved no longer matches.
class AutoShareAbsentChores {
  const AutoShareAbsentChores({
    required this.families,
    required this.choreSettings,
    required this.availability,
    required this.occurrences,
    required this.templates,
    required this.dutyGroups,
    required this.reassign,
    required this.dateKeys,
    required this.inbox,
    required this.clock,
  });

  /// Most chores moved by one run (each move is its own server write).
  static const int maxPerRun = 40;

  /// How far ahead an absence is looked at (days from today).
  static const int horizonDays = 60;

  final FamilyRepository families;
  final ChoreSettingsRepository choreSettings;
  final AvailabilityRepository availability;
  final OccurrenceRepository occurrences;
  final TemplateRepository templates;
  final DutyGroupRepository dutyGroups;
  final ReassignOccurrence reassign;
  final FamilyDateKeys dateKeys;
  final InboxPort inbox;
  final Clock clock;

  /// The number of chores moved.
  Future<Result<int>> call({
    required String familyId,
    required String actorUid,
    bool force = false,
  }) async {
    final loaded = await loadActiveActor(families, familyId, actorUid);
    final actorFailure = loaded.failureOrNull;
    if (actorFailure != null) return Failure<int>(actorFailure);
    final actor = loaded.valueOrNull!;
    final denied = checkPermission(
      actor.member,
      Permission.reassignChore,
      settings: actor.settings,
    ).failureOrNull;
    if (denied != null) return const Success<int>(0);

    final policy =
        (await choreSettings.getAbsencePolicy(familyId)).valueOrNull ??
        AbsencePolicy.autoAssign;
    if (!force && policy != AbsencePolicy.autoAssign) {
      return const Success<int>(0);
    }

    final today = dateKeys.today();
    final activeRecords =
        (await availability.listActive(familyId, today)).valueOrNull ??
        const <MemberAvailability>[];
    if (activeRecords.isEmpty) return const Success<int>(0);
    final index = AvailabilityIndex.fromRecords(activeRecords);
    final horizon = today.addDays(horizonDays);
    var last = today;
    for (final record in activeRecords) {
      if (record.endDate.isAfter(last)) last = record.endDate;
    }
    if (last.isAfter(horizon)) last = horizon;

    final listed = await occurrences.listRange(familyId, from: today, to: last);
    final listFailure = listed.failureOrNull;
    if (listFailure != null) return Failure<int>(listFailure);
    final affected = <ChoreOccurrence>[
      for (final o in listed.valueOrNull!)
        if (!o.isDeleted &&
            o.assigneeId != null &&
            isUnstarted(o) &&
            index.isUnavailable(o.assigneeId!, o.dateKey))
          o,
    ]..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    if (affected.isEmpty) return const Success<int>(0);

    final members =
        (await families.getMembers(familyId)).valueOrNull ?? const [];
    final everybody = <String>[
      for (final m in members)
        if (m.isActive) m.uid,
    ];
    final templateList =
        (await templates.list(familyId)).valueOrNull ??
        const <TemplateRecord>[];
    final groupOfTemplate = <String, String>{
      for (final record in templateList)
        if (record.template.draft.assignee.dutyGroupId != null)
          record.template.id: record.template.draft.assignee.dutyGroupId!,
    };
    final groupList = (await dutyGroups.list(familyId)).valueOrNull ?? const [];
    final membersOfGroup = <String, List<String>>{
      for (final group in groupList)
        if (group.active) group.id: group.members,
    };

    final load = <String, int>{};
    final movedTo = <String, List<ChoreOccurrence>>{};
    var moved = 0;
    for (final occurrence in affected.take(maxPerRun)) {
      final absent = occurrence.assigneeId!;
      final groupId = groupOfTemplate[occurrence.templateId];
      final groupMembers = groupId == null ? null : membersOfGroup[groupId];
      String? to;
      if (groupMembers != null) {
        to = CoverPicker.pick(
          candidates: <String>[
            for (final uid in groupMembers)
              if (everybody.contains(uid)) uid,
          ],
          day: occurrence.dateKey,
          windowLoad: load,
          unavailable: index,
          exclude: <String>{absent},
        );
      }
      // Nobody free in the duty group: anybody else in the family.
      to ??= CoverPicker.pick(
        candidates: everybody,
        day: occurrence.dateKey,
        windowLoad: load,
        unavailable: index,
        exclude: <String>{absent},
      );
      if (to == null) continue;

      final result = await reassign(
        familyId: familyId,
        actorUid: actorUid,
        occurrenceId: occurrence.id,
        toMemberId: to,
        reason: _reasonFor(activeRecords, absent, occurrence),
        notify: false,
      );
      if (result.failureOrNull == null) {
        moved++;
        load[to] = (load[to] ?? 0) + 1;
        movedTo.putIfAbsent(to, () => <ChoreOccurrence>[]).add(occurrence);
      }
    }

    // ONE row per recipient instead of one per chore: 40 moves used to become
    // 40 phone notifications. Best effort: the moves already happened, so a
    // failed summary must not change the count the caller gets back.
    final rows = <NewInboxItem>[];
    for (final entry in movedTo.entries) {
      final to = entry.key;
      if (to == actorUid) continue;
      final list = entry.value..sort((a, b) => a.dateKey.compareTo(b.dateKey));
      final row = inbox.choresAssignedSummary(
        batchId: 'as_${list.first.id}',
        toMemberId: to,
        byMemberId: actorUid,
        count: list.length,
        from: list.first.dateKey.toString(),
        to: list.last.dateKey.toString(),
      );
      if (row != null) rows.add(row.withId('ib_as_${list.first.id}'));
    }
    if (rows.isNotEmpty) {
      await occurrences.stageIntegrity(
        familyId,
        OccurrenceWritePlan(actorId: actorUid, at: clock.nowUtc(), inbox: rows),
      );
    }
    return Success<int>(moved);
  }

  /// The absent member's own reason (3-300 characters), so the history of the
  /// chore says WHY it moved.
  static String _reasonFor(
    List<MemberAvailability> records,
    String memberId,
    ChoreOccurrence occurrence,
  ) {
    for (final record in records) {
      if (record.memberId == memberId &&
          !occurrence.dateKey.isBefore(record.startDate) &&
          !occurrence.dateKey.isAfter(record.endDate)) {
        final text = record.reason.trim();
        if (text.length >= 3) {
          return text.length > 300 ? text.substring(0, 300) : text;
        }
      }
    }
    return 'Absent';
  }
}
