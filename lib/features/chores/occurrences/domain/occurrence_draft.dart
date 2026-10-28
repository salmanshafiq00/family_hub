import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// One occurrence the generator WOULD write (P3-12, D-P3-6).
///
/// A draft carries exactly the document a create writes: the same snapshot, the
/// same deterministic id and planned owner, `status = scheduled` and no ticks.
/// It is stored as a [ChoreOccurrence] on purpose: a projected item and the
/// materialized one are then the SAME value, which is C-9 ("a projected month
/// and a generated month must look identical").
final class OccurrenceDraft {
  OccurrenceDraft(this.occurrence)
    : assert(
        occurrence.status == OccurrenceStatus.scheduled,
        'a draft is always scheduled',
      ),
      assert(occurrence.subtaskDone.isEmpty, 'a draft has no ticks'),
      assert(occurrence.deletedAt == null, 'a draft is not deleted');

  /// The document a create writes.
  final ChoreOccurrence occurrence;

  String get id => occurrence.id;
  String get templateId => occurrence.templateId;
  DateKey get dateKey => occurrence.dateKey;
  String? get slotKey => occurrence.slotKey;
  String? get assigneeId => occurrence.assigneeId;
  String? get plannedAssigneeId => occurrence.plannedAssigneeId;
  AssignmentSource get assignmentSource => occurrence.assignmentSource;
  bool get needsCover => occurrence.needsCover;

  /// The occurrence this draft becomes once it is written.
  ChoreOccurrence toOccurrence() => occurrence;

  @override
  bool operator ==(Object other) =>
      other is OccurrenceDraft && other.occurrence == occurrence;

  @override
  int get hashCode => occurrence.hashCode;

  @override
  String toString() => 'OccurrenceDraft($id, $dateKey)';
}
