import 'package:family_hub/features/chores/occurrences/domain/day_part.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../calendar/calendar_test_support.dart';

void main() {
  test('boundaries', () {
    expect(dayPartOf(0), ChoreDayPart.earlyMorning);
    expect(dayPartOf(359), ChoreDayPart.earlyMorning);
    expect(dayPartOf(360), ChoreDayPart.morning);
    expect(dayPartOf(599), ChoreDayPart.morning);
    expect(dayPartOf(600), ChoreDayPart.noon);
    expect(dayPartOf(839), ChoreDayPart.noon);
    expect(dayPartOf(840), ChoreDayPart.afternoon);
    expect(dayPartOf(1019), ChoreDayPart.afternoon);
    expect(dayPartOf(1020), ChoreDayPart.evening);
    expect(dayPartOf(1199), ChoreDayPart.evening);
    expect(dayPartOf(1200), ChoreDayPart.night);
    expect(dayPartOf(1439), ChoreDayPart.night);
  });

  test('a chore without a time belongs to the night', () {
    expect(dayPartOf(null), ChoreDayPart.night);
  });

  test('groupByDayPart keeps clock order and drops empty parts', () {
    final groups = groupByDayPart([
      aChoreItem('n', kToday, dueMinutes: 1300),
      aChoreItem('m', kToday, dueMinutes: 540),
      aChoreItem('m2', kToday, dueMinutes: 500),
    ]);
    expect(groups.map((g) => g.$1), [ChoreDayPart.morning, ChoreDayPart.night]);
    expect(groups.first.$2.map((i) => i.id), ['m', 'm2']);
    expect(groupByDayPart(const []), isEmpty);
  });
}
