import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';

/// Picks a replacement for an unavailable member (road map P3-09).
///
/// Deterministic on purpose: no randomness, no "who completed last" (D-P3-11).
/// The candidate list is already in rotation order, so a tie on workload is
/// broken by that order and two devices always suggest the same person.
abstract final class CoverPicker {
  /// The eligible candidate with the fewest weighted items in the window, or
  /// `null` when nobody is left.
  ///
  /// [candidates] must contain only ACTIVE members, in rotation order. A member
  /// who is unavailable on [day] (or listed in [exclude]) is skipped.
  /// [windowLoad] is the weighted workload of the visible window; a missing
  /// entry counts as 0.
  static String? pick({
    required List<String> candidates,
    required DateKey day,
    Map<String, int> windowLoad = const <String, int>{},
    AvailabilityIndex unavailable = AvailabilityIndex.empty,
    Set<String> exclude = const <String>{},
  }) {
    String? best;
    var bestLoad = 0;
    for (final candidate in candidates) {
      if (exclude.contains(candidate)) continue;
      if (unavailable.isUnavailable(candidate, day)) continue;
      final load = windowLoad[candidate] ?? 0;
      if (best == null || load < bestLoad) {
        best = candidate;
        bestLoad = load;
      }
    }
    return best;
  }
}
