import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// Port for `choreOccurrences/{id}` (P3-11; implemented in P3-13).
///
/// Reads are by DATE RANGE, never "all occurrences": the calendar keeps ONE
/// listener per visible month (D-P3-8) and filters "mine / family" in memory.
///
/// Writes go through [stage] / [stageIntegrity], which apply a whole
/// [OccurrenceWritePlan] (creates + dotted-key patches + lifecycle events +
/// inbox rows + audit entries) in one batch. A use case never writes an
/// occurrence field directly, so the "patch only the keys you need" rule cannot
/// be broken by accident.
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

  /// The lifecycle events of one occurrence, oldest first.
  Stream<List<OccurrenceEvent>> watchEvents(
    String familyId,
    String occurrenceId,
  );

  /// The manager's verification queue: completed occurrences, newest first.
  ///
  /// The query filters on `status` only; the caller drops rows whose snapshot
  /// says `verification == off` (that keeps the query to the single
  /// `status + dateKey DESC` index in road map 3.8).
  Stream<List<ChoreOccurrence>> watchVerifyQueue(String familyId);

  /// One-shot read (materializing a projected item, repairing a status).
  Future<Result<ChoreOccurrence?>> get(String familyId, String occurrenceId);

  /// Existing ids in `[from, to]`, INCLUDING soft-deleted tombstones.
  ///
  /// Generation needs the ids only: a `set` on an existing id would be an
  /// UPDATE for the rules (and be rejected), so a tombstone must block a create
  /// exactly like a live document does.
  Future<Result<List<String>>> idsInRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  });

  /// Full documents in `[from, to]`, INCLUDING soft-deleted ones.
  ///
  /// Regenerate needs the tombstone so it can restore a document that matches
  /// the recurrence again after a template is resumed.
  Future<Result<List<ChoreOccurrence>>> listRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  });

  /// Full documents of one template from [from] onwards, bounded by the page
  /// limit (the `templateId + dateKey` index). Used by the replan.
  Future<Result<List<ChoreOccurrence>>> listByTemplate(
    String familyId,
    String templateId, {
    required DateKey from,
  });

  /// Applies [plan] in one batch. Everyday actions queue offline.
  Future<Result<void>> stage(String familyId, OccurrenceWritePlan plan);

  /// Applies [plan] with a SERVER PROBE (integrity write, road map 3.4).
  ///
  /// Generation, regeneration and replan use this: two devices writing the same
  /// deterministic ids offline would otherwise diverge. A create whose id
  /// already exists fails with `Conflict`.
  Future<Result<void>> stageIntegrity(
    String familyId,
    OccurrenceWritePlan plan,
  );
}
