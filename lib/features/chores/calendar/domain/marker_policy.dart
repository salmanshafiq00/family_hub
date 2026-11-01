import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// What a day cell shows: up to [MarkerPolicy.maxMarkers] status glyphs and a
/// "+N" for the chores that did not fit (Appendix B.2).
final class MarkerPick {
  const MarkerPick({required this.markers, required this.extra});

  static const MarkerPick none = MarkerPick(
    markers: <ChoreStatus>[],
    extra: 0,
  );

  /// The glyphs to draw, most urgent first.
  final List<ChoreStatus> markers;

  /// How many chores are not drawn (the "+N").
  final int extra;

  @override
  bool operator ==(Object other) =>
      other is MarkerPick &&
      other.extra == extra &&
      other.markers.length == markers.length &&
      _same(other.markers, markers);

  @override
  int get hashCode => Object.hash(Object.hashAll(markers), extra);

  static bool _same(List<ChoreStatus> a, List<ChoreStatus> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'MarkerPick($markers, +$extra)';
}

/// Chooses the markers of one day: the most urgent chores first
/// (overdue > in progress > scheduled > completed > verified > skipped).
///
/// One marker per CHORE, not per distinct status, so a day with seven open
/// chores reads "three rings and +4" instead of a single ring that hides the
/// load. Pure and stable: equal urgency keeps the order given.
abstract final class MarkerPolicy {
  static const int maxMarkers = 3;

  /// Lower is more urgent.
  static int urgencyRank(ChoreStatus status) => switch (status) {
    ChoreStatus.overdue => 0,
    ChoreStatus.inProgress => 1,
    ChoreStatus.scheduled => 2,
    ChoreStatus.completed => 3,
    ChoreStatus.verified => 4,
    ChoreStatus.skipped => 5,
  };

  static MarkerPick pick(Iterable<ChoreItem> items) {
    final statuses = <ChoreStatus>[for (final item in items) item.status];
    if (statuses.isEmpty) return MarkerPick.none;
    // List.sort is not stable, so rank ties are broken by position.
    final order = List<int>.generate(statuses.length, (i) => i)
      ..sort((a, b) {
        final byRank = urgencyRank(
          statuses[a],
        ).compareTo(urgencyRank(statuses[b]));
        return byRank != 0 ? byRank : a.compareTo(b);
      });
    final shown = order.length < maxMarkers ? order.length : maxMarkers;
    return MarkerPick(
      markers: List<ChoreStatus>.unmodifiable(<ChoreStatus>[
        for (var i = 0; i < shown; i++) statuses[order[i]],
      ]),
      extra: statuses.length - shown,
    );
  }
}
