import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';

/// How many of [memberId]'s still-open chores fall inside `start..end`
/// (P3-27 preview "N chores are affected"). Projected chores count: the
/// generator will write them with the same owner.
int affectedChoresCount(
  Iterable<ChoreItem> items, {
  required String memberId,
  required DateKey start,
  required DateKey end,
}) => items
    .where(
      (item) =>
          item.assigneeId == memberId &&
          !item.dateKey.isBefore(start) &&
          !item.dateKey.isAfter(end) &&
          item.status != ChoreStatus.completed &&
          item.status != ChoreStatus.verified &&
          item.status != ChoreStatus.skipped,
    )
    .length;

/// The months a range touches, at most [limit] of them (each is one listener;
/// a longer absence shows a lower bound).
List<MonthKey> monthsOfRange(DateKey start, DateKey end, {int limit = 3}) {
  final months = <MonthKey>[];
  var year = start.year;
  var month = start.month;
  while (months.length < limit &&
      (year < end.year || (year == end.year && month <= end.month))) {
    months.add(MonthKey(year, month));
    month++;
    if (month > 12) {
      month = 1;
      year++;
    }
  }
  return months;
}

/// Which message tells what the family's policy does for a new absence.
enum PolicyLine { ask, auto, skip, share }

PolicyLine policyLineOf(AbsencePolicy policy) => switch (policy) {
  AbsencePolicy.askCover => PolicyLine.ask,
  AbsencePolicy.autoCover => PolicyLine.auto,
  AbsencePolicy.skip => PolicyLine.skip,
  AbsencePolicy.autoAssign => PolicyLine.share,
};
