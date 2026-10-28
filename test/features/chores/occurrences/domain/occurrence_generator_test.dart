import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_generator.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_parts.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-12: the generator table of Appendix F.3 (recurrence × assignment ×
/// absence), plus the due-time and slot rules.
void main() {
  final fixture = ChoresFixture();
  final members = fixture.roster;
  final dayGroup = aDutyGroup(
    rotation: aRotation(
      members: <String>['alice', 'cara', 'dave'],
      anchorDate: DateKey(2026, 10, 24),
      cycleUnit: CycleUnit.day,
    ),
  );
  final weekGroup = aDutyGroup(
    rotation: aRotation(
      members: <String>['alice', 'cara', 'dave'],
      anchorDate: DateKey(2026, 10, 3),
      cycleUnit: CycleUnit.week,
    ),
  );
  final ownDayRotation = aRotation(
    members: <String>['alice', 'cara', 'dave'],
    anchorDate: DateKey(2026, 10, 24),
    cycleUnit: CycleUnit.day,
  );
  final absentAlice = <AvailabilitySpan>[
    AvailabilitySpan(
      memberId: 'alice',
      startDate: DateKey(2026, 10, 24),
      endDate: DateKey(2026, 10, 24),
    ),
  ];

  List<OccurrenceDraft> generate(_Case c) => OccurrenceGenerator.drafts(
    templates: <ChoreTemplate>[
      ChoreTemplate(
        id: 'tpl_1',
        draft: aTemplate(
          recurrence: c.recurrence,
          startDate: c.startDate ?? DateKey(2026, 10, 1),
          endDate: c.endDate,
          assignee: c.assignee,
          slots: <TemplateSlot>[aSlot(dueMinutes: 540)],
        ),
      ),
    ],
    dutyGroups: c.dutyGroups,
    members: c.members ?? members,
    range: c.range,
    dateKeys: fixture.dateKeys,
    availabilityIndex: AvailabilityIndex(c.absent),
    policy: c.policy,
  );

  final cases = <_Case>[
    // ── Recurrence ──────────────────────────────────────────────────────────
    _Case(
      'daily 10-24..10-26',
      range: _range(24, 26),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
    ),
    _Case(
      'daily clipped by startDate',
      range: _range(24, 26),
      startDate: DateKey(2026, 10, 25),
      expectedDates: <String>['2026-10-25', '2026-10-26'],
    ),
    _Case(
      'daily clipped by endDate',
      range: _range(24, 26),
      endDate: DateKey(2026, 10, 24),
      expectedDates: <String>['2026-10-24'],
    ),
    _Case(
      'once inside',
      range: _range(24, 26),
      recurrence: OnceRecurrence(DateKey(2026, 10, 25)),
      expectedDates: <String>['2026-10-25'],
    ),
    _Case(
      'once outside',
      range: _range(24, 26),
      recurrence: OnceRecurrence(DateKey(2026, 11, 5)),
      expectedDates: const <String>[],
    ),
    _Case(
      'every 2 days',
      range: _range(24, 30),
      recurrence: EveryNDaysRecurrence(n: 2, anchor: DateKey(2026, 10, 24)),
      expectedDates: <String>[
        '2026-10-24',
        '2026-10-26',
        '2026-10-28',
        '2026-10-30',
      ],
    ),
    _Case(
      'Saturday and Sunday',
      range: _range(24, 31),
      recurrence: const WeekdaysRecurrence(
        weekdays: <int>[DateTime.saturday, DateTime.sunday],
      ),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-31'],
    ),
    _Case(
      'every 2 weeks on Saturday',
      range: _range(10, 31),
      recurrence: EveryNWeeksRecurrence(
        n: 2,
        anchor: DateKey(2026, 10, 3),
        weekdays: <int>[DateTime.saturday],
        weekStart: DateTime.saturday,
      ),
      expectedDates: <String>['2026-10-17', '2026-10-31'],
    ),
    _Case(
      'monthly day 1',
      range: DateKeyRange(DateKey(2026, 10, 24), DateKey(2026, 11, 5)),
      recurrence: const DaysOfMonthRecurrence(days: <int>[1]),
      expectedDates: <String>['2026-11-01'],
    ),
    _Case(
      'day 31 clamps to the last day',
      range: DateKeyRange(DateKey(2026, 11, 1), DateKey(2026, 11, 30)),
      recurrence: const DaysOfMonthRecurrence(days: <int>[31]),
      expectedDates: <String>['2026-11-30'],
    ),
    _Case(
      'day 31 skipped in a short month',
      range: DateKeyRange(DateKey(2026, 11, 1), DateKey(2026, 11, 30)),
      recurrence: const DaysOfMonthRecurrence(
        days: <int>[31],
        monthEnd: MonthEndMode.skip,
      ),
      expectedDates: const <String>[],
    ),
    _Case(
      'second Saturday',
      range: DateKeyRange(DateKey(2026, 10, 1), DateKey(2026, 10, 31)),
      recurrence: const NthWeekdayRecurrence(
        nth: 2,
        weekday: DateTime.saturday,
      ),
      expectedDates: <String>['2026-10-10'],
    ),
    _Case(
      'last Saturday',
      range: DateKeyRange(DateKey(2026, 10, 1), DateKey(2026, 10, 31)),
      recurrence: const NthWeekdayRecurrence(
        nth: -1,
        weekday: DateTime.saturday,
      ),
      expectedDates: <String>['2026-10-31'],
    ),
    _Case(
      'last day of the month',
      range: DateKeyRange(DateKey(2026, 10, 1), DateKey(2026, 11, 30)),
      recurrence: const LastDayRecurrence(),
      expectedDates: <String>['2026-10-31', '2026-11-30'],
    ),
    // ── Assignment and absence ─────────────────────────────────────────────
    _Case(
      'manual stays unassigned without needs-cover',
      range: _range(24, 26),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>[null, null, null],
      expectedPlanned: <String?>[null, null, null],
      expectedNeedsCover: <bool>[false, false, false],
    ),
    _Case(
      'fixed member',
      range: _range(24, 26),
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.fixed,
        fixedMemberId: 'bob',
      ),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['bob', 'bob', 'bob'],
      expectedPlanned: <String?>['bob', 'bob', 'bob'],
      expectedNeedsCover: <bool>[false, false, false],
      expectedSource: AssignmentSource.fixed,
    ),
    _Case(
      'fixed member disabled',
      range: _range(24, 26),
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.fixed,
        fixedMemberId: 'dave',
      ),
      members: <Member>[
        for (final member in members)
          member.uid == 'dave'
              ? aMember(uid: 'dave', status: MembershipStatus.disabled)
              : member,
      ],
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>[null, null, null],
      expectedPlanned: <String?>['dave', 'dave', 'dave'],
      expectedNeedsCover: <bool>[true, true, true],
      expectedSource: AssignmentSource.fixed,
    ),
    _Case(
      'daily rotation from a duty group',
      range: _range(24, 26),
      dutyGroups: <DutyGroup>[dayGroup],
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: 'group_1',
      ),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['alice', 'cara', 'dave'],
      expectedPlanned: <String?>['alice', 'cara', 'dave'],
      expectedNeedsCover: <bool>[false, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'weekly rotation keeps one owner for the week',
      range: _range(24, 26),
      dutyGroups: <DutyGroup>[weekGroup],
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: 'group_1',
      ),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['alice', 'alice', 'alice'],
      expectedPlanned: <String?>['alice', 'alice', 'alice'],
      expectedNeedsCover: <bool>[false, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'rotation from the template itself',
      range: _range(24, 26),
      assignee: AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        rotation: ownDayRotation,
      ),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['alice', 'cara', 'dave'],
      expectedPlanned: <String?>['alice', 'cara', 'dave'],
      expectedNeedsCover: <bool>[false, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'absence policy A keeps the planned owner and flags cover',
      range: _range(24, 26),
      dutyGroups: <DutyGroup>[dayGroup],
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: 'group_1',
      ),
      absent: absentAlice,
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['alice', 'cara', 'dave'],
      expectedPlanned: <String?>['alice', 'cara', 'dave'],
      expectedNeedsCover: <bool>[true, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'absence policy B still keeps the planned owner until a cover accepts',
      range: _range(24, 26),
      dutyGroups: <DutyGroup>[dayGroup],
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: 'group_1',
      ),
      absent: absentAlice,
      policy: AbsencePolicy.autoCover,
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['alice', 'cara', 'dave'],
      expectedPlanned: <String?>['alice', 'cara', 'dave'],
      expectedNeedsCover: <bool>[true, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'absence policy C leaves the day unflagged for the manager',
      range: _range(24, 26),
      dutyGroups: <DutyGroup>[dayGroup],
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: 'group_1',
      ),
      absent: absentAlice,
      policy: AbsencePolicy.skip,
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['alice', 'cara', 'dave'],
      expectedPlanned: <String?>['alice', 'cara', 'dave'],
      expectedNeedsCover: <bool>[false, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'inactive group falls back to the template rotation',
      range: _range(24, 26),
      dutyGroups: <DutyGroup>[
        aDutyGroup(
          rotation: aRotation(
            members: <String>['bob', 'dave'],
            anchorDate: DateKey(2026, 10, 24),
            cycleUnit: CycleUnit.day,
          ),
          active: false,
        ),
      ],
      assignee: AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: 'group_1',
        rotation: ownDayRotation,
      ),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['alice', 'cara', 'dave'],
      expectedPlanned: <String?>['alice', 'cara', 'dave'],
      expectedNeedsCover: <bool>[false, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'missing group and no own rotation',
      range: _range(24, 26),
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.rotation,
        dutyGroupId: 'missing',
      ),
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>[null, null, null],
      expectedPlanned: <String?>[null, null, null],
      expectedNeedsCover: <bool>[false, false, false],
      expectedSource: AssignmentSource.rotation,
    ),
    _Case(
      'fixed member absent still needs cover',
      range: _range(24, 26),
      assignee: const AssigneeSpec(
        strategy: AssigneeStrategy.fixed,
        fixedMemberId: 'bob',
      ),
      absent: <AvailabilitySpan>[
        AvailabilitySpan(
          memberId: 'bob',
          startDate: DateKey(2026, 10, 25),
          endDate: DateKey(2026, 10, 25),
        ),
      ],
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>['bob', 'bob', 'bob'],
      expectedPlanned: <String?>['bob', 'bob', 'bob'],
      expectedNeedsCover: <bool>[false, true, false],
      expectedSource: AssignmentSource.fixed,
    ),
    _Case(
      'manual ignores an absence',
      range: _range(24, 26),
      absent: absentAlice,
      expectedDates: <String>['2026-10-24', '2026-10-25', '2026-10-26'],
      expectedAssignees: <String?>[null, null, null],
      expectedPlanned: <String?>[null, null, null],
      expectedNeedsCover: <bool>[false, false, false],
    ),
  ];

  test('generator table (F.3) has at least 25 cases', () {
    expect(cases.length, greaterThanOrEqualTo(25));
  });

  for (final c in cases) {
    test('generator: ${c.name}', () {
      final drafts = generate(c);
      expect(<String>[
        for (final draft in drafts) draft.dateKey.toString(),
      ], c.expectedDates);
      if (c.expectedAssignees != null) {
        expect(<String?>[
          for (final draft in drafts) draft.assigneeId,
        ], c.expectedAssignees);
      }
      if (c.expectedPlanned != null) {
        expect(<String?>[
          for (final draft in drafts) draft.plannedAssigneeId,
        ], c.expectedPlanned);
      }
      if (c.expectedNeedsCover != null) {
        expect(<bool>[
          for (final draft in drafts) draft.needsCover,
        ], c.expectedNeedsCover);
      }
      if (drafts.isNotEmpty) {
        expect(drafts.first.assignmentSource, c.expectedSource);
      }
    });
  }

  test('F.3 1: three slots give the three deterministic ids', () {
    final drafts = OccurrenceGenerator.drafts(
      templates: <ChoreTemplate>[
        ChoreTemplate(
          id: 'tpl_1',
          draft: aTemplate(
            slots: <TemplateSlot>[
              aSlot(),
              aSlot(key: 'noon', dueMinutes: 840),
              aSlot(key: 'evening', dueMinutes: 1140),
            ],
          ),
        ),
      ],
      dutyGroups: const <DutyGroup>[],
      members: members,
      range: DateKeyRange(DateKey(2026, 10, 25), DateKey(2026, 10, 25)),
      dateKeys: fixture.dateKeys,
    );

    expect(
      <String>[for (final draft in drafts) draft.id],
      <String>[
        'tpl_1_20261025',
        'tpl_1_20261025_noon',
        'tpl_1_20261025_evening',
      ],
    );
    expect(drafts.first.slotKey, isNull);
    expect(drafts[1].slotKey, 'noon');
  });

  test('F.3 2: weekly Saturday group chore rotates week by week', () {
    final drafts = OccurrenceGenerator.drafts(
      templates: <ChoreTemplate>[
        ChoreTemplate(
          id: 'tpl_1',
          draft: aTemplate(
            recurrence: const WeekdaysRecurrence(
              weekdays: <int>[DateTime.saturday],
            ),
            assignee: const AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              dutyGroupId: 'group_1',
            ),
          ),
        ),
      ],
      dutyGroups: <DutyGroup>[weekGroup],
      members: members,
      range: DateKeyRange(DateKey(2026, 10, 24), DateKey(2026, 10, 31)),
      dateKeys: fixture.dateKeys,
    );

    expect(
      <String>[for (final draft in drafts) draft.dateKey.toString()],
      <String>['2026-10-24', '2026-10-31'],
    );
    expect(
      <String?>[for (final draft in drafts) draft.assigneeId],
      <String?>['alice', 'cara'],
    );
  });

  test('F.3 19: dueAt follows the family zone, not the device zone', () {
    final drafts = OccurrenceGenerator.drafts(
      templates: <ChoreTemplate>[
        ChoreTemplate(
          id: 'tpl_1',
          draft: aTemplate(
            slots: <TemplateSlot>[
              aSlot(key: 'main', dueMinutes: 1439),
              aSlot(key: 'late', dueMinutes: null),
            ],
          ),
        ),
      ],
      dutyGroups: const <DutyGroup>[],
      members: members,
      range: DateKeyRange(DateKey(2026, 10, 24), DateKey(2026, 10, 24)),
      dateKeys: fixture.dateKeys,
    );

    expect(drafts[0].occurrence.dueAt, DateTime.utc(2026, 10, 24, 17, 59));
    expect(drafts[1].occurrence.dueAt, DateTime.utc(2026, 10, 24, 17, 59, 59));
  });

  test('paused and archived templates generate nothing', () {
    final drafts = OccurrenceGenerator.drafts(
      templates: <ChoreTemplate>[
        ChoreTemplate(id: 'paused', draft: aTemplate(), active: false),
        ChoreTemplate(
          id: 'archived',
          draft: aTemplate(),
          archivedAt: DateTime.utc(2026, 10, 1),
        ),
      ],
      dutyGroups: const <DutyGroup>[],
      members: members,
      range: DateKeyRange(DateKey(2026, 10, 24), DateKey(2026, 10, 26)),
      dateKeys: fixture.dateKeys,
    );

    expect(drafts, isEmpty);
  });
}

DateKeyRange _range(int fromDay, int toDay) =>
    DateKeyRange(DateKey(2026, 10, fromDay), DateKey(2026, 10, toDay));

final class _Case {
  _Case(
    this.name, {
    required this.range,
    required this.expectedDates,
    this.recurrence = const DailyRecurrence(),
    this.startDate,
    this.endDate,
    this.assignee = AssigneeSpec.manual,
    this.dutyGroups = const <DutyGroup>[],
    this.members,
    this.absent = const <AvailabilitySpan>[],
    this.policy = AbsencePolicy.askCover,
    this.expectedAssignees,
    this.expectedPlanned,
    this.expectedNeedsCover,
    this.expectedSource = AssignmentSource.manual,
  });

  final String name;
  final DateKeyRange range;
  final Recurrence recurrence;
  final DateKey? startDate;
  final DateKey? endDate;
  final AssigneeSpec assignee;
  final List<DutyGroup> dutyGroups;
  final List<Member>? members;
  final List<AvailabilitySpan> absent;
  final AbsencePolicy policy;
  final List<String> expectedDates;
  final List<String?>? expectedAssignees;
  final List<String?>? expectedPlanned;
  final List<bool>? expectedNeedsCover;
  final AssignmentSource expectedSource;
}
