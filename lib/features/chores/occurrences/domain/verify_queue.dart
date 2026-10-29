                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// Who may verify, and what belongs in the queue (B-03).
///
/// The stored `status` is a cache (CLAUDE.md rule 36), so the queue is decided
/// by the EFFECTIVE status: a document whose ticks were removed but whose cache
/// still says `completed` is not waiting for a check.  The filter lives here, in
/// one pure function, so the provider, the hub badge and the tests can never
/// disagree about the list.
abstract final class VerifyQueue {
  /// True when [occurrence] is a completion that still needs somebody to look
  /// at it: the snapshot asks for a check, the derived status is `completed`,
  /// nobody verified it yet, and [uid] did not complete it (nobody verifies
  /// their own work).
  static bool needsVerification(ChoreOccurrence occurrence, String? uid) =>
      !occurrence.isDeleted &&
      occurrence.verification == VerificationMode.required &&
      occurrence.verifiedAt == null &&
      effectiveStatus(occurrence) == ChoreStatus.completed &&
      (uid == null || occurrence.completedBy != uid);

  /// The queue, oldest deadline first.
  static List<ChoreOccurrence> filter(
    Iterable<ChoreOccurrence> candidates,
    String? uid,
  ) => <ChoreOccurrence>[
    for (final occurrence in candidates)
      if (needsVerification(occurrence, uid)) occurrence,
  ]..sort((a, b) => a.dueAt.compareTo(b.dueAt));

  /// Whether the chore needs a check at all, whoever completed it (the hub
  /// tile's gate: it asks about the FAMILY, not about one completion).
  static bool requiresCheck(ChoreOccurrence occurrence) =>
      !occurrence.isDeleted &&
      occurrence.verification == VerificationMode.required;
}
