import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/day_cell_state.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final day = DateKey(2026, 10, 25);

  DaySummary of(Map<ChoreStatus, int> counts) => DaySummary(
    dateKey: day,
    total: counts.values.fold(0, (a, b) => a + b),
    counts: counts,
  );

  group('dayCellStateOf', () {
    test('a day without chores, or outside the month, is none', () {
      expect(dayCellStateOf(DaySummary(dateKey: day)), DayCellState.none);
      expect(dayCellStateOf(DaySummary.outside(day)), DayCellState.none);
    });

    test('open chores only are scheduled', () {
      expect(
        dayCellStateOf(of({ChoreStatus.scheduled: 2})),
        DayCellState.scheduled,
      );
    });

    test('some done and some open is in progress', () {
      expect(
        dayCellStateOf(
          of({ChoreStatus.completed: 1, ChoreStatus.scheduled: 1}),
        ),
        DayCellState.inProgress,
      );
      expect(
        dayCellStateOf(of({ChoreStatus.inProgress: 1})),
        DayCellState.inProgress,
      );
    });

    test('all done, skipped ones aside, is done', () {
      expect(
        dayCellStateOf(of({ChoreStatus.completed: 1, ChoreStatus.verified: 1})),
        DayCellState.done,
      );
      expect(
        dayCellStateOf(of({ChoreStatus.completed: 2, ChoreStatus.skipped: 1})),
        DayCellState.done,
      );
    });

    test('only skipped chores is skipped', () {
      expect(
        dayCellStateOf(of({ChoreStatus.skipped: 2})),
        DayCellState.skipped,
      );
    });

    test('overdue beats everything', () {
      expect(
        dayCellStateOf(
          of({
            ChoreStatus.overdue: 1,
            ChoreStatus.completed: 3,
            ChoreStatus.inProgress: 1,
          }),
        ),
        DayCellState.overdue,
      );
    });

    test('in progress beats done and scheduled', () {
      expect(
        dayCellStateOf(
          of({
            ChoreStatus.inProgress: 1,
            ChoreStatus.completed: 1,
            ChoreStatus.scheduled: 1,
          }),
        ),
        DayCellState.inProgress,
      );
    });
  });
}
