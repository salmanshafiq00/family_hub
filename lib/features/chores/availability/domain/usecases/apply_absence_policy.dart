import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/availability/domain/availability_repository.dart';
import 'package:family_hub/features/chores/availability/domain/availability_write_plan.dart';
import 'package:family_hub/features/chores/availability/domain/usecases/auto_share_absent_chores.dart';
import 'package:family_hub/features/chores/duty_groups/domain/cover_picker.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_plan_helpers.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_repository.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_request.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_rules.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_write_plan.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';

/// What the policy did for one absence.
final class AbsenceOutcome {
  const AbsenceOutcome({
    required this.policy,
    required this.affected,
    this.requested = 0,
    this.uncovered = 0,
  });

  final AbsencePolicy policy;

  /// The member's unstarted chores inside the absence (A and C list them; B
  /// asked somebody for each).
  final List<ChoreOccurrence> affected;

  /// Cover requests created (policy B only).
  final int requested;

  /// Chores nobody could be asked for (policy B), reported like policy A.
  final int uncovered;
}

/// Applies the family's absence policy after an absence became ACTIVE (P3-26,
/// D-P3-13). INTEGRITY write.
///
/// The affected chores are the member's stored, unstarted, undeleted chores
/// inside the range (a day that has no document yet is planned by the generator,
/// which already reads the same absence).
///
/// * **A ask for cover:** nothing on the chores; ONE `needs_cover` inbox row
///   (with the count) for the member and for each manager.
/// * **B auto cover:** per chore, [CoverPicker] picks an available active member
///   and a `cover` request is created for them with an inbox row and an audit
///   entry. **The chore is not touched until they accept.** A chore nobody can be
///   asked for counts as uncovered and is reported like policy A.
/// * **C skip:** nothing is written; the result lists the chores so a manager can
///   skip them one by one (`SkipOccurrence`).
///
/// Ids are deterministic (`cv_{availabilityId}_{hash}`), so running it
/// twice rewrites the same documents and an already pending cover is skipped.
class ApplyAbsencePolicy {
  const ApplyAbsencePolicy({
    required this.families,
    required this.choreSettings,
    required this.availability,
    required this.occurrences,
    required this.swaps,
    required this.clock,
    this.inbox = const NoopInboxPort(),
    this.autoShare,
  });

  /// Most chores one run handles (3 documents each; the batch limit is 500).
  static const int maxPerRun = 100;

  final FamilyRepository families;
  final ChoreSettingsRepository choreSettings;
  final AvailabilityRepository availability;
  final OccurrenceRepository occurrences;
  final SwapRepository swaps;
  final Clock clock;
  final InboxPort inbox;

  /// Policy D (`auto_assign`): runs before the affected chores are listed, so
  /// whatever it moved is no longer "affected". Only a member who may reassign
  /// chores moves anything; for everybody else it is a no-op and the rest of
  /// this use case reports the chores like policy A.
  final AutoShareAbsentChores? autoShare;

