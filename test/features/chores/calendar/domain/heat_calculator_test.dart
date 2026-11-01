import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/heat_calculator.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar_test_support.dart';

void main() {
  test('weights are easy 1, normal 2, hard 3', () {
    expect(HeatCalculator.weightOf(Difficulty.easy), 1);
    expect(HeatCalculator.weightOf(Difficulty.normal), 2);
    expect(HeatCalculator.weightOf(Difficulty.hard), 3);
  });

  test('workload sums the weights and ignores skipped chores', () {
    expect(
      HeatCalculator.workloadOf([
        aChoreItem('a', kToday, difficulty: Difficulty.easy),
        aChoreItem('b', kToday, difficulty: Difficulty.hard),
        aChoreItem('c', kToday, status: ChoreStatus.skipped),
      ]),
      4,
    );
    expect(HeatCalculator.workloadOf(const []), 0);
  });

  DateKey day(int n) => DateKey(2026, 10, n);

  test('an empty month is all level 0', () {
    expect(
      HeatCalculator.levels({day(1): 0, day(2): 0}),
      {day(1): 0, day(2): 0},
    );
    expect(HeatCalculator.levels(const {}), isEmpty);
  });

  test('a single busy day is the busiest, level 4', () {
    expect(HeatCalculator.levels({day(1): 5, day(2): 0}), {
      day(1): 4,
      day(2): 0,
    });
  });

  test('equal loads share a level and the busiest day is level 4', () {
    final levels = HeatCalculator.levels({
      day(1): 2,
      day(2): 2,
      day(3): 4,
      day(4): 6,
      day(5): 8,
    });
    expect(levels[day(1)], levels[day(2)]);
    expect(levels[day(5)], 4);
    // 2 -> 2 of 5 days are <= 2 -> ceil(8/5) = 2; 4 -> 3 of 5 -> 3; 6 -> 4; 8 -> 4
    expect(levels[day(1)], 2);
    expect(levels[day(3)], 3);
    expect(levels[day(4)], 4);
  });

  test('levels never decrease as the load grows', () {
    final loads = {for (var i = 1; i <= 20; i++) day(i): i};
    final levels = HeatCalculator.levels(loads);
    for (var i = 2; i <= 20; i++) {
      expect(levels[day(i)]! >= levels[day(i - 1)]!, isTrue);
    }
    expect(levels.values.every((level) => level >= 1 && level <= 4), isTrue);
  });

  test('a day with no load is 0 even beside busy days', () {
    expect(HeatCalculator.levels({day(1): 0, day(2): 3})[day(1)], 0);
  });
}
