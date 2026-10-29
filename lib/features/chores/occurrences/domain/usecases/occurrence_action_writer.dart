import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';

/// Turns one [OccurrenceContext] + one action into ONE [OccurrenceWritePlan]
/// and stages it (P3-14).
///
/// The plan always contains, in this order of responsibility:
/// * the draft, when the item was projected (D-P3-6: the first action
///   materializes it in the same batch);
/// * the dotted-key patch (never a whole-document write, so two phones merge);
/// * the lifecycle event the state machine requires, with its OWN unique id
///   (B-05) that the patch records as `lastEventId`;
/// * the inbox row (only when the port builds one);
/// * the audit entry (always).
final class OccurrenceActionWriter {
  const OccurrenceActionWriter(this._occurrences, [this._newId = randomId]);

  final OccurrenceRepository _occurrences;

  /// One id per event, drawn once per [stage] call (once per user intent).
  final IdGenerator _newId;

  /// Builds the plan, so a test can assert it without a repository.
  static OccurrenceWritePlan planFor({
    required OccurrenceContext context,
    required DateTime at,
    required OccurrencePatch? patch,
    NewEvent? event,
    NewInboxItem? inbox,
    RequiredAudit? audit,
    IdGenerator newId = randomId,
  }) {
    // B-05: every event gets a unique id, and the occurrence names it in
    // `lastEventId` so the rules can find it without guessing a path.
    final stamped = event == null || event.id.isNotEmpty
        ? event
        : event.withId(newId());
    final linked = patch != null && stamped != null
        ? patch.withField('lastEventId', stamped.id)
        : patch;
    // B-10: the audit and inbox rows get an id generated ONCE per intent too,
    // so restaging the same plan writes the same path instead of a second row.
    final inboxItem = inbox == null || inbox.id.isNotEmpty
        ? inbox
        : inbox.withId(newId());
    final builtAudit = audit?.build(context, at);
    final auditEntry = builtAudit == null || builtAudit.id.isNotEmpty
        ? builtAudit
        : builtAudit.withId(newId());
    return OccurrenceWritePlan(
      actorId: context.member.uid,
      at: at,
      creates: <OccurrenceDraft>[?context.draft],
      patches: <OccurrencePatch>[?linked],
      events: <NewEvent>[?stamped],
      inbox: <NewInboxItem>[?inboxItem],
      audits: <NewAudit>[?auditEntry],
    );
  }

  Future<Result<void>> stage(
    String familyId,
    OccurrenceContext context, {
    required DateTime at,
    required bool integrity,
    OccurrencePatch? patch,
    NewEvent? event,
    NewInboxItem? inbox,
    RequiredAudit? audit,
  }) {
    final plan = planFor(
      context: context,
      at: at,
      patch: patch,
      event: event,
      inbox: inbox,
      audit: audit,
      newId: _newId,
    );
    return integrity
        ? _occurrences.stageIntegrity(familyId, plan)
        : _occurrences.stage(familyId, plan);
  }
}

/// The audit entry of one action (road map 3.9), built from the context so the
/// chore name, the date and the member are never typed twice.
final class RequiredAudit {
  const RequiredAudit({
    required this.type,
    this.byMemberId,
    this.reason,
    this.extra = const <String, String>{},
  });

  /// A key of `AuditEventType`.
  final String type;

  /// The "done by" of a completion for somebody else (D-P3-14).
  final String? byMemberId;
  final String? reason;
  final Map<String, String> extra;

  NewAudit build(OccurrenceContext context, DateTime at) => NewAudit(
    type: type,
    refId: context.occurrence.id,
    params: <String, String>{
      'name': context.occurrence.nameBn,
      'date': context.occurrence.dateKey.toString(),
      'member': context.member.uid,
      if (context.occurrence.assigneeId != null &&
          context.occurrence.assigneeId != context.member.uid)
        'assignee': context.occurrence.assigneeId!,
      'by': ?byMemberId,
      'reason': ?reason,
      ...extra,
    },
  );
}
