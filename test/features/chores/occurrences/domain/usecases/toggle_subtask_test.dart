import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/permissions/permission_settings.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../chores_test_helpers.dart';
import 'completion_test_support.dart';

/// P3-14: ticking one subtask — who may, what the patch touches, what the
/// history keeps (Appendix C).
void main() {
  late ChoresFixture fixture;
  late CompletionUseCases useCases;

  setUp(() {
    fixture = ChoresFixture();
    useCases = CompletionUseCases(fixture);
  });

  Future<AppFailure?> tick(
    String uid, {
    String subtaskId = 'step_1',
    String id = 'tpl_1_20261024',
  }) async {
    final result = await useCases.toggleSubtask(
      familyId: ChoresFixture.familyId,
      actorUid: uid,
      occurrenceId: id,
      subtaskId: subtaskId,
    );
    return result.failureOrNull;
  }

  OccurrenceWritePlan lastPlan() => fixture.occurrences.plans.last;

  test('the assignee completes the last required step', () async {
    seedOccurrence(
      fixture,
      anOccurrence(subtasks: <TemplateSubtask>[aSubtask(required: true)]),
    );

    expect(await tick('cara'), isNull);

    final stored = fixture
        .occurrences
        .occurrences[ChoresFixture.familyId]!['tpl_1_20261024']!;
    expect(stored.status, OccurrenceStatus.completed);
    expect(stored.completedBy, 'cara');
    expect(stored.subtaskDone.keys, <String>['step_1']);
    expect(effectiveStatus(stored).id, 'completed');
    expect(lastPlan().audits.map((audit) => audit.type), <String>[
      AuditEventType.choresOccurrenceCompleted,
    ]);
    expect(lastPlan().events, isEmpty, reason: 'a tick writes no event');
  });

  test('the patch names only the ticked key (two phones merge)', () async {
    seedOccurrence(
      fixture,
      anOccurrence(
        subtasks: <TemplateSubtask>[
          aSubtask(id: 'a', required: true),
          aSubtask(id: 'b', required: true),
        ],
      ),
    );

    expect(await tick('cara', subtaskId: 'a'), isNull);

    final patch = lastPlan().patches.single;
    expect(patch.fields.keys, contains('subtaskDone.a'));
    expect(patch.fields.keys, isNot(contains('subtaskDone.b')));
    expect(patch.removedFields, isEmpty);
  });

  test('two phones ticking different boxes end in one completion', () async {
    seedOccurrence(
      fixture,
      anOccurrence(
        subtasks: <TemplateSubtask>[
          aSubtask(id: 'a', required: true),
          aSubtask(id: 'b', required: true),
        ],
      ),
    );

    expect(await tick('cara', subtaskId: 'a'), isNull);
    expect(await tick('cara', subtaskId: 'b'), isNull);

    final stored = fixture
        .occurrences
        .occurrences[ChoresFixture.familyId]!['tpl_1_20261024']!;
    expect(effectiveStatus(stored).id, 'completed');
    expect(stored.subtaskDone.keys, containsAll(<String>['a', 'b']));
  });

  test('a manager may tick somebody else’s chore', () async {
    seedOccurrence(
      fixture,
      anOccurrence(subtasks: <TemplateSubtask>[aSubtask()]),
    );

    expect(await tick('bob'), isNull);
  });

  test('a plain member may not, unless the family switch is on', () async {
    seedOccurrence(
      fixture,
      anOccurrence(subtasks: <TemplateSubtask>[aSubtask()]),
    );

    expect(await tick('dave'), isA<PermissionDenied>());

    fixture.backend.permissionSettings[ChoresFixture.familyId] =
        PermissionSettings.defaults.copyWith(membersCanCompleteForOthers: true);
    expect(await tick('dave'), isNull);
  });

  test('a pending member may never tick', () async {
    seedOccurrence(
      fixture,
      anOccurrence(subtasks: <TemplateSubtask>[aSubtask()], assigneeId: 'erin'),
    );

    expect(await tick('erin'), isA<PermissionDenied>());
  });

  test('a verified chore is frozen', () async {
    seedOccurrence(
      fixture,
      anOccurrence(
        subtasks: <TemplateSubtask>[aSubtask(required: true)],
        status: OccurrenceStatus.verified,
        completedAt: DateTime.utc(2026, 10, 24, 3, 30),
        completedBy: 'cara',
        verifiedAt: DateTime.utc(2026, 10, 24, 4),
        verifiedBy: 'bob',
      ),
    );

    final failure = await tick('cara');
    expect(failure, const Conflict(code: 'already_verified'));
  });

  test(
    'unticking a completed box keeps the old completion in history',
    () async {
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

      expect(await tick('cara', subtaskId: 'a'), isNull);

      final stored = fixture
          .occurrences
          .occurrences[ChoresFixture.familyId]!['tpl_1_20261024']!;
      expect(stored.completedAt, isNull);
      expect(effectiveStatus(stored).id, 'scheduled');

      final plan = lastPlan();
      expect(plan.patches.single.removedFields, contains('subtaskDone.a'));
      final event = plan.events.single;
      expect(event.type, OccurrenceEventType.uncompleted);
      expect(event.prevCompletedAt, at);
      expect(
        plan.audits.single.type,
        AuditEventType.choresOccurrenceUncompleted,
      );
    },
  );

  test('an unknown subtask is a concurrent edit, not a crash', () async {
    seedOccurrence(
      fixture,
      anOccurrence(subtasks: <TemplateSubtask>[aSubtask()]),
    );

    expect(
      await tick('cara', subtaskId: 'gone'),
      const Conflict(code: 'concurrent_edit'),
    );
  });

  test(
    'an unwritten (projected) chore is materialized in the same batch',
    () async {
      // The DRAFT is generated from the template, so the template (not the
      // occurrence helper) decides the owner and the snapshot: a fixed
      // assignment to cara, with the same `step_1` the test ticks.
      seedTemplate(
        fixture,
        wrapTemplate(
          aTemplate(
            subtasks: <TemplateSubtask>[aSubtask(id: 'step_1')],
            assignee: const AssigneeSpec(
              strategy: AssigneeStrategy.fixed,
              fixedMemberId: 'cara',
            ),
          ),
        ),
      );

      final result = await useCases.toggleSubtask(
        familyId: ChoresFixture.familyId,
        actorUid: 'cara',
        occurrenceId: 'tpl_1_20261024',
        subtaskId: 'step_1',
      );
      expect(
        result.failureOrNull,
        isNull,
        reason: 'code: ${(result.failureOrNull as Conflict?)?.code}',
      );

      final plan = lastPlan();
      expect(plan.creates.single.id, 'tpl_1_20261024');
      expect(plan.patches.single.occurrenceId, 'tpl_1_20261024');
      expect(
        fixture.occurrences.occurrences[ChoresFixture.familyId],
        contains('tpl_1_20261024'),
      );
    },
  );

  test('an occurrence with no template and no document is NotFound', () async {
    expect(await tick('cara'), const NotFound(entity: 'occurrence'));
  });

  test('B-08: a projected duty-group chore keeps the rotation owner', () async {
    // The template rotates through a duty group, so the planned owner can only
    // come from the group's rotation - not from the template.
    fixture.chores.dutyGroups.groups[ChoresFixture.familyId] =
        <String, DutyGroup>{
          'group_1': aDutyGroup(
            id: 'group_1',
            rotation: aRotation(
              members: const <String>['cara', 'alice', 'dave'],
              anchorDate: DateKey(2026, 10, 24),
            ),
          ),
        };
    seedTemplate(
      fixture,
      wrapTemplate(
        aTemplate(
          subtasks: <TemplateSubtask>[aSubtask(id: 'step_1')],
          assignee: const AssigneeSpec(
            strategy: AssigneeStrategy.rotation,
            dutyGroupId: 'group_1',
          ),
        ),
      ),
    );

    final failure = await tick('cara');
    expect(failure, isNull, reason: 'failure: $failure');

    final created = fixture
        .occurrences
        .occurrences[ChoresFixture.familyId]!['tpl_1_20261024']!;
    expect(created.plannedAssigneeId, 'cara');
    expect(created.assigneeId, 'cara');
    expect(created.needsCover, isFalse);
  });
}
