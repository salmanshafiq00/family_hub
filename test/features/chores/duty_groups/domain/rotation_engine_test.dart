import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/absence_resolver.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_validator.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-09: the rotation engine, the absence resolver and the rotation shape
/// checks, row by row against Appendix F.2.
void main() {
  DateKey day(int month, int date) => DateKey(2026, month, date);
  String? plan(Rotation rotation, DateKey on) =>
      RotationEngine.planned(rotation, on);

  group('RotationEngine (F.2 rows 1-13)', () {
    final weekly = aRotation();

    test('1: a whole week belongs to the person planned for its start', () {
      for (var i = 0; i < 7; i++) {
        expect(plan(weekly, day(10, 3).addDays(i)), 'alice', reason: 'day $i');
      }
    });

    test('2: the next weeks advance through the roster', () {
      expect(plan(weekly, day(10, 10)), 'cara');
      expect(plan(weekly, day(10, 17)), 'dave');
      expect(plan(weekly, day(10, 24)), 'alice');
    });

    test('3: the day before the anchor uses the negative cycle', () {
      expect(plan(weekly, day(10, 2)), 'dave');
    });

    test('4: three cycles before the anchor wraps to the first person', () {
      expect(plan(weekly, day(9, 12)), 'alice');
    });

    test('5: an anchor in the middle of a week starts that week', () {
      final rotation = aRotation(anchorDate: day(10, 7));
      expect(plan(rotation, day(10, 3)), 'alice');
    });

    test('6: the day unit advances every day', () {
      final rotation = aRotation(cycleUnit: CycleUnit.day, anchorIndex: 1);
      expect(plan(rotation, day(10, 3)), 'cara');
      expect(plan(rotation, day(10, 4)), 'dave');
      expect(plan(rotation, day(10, 5)), 'alice');
    });

    test('7: the month unit counts month keys', () {
      final rotation = aRotation(
        members: <String>['alice', 'cara'],
        cycleUnit: CycleUnit.month,
        anchorDate: day(10, 1),
      );
      expect(plan(rotation, day(10, 15)), 'alice');
      expect(plan(rotation, day(11, 15)), 'cara');
      expect(plan(rotation, day(12, 1)), 'alice');
      expect(plan(rotation, day(9, 30)), 'cara');
    });

    test('8: a Sunday week start keeps Saturday in the same week', () {
      final rotation = aRotation(
        members: <String>['alice', 'cara'],
        anchorDate: day(10, 4),
        weekStartDay: DateTime.sunday,
      );
      expect(plan(rotation, day(10, 10)), 'alice');
      expect(plan(rotation, day(10, 11)), 'cara');
    });

    test('9: the occurrence unit skips a non-firing Friday', () {
      final rotation = aRotation(
        members: <String>['alice', 'cara'],
        cycleUnit: CycleUnit.occurrence,
        anchorDate: day(10, 3),
      );
      const saturdayToThursday = WeekdaysRecurrence(
        weekdays: <int>[6, 7, 1, 2, 3, 4],
      );
      expect(
        RotationEngine.planned(
          rotation,
          day(10, 3),
          recurrence: saturdayToThursday,
        ),
        'alice',
      );
      expect(
        RotationEngine.planned(
          rotation,
          day(10, 4),
          recurrence: saturdayToThursday,
        ),
        'cara',
      );
      expect(
        RotationEngine.planned(
          rotation,
          day(10, 8),
          recurrence: saturdayToThursday,
        ),
        'cara',
      );
      expect(
        RotationEngine.planned(
          rotation,
          day(10, 10),
          recurrence: saturdayToThursday,
        ),
        'alice',
      );
    });

    test(
      '10: a new version starts a fresh roster without touching the past',
      () {
        final rotation = Rotation(
          versions: <RotationVersion>[
            aVersion(
              members: <String>['alice', 'cara', 'dave'],
              from: day(9, 1),
              anchorDate: day(9, 5),
            ),
            aVersion(
              members: <String>['alice', 'cara', 'dave', 'bob'],
              from: day(10, 17),
              anchorDate: day(10, 17),
            ),
          ],
        );
        expect(plan(rotation, day(10, 10)), 'dave');
        expect(plan(rotation, day(10, 17)), 'alice');
        expect(plan(rotation, day(10, 24)), 'cara');
        expect(plan(rotation, day(10, 31)), 'dave');
        expect(plan(rotation, day(11, 7)), 'bob');
        expect(plan(rotation, day(11, 14)), 'alice');
      },
    );

    test('13: the day before the first version has no owner', () {
      expect(plan(weekly, day(8, 31)), isNull);
    });

    test('an empty rotation never crashes', () {
      const rotation = Rotation(versions: <RotationVersion>[]);
      expect(plan(rotation, day(10, 3)), isNull);
    });

    test('a pre-computed occurrence index overrides the count', () {
      final rotation = aRotation(
        members: <String>['alice', 'cara'],
        anchorDate: day(10, 3),
      );
      expect(
        RotationEngine.planned(rotation, day(10, 3), occurrenceIndex: 3),
        'cara',
      );
    });
  });

  group('RotationValidator (F.2 row 19)', () {
    test('12 members and 20 versions are accepted', () {
      final rotation = _manyVersions(versions: 20);
      expect(RotationValidator.validate(rotation), isNull);
    });

    test('21 versions are too many', () {
      final rotation = _manyVersions(versions: 21);
      expect(RotationValidator.validate(rotation)?.code, 'too_many_items');
    });

    test('one member is not a rotation', () {
      final rotation = aRotation(members: <String>['alice']);
      expect(RotationValidator.validate(rotation)?.code, 'too_few_members');
    });

    test('a duplicate member is rejected', () {
      final rotation = aRotation(members: <String>['alice', 'alice']);
      expect(RotationValidator.validate(rotation)?.code, 'duplicate_id');
    });

    test('versions must be strictly increasing', () {
      final rotation = Rotation(
        versions: <RotationVersion>[
          aVersion(from: day(10, 1)),
          aVersion(from: day(10, 1)),
        ],
      );
      expect(RotationValidator.validate(rotation)?.code, 'invalid_range');
    });

    test('an out-of-range week start is rejected', () {
      final rotation = aRotation(weekStartDay: 0);
      expect(RotationValidator.validate(rotation)?.code, 'invalid_week_start');
    });
  });

  group('AbsenceResolver (F.2 rows 14-18)', () {
    late List<Member> roster;
    setUp(() => roster = ChoresFixture().roster);

    AssignmentDecision resolve({
      String? planned = 'alice',
      required DateKey on,
      AbsencePolicy policy = AbsencePolicy.askCover,
      AvailabilityIndex availability = AvailabilityIndex.empty,
      Map<String, int> load = const <String, int>{},
    }) => AbsenceResolver.resolve(
      planned: planned,
      day: on,
      availabilityIndex: availability,
      policy: policy,
      members: roster,
      windowLoad: load,
    );

    test(
      '14: an inactive planned member becomes unassigned, never skipped',
      () {
        final decision = resolve(planned: 'erin', on: day(10, 24));
        expect(decision.assigneeId, isNull);
        expect(decision.needsCover, isTrue);
      },
    );

    test('15: policy A keeps the person and flags the day', () {
      final decision = resolve(
        on: day(10, 24),
        availability: _sick('alice', day(10, 24), day(10, 26)),
      );
      expect(decision.assigneeId, 'alice');
      expect(decision.needsCover, isTrue);
      expect(decision.suggestedCoverId, isNull);
    });

    test('16: policy B suggests the least loaded eligible member', () {
      final decision = resolve(
        on: day(10, 24),
        policy: AbsencePolicy.autoCover,
        availability: _sick('alice', day(10, 24), day(10, 26)),
        load: <String, int>{'alice': 3, 'bob': 2, 'cara': 1, 'dave': 1},
      );
      expect(decision.assigneeId, 'alice');
      expect(decision.needsCover, isTrue);
      expect(decision.suggestedCoverId, 'cara');
    });

    test('17: policy B with everybody unavailable suggests nobody', () {
      final spans = <AvailabilitySpan>[
        for (final uid in <String>['alice', 'bob', 'cara', 'dave'])
          AvailabilitySpan(
            memberId: uid,
            startDate: day(10, 1),
            endDate: day(10, 31),
          ),
      ];
      final decision = resolve(
        on: day(10, 24),
        policy: AbsencePolicy.autoCover,
        availability: AvailabilityIndex(spans),
      );
      expect(decision.suggestedCoverId, isNull);
      expect(decision.needsCover, isTrue);
    });

    test('18: policy C keeps the person and flags nothing', () {
      final decision = resolve(
        on: day(10, 24),
        policy: AbsencePolicy.skip,
        availability: _sick('alice', day(10, 24), day(10, 26)),
      );
      expect(decision.assigneeId, 'alice');
      expect(decision.needsCover, isFalse);
    });

    test('an available planned member needs no cover', () {
      final decision = resolve(on: day(10, 24));
      expect(decision.assigneeId, 'alice');
      expect(decision.needsCover, isFalse);
    });

    test('a manual unassigned chore is not "needs cover"', () {
      final decision = resolve(planned: null, on: day(10, 24));
      expect(decision.assigneeId, isNull);
      expect(decision.needsCover, isFalse);
    });

    test('an absent member is unassigned and may still get a cover', () {
      final decision = resolve(
        planned: 'erin',
        on: day(10, 24),
        policy: AbsencePolicy.autoCover,
      );
      expect(decision.assigneeId, isNull);
      expect(decision.needsCover, isTrue);
      expect(decision.suggestedCoverId, isNotNull);
      expect(decision.suggestedCoverId, isNot('erin'));
    });
  });
}

AvailabilityIndex _sick(String memberId, DateKey start, DateKey end) =>
    AvailabilityIndex(<AvailabilitySpan>[
      AvailabilitySpan(memberId: memberId, startDate: start, endDate: end),
    ]);

Rotation _manyVersions({required int versions}) => Rotation(
  versions: <RotationVersion>[
    for (var i = 0; i < versions; i++)
      aVersion(
        members: <String>[
          'm0',
          'm1',
          'm2',
          'm3',
          'm4',
          'm5',
          'm6',
          'm7',
          'm8',
          'm9',
          'm10',
          'm11',
        ],
        from: DateKey(2026, 1, 1).addDays(i),
        anchorDate: DateKey(2026, 1, 1),
      ),
  ],
);
