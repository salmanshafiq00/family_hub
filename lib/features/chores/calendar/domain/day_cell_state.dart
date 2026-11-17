import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// What one date cell says about its day (pure, no widgets).
///
/// The order of the constants is the priority: when a day fits several, the
/// first one that matches wins (overdue > in progress > done > scheduled >
/// skipped > none).
enum DayCellState { overdue, inProgress, done, scheduled, skipped, none }

/// The state of [summary] (D: state = surface + a pip shape + a label).
DayCellState dayCellStateOf(DaySummary summary) {
  if (summary.isOutsideMonth || summary.total == 0) return DayCellState.none;
  final done = summary.doneCount;
  final skipped = summary.skippedCount;
  final open = summary.openCount;
  if (summary.countOf(ChoreStatus.overdue) > 0) return DayCellState.overdue;
  if (summary.countOf(ChoreStatus.inProgress) > 0 || (done > 0 && open > 0)) {
    return DayCellState.inProgress;
  }
  if (done > 0 && done == summary.total - skipped) return DayCellState.done;
  if (open > 0) return DayCellState.scheduled;
  if (skipped > 0) return DayCellState.skipped;
  return DayCellState.none;
}
