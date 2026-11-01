import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_enums.dart';

/// Turns the workload of each day into a 0–4 tint level (Appendix B.4).
///
/// The weights are the ones the rota board (P3-28) uses, so the calendar and
/// the fair-share bars never rank a day differently.
abstract final class HeatCalculator {
  /// Highest level.
  static const int maxLevel = 4;

  /// easy 1, normal 2, hard 3 (D-P3-20: points of effort, never a ranking).
  static int weightOf(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => 1,
    Difficulty.normal => 2,
    Difficulty.hard => 3,
  };

  /// The effort of one day: the sum of the weights of the chores that still
  /// count. A skipped chore is nobody's workload.
  static int workloadOf(Iterable<ChoreItem> items) {
    var total = 0;
    for (final item in items) {
      if (item.status == ChoreStatus.skipped) continue;
      total += weightOf(item.difficulty);
    }
    return total;
  }

  /// Level 0 for a day with no workload, otherwise 1–4 from the share of busy
  /// days that are at most as busy: `ceil(4 * (days with load <= mine) / busy
  /// days)`. Equal loads always get the same level; the busiest day is always
  /// level 4; a month where every busy day is alike is level 4 throughout.
  static Map<DateKey, int> levels(Map<DateKey, int> workload) {
    final busy = <int>[
      for (final load in workload.values)
        if (load > 0) load,
    ];
    final result = <DateKey, int>{};
    for (final entry in workload.entries) {
      final load = entry.value;
      if (load <= 0) {
        result[entry.key] = 0;
        continue;
      }
      var atMost = 0;
      for (final other in busy) {
        if (other <= load) atMost++;
      }
      final level = (atMost * maxLevel + busy.length - 1) ~/ busy.length;
      // atMost is 1..busy.length, so the level is already within 1..maxLevel.
      result[entry.key] = level;
    }
    return result;
  }
}
