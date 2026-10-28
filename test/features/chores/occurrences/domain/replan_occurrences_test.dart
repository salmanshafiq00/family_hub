import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/replan_occurrences.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-12 / Appendix F.3 9: replan refreshes the future unstarted snapshot and
/// recomputes the planned owner only for a rotation/fixed source.
void main() {
  late ChoresFixture fixture;
  late ReplanOccurrences replan;

  const familyId = ChoresFixture.familyId;
  final at = DateTime.utc(2026, 10, 24, 9);
  final dayGroup = aDutyGroup(
    rotation: aRotation(
      members: <String>['alice', 'cara', 'dave'],
      anchorDate: DateKey(2026, 10, 24),
      cycleUnit: CycleUnit.day,
    ),
  );

  setUp(() {
    fixture = ChoresFixture();
    fixture.chores.dutyGroups.groups[familyId] = <String, DutyGroup>{
      'group_1': dayGroup,
    };
    replan = ReplanOccurrences(
      occurrences: fixture.occurrences,
      templates: fixture.chores,
      dutyGroups: fixture.chores.dutyGroups,
      settings: fixture.settings,
      families: fixture.families,
      dateKeys: fixture.dateKeys,
      clock: fixture.clock,
    );
  });

  void seedTemplate({bool active = true}) {
    fixture.chores.templates[familyId] = <String, ChoreTemplate>{
      'tpl_1': ChoreTemplate(
        id: 'tpl_1',
        revision: 2,
        active: active,
        draft: aTemplate(
          nameBn: 'নতুন নাম',
          startDate: DateKey(2026, 10, 1),
          assignee: const AssigneeSpec(
            strategy: AssigneeStrategy.rotation,
            dutyGroupId: 'group_1',
          ),
          slots: <TemplateSlot>[aSlot(dueMinutes: 600)],
          subtasks: <TemplateSubtask>[
            aSubtask(id: 'step_1'),
            aSubtask(id: 'step_2'),
          ],
        ),
      ),
    };
  }

  void seed(ChoreOccurrence occurrence) {
    (fixture.occurrences.occurrences[familyId] ??=
            <String, ChoreOccurrence>{})[occurrence.id] =
        occurrence;
  }

  ChoreOccurrence oldOccurrence(
    int day, {
    String? id,
    OccurrenceStatus status = OccurrenceStatus.scheduled,
    AssignmentSource source = AssignmentSource.rotation,
    String? assigneeId = 'alice',
    Map<String, SubtaskDone>? subtaskDone,
    DateTime? completedAt,
  }) => anOccurrence(
    id: id ?? 'tpl_1_202610$day',
    dateKey: DateKey(2026, 10, day),
    templateRev: 1,
    nameBn: 'পুরনো নাম',
    subtasks: <TemplateSubtask>[aSubtask(id: 'old_step')],
    dueMinutes: 540,
    status: status,
    assignmentSource: source,
    plannedAssigneeId: 'alice',
    assigneeId: assigneeId,
    subtaskDone: subtaskDone,
    completedAt: completedAt,
    completedBy: completedAt == null ? null : 'cara',
  );

  test('F.3 9: refreshes unstarted future documents only', () async {
    seedTemplate();
    seed(oldOccurrence(24));
    seed(oldOccurrence(25));
    seed(oldOccurrence(26));
    seed(
      oldOccurrence(
        27,
        subtaskDone: <String, SubtaskDone>{
          'old_step': SubtaskDone(at: at, by: 'cara'),
        },
      ),
    );
    seed(
      oldOccurrence(28, status: OccurrenceStatus.completed, completedAt: at),
    );

    final result = await replan(
      familyId: familyId,
      actorUid: 'bob',
      templateId: 'tpl_1',
      from: DateKey(2026, 10, 25),
    );

    expect(result.valueOrNull!.replanned, 2);
    final docs = fixture.occurrences.occurrences[familyId]!;

    final refreshed = docs['tpl_1_20261025']!;
    expect(refreshed.nameBn, 'নতুন নাম');
    expect(refreshed.templateRev, 2);
    expect(refreshed.subtasks, hasLength(2));
    expect(refreshed.dueMinutes, 600);
    expect(refreshed.dueAt, DateTime.utc(2026, 10, 25, 4));
    expect(refreshed.assigneeId, 'cara');
    expect(refreshed.plannedAssigneeId, 'cara');
    expect(refreshed.assignmentSource, AssignmentSource.rotation);
    expect(docs['tpl_1_20261026']!.nameBn, 'নতুন নাম');

    expect(docs['tpl_1_20261024']!.nameBn, 'পুরনো নাম');
    expect(docs['tpl_1_20261024']!.templateRev, 1);
    expect(docs['tpl_1_20261027']!.nameBn, 'পুরনো নাম');
    expect(docs['tpl_1_20261028']!.nameBn, 'পুরনো নাম');
  });

  test('a swapped assignee survives the replan', () async {
    seedTemplate();
    seed(oldOccurrence(28, source: AssignmentSource.swap, assigneeId: 'dave'));

    final result = await replan(
      familyId: familyId,
      actorUid: 'bob',
      templateId: 'tpl_1',
      from: DateKey(2026, 10, 28),
    );

    expect(result.valueOrNull!.replanned, 1);
    final swapped =
        fixture.occurrences.occurrences[familyId]!['tpl_1_20261028']!;
    expect(swapped.nameBn, 'নতুন নাম');
    expect(swapped.templateRev, 2);
    expect(swapped.assigneeId, 'dave');
    expect(swapped.plannedAssigneeId, 'alice');
    expect(swapped.assignmentSource, AssignmentSource.swap);
  });

  test('the replan writes one audit naming the template', () async {
    seedTemplate();
    seed(oldOccurrence(25));

    await replan(
      familyId: familyId,
      actorUid: 'bob',
      templateId: 'tpl_1',
      from: DateKey(2026, 10, 25),
    );

    final audit = fixture.occurrences.audits.single;
    expect(audit.type, AuditEventType.choresOccurrencesReplanned);
    expect(audit.refType, AuditRefType.choreTemplate);
    expect(audit.refId, 'tpl_1');
    expect(audit.params['name'], 'নতুন নাম');
    expect(audit.params['from'], '2026-10-25');
    expect(audit.params['count'], '1');
  });

  test('a paused template and a plain member write nothing', () async {
    seedTemplate(active: false);
    seed(oldOccurrence(25));

    final paused = await replan(
      familyId: familyId,
      actorUid: 'bob',
      templateId: 'tpl_1',
      from: DateKey(2026, 10, 25),
    );
    expect(paused.valueOrNull!.isEmpty, isTrue);
    expect(fixture.occurrences.plans, isEmpty);

    seedTemplate();
    final denied = await replan(
      familyId: familyId,
      actorUid: 'cara',
      templateId: 'tpl_1',
      from: DateKey(2026, 10, 25),
    );
    expect(denied.failureOrNull, const PermissionDenied());
    expect(fixture.occurrences.plans, isEmpty);
  });

  test('an unknown template is a NotFound', () async {
    final result = await replan(
      familyId: familyId,
      actorUid: 'bob',
      templateId: 'missing',
      from: DateKey(2026, 10, 25),
    );
    expect(result.failureOrNull, const NotFound(entity: 'template'));
  });
}
