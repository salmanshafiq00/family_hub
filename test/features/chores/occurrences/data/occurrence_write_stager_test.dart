import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/firebase/fake_tx_runner.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/permissions/permission_settings.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_write_stager.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action_writer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// B-10: the audit and inbox ids are the intent's, generated once, not the
/// identity hash of a fresh object.
void main() {
  const familyId = ChoresFixture.familyId;
  final at = DateTime.utc(2026, 10, 24, 3, 30);

  OccurrenceWritePlan planWith({
    required String auditId,
    required String inboxId,
  }) => OccurrenceWritePlan(
    actorId: 'cara',
    at: at,
    audits: <NewAudit>[
      NewAudit(
        id: auditId,
        type: AuditEventType.choresOccurrenceCompleted,
        refId: 'tpl_1_20261024',
      ),
    ],
    inbox: <NewInboxItem>[
      NewInboxItem(
        id: inboxId,
        toMemberId: 'bob',
        type: 'verification_needed',
        refType: 'occurrence',
        refId: 'tpl_1_20261024',
      ),
    ],
  );

  test('B-10: the same intent staged twice writes one audit and one row', () async {
    final tx = FakeTxRunner();
    Future<void> stage() => tx.runBatch(
      (batch) => OccurrenceWriteStager.stage(
        batch,
        familyId,
        planWith(auditId: 'intent_1', inboxId: 'intent_2'),
      ),
    );

    await stage();
    await stage();

    final activities = tx.store.keys
        .where(
          (path) => path.startsWith('${FirestorePaths.activity(familyId)}/'),
        )
        .toList();
    final auditLogs = tx.store.keys
        .where(
          (path) => path.startsWith('${FirestorePaths.auditLogs(familyId)}/'),
        )
        .toList();
    final inbox = tx.store.keys
        .where(
          (path) =>
              path.startsWith('${FirestorePaths.notificationInbox(familyId)}/'),
        )
        .toList();

    expect(activities, <String>[
      FirestorePaths.activityDoc(familyId, 'aud_intent_1'),
    ]);
    expect(auditLogs, <String>[
      FirestorePaths.auditLogDoc(familyId, 'aud_intent_1'),
    ]);
    expect(inbox, <String>[FirestorePaths.inboxDoc(familyId, 'inb_intent_2')]);
  });

  test('B-10: planFor gives each audit and inbox row its own intent id', () {
    final context = OccurrenceContext.build(
      occurrence: anOccurrence(assigneeId: 'cara'),
      member: aMember(),
      settings: PermissionSettings.defaults,
    );
    var next = 0;
    String newId() => 'id_${++next}';

    final plan = OccurrenceActionWriter.planFor(
      context: context,
      at: at,
      patch: null,
      event: NewEvent(
        occurrenceId: context.occurrence.id,
        type: OccurrenceEventType.completed,
      ),
      inbox: NewInboxItem(
        toMemberId: 'bob',
        type: 'verification_needed',
        refType: 'occurrence',
        refId: context.occurrence.id,
      ),
      audit: const RequiredAudit(type: AuditEventType.choresOccurrenceCompleted),
      newId: newId,
    );

    final event = plan.events.single;
    final inboxItem = plan.inbox.single;
    final audit = plan.audits.single;
    expect(event.id, isNotEmpty);
    expect(inboxItem.id, isNotEmpty);
    expect(audit.id, isNotEmpty);
    expect(<String>{event.id, inboxItem.id, audit.id}, hasLength(3));
  });
}
