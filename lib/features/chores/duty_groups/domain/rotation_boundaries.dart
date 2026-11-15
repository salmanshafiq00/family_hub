import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/date_ranges.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';

/// Where a cycle ends, for the rotation builder and the change sheet.
abstract final class RotationBoundaries {
  /// The first cycle boundary on or after [requested] for [version].
  ///
  /// Day cycles change any day; week cycles only on a week start; month cycles
  /// on the first of a month. The `occurrence` unit has no single schedule on
  /// its own, so the caller picks a firing day and it is used as-is.
  static DateKey next(RotationVersion version, DateKey requested) {
    switch (version.cycleUnit) {
      case CycleUnit.day:
      case CycleUnit.occurrence:
        return requested;
      case CycleUnit.week:
        final start = startOfWeek(
          requested,
          _safeWeekStart(version.weekStartDay),
        );
        return start == requested ? start : start.addDays(7);
      case CycleUnit.month:
        return requested.day == 1
            ? requested
            : requested.monthKey.addMonths(1).startOfMonth;
    }
  }

  static int _safeWeekStart(int weekStartDay) =>
      weekStartDay < DateTime.monday || weekStartDay > DateTime.sunday
      ? DateTime.saturday
      : weekStartDay;
}
