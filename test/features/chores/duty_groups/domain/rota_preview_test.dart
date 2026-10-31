import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rota_preview.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-18: the rota preview names the same people as the engine, never spans a
/// version boundary, and shows an unchanged past when a member is added.
void main() {
  // Weekly rotation alice -> cara -> dave, Saturday weeks, cycle 0 = 2026-10-03.
  final rotation = aRotation();

  group('RotaPreview.build', () {
    test('lists the next turns from the cycle that contains the day', () {
      final cells = RotaPreview.build(rotation, from: DateKey(2026, 10, 28));

      expect(cells, hasLength(RotaPreview.defaultCycles));
      expect(cells[0].start, DateKey(2026, 10, 24));
      expect(cells[0].end, DateKey(2026, 10, 30));
      expect(cells[0].memberId, 'alice');
      expect(cells[1].start, DateKey(2026, 10, 31));
      expect(cells[1].memberId, 'cara');
      expect(cells[2].memberId, 'dave');
      expect(cells[3].memberId, 'alice');
    });

    test('day and month cycles step by their own boundary', () {
      final daily = aRotation(cycleUnit: CycleUnit.day);
      final days = RotaPreview.build(daily, from: DateKey(2026, 10, 24));
      expect(days[0].start, days[0].end);
      expect(days[1].start, DateKey(2026, 10, 25));

      final monthly = aRotation(cycleUnit: CycleUnit.month);
      final months = RotaPreview.build(
        monthly,
        from: DateKey(2026, 10, 24),
        cycles: 2,
      );
      expect(months[0].start, DateKey(2026, 10, 1));
      expect(months[0].end, DateKey(2026, 10, 31));
      expect(months[1].start, DateKey(2026, 11, 1));
    });

    test('a member who is not active needs a cover', () {
      final cells = RotaPreview.build(
        rotation,
        from: DateKey(2026, 10, 24),
        cycles: 3,
        activeMemberIds: <String>{'alice', 'dave'},
      );
      expect(cells.map((c) => c.needsCover), [false, true, false]);
    });

    test('an occurrence rotation without a schedule cannot be previewed', () {
      final byChore = aRotation(cycleUnit: CycleUnit.occurrence);
      expect(
        RotaPreview.needsSchedule(byChore, DateKey(2026, 10, 24)),
        isTrue,
      );
      expect(
        RotaPreview.build(byChore, from: DateKey(2026, 10, 24)),
        isEmpty,
      );
    });

    test('before the first version the preview starts at that version', () {
      final cells = RotaPreview.build(
        rotation,
        from: DateKey(2026, 1, 1),
        cycles: 1,
      );
      expect(cells.single.start, DateKey(2026, 9, 1));
    });
  });

  group('adding a member from a boundary', () {
    test('keeps every turn before the boundary and the boundary person', () {
      final changed = RotationBuilder.add(
        rotation,
        memberId: 'bob',
        effectiveFrom: DateKey(2026, 10, 21),
      ).valueOrNull!;
      final boundary = changed.versions.last.from;
      expect(boundary, DateKey(2026, 10, 24));

      final from = DateKey(2026, 10, 3);
      final before = RotaPreview.build(rotation, from: from, cycles: 12);
      final after = RotaPreview.build(changed, from: from, cycles: 12);

      for (var i = 0; i < before.length; i++) {
        if (before[i].end.isBefore(boundary)) {
          expect(after[i], before[i], reason: 'turn $i must not change');
        }
      }
      final atBoundary = after.firstWhere((c) => c.start == boundary);
      expect(atBoundary.memberId, 'alice');
      final rest = after.where((c) => !c.start.isBefore(boundary)).toList();
      expect(rest.take(4).map((c) => c.memberId), [
        'alice',
        'cara',
        'dave',
        'bob',
      ]);
    });
  });
}
