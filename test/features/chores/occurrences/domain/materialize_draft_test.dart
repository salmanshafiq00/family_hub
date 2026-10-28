import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/materialize_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-12 / Appendix F.3 18: the first action on a projected day creates the
/// occurrence and applies the action in ONE batch.
void main() {
  test('a draft becomes a one-create everyday plan', () {
    final fixture = ChoresFixture();
    final draft = anOccurrenceDraft();

    final plan = MaterializeDraft(clock: fixture.clock)(
      actorId: 'cara',
      draft: draft,
    );

    expect(plan.creates, <Object>[draft]);
    expect(plan.actorId, 'cara');
    expect(plan.at, fixture.clock.nowUtc());
    expect(plan.isEmpty, isFalse);
    expect(plan.patches, isEmpty);
  });

  test('the create and the first action are merged into one plan', () {
    final fixture = ChoresFixture();
    final draft = anOccurrenceDraft();
    final action = OccurrenceWritePlan(
      actorId: 'cara',
      at: DateTime.utc(2026, 10, 24, 10),
      patches: <OccurrencePatch>[
        OccurrencePatch(
          occurrenceId: draft.id,
          fields: <String, Object?>{'status': 'completed'},
        ),
      ],
      audits: <NewAudit>[
        NewAudit(
          type: AuditEventType.choresOccurrenceCompleted,
          refId: draft.id,
        ),
      ],
    );

    final plan = MaterializeDraft(clock: fixture.clock)(
      actorId: 'cara',
      draft: draft,
      action: action,
    );

    expect(plan.creates, <Object>[draft]);
    expect(plan.patches, action.patches);
    expect(plan.audits, action.audits);
    expect(plan.at, action.at);
  });
}
