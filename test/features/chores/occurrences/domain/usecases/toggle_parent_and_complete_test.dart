import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';

import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../chores_test_helpers.dart';
import 'completion_test_support.dart';

/// P3-14: the parent checkbox and one-tap completion.
void main() {
  late ChoresFixture fixture;
  late CompletionUseCases useCases;

  setUp(() {
    fixture = ChoresFixture();
    useCases = CompletionUseCases(fixture);
  });

  Future<AppFailure?> toggleParent(String uid) async {
    final result = await useCases.toggleParent(
      familyId: ChoresFixture.familyId,
      actorUid: uid,
      occurrenceId: 'tpl_1_20261024',
    );
    return result.failureOrNull;
  }

  Future<AppFailure?> complete(String uid) async {
    final result = await useCases.complete(
      familyId: ChoresFixture.familyId,
      actorUid: uid,
      occurrenceId: 'tpl_1_20261024',
    );
    return result.failureOrNull;
  }

  ChoreOccurrence? stored() => fixture
      .occurrences
      .occurrences[ChoresFixture.familyId]?['tpl_1_20261024'];

  group('toggleParent', () {
    test('checking ticks every step and completes', () async {
      // Optional steps: the parent box ticks them all and completes (a required
      // step that is still open is refused, see the next test).
      seedOccurrence(
        fixture,
        anOccurrence(
          subtasks: <TemplateSubtask>[
            aSubtask(id: 'a'),
            aSubtask(id: 'b'),
          ],
        ),
      );

      expect(await toggleParent('cara'), isNull);

      final occurrence = stored()!;
      expect(effectiveStatus(occurrence).id, 'completed');
      expect(occurrence.subtaskDone.keys, containsAll(<String>['a', 'b']));
      expect(occurrence.completedBy, 'cara');
      expect(
        fixture.occurrences.plans.last.audits.single.type,
        AuditEventType.choresOccurrenceCompleted,
      );
    });

    test(
      'an open required step is refused until an exception exists',
      () async {
        seedOccurrence(
          fixture,
          anOccurrence(
            subtasks: <TemplateSubtask>[aSubtask(id: 'a', required: true)],
          ),
        );

        expect(
          await toggleParent('cara'),
          const Conflict(code: 'required_subtasks_open'),
        );

        expect(
          await useCases
              .recordException(
                familyId: ChoresFixture.familyId,
                actorUid: 'bob',
                occurrenceId: 'tpl_1_20261024',
                note: 'চুলা নষ্ট ছিল',
              )
              .then((result) => result.failureOrNull),
          isNull,
        );
        expect(await toggleParent('cara'), isNull);
      },
    );

    test('unchecking undoes the completion and keeps the history', () async {
      final at = DateTime.utc(2026, 10, 24, 3, 30);
      seedOccurrence(
        fixture,
        anOccurrence(
          subtasks: <TemplateSubtask>[aSubtask(id: 'a', required: true)],
          status: OccurrenceStatus.completed,
          completedAt: at,
          completedBy: 'cara',
          subtaskDone: <String, SubtaskDone>{
            'a': SubtaskDone(at: at, by: 'cara'),
          },
        ),
      );

      expect(await toggleParent('cara'), isNull);

      final occurrence = stored()!;
      expect(occurrence.status, OccurrenceStatus.scheduled);
      expect(occurrence.subtaskDone, isEmpty);
      expect(occurrence.completedAt, isNull);

      final plan = fixture.occurrences.plans.last;
      expect(plan.events.single.type, OccurrenceEventType.uncompleted);
      expect(plan.events.single.prevCompletedAt, at);
    });

    test(
      'a required step is refused even when the others are optional',
      () async {
        seedOccurrence(
          fixture,
          anOccurrence(
            subtasks: <TemplateSubtask>[
              aSubtask(id: 'a', required: true),
              aSubtask(id: 'b'),
            ],
          ),
        );

        expect(
          await toggleParent('cara'),
          const Conflict(code: 'required_subtasks_open'),
        );
      },
    );

    test('a chore without subtasks completes from the parent box', () async {
      seedOccurrence(fixture, anOccurrence());

      expect(await toggleParent('cara'), isNull);
      expect(effectiveStatus(stored()!).id, 'completed');
    });
  });

  group('complete', () {
    test('records the real actor and keeps the ticks', () async {
      // An all-optional chore: the completion ticks its steps (the parent box),
      // so the derived status and the boxes agree.
      seedOccurrence(
        fixture,
        anOccurrence(subtasks: <TemplateSubtask>[aSubtask(id: 'a')]),
      );

      expect(await complete('cara'), isNull);

      final occurrence = stored()!;
      expect(occurrence.status, OccurrenceStatus.completed);
      expect(occurrence.completedBy, 'cara');
      expect(occurrence.subtaskDone.keys, <String>['a']);
      expect(fixture.occurrences.plans.last.events, isEmpty);
    });

    test('the last required tick completes without a second action', () async {
      seedOccurrence(
        fixture,
        anOccurrence(
          subtasks: <TemplateSubtask>[aSubtask(id: 'b', required: true)],
          subtaskDone: <String, SubtaskDone>{
            'b': SubtaskDone(at: DateTime.utc(2026, 10, 24, 3), by: 'cara'),
          },
        ),
      );

      expect(await complete('cara'), isNull);

      final before = fixture.occurrences.plans.length;
      expect(effectiveStatus(stored()!).id, 'completed');
      expect(fixture.occurrences.plans.length, before);
    });

    test('completing an already completed chore is a no-op', () async {
      final at = DateTime.utc(2026, 10, 24, 3, 30);
      seedOccurrence(
        fixture,
        anOccurrence(
          status: OccurrenceStatus.completed,
          completedAt: at,
          completedBy: 'cara',
        ),
      );
      final before = fixture.occurrences.plans.length;

      expect(await complete('cara'), isNull);

      expect(
        fixture.occurrences.plans.length,
        before,
        reason: 'nothing written',
      );
      expect(stored()!.completedAt, at);
    });

    test('a manager completing for somebody else records the actor', () async {
      seedOccurrence(fixture, anOccurrence());

      expect(await complete('bob'), isNull);

      final occurrence = stored()!;
      expect(occurrence.completedBy, 'bob');
      final audit = fixture.occurrences.plans.last.audits.single;
      expect(audit.params['by'], 'bob');
      expect(audit.params['assignee'], 'cara');
    });

    test('refuses while a required step is open', () async {
      seedOccurrence(
        fixture,
        anOccurrence(
          subtasks: <TemplateSubtask>[aSubtask(id: 'a', required: true)],
        ),
      );

      expect(
        await complete('cara'),
        const Conflict(code: 'required_subtasks_open'),
      );
      expect(stored()!.status, OccurrenceStatus.scheduled);
    });

    test(
      'an all-optional chore completes and its boxes become ticked',
      () async {
        seedOccurrence(
          fixture,
          anOccurrence(subtasks: <TemplateSubtask>[aSubtask(id: 'a')]),
        );

        final c = await complete('cara');
        expect(c, isNull, reason: 'CODE=${(c as Conflict?)?.code}');

        final occurrence = stored()!;
        expect(effectiveStatus(occurrence).id, 'completed');
        expect(occurrence.subtaskDone.keys, <String>['a']);
      },
    );

    test('a verified chore cannot be completed again', () async {
      seedOccurrence(
        fixture,
        anOccurrence(
          status: OccurrenceStatus.verified,
          completedAt: DateTime.utc(2026, 10, 24, 3),
          completedBy: 'cara',
          verifiedAt: DateTime.utc(2026, 10, 24, 4),
          verifiedBy: 'bob',
        ),
      );

      expect(await complete('cara'), isA<AppFailure>());
    });
  });

  group('uncomplete', () {
    test('undoes a completion and keeps its time on the event', () async {
      final at = DateTime.utc(2026, 10, 24, 3, 30);
      seedOccurrence(
        fixture,
        anOccurrence(
          status: OccurrenceStatus.completed,
          completedAt: at,
          completedBy: 'cara',
        ),
      );

      final result = await useCases.uncomplete(
        familyId: ChoresFixture.familyId,
        actorUid: 'cara',
        occurrenceId: 'tpl_1_20261024',
      );

      expect(result.failureOrNull, isNull);
      expect(stored()!.status, OccurrenceStatus.inProgress);
      expect(stored()!.completedAt, isNull);
      final plan = fixture.occurrences.plans.last;
      expect(plan.events.single.prevCompletedAt, at);
      expect(
        plan.audits.single.type,
        AuditEventType.choresOccurrenceUncompleted,
      );
    });

    test('an open chore cannot be uncompleted', () async {
      seedOccurrence(fixture, anOccurrence());

      final result = await useCases.uncomplete(
        familyId: ChoresFixture.familyId,
        actorUid: 'cara',
        occurrenceId: 'tpl_1_20261024',
      );

      expect(result.failureOrNull, const Conflict(code: 'not_completed'));
    });
  });

  test(
    'a whole plan stays one batch (the in-memory backend records one plan)',
    () async {
      seedOccurrence(fixture, anOccurrence());

      expect(await complete('cara'), isNull);

      final plan = fixture.occurrences.plans.last;
      expect(plan.patches, hasLength(1));
      expect(plan.audits, hasLength(1));
      expect(fixture.occurrences.integrityWrites, 0);
      expect(fixture.occurrences.writes, 1);
    },
  );
}
