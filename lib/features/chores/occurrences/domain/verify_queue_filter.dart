import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// The occurrences that really wait for a check (B-03).
///
/// A chore belongs in the verification queue only when ALL of these hold:
/// * its snapshot says `verification == required`;
/// * its DERIVED status is `completed` (CLAUDE rule 36: never the stored
///   `status` cache, which can be stale);
/// * nobody has verified it yet;
/// * the viewer did not complete it (nobody verifies their own work).
///
/// Pure, so the rule is unit-tested without Riverpod.
List<ChoreOccurrence> verifiableOccurrences(
  Iterable<ChoreOccurrence> documents, {
  required String? viewerUid,
}) => <ChoreOccurrence>[
  for (final occurrence in documents)
    if (occurrence.verification == VerificationMode.required &&
        occurrence.verifiedAt == null &&
        effectiveStatus(occurrence) == ChoreStatus.completed &&
        occurrence.completedBy != viewerUid)
      occurrence,
];
