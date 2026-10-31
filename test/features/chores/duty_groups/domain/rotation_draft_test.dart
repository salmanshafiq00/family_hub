import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/group_planning.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_draft.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

RotationDraft _draft([List<String> members = const <String>[]]) =>
    RotationDraft(
      members: members,
      startsOn: DateKey(2026, 10, 24),
      cycleUnit: CycleUnit.week,
      weekStartDay: DateTime.saturday,
    );

void main() {
  group('RotationDraft', () {
    test('adds, removes and ignores duplicates', () {
      final draft = _draft().withMember('a').withMember('b').withMember('a');
      expect(draft.members, ['a', 'b']);
      expect(draft.withoutMember('a').members, ['b']);
    });

    test('removing the first member resets who goes first', () {
      final draft = _draft(<String>['a', 'b', 'c']).copyWith(startsWith: 'b');
      expect(draft.firstMember, 'b');
      final removed = draft.withoutMember('b');
      expect(removed.startsWith, isNull);
      expect(removed.firstMember, 'a');
    });

    test('moved follows ReorderableListView semantics', () {
      final draft = _draft(<String>['a', 'b', 'c']);
      expect(draft.moved(0, 3).members, ['b', 'c', 'a']);
      expect(draft.moved(2, 0).members, ['c', 'a', 'b']);
      expect(draft.moved(1, 1).members, ['a', 'b', 'c']);
    });

    test('one member is not a rotation', () {
      final failure = _draft(<String>['a']).toRotation().failureOrNull;
      expect(failure, const Validation('members', 'too_few_members'));
      expect(_draft().toRotation().isFailure, isTrue);
    });

    test('the chosen first member takes the first turn', () {
      final rotation = _draft(<String>['a', 'b', 'c'])
          .copyWith(startsWith: 'b')
          .toRotation()
          .valueOrNull!;
      expect(RotationEngine.planned(rotation, DateKey(2026, 10, 24)), 'b');
      expect(RotationEngine.planned(rotation, DateKey(2026, 10, 31)), 'c');
      expect(rotation.versions.single.weekStartDay, DateTime.saturday);
    });
  });

  group('planningRange', () {
    final today = DateKey(2026, 10, 24);

    test('runs from the effective day to the marker', () {
      final range = planningRange(
        today: today,
        effectiveFrom: DateKey(2026, 10, 31),
        marker: DateKey(2026, 11, 20),
        horizonDays: 30,
      );
      expect(range?.from, DateKey(2026, 10, 31));
      expect(range?.to, DateKey(2026, 11, 20));
    });

    test('never starts in the past and falls back to the horizon', () {
      final range = planningRange(
        today: today,
        effectiveFrom: DateKey(2026, 10, 1),
        marker: null,
        horizonDays: 30,
      );
      expect(range?.from, today);
      expect(range?.to, DateKey(2026, 11, 23));
    });

    test('a change after everything generated needs no planning', () {
      expect(
        planningRange(
          today: today,
          effectiveFrom: DateKey(2027, 3, 1),
          marker: DateKey(2026, 11, 20),
          horizonDays: 30,
        ),
        isNull,
      );
    });
  });
}
