import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_month_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar/calendar_test_support.dart';

/// P3-30 (acceptance 5, D-01): a month at the listener cap still builds fast.
///
/// A wall-clock bound in a unit test is only a smoke check; the real budget is
/// measured on a device. The bound is generous (the roadmap target is 30 ms) so
/// a slow CI machine does not flake.
void main() {
  final october = MonthKey(2026, 10);

  test('900 chores build one month model well inside the frame budget', () {
    final items = [
      for (var i = 0; i < 900; i++)
        aChoreItem('t${i % 30}_$i', DateKey(2026, 10, 1 + i % 31)),
    ];
    // Warm-up, then measure.
    CalendarMonthModel.build(
      month: october,
      weekStartDay: 6,
      items: items,
      today: kToday,
    );
    final watch = Stopwatch()..start();
    final model = CalendarMonthModel.build(
      month: october,
      weekStartDay: 6,
      items: items,
      today: kToday,
    );
    watch.stop();

    expect(model.weeks, isNotEmpty);
    expect(watch.elapsedMilliseconds, lessThan(250));
  });

  test('a second build of the same input gives an equal shape', () {
    final items = [for (var i = 0; i < 100; i++) aChoreItem('x$i', kToday)];
    final a = CalendarMonthModel.build(
      month: october,
      weekStartDay: 6,
      items: items,
      today: kToday,
    );
    final b = CalendarMonthModel.build(
      month: october,
      weekStartDay: 6,
      items: items,
      today: kToday,
    );
    expect(a.weeks.length, b.weeks.length);
  });
}
