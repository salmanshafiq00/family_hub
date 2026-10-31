import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/date_ranges.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_engine.dart';

/// One turn of a rota: who is on duty from [start] to [end] (both inclusive).
final class RotaCell {
  const RotaCell({
    required this.start,
    required this.end,
    required this.memberId,
    this.needsCover = false,
  });

  final DateKey start;
  final DateKey end;

  /// The planned member, or `null` when nobody is planned for the turn.
  final String? memberId;

  /// The planned member is no longer an active member of the family, so the
  /// turn will need a cover (P3-18).
  final bool needsCover;

  @override
  bool operator ==(Object other) =>
      other is RotaCell &&
      other.start == start &&
      other.end == end &&
      other.memberId == memberId &&
      other.needsCover == needsCover;

  @override
  int get hashCode => Object.hash(start, end, memberId, needsCover);

  @override
  String toString() => 'RotaCell($start..$end, $memberId, cover: $needsCover)';
}

/// The next turns of a rotation, for the duty-group screens (road map P3-18).
///
/// PURE: it only asks [RotationEngine], so the preview, the generator and the
/// rota board always name the same person for the same day. A cell never spans
/// a version boundary, so "adding Dave from next Saturday" shows the old turns
/// unchanged up to that Saturday and the new roster from it.
abstract final class RotaPreview {
  /// The number of turns the screens show.
  static const int defaultCycles = 8;

  /// True when [rotation] advances by chore days (`occurrence`) at [from] but no
  /// [Recurrence] was given: such a rota cannot be previewed on its own.
  static bool needsSchedule(
    Rotation rotation,
    DateKey from, {
    Recurrence? recurrence,
  }) {
    if (recurrence != null) return false;
    final version =
        RotationEngine.versionFor(rotation, from) ??
        (rotation.versions.isEmpty ? null : rotation.versions.first);
    return version?.cycleUnit == CycleUnit.occurrence;
  }

  /// The [cycles] turns that start with the one containing [from].
  ///
  /// [activeMemberIds] marks a planned member who is gone as `needsCover`; pass
  /// `null` to skip the check. Before the first version the preview starts at
  /// that version's date.
  static List<RotaCell> build(
    Rotation rotation, {
    required DateKey from,
    int cycles = defaultCycles,
    Recurrence? recurrence,
    Set<String>? activeMemberIds,
  }) {
    if (rotation.versions.isEmpty || cycles <= 0) return const <RotaCell>[];
    if (needsSchedule(rotation, from, recurrence: recurrence)) {
      return const <RotaCell>[];
    }

    var cursor = from;
    final earliest = rotation.versions
        .map((version) => version.from)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    if (cursor.isBefore(earliest)) cursor = earliest;

    final first = RotationEngine.versionFor(rotation, cursor)!;
    if (first.cycleUnit == CycleUnit.occurrence) {
      if (!RecurrenceEngine.occursOn(recurrence!, cursor)) {
        final next = RecurrenceEngine.nextAfter(recurrence, cursor);
        if (next == null) return const <RotaCell>[];
        cursor = next;
      }
    } else {
      cursor = _cycleStart(rotation, first, cursor);
    }

    final cells = <RotaCell>[];
    while (cells.length < cycles) {
      final version = RotationEngine.versionFor(rotation, cursor)!;
      final planned = RotationEngine.planned(
        rotation,
        cursor,
        recurrence: recurrence,
      );
      final next = _nextStart(rotation, version, cursor, recurrence);
      if (next == null) {
        cells.add(_cell(cursor, cursor, planned, activeMemberIds));
        break;
      }
      final end = version.cycleUnit == CycleUnit.occurrence
          ? cursor
          : next.addDays(-1);
      cells.add(_cell(cursor, end, planned, activeMemberIds));
      cursor = next;
    }
    return List<RotaCell>.unmodifiable(cells);
  }

  static RotaCell _cell(
    DateKey start,
    DateKey end,
    String? planned,
    Set<String>? activeMemberIds,
  ) => RotaCell(
    start: start,
    end: end,
    memberId: planned,
    needsCover:
        planned != null &&
        activeMemberIds != null &&
        !activeMemberIds.contains(planned),
  );

  /// The first day of the cycle of [day], never before the version's date.
  static DateKey _cycleStart(
    Rotation rotation,
    RotationVersion version,
    DateKey day,
  ) {
    final DateKey start;
    switch (version.cycleUnit) {
      case CycleUnit.day:
      case CycleUnit.occurrence:
        start = day;
      case CycleUnit.week:
        start = startOfWeek(day, _safeWeekStart(version.weekStartDay));
      case CycleUnit.month:
        start = DateKey(day.year, day.month, 1);
    }
    return start.isBefore(version.from) ? version.from : start;
  }

  /// The start of the next turn, clamped to the next rotation version.
  static DateKey? _nextStart(
    Rotation rotation,
    RotationVersion version,
    DateKey cursor,
    Recurrence? recurrence,
  ) {
    DateKey? raw;
    switch (version.cycleUnit) {
      case CycleUnit.day:
        raw = cursor.addDays(1);
      case CycleUnit.week:
        raw = startOfWeek(
          cursor,
          _safeWeekStart(version.weekStartDay),
        ).addDays(7);
      case CycleUnit.month:
        raw = cursor.monthKey.addMonths(1).startOfMonth;
      case CycleUnit.occurrence:
        raw = recurrence == null
            ? null
            : RecurrenceEngine.nextAfter(recurrence, cursor);
    }
    for (final later in rotation.versions) {
      if (later.from.isAfter(cursor) && (raw == null || later.from.isBefore(raw))) {
        raw = later.from;
      }
    }
    return raw;
  }

  static int _safeWeekStart(int weekStartDay) =>
      weekStartDay < DateTime.monday || weekStartDay > DateTime.sunday
      ? DateTime.saturday
      : weekStartDay;
}
