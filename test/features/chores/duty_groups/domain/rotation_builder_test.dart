import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_builder.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-09: [RotationBuilder] must never move a turn that is already in the past.
void main() {
  DateKey day(int month, int date) => DateKey(2026, month, date);

  group('add', () {
    test('appends the member at the next week boundary', () {
      final before = aRotation();
      final added = RotationBuilder.add(
        before,
        memberId: 'bob',
        effectiveFrom: day(10, 7),
      ).valueOrNull!;

      final version = added.versions.last;
      expect(version.from, day(10, 10), reason: 'next Saturday');
      expect(version.members, <String>['alice', 'cara', 'dave', 'bob']);
      expect(version.anchorDate, day(10, 10));
      // Whoever the old rotation planned for 10-10 keeps that turn.
      expect(
        RotationEngine.planned(added, day(10, 10)),
        RotationEngine.planned(before, day(10, 10)),
      );
    });

    test('property: nothing before the boundary changes (F.2 row 11)', () {
      final before = aRotation();
      final added = RotationBuilder.add(
        before,
        memberId: 'bob',
        effectiveFrom: day(10, 7),
      ).valueOrNull!;
      final boundary = added.versions.last.from;

      for (var i = 1; i <= 90; i++) {
        final earlier = boundary.addDays(-i);
        expect(
          RotationEngine.planned(added, earlier),
          RotationEngine.planned(before, earlier),
          reason: '$earlier must be unchanged',
        );
      }
    });

    test('a boundary date is used as-is', () {
      final added = RotationBuilder.add(
        aRotation(),
        memberId: 'bob',
        effectiveFrom: day(10, 10),
      ).valueOrNull!;
      expect(added.versions.last.from, day(10, 10));
    });

    test('a duplicate member is refused', () {
      final result = RotationBuilder.add(
        aRotation(),
        memberId: 'cara',
        effectiveFrom: day(10, 10),
      );
      expect(result.failureOrNull, failureCode('duplicate_id'));
    });

    test('a full roster is refused', () {
      final rotation = aRotation(
        members: <String>[for (var i = 0; i < 12; i++) 'm$i'],
      );
      final result = RotationBuilder.add(
        rotation,
        memberId: 'bob',
        effectiveFrom: day(10, 10),
      );
      expect(result.failureOrNull, failureCode('too_many_items'));
    });

    test('a date before the first version is refused', () {
      final result = RotationBuilder.add(
        aRotation(),
        memberId: 'bob',
        effectiveFrom: day(8, 1),
      );
      expect(result.failureOrNull, failureCode('invalid_date'));
    });
  });

  group('remove', () {
    test(
      'the next person in the old order takes the removed turn (row 12)',
      () {
        final before = aRotation(anchorIndex: 1);
        expect(RotationEngine.planned(before, day(10, 24)), 'cara');

        final removed = RotationBuilder.remove(
          before,
          memberId: 'cara',
          effectiveFrom: day(10, 24),
        ).valueOrNull!;

        expect(
          RotationEngine.planned(removed, day(10, 24)),
          'dave',
          reason: 'C takes B\'s boundary turn',
        );
        expect(RotationEngine.planned(removed, day(10, 31)), 'alice');
        expect(RotationEngine.planned(removed, day(11, 7)), 'dave');
      },
    );

    test('removing somebody who was not due keeps the anchor', () {
      final before = aRotation();
      expect(RotationEngine.planned(before, day(10, 24)), 'alice');
      final removed = RotationBuilder.remove(
        before,
        memberId: 'cara',
        effectiveFrom: day(10, 24),
      ).valueOrNull!;
      expect(RotationEngine.planned(removed, day(10, 24)), 'alice');
      expect(RotationEngine.planned(removed, day(10, 31)), 'dave');
      expect(RotationEngine.planned(removed, day(11, 7)), 'alice');
    });

    test('the last two members cannot be cut to one', () {
      final result = RotationBuilder.remove(
        aRotation(members: <String>['alice', 'cara']),
        memberId: 'cara',
        effectiveFrom: day(10, 10),
      );
      expect(result.failureOrNull, failureCode('too_few_members'));
    });

    test('an unknown member is refused', () {
      final result = RotationBuilder.remove(
        aRotation(),
        memberId: 'zoe',
        effectiveFrom: day(10, 10),
      );
      expect(result.failureOrNull, failureCode('invalid_rotation'));
    });
  });

  group('reorder', () {
    test('starts with the chosen member at the boundary (row 20)', () {
      final before = aRotation();
      final reordered = RotationBuilder.reorder(
        before,
        members: <String>['dave', 'alice', 'cara'],
        startsWith: 'dave',
        effectiveFrom: day(11, 7),
      ).valueOrNull!;

      expect(reordered.versions.last.from, day(11, 7));
      expect(reordered.versions.last.anchorIndex, 0);
      expect(RotationEngine.planned(reordered, day(11, 7)), 'dave');
      expect(RotationEngine.planned(reordered, day(11, 14)), 'alice');
      expect(RotationEngine.planned(reordered, day(11, 21)), 'cara');
    });

    test('nothing before the boundary changes', () {
      final before = aRotation();
      final reordered = RotationBuilder.reorder(
        before,
        members: <String>['dave', 'alice', 'cara'],
        startsWith: 'dave',
        effectiveFrom: day(11, 7),
      ).valueOrNull!;
      for (var i = 1; i <= 60; i++) {
        final earlier = day(11, 7).addDays(-i);
        expect(
          RotationEngine.planned(reordered, earlier),
          RotationEngine.planned(before, earlier),
          reason: '$earlier',
        );
      }
    });

    test('reordering may not add or drop a member', () {
      final result = RotationBuilder.reorder(
        aRotation(),
        members: <String>['alice', 'cara'],
        startsWith: 'alice',
        effectiveFrom: day(10, 10),
      );
      expect(result.failureOrNull, failureCode('invalid_rotation'));
    });

    test('the "starts with" member must be in the list', () {
      final result = RotationBuilder.reorder(
        aRotation(),
        members: <String>['alice', 'cara', 'dave'],
        startsWith: 'bob',
        effectiveFrom: day(10, 10),
      );
      expect(result.failureOrNull, failureCode('member_required'));
    });
  });

  group('occurrence unit', () {
    const schedule = WeekdaysRecurrence(weekdays: <int>[6, 7, 1, 2, 3, 4]);

    test('the builder needs the schedule to keep the boundary turn', () {
      final rotation = aRotation(
        members: <String>['alice', 'cara'],
        cycleUnit: CycleUnit.occurrence,
      );
      final without = RotationBuilder.add(
        rotation,
        memberId: 'bob',
        effectiveFrom: day(10, 4),
      );
      expect(without.failureOrNull, failureCode('invalid_rotation'));

      final withSchedule = RotationBuilder.add(
        rotation,
        memberId: 'bob',
        effectiveFrom: day(10, 4),
        recurrence: schedule,
      ).valueOrNull!;
      expect(
        RotationEngine.planned(withSchedule, day(10, 4), recurrence: schedule),
        'cara',
      );
    });
  });

  group('version retention', () {
    test('21 versions within 400 days cannot be stored', () {
      final rotation = Rotation(
        versions: <RotationVersion>[
          for (var i = 0; i < 20; i++)
            aVersion(from: day(9, 20).addDays(i), anchorDate: day(9, 20)),
        ],
      );
      final result = RotationBuilder.add(
        rotation,
        memberId: 'bob',
        effectiveFrom: day(10, 24),
      );
      expect(result.failureOrNull, failureCode('too_many_items'));
    });

    test('a version older than 400 days is dropped instead', () {
      final rotation = Rotation(
        versions: <RotationVersion>[
          for (var i = 0; i < 19; i++)
            aVersion(
              from: DateKey(2024, 1, 1).addDays(i),
              anchorDate: DateKey(2024, 1, 1),
            ),
          aVersion(from: day(10, 17), anchorDate: day(10, 17)),
        ],
      );
      final added = RotationBuilder.add(
        rotation,
        memberId: 'bob',
        effectiveFrom: day(10, 24),
      ).valueOrNull!;
      expect(added.versions, hasLength(20));
      expect(added.versions.first.from.year, 2024);
      expect(added.versions.last.from, day(10, 24));
    });
  });

  test('a change on the same date replaces that version', () {
    final before = aRotation();
    final added = RotationBuilder.add(
      before,
      memberId: 'bob',
      effectiveFrom: day(10, 10),
    ).valueOrNull!;
    final removed = RotationBuilder.remove(
      added,
      memberId: 'bob',
      effectiveFrom: day(10, 10),
    ).valueOrNull!;
    expect(removed.versions, hasLength(2));
    expect(removed.versions.last.members, before.versions.last.members);
  });
}

/// Compares only the stable failure code, so the field name may be refined
/// without breaking every row of the table.
Matcher failureCode(String expected) => isA<AppFailure>().having(
  (failure) => switch (failure) {
    Validation(:final code) => code,
    Conflict(:final code) => code,
    _ => null,
  },
  'code',
  expected,
);
