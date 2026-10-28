import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// Builds the write that materializes a projected item (P3-12, D-P3-6).
///
/// A projected item is not a document yet. The FIRST action on it (complete,
/// comment, swap) must create the occurrence and apply the action in ONE batch,
/// so the calendar never shows a half-done item and an offline phone never
/// queues two independent writes that could land out of order.
///
/// EVERYDAY write: it queues offline like the action it carries.
class MaterializeDraft {
  const MaterializeDraft({required this._clock});

  final Clock _clock;

  /// A plan with [draft] as its create, merged with [action] when given.
  OccurrenceWritePlan call({
    required String actorId,
    required OccurrenceDraft draft,
    OccurrenceWritePlan? action,
  }) {
    assert(
      action == null || action.actorId == actorId,
      'the action and the materialization must have the same actor',
    );
    return OccurrenceWritePlan(
      actorId: actorId,
      at: action?.at ?? _clock.nowUtc(),
      creates: <OccurrenceDraft>[draft, ...?action?.creates],
      restores: action?.restores ?? const <OccurrenceDraft>[],
      replans: action?.replans ?? const <OccurrenceReplan>[],
      patches: action?.patches ?? const <OccurrencePatch>[],
      events: action?.events ?? const <NewEvent>[],
      inbox: action?.inbox ?? const <NewInboxItem>[],
      audits: action?.audits ?? const <NewAudit>[],
    );
  }
}
