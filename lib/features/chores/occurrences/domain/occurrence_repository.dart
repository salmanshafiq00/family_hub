import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// Port for `choreOccurrences/{id}` (P3-11; implemented in P3-13).
///
/// Reads are by DATE RANGE, never "all occurrences": the calendar keeps ONE
/// listener per visible month (D-P3-8) and filters "mine / family" in memory.
///
/// Writes go through [stage], which applies a whole [OccurrenceWritePlan]
/// (dotted-key patches + lifecycle events + inbox rows + audit entries) in one
/// batch. A use case never writes an occurrence field directly, so the
/// "patch only the keys you need" rule cannot be broken by accident.
abstract interface class OccurrenceRepository {
  /// Live occurrences whose `dateKey` is in `[from, to]`, bounded by the
  /// month/page limit. Soft-deleted documents are returned and filtered by the
  /// caller (the query then needs no extra index).
  Stream<List<ChoreOccurrence>> watchRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  });

  /// One live document, or null when it does not exist (yet).
  Stream<ChoreOccurrence?> watchOne(String familyId, String occurrenceId);

  /// One-shot read (materializing a projected item, repairing a status).
  Future<Result<ChoreOccurrence?>> get(String familyId, String occurrenceId);

  /// Applies [plan] in one batch. Everyday actions queue offline; generation
  /// (P3-12) is the integrity write and probes the server first.
  Future<Result<void>> stage(String familyId, OccurrenceWritePlan plan);
}
