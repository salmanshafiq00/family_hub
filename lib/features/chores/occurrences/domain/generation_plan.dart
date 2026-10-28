import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// How many occurrence documents one generation batch may contain.
///
/// 400 drafts plus the chunk's ONE audit entry is 401 writes, below Firestore's
/// 500-write batch cap. P3-13's emulator test may lower this value if the rules'
/// access-call budget rejects 400 creates in one batch.
abstract final class GenerationLimits {
  static const int chunkWrites = 400;
}

/// Port for `settings/choreGeneration {throughEpochDay}` (D-P3-10).
///
/// The marker is the last day that has been generated. It is advanced only
/// after the last chunk, so a crash leaves it behind and the next app open
/// continues where the previous run stopped.
abstract interface class GenerationMarkerRepository {
  /// The stored `through` day, or null when the marker does not exist yet.
  Future<Result<DateKey?>> readThrough(String familyId);

  /// The live marker (the app-open hook and the calendar show it).
  Stream<DateKey?> watchThrough(String familyId);

  /// Advances the marker. The rules only accept a value that is greater and at
  /// most 120 days ahead of the stored one.
  Future<Result<void>> writeThrough(
    String familyId,
    DateKey through, {
    required String actorId,
  });
}

/// What one generation / regeneration / replan run did.
final class GenerationOutcome {
  const GenerationOutcome({
    this.created = 0,
    this.restored = 0,
    this.removed = 0,
    this.replanned = 0,
    this.chunks = 0,
    this.through,
  });

  static const GenerationOutcome none = GenerationOutcome();

  /// Documents created.
  final int created;

  /// Soft-deleted documents brought back (a resumed template).
  final int restored;

  /// Documents soft-deleted because they no longer match.
  final int removed;

  /// Documents whose snapshot was refreshed.
  final int replanned;

  /// Batches committed.
  final int chunks;

  /// The marker after the run (EnsureOccurrences only).
  final DateKey? through;

  bool get isEmpty =>
      created == 0 && restored == 0 && removed == 0 && replanned == 0;

  @override
  bool operator ==(Object other) =>
      other is GenerationOutcome &&
      other.created == created &&
      other.restored == restored &&
      other.removed == removed &&
      other.replanned == replanned &&
      other.chunks == chunks &&
      other.through == through;

  @override
  int get hashCode =>
      Object.hash(created, restored, removed, replanned, chunks, through);

  @override
  String toString() =>
      'GenerationOutcome(created: $created, restored: $restored, '
      'removed: $removed, replanned: $replanned, chunks: $chunks, '
      'through: $through)';
}

/// True when nothing has happened to [occurrence] yet.
///
/// This is the ONLY definition of "unstarted" the replan and regenerate flows
/// use: a tick, a completion, a verification, a skip, a reopen, a comment or an
/// exception all make a document history, and history is never rewritten (road
/// map 3.4).
bool isUnstarted(ChoreOccurrence occurrence) =>
    !occurrence.isDeleted &&
    occurrence.status == OccurrenceStatus.scheduled &&
    occurrence.reopenCount == 0 &&
    occurrence.subtaskDone.isEmpty &&
    occurrence.completedAt == null &&
    occurrence.verifiedAt == null &&
    occurrence.skipReason == null &&
    occurrence.exception == null &&
    occurrence.lastCommentAt == null;

/// [isUnstarted] and on/after [from] (the caller's future boundary).
bool isUnstartedOnOrAfter(ChoreOccurrence occurrence, DateKey from) =>
    !occurrence.dateKey.isBefore(from) && isUnstarted(occurrence);

/// Splits [values] into batches of at most [size] (the last one may be short).
List<List<T>> chunksOf<T>(
  List<T> values, [
  int size = GenerationLimits.chunkWrites,
]) {
  if (size < 1) throw ArgumentError.value(size, 'size', 'must be positive');
  final chunks = <List<T>>[];
  for (var start = 0; start < values.length; start += size) {
    final end = start + size > values.length ? values.length : start + size;
    chunks.add(values.sublist(start, end));
  }
  return chunks;
}
