import 'package:family_hub/core/utils/date_key.dart';

/// One member's approved (or pending) absence, as the rotation engine needs it.
///
/// Only the days matter here; the record's id, type and reason belong to the
/// availability feature (P3-26). A range is inclusive on both ends.
final class AvailabilitySpan {
  const AvailabilitySpan({
    required this.memberId,
    required this.startDate,
    required this.endDate,
  });

  final String memberId;
  final DateKey startDate;
  final DateKey endDate;

  bool covers(DateKey day) => !day.isBefore(startDate) && !day.isAfter(endDate);

  @override
  bool operator ==(Object other) =>
      other is AvailabilitySpan &&
      other.memberId == memberId &&
      other.startDate == startDate &&
      other.endDate == endDate;

  @override
  int get hashCode => Object.hash(memberId, startDate, endDate);

  @override
  String toString() => 'AvailabilitySpan($memberId, $startDate..$endDate)';
}

/// A pure, in-memory index of who is unavailable on which day (P3-09).
///
/// The generator, the rotation preview and the calendar ask this one question,
/// so an absence can never hide the rota differently on two screens (D-P3-12).
/// P3-26 builds it from `memberAvailability`; until then every caller passes
/// [empty], which must keep the engine's answer identical to "no absences".
final class AvailabilityIndex {
  const AvailabilityIndex(this.spans);

  /// No absences known. Never null, so callers need no special case.
  static const AvailabilityIndex empty = AvailabilityIndex(
    <AvailabilitySpan>[],
  );

  final List<AvailabilitySpan> spans;

  /// True when [memberId] has a span covering [day].
  bool isUnavailable(String memberId, DateKey day) {
    for (final span in spans) {
      if (span.memberId == memberId && span.covers(day)) return true;
    }
    return false;
  }

  /// Every member with a span covering [day], in index order.
  Set<String> unavailableOn(DateKey day) => <String>{
    for (final span in spans)
      if (span.covers(day)) span.memberId,
  };

  @override
  bool operator ==(Object other) =>
      other is AvailabilityIndex &&
      other.spans.length == spans.length &&
      _sameSpans(other.spans, spans);

  @override
  int get hashCode => Object.hashAll(spans);

  static bool _sameSpans(List<AvailabilitySpan> a, List<AvailabilitySpan> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'AvailabilityIndex(${spans.length} spans)';
}
