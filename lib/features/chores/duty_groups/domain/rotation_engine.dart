import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/date_ranges.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_engine.dart';

/// Answers "who is on duty on this day?" (road map P3-09).
///
/// The rotation is CALENDAR based (D-P3-11): the same date always gives the
/// same person, whatever happened before, so an absence or a completion can
/// never move the rota. Everything is computed on household local days
/// ([DateKey]); no clock, no timezone, no randomness.
///
/// This is the ONLY runtime caller of the maths (the generator P3-12), and the
/// rota preview (P3-18) and rota board (P3-28) use it too, so every screen
/// agrees.
abstract final class RotationEngine {
  /// The planned member on [day], or `null` when no version is effective yet.
  ///
  /// [occurrenceIndex] is a pre-computed cycle count for callers that already
  /// counted occurrences (the `occurrence` unit); when null the engine computes
  /// it. [recurrence] is REQUIRED by the `occurrence` unit and ignored by the
  /// others. [startDate] / [endDate] clip that recurrence to the template span.
  static String? planned(
    Rotation rotation,
    DateKey day, {
    int? occurrenceIndex,
    Recurrence? recurrence,
    DateKey? startDate,
    DateKey? endDate,
  }) {
    final version = versionFor(rotation, day);
    if (version == null || version.members.isEmpty) return null;

    final cycles =
        occurrenceIndex ??
        cyclesBetween(
          anchor: version.anchorDate,
          day: day,
          unit: version.cycleUnit,
          weekStartDay: version.weekStartDay,
          recurrence: recurrence,
          startDate: startDate,
          endDate: endDate,
        );
    final index = _positiveMod(
      version.anchorIndex + cycles,
      version.members.length,
    );
    return version.members[index];
  }

  /// The version with the greatest `from` that is not after [day].
  ///
  /// `null` before the first version: the chore simply has no owner yet.
  static RotationVersion? versionFor(Rotation rotation, DateKey day) {
    RotationVersion? best;
    for (final version in rotation.versions) {
      if (version.from.isAfter(day)) continue;
      if (best == null || version.from.isAfter(best.from)) best = version;
    }
    return best;
  }

  /// How many cycles lie between [anchor] and [day].
  ///
  /// Floor semantics: a day before the anchor gives a negative count, so
  /// `(anchorIndex + cycles) mod n` still names the right person (F.2 cases
  /// 3-4). The `week` unit counts differences of week starts; the `month` unit
  /// differences of month keys; the `occurrence` unit counts firing days of
  /// [recurrence], so a skipped Friday does not advance the rota (F.2 case 9).
  static int cyclesBetween({
    required DateKey anchor,
    required DateKey day,
    required CycleUnit unit,
    required int weekStartDay,
    Recurrence? recurrence,
    DateKey? startDate,
    DateKey? endDate,
  }) {
    if (day == anchor) return 0;
    switch (unit) {
      case CycleUnit.day:
        return day.epochDay - anchor.epochDay;
      case CycleUnit.week:
        final start = _safeWeekStart(weekStartDay);
        return _floorDiv(
          startOfWeek(day, start).epochDay -
              startOfWeek(anchor, start).epochDay,
          7,
        );
      case CycleUnit.month:
        return _monthIndex(day) - _monthIndex(anchor);
      case CycleUnit.occurrence:
        if (recurrence == null) return 0;
        return _occurrenceDistance(
          recurrence,
          anchor,
          day,
          startDate: startDate,
          endDate: endDate,
        );
    }
  }

  /// The number of firing days strictly after [anchor] up to [day], or the
  /// negative number strictly before it when [day] is earlier.
  ///
  /// The anchor itself is cycle 0. Callers must pass a recurrence whose anchor
  /// is a firing day (the editor and the generator do), otherwise the two
  /// neighbouring occurrences are two cycles apart, which is still stable but
  /// not what a rota means.
  static int _occurrenceDistance(
    Recurrence recurrence,
    DateKey anchor,
    DateKey day, {
    DateKey? startDate,
    DateKey? endDate,
  }) {
    final anchorFires = RecurrenceEngine.occursOn(
      recurrence,
      anchor,
      startDate: startDate,
      endDate: endDate,
    );
    if (day.isAfter(anchor)) {
      final count = RecurrenceEngine.countBetween(
        recurrence,
        anchor,
        day,
        startDate: startDate,
        endDate: endDate,
      );
      return anchorFires ? count - 1 : count;
    }
    final count = RecurrenceEngine.countBetween(
      recurrence,
      day,
      anchor,
      startDate: startDate,
      endDate: endDate,
    );
    return -(anchorFires ? count - 1 : count);
  }

  /// 1-based weekday with Saturday (6) as the default for a bad stored value.
  static int _safeWeekStart(int weekStartDay) =>
      weekStartDay < DateTime.monday || weekStartDay > DateTime.sunday
      ? DateTime.saturday
      : weekStartDay;

  /// `year * 12 + month` so two month keys subtract to a cycle count.
  static int _monthIndex(DateKey day) => day.year * 12 + (day.month - 1);

  /// A modulo that never returns a negative index.
  static int _positiveMod(int value, int n) {
    final remainder = value % n;
    return remainder < 0 ? remainder + n : remainder;
  }

  /// `a ~/ b` that floors for a negative [a] (Dart's `~/` truncates).
  static int _floorDiv(int a, int b) {
    final quotient = a ~/ b;
    final remainder = a - quotient * b;
    return remainder < 0 ? quotient - 1 : quotient;
  }
}
