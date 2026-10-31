import 'package:family_hub/core/utils/date_key.dart';

/// The days a rotation change must re-plan (P3-18).
final class PlanningRange {
  const PlanningRange({required this.from, required this.to});

  final DateKey from;
  final DateKey to;

  @override
  bool operator ==(Object other) =>
      other is PlanningRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'PlanningRange($from..$to)';
}

/// From [effectiveFrom] (never before [today]) to the generation marker, or to
/// [today] + [horizonDays] when the marker is missing or behind.
///
/// Returns `null` when the change starts after everything that is generated
/// today: nothing exists there yet, and the next generation will use the new
/// rotation by itself. Same bound the template editor uses (P3-16).
PlanningRange? planningRange({
  required DateKey today,
  required DateKey effectiveFrom,
  required DateKey? marker,
  required int horizonDays,
}) {
  final from = effectiveFrom.isBefore(today) ? today : effectiveFrom;
  final to = marker != null && !marker.isBefore(today)
      ? marker
      : today.addDays(horizonDays);
  return from.isAfter(to) ? null : PlanningRange(from: from, to: to);
}
