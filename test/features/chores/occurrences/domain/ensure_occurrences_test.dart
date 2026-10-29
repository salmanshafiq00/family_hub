import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/ensure_occurrences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-12 / Appendix F.3 4-7: the horizon, idempotence, the two-device race and
/// the 400-draft chunking.
void main() {
  late ChoresFixture fixture;
  late EnsureOccurrences ensure;

  const familyId = ChoresFixture.familyId;

  setUp(() {
    fixture = ChoresFixture();
    fixture.settings.settings = const ChoreSettings(generationHorizonDays: 30);
    ensure = EnsureOccurrences(
      occurrences: fixture.occurrences,
      markers: fixture.occurrences,
      templates: fixture.chores,
      dutyGroups: fixture.chores.dutyGroups,
      settings: fixture.settings,
      families: fixture.families,
      dateKeys: fixture.dateKeys,
      clock: fixture.clock,
    );
  });

  void seedTemplate({String id = 'tpl_1', TemplateDraft? draft}) {
    (fixture.chores.templates[familyId] ??= <String, ChoreTemplate>{})[id] =
        ChoreTemplate(id: id, draft: draft ?? aTemplate());
  }

  test('F.3 4: an absent marker generates today..today + horizon', () async {
    seedTemplate();
    final result = await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );

    final outcome = result.valueOrNull!;
    expect(outcome.created, 31);
    expect(outcome.through, DateKey(2026, 11, 24));
    expect(fixture.occurrences.markers[familyId], DateKey(2026, 11, 24));

    final docs = fixture.occurrences.occurrences[familyId]!;
    expect(docs, hasLength(31));
    expect(docs.keys.first, 'tpl_1_20261025');
    expect(docs.keys.last, 'tpl_1_20261124');
  });

  test('F.3 5: a second run is a no-op', () async {
    seedTemplate();
    await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );
    final plans = fixture.occurrences.plans.length;
    final writes = fixture.occurrences.integrityWrites;

    final second = await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );

    expect(second.valueOrNull!.isEmpty, isTrue);
    expect(second.valueOrNull!.through, DateKey(2026, 11, 24));
    expect(fixture.occurrences.plans, hasLength(plans));
    expect(fixture.occurrences.integrityWrites, writes);
    expect(fixture.occurrences.occurrences[familyId], hasLength(31));
  });

  test(
    'F.3 6: a racing device retries once and creates no duplicate',
    () async {
      seedTemplate();
      await ensure(
        familyId: familyId,
        actorUid: 'cara',
        today: DateKey(2026, 10, 25),
      );
      // The second device read the old marker and the empty range before the
      // first device's batch landed; its create then loses the conflict.
      fixture.occurrences.markers.remove(familyId);
      fixture.occurrences.hideExistingIdsOnce = true;

      final second = await ensure(
        familyId: familyId,
        actorUid: 'bob',
        today: DateKey(2026, 10, 25),
      );

      expect(second.valueOrNull!.created, 0);
      expect(fixture.occurrences.conflicts, 1);
      final docs = fixture.occurrences.occurrences[familyId]!;
      expect(docs, hasLength(31));
      expect(docs.keys.toSet(), hasLength(31));
      expect(fixture.occurrences.markers[familyId], DateKey(2026, 11, 24));
    },
  );

  test(
    'B-07: a create denied because the id exists retries once and succeeds',
    () async {
      seedTemplate();
      // The RULES see a create on an existing id as an update and deny it with
      // `permission-denied`; the run must retry exactly like a Conflict.
      fixture.occurrences.createsDeniedAsPermission = true;
      // This device read the ids before the other one's batch landed.
      fixture.occurrences.hideExistingIdsOnce = true;
      var seeded = false;
      fixture.occurrences.beforeStage = (familyId, plan) {
        if (seeded) return;
        seeded = true;
        final docs = fixture.occurrences.occurrences[familyId] ??=
            <String, ChoreOccurrence>{};
        for (final draft in plan.creates.take(10)) {
          docs[draft.id] = draft.toOccurrence();
        }
      };

      final result = await ensure(
        familyId: familyId,
        actorUid: 'cara',
        today: DateKey(2026, 10, 25),
      );

      expect(result.failureOrNull, isNull);
      expect(result.valueOrNull!.created, 21);
      expect(fixture.occurrences.conflicts, 1);
      expect(fixture.occurrences.stageAttempts, 2);
      expect(fixture.occurrences.occurrences[familyId], hasLength(31));
      expect(fixture.occurrences.markers[familyId], DateKey(2026, 11, 24));
    },
  );

  test('B-07: a second denied chunk ends with concurrent_edit', () async {
    seedTemplate();
    var attempts = 0;
    fixture.occurrences.beforeStage = (_, _) {
      if (attempts++ < 2) {
        fixture.occurrences.nextStageFailure = const PermissionDenied();
      }
    };

    final result = await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );

    expect(result.failureOrNull, const Conflict(code: 'concurrent_edit'));
    expect(fixture.occurrences.markers, isEmpty);
  });

  test(
    'F.3 7: 20 templates x 30 days fit in at most 3 chunks of 400',
    () async {
      fixture.settings.settings = const ChoreSettings(
        generationHorizonDays: 29,
      );
      for (var i = 1; i <= 20; i++) {
        seedTemplate(id: 'tpl_$i');
      }

      final result = await ensure(
        familyId: familyId,
        actorUid: 'cara',
        today: DateKey(2026, 10, 25),
      );

      expect(result.valueOrNull!.created, 600);
      expect(fixture.occurrences.plans.length, lessThanOrEqualTo(3));
      for (final plan in fixture.occurrences.plans) {
        expect(plan.creates.length, lessThanOrEqualTo(400));
        expect(
          plan.creates.length + plan.audits.length,
          lessThanOrEqualTo(401),
        );
      }
      expect(fixture.occurrences.occurrences[familyId], hasLength(600));
    },
  );

  test('a plain member may run it; a pending member may not', () async {
    seedTemplate();

    final pending = await ensure(
      familyId: familyId,
      actorUid: 'erin',
      today: DateKey(2026, 10, 25),
    );
    expect(pending.failureOrNull, const PermissionDenied());
    expect(fixture.occurrences.plans, isEmpty);

    final member = await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );
    expect(member.isSuccess, isTrue);
    expect(fixture.occurrences.integrityWrites, 1);
    expect(fixture.occurrences.writes, 0);
  });

  test('with no generating template the marker still advances', () async {
    seedTemplate(draft: aTemplate());
    fixture.chores.templates[familyId]!['tpl_1'] = ChoreTemplate(
      id: 'tpl_1',
      draft: aTemplate(),
      active: false,
    );

    final result = await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );

    expect(result.valueOrNull!.created, 0);
    expect(result.valueOrNull!.through, DateKey(2026, 11, 24));
    expect(fixture.occurrences.markers[familyId], DateKey(2026, 11, 24));
    expect(fixture.occurrences.plans, isEmpty);
  });

  test('each chunk writes one audit with from/to/count', () async {
    seedTemplate();
    await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );

    final audit = fixture.occurrences.audits.single;
    expect(audit.type, AuditEventType.choresOccurrencesGenerated);
    expect(audit.refType, AuditRefType.choreSettings);
    expect(audit.refId, familyId);
    expect(audit.params['from'], '2026-10-25');
    expect(audit.params['to'], '2026-11-24');
    expect(audit.params['count'], '31');
  });

  test('a second conflict ends with concurrent_edit', () async {
    seedTemplate();
    fixture.occurrences.beforeStage = (_, _) {
      fixture.occurrences.nextStageFailure = const Conflict();
    };

    final result = await ensure(
      familyId: familyId,
      actorUid: 'cara',
      today: DateKey(2026, 10, 25),
    );

    expect(result.failureOrNull, const Conflict(code: 'concurrent_edit'));
    expect(fixture.occurrences.markers, isEmpty);
  });

  test(
    'a marker failure leaves the occurrences and resumes on the next run',
    () async {
      seedTemplate();
      fixture.occurrences.nextMarkerFailure = const Network();

      final first = await ensure(
        familyId: familyId,
        actorUid: 'cara',
        today: DateKey(2026, 10, 25),
      );
      expect(first.failureOrNull, const Network());
      expect(fixture.occurrences.occurrences[familyId], hasLength(31));
      expect(fixture.occurrences.markers, isEmpty);

      final second = await ensure(
        familyId: familyId,
        actorUid: 'cara',
        today: DateKey(2026, 10, 25),
      );
      expect(second.valueOrNull!.created, 0);
      expect(second.valueOrNull!.through, DateKey(2026, 11, 24));
      expect(fixture.occurrences.markers[familyId], DateKey(2026, 11, 24));
    },
  );
}
