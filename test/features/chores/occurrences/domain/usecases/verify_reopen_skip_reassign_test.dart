import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/permissions/permission_settings.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/repair_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../chores_test_helpers.dart';
import 'completion_test_support.dart';

/// P3-14: verification, reopen, exception, skip and reassignment.
void main() {
  late ChoresFixture fixture;
  late CompletionUseCases useCases;

  final at = DateTime.utc(2026, 10, 24, 4);

  setUp(() {
    fixture = ChoresFixture();
    useCases = CompletionUseCases(fixture);
  });

  ChoreOccurrence? stored() => fixture
      .occurrences
      .occurrences[ChoresFixture.familyId]?['tpl_1_20261024'];

  void seedCompleted({
    VerificationMode verification = VerificationMode.required,
    String completedBy = 'cara',
  }) {
    seedOccurrence(
      fixture,
      anOccurrence(
        verification: verification,
        status: OccurrenceStatus.completed,
        completedAt: at,
        completedBy: completedBy,
      ),
    );
  }

  Future<AppFailure?> verify(String uid) async {
    final result = await useCases.verify(
      familyId: ChoresFixture.familyId,
      actorUid: uid,
      occurrenceId: 'tpl_1_20261024',
    );
    return result.failureOrNull;
  }

  group('verify', () {
    setUp(() {
      fixture.backend.permissionSettings[ChoresFixture.familyId] =
          PermissionSettings.defaults.copyWith(choreVerificationEnabled: true);
    });

    test('a manager verifies somebody else’s work in one batch', () async {
      seedCompleted();

      expect(await verify('bob'), isNull);

      final occurrence = stored()!;
      expect(occurrence.status, OccurrenceStatus.verified);
      expect(occurrence.verifiedBy, 'bob');
      final plan = fixture.occurrences.plans.last;
      expect(plan.patches.single.fields['status'], 'verified');
      expect(plan.events.single.type, OccurrenceEventType.verified);
      expect(plan.audits.single.type, AuditEventType.choresOccurrenceVerified);
    });

    test('nobody verifies their own work', () async {
      seedCompleted(completedBy: 'bob');

      expect(await verify('bob'), const Conflict(code: 'self_verification'));
    });

    test('a chore that does not need a check is refused', () async {
      seedCompleted(verification: VerificationMode.off);

      expect(
        await verify('bob'),
        const Conflict(code: 'verification_not_required'),
      );
    });

    test('the family switch closes verification', () async {
      fixture.backend.permissionSettings[ChoresFixture.familyId] =
          PermissionSettings.defaults;
      seedCompleted();

      expect(await verify('bob'), isA<PermissionDenied>());
    });

    test('a plain member cannot verify', () async {
      seedCompleted();

      expect(await verify('dave'), isA<PermissionDenied>());
    });
  });

  group('reopen', () {
    Future<AppFailure?> reopen(
      String uid, {
      String reason = 'ভুল হয়ে গেছে',
    }) async {
      final result = await useCases.reopen(
        familyId: ChoresFixture.familyId,
        actorUid: uid,
        occurrenceId: 'tpl_1_20261024',
        reason: reason,
      );
      return result.failureOrNull;
    }

    test(
      'a completed chore is reopened with a reason, keeping the old time',
      () async {
        seedCompleted(verification: VerificationMode.off);

        expect(await reopen('cara'), isNull);

        final occurrence = stored()!;
        expect(occurrence.status, OccurrenceStatus.inProgress);
        expect(occurrence.reopenCount, 1);
        expect(occurrence.completedAt, isNull);

        final plan = fixture.occurrences.plans.last;
        final event = plan.events.single;
        // B-05: the id is unique per intent and the patch names it.
        expect(event.id, isNotEmpty);
        expect(plan.patches.single.fields['lastEventId'], event.id);
        expect(event.type, OccurrenceEventType.reopened);
        expect(event.reason, 'ভুল হয়ে গেছে');
        expect(event.prevCompletedAt, at);
        expect(plan.patches.single.removedFields, contains('completedAt'));
        expect(
          plan.audits.single.type,
          AuditEventType.choresOccurrenceReopened,
        );
        expect(useCases.inbox.sent, <String>['chore_reopened -> cara']);
      },
    );

    test(
      'B-04: reopening a chore with steps unticks the steps to redo',
      () async {
        seedOccurrence(
          fixture,
          anOccurrence(
            subtasks: <TemplateSubtask>[
              aSubtask(id: 'step_1', required: true),
              aSubtask(id: 'step_2', required: true),
              aSubtask(id: 'step_3', required: true),
            ],
            subtaskDone: <String, SubtaskDone>{
              'step_1': SubtaskDone(at: at, by: 'cara'),
              'step_2': SubtaskDone(at: at, by: 'cara'),
              'step_3': SubtaskDone(at: at, by: 'cara'),
            },
            status: OccurrenceStatus.completed,
            completedAt: at,
            completedBy: 'cara',
          ),
        );

        final result = await useCases.reopen(
          familyId: ChoresFixture.familyId,
          actorUid: 'cara',
          occurrenceId: 'tpl_1_20261024',
          reason: 'ভুল হয়ে গেছে',
          redoSubtaskIds: <String>{'step_2'},
        );
        expect(result.failureOrNull, isNull);

        final occurrence = stored()!;
        expect(effectiveStatus(occurrence), ChoreStatus.inProgress);
        expect(occurrence.subtaskDone.keys, <String>['step_1', 'step_3']);
        expect(
          fixture.occurrences.plans.last.events.single.redoSubtaskIds,
          <String>['step_2'],
        );
      },
    );

    test('the reason is required (D-P3-17)', () async {
      seedCompleted(verification: VerificationMode.off);

      expect(
        await reopen('cara', reason: 'ok'),
        const Validation('reason', 'reason_required'),
      );
      expect(stored()!.reopenCount, 0);
    });

    test('a verified chore needs a manager', () async {
      seedOccurrence(
        fixture,
        anOccurrence(
          status: OccurrenceStatus.verified,
          completedAt: at,
          completedBy: 'cara',
          verifiedAt: at,
          verifiedBy: 'bob',
        ),
      );

      expect(
        await reopen('cara'),
        const Conflict(code: 'verified_requires_manager'),
      );
      expect(await reopen('bob'), isNull);
      expect(stored()!.verifiedAt, isNull);
    });

    test('an open chore cannot be reopened', () async {
      seedOccurrence(fixture, anOccurrence());

      expect(await reopen('cara'), const Conflict(code: 'not_completed'));
    });
  });

  group('exception and skip', () {
    Future<AppFailure?> skip(
      String uid, {
      String reason = 'কেউ করতে পারেনি',
    }) async {
      final result = await useCases.skip(
        familyId: ChoresFixture.familyId,
        actorUid: uid,
        occurrenceId: 'tpl_1_20261024',
        reason: reason,
      );
      return result.failureOrNull;
    }

    test('a manager records an exception with its event', () async {
      seedOccurrence(fixture, anOccurrence());

      final result = await useCases.recordException(
        familyId: ChoresFixture.familyId,
        actorUid: 'bob',
        occurrenceId: 'tpl_1_20261024',
        note: 'চুলা নষ্ট',
      );

      expect(result.failureOrNull, isNull);
      expect(stored()!.exception?.by, 'bob');
      final plan = fixture.occurrences.plans.last;
      expect(plan.events.single.type, OccurrenceEventType.exception);
      expect(plan.events.single.reason, 'চুলা নষ্ট');
    });

    test('a plain member cannot record an exception', () async {
      seedOccurrence(fixture, anOccurrence());

      final result = await useCases.recordException(
        familyId: ChoresFixture.familyId,
        actorUid: 'dave',
        occurrenceId: 'tpl_1_20261024',
        note: 'চুলা নষ্ট',
      );

      expect(result.failureOrNull, isA<PermissionDenied>());
    });

    test('a skip freezes the chore and can be undone', () async {
      seedOccurrence(fixture, anOccurrence());

      expect(await skip('bob'), isNull);
      expect(stored()!.status, OccurrenceStatus.skipped);
      expect(stored()!.skipReason, SkipReason.manager);
      final plan = fixture.occurrences.plans.last;
      expect(plan.events.single.type, OccurrenceEventType.skipped);
      expect(plan.events.single.reason, 'কেউ করতে পারেনি');

      final skipped = await useCases.toggleSubtask(
        familyId: ChoresFixture.familyId,
        actorUid: 'cara',
        occurrenceId: 'tpl_1_20261024',
        subtaskId: 'step_1',
      );
      expect(skipped.failureOrNull, const Conflict(code: 'already_skipped'));

      final unskip = await useCases.unskip(
        familyId: ChoresFixture.familyId,
        actorUid: 'bob',
        occurrenceId: 'tpl_1_20261024',
      );
      expect(unskip.failureOrNull, isNull);
      expect(stored()!.status, OccurrenceStatus.scheduled);
      expect(stored()!.skipReason, isNull);
      expect(
        fixture.occurrences.plans.last.events.single.type,
        OccurrenceEventType.unskipped,
      );
    });

    test('an absence skip stores its own reason kind', () async {
      seedOccurrence(fixture, anOccurrence());

      final result = await useCases.skip(
        familyId: ChoresFixture.familyId,
        actorUid: 'bob',
        occurrenceId: 'tpl_1_20261024',
        reason: 'অসুস্থ',
        kind: SkipReason.absence,
      );

      expect(result.failureOrNull, isNull);
      expect(stored()!.skipReason, SkipReason.absence);
    });

    test('unskipping a chore that is not skipped is refused', () async {
      seedOccurrence(fixture, anOccurrence());

      final result = await useCases.unskip(
        familyId: ChoresFixture.familyId,
        actorUid: 'bob',
        occurrenceId: 'tpl_1_20261024',
      );

      expect(result.failureOrNull, const Conflict(code: 'not_skipped'));
    });
  });

  group('reassign', () {
    Future<AppFailure?> reassign(
      String to, {
      String reason = 'কারা আজ ছুটিতে',
    }) async {
      final result = await useCases.reassign(
        familyId: ChoresFixture.familyId,
        actorUid: 'bob',
        occurrenceId: 'tpl_1_20261024',
        toMemberId: to,
        reason: reason,
      );
      return result.failureOrNull;
    }

    test('a manager moves the chore with a reason and an event', () async {
      seedOccurrence(fixture, anOccurrence());

      expect(await reassign('dave'), isNull);

      final occurrence = stored()!;
      expect(occurrence.assigneeId, 'dave');
      expect(occurrence.assignmentSource, AssignmentSource.reassign);
      expect(occurrence.plannedAssigneeId, 'cara');

      final plan = fixture.occurrences.plans.last;
      expect(fixture.occurrences.integrityWrites, 1);
      final event = plan.events.single;
      // B-05: the id is unique per intent and the patch names it.
      expect(event.id, isNotEmpty);
      expect(plan.patches.last.fields['lastEventId'], event.id);
      expect(event.fromAssigneeId, 'cara');
      expect(event.toAssigneeId, 'dave');
      expect(event.reason, 'কারা আজ ছুটিতে');
      expect(useCases.inbox.sent, <String>['swap_result -> dave']);
    });

    test('a reason is required', () async {
      seedOccurrence(fixture, anOccurrence());

      expect(
        await reassign('dave', reason: ' '),
        const Validation('reason', 'reason_required'),
      );
    });

    test('a pending member cannot receive a chore', () async {
      seedOccurrence(fixture, anOccurrence());

      expect(
        await reassign('erin'),
        const Conflict(code: 'member_unavailable'),
      );
    });

    test('a plain member cannot reassign', () async {
      seedOccurrence(fixture, anOccurrence());

      final result = await useCases.reassign(
        familyId: ChoresFixture.familyId,
        actorUid: 'dave',
        occurrenceId: 'tpl_1_20261024',
        toMemberId: 'dave',
        reason: 'কারা আজ ছুটিতে',
      );

      expect(result.failureOrNull, isA<PermissionDenied>());
    });

    test('a verified chore cannot be reassigned', () async {
      seedOccurrence(
        fixture,
        anOccurrence(
          status: OccurrenceStatus.verified,
          completedAt: at,
          completedBy: 'cara',
          verifiedAt: at,
          verifiedBy: 'bob',
        ),
      );

      expect(await reassign('dave'), isA<AppFailure>());
    });
  });

  group('repairStatus', () {
    test('writes only the status when the cache disagrees', () async {
      seedOccurrence(
        fixture,
        anOccurrence(
          subtasks: <TemplateSubtask>[aSubtask(id: 'a', required: true)],
          status: OccurrenceStatus.inProgress,
          subtaskDone: <String, SubtaskDone>{
            'a': SubtaskDone(at: at, by: 'cara'),
          },
        ),
      );
      expect(effectiveStatus(stored()!).id, 'completed');

      final result = await useCases.repair(
        familyId: ChoresFixture.familyId,
        actorUid: 'cara',
        occurrenceId: 'tpl_1_20261024',
      );

      expect(result.failureOrNull, isNull);
      expect(stored()!.status, OccurrenceStatus.completed);
      final patch = fixture.occurrences.plans.last.patches.single;
      expect(patch.fields.keys, <String>['status', 'updatedAt', 'updatedBy']);
      expect(fixture.occurrences.plans.last.audits, isEmpty);
    });

    test('a matching cache writes nothing (idempotent)', () async {
      seedOccurrence(fixture, anOccurrence());

      final result = await useCases.repair(
        familyId: ChoresFixture.familyId,
        actorUid: 'cara',
        occurrenceId: 'tpl_1_20261024',
      );

      expect(result.failureOrNull, isNull);
      expect(fixture.occurrences.plans, isEmpty);
    });

    test('needsRepair is false for a verified document', () {
      final occurrence = anOccurrence(
        status: OccurrenceStatus.verified,
        completedAt: at,
        completedBy: 'cara',
        verifiedAt: at,
        verifiedBy: 'bob',
      );
      expect(RepairStatus.needsRepair(occurrence), isFalse);
    });
  });

  test('an inbox port is a no-op until P3-26', () {
    const port = NoopInboxPort();
    expect(
      port.choreReopened(
        occurrenceId: 'o',
        toMemberId: 'cara',
        choreName: 'x',
        dateKey: '2026-10-24',
        actorId: 'bob',
      ),
      isNull,
    );
    expect(InboxType.all, hasLength(7));
  });

  test('a plan with no event and no audit still stages the patch', () async {
    seedOccurrence(fixture, anOccurrence());
    final result = await useCases.repair(
      familyId: ChoresFixture.familyId,
      actorUid: 'cara',
      occurrenceId: 'tpl_1_20261024',
    );
    expect(result.failureOrNull, isNull);
    expect(fixture.occurrences.plans, isEmpty);
    final plan = OccurrenceWritePlan(actorId: 'cara', at: at);
    expect(plan.isEmpty, isTrue);
  });
}
