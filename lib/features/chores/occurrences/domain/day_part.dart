import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';

/// The parts of a day a chore can be due in (road map P3-15, P3-20).
///
/// They are a closed domain set (not a configurable list like the due-time
/// presets, D-P3-4): the labels come from the ARB, the boundaries are fixed so
/// Today, the week view and the day panel never group the same chore
/// differently.
enum ChoreDayPart { earlyMorning, morning, noon, afternoon, evening, night }

/// The part of the day a due time falls in.
///
/// 00:00–05:59 early morning, 06:00–09:59 morning, 10:00–13:59 noon,
/// 14:00–16:59 afternoon, 17:00–19:59 evening, 20:00–23:59 night. A chore
/// without a time belongs to `night` (its deadline is the end of the day).
ChoreDayPart dayPartOf(int? dueMinutes) {
  if (dueMinutes == null) return ChoreDayPart.night;
  if (dueMinutes < 6 * 60) return ChoreDayPart.earlyMorning;
  if (dueMinutes < 10 * 60) return ChoreDayPart.morning;
  if (dueMinutes < 14 * 60) return ChoreDayPart.noon;
  if (dueMinutes < 17 * 60) return ChoreDayPart.afternoon;
  if (dueMinutes < 20 * 60) return ChoreDayPart.evening;
  return ChoreDayPart.night;
}

/// The items of one day grouped by [ChoreDayPart], in clock order. Parts with
/// no item are left out; the order inside a part is the order given.
List<(ChoreDayPart, List<ChoreItem>)> groupByDayPart(List<ChoreItem> items) {
  final groups = <ChoreDayPart, List<ChoreItem>>{};
  for (final item in items) {
    (groups[dayPartOf(item.dueMinutes)] ??= <ChoreItem>[]).add(item);
  }
  return <(ChoreDayPart, List<ChoreItem>)>[
    for (final part in ChoreDayPart.values)
      if (groups[part] != null) (part, groups[part]!),
  ];
}