  Future<Result<AbsenceOutcome>> call({
    required String familyId,
    required String actorUid,
    required String availabilityId,
  }) async {
    final loaded = await loadActiveActor(families, familyId, actorUid);
    final actorFailure = loaded.failureOrNull;
    if (actorFailure != null) return Failure<AbsenceOutcome>(actorFailure);
    final actor = loaded.valueOrNull!;

    final found = await availability.get(familyId, availabilityId);
    final readFailure = found.failureOrNull;
    if (readFailure != null) return Failure<AbsenceOutcome>(readFailure);
    final record = found.valueOrNull;
    if (record == null) {
      return const Failure<AbsenceOutcome>(NotFound(entity: 'availability'));
    }
    if (actorUid != record.memberId) {
      final denied = checkPermission(
        actor.member,
        Permission.manageAvailability,
        settings: actor.settings,
      ).failureOrNull;
      if (denied != null) return Failure<AbsenceOutcome>(denied);
    }
    if (!record.isActive) {
      return const Failure<AbsenceOutcome>(Conflict(code: 'concurrent_edit'));
    }

    final policy =
        (await choreSettings.getAbsencePolicy(familyId)).valueOrNull ??
        AbsencePolicy.autoAssign;
    if (policy == AbsencePolicy.autoAssign) {
      final share = autoShare;
      if (share != null) {
        await share(familyId: familyId, actorUid: actorUid);
      }
    }
    final listed = await occurrences.listRange(
      familyId,
      from: record.startDate,
      to: record.endDate,
    );
    final listFailure = listed.failureOrNull;
    if (listFailure != null) return Failure<AbsenceOutcome>(listFailure);
    final affected = <ChoreOccurrence>[
      for (final o in listed.valueOrNull!)
        if (!o.isDeleted && o.assigneeId == record.memberId && isUnstarted(o))
          o,
    ]..sort((a, b) => a.dateKey.compareTo(b.dateKey));
    if (affected.isEmpty || policy == AbsencePolicy.skip) {
      return Success<AbsenceOutcome>(
        AbsenceOutcome(policy: policy, affected: affected),
      );
    }

    final members =
        (await families.getMembers(familyId)).valueOrNull ?? const [];
    final at = clock.nowUtc();
    final inboxRows = <NewInboxItem>[];
    final audits = <NewAudit>[];
    final creates = <NewSwap>[];
    var uncovered = affected.length;

    if (policy == AbsencePolicy.autoCover) {
      final settings = (await choreSettings.get(familyId)).valueOrNull;
      final buffer = settings?.swapExpiryBufferMinutes ?? 120;
      final records = await availability.listActive(familyId, record.startDate);
      final index = AvailabilityIndex.fromRecords(
        records.valueOrNull ?? const [],
      );
      final pending =
          (await swaps.listPending(familyId)).valueOrNull ?? const [];
      final busy = <String>{for (final r in pending) r.occurrenceId};
      final candidates = <String>[
        for (final m in members)
          if (m.isActive && m.uid != record.memberId) m.uid,
      ];
      final load = <String, int>{};
      for (final occurrence in affected.take(maxPerRun)) {
        if (busy.contains(occurrence.id)) {
          uncovered--;
          continue;
        }
        final expiresAt = swapExpiry(occurrence, buffer);
        final to = CoverPicker.pick(
          candidates: candidates,
          day: occurrence.dateKey,
          windowLoad: load,
          unavailable: index,
        );
        if (to == null || !expiresAt.isAfter(at)) continue;
        load[to] = (load[to] ?? 0) + 1;
        uncovered--;
        final id = coverRequestId(availabilityId, occurrence.id);
        final date = occurrence.dateKey.toString();
        creates.add(
          NewSwap(
            id: id,
            occurrenceId: occurrence.id,
            occurrenceDateKey: occurrence.dateKey,
            kind: SwapKind.cover,
            fromMemberId: record.memberId,
            toMemberId: to,
            reason: record.reason,
            expiresAt: expiresAt,
            availabilityId: availabilityId,
          ),
        );
        final row = inbox.swapRequested(
          requestId: id,
          toMemberId: to,
          choreName: occurrence.nameBn,
          dateKey: date,
          fromMemberId: record.memberId,
          cover: true,
        );
        if (row != null) inboxRows.add(row.withId('ib_$id'));
        audits.add(
          swapAudit(
            type: AuditEventType.choresSwapRequested,
            id: 'au_$id',
            requestId: id,
            name: occurrence.nameBn,
            date: date,
            from: record.memberId,
            to: to,
          ),
        );
      }
    }

    // A, and the part of B nobody could be asked for: tell the member and the
    // managers once, with the count.
    if (uncovered > 0) {
      final recipients = <String>{
        record.memberId,
        for (final m in managersOf(members)) m.uid,
      };
      for (final to in recipients) {
        final row = inbox.needsCover(
          availabilityId: availabilityId,
          toMemberId: to,
          absentMemberId: record.memberId,
          count: uncovered,
          from: record.startDate.toString(),
          to: record.endDate.toString(),
        );
        if (row != null) {
          inboxRows.add(row.withId('ib_nc_${availabilityId}_$to'));
        }
      }
    }

    final staged = await availability.stage(
      familyId,
      AvailabilityWritePlan(
        occurrence: OccurrenceWritePlan(
          actorId: actorUid,
          at: at,
          inbox: inboxRows,
          audits: audits,
        ),
        swaps: creates,
      ),
      integrity: true,
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<AbsenceOutcome>(writeFailure);
    return Success<AbsenceOutcome>(
      AbsenceOutcome(
        policy: policy,
        affected: affected,
        requested: creates.length,
        uncovered: uncovered,
      ),
    );
  }
}
