import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/member_availability.dart';
import 'package:family_hub/features/chores/availability/domain/usecases/auto_share_absent_chores.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../occurrences/domain/usecases/completion_test_support.dart';

/// FIX-3: a bulk move sends ONE summary row per recipient, never one per chore.
///
/// The fixture family is `alice` (admin), `bob`, `cara`, `dave`; "today" is
/// Saturday 2026-10-24. A test that needs a single available member replaces
/// the roster with `alice` + `cara`.
void main() {
  const familyId = ChoresFixture.familyId;
  late ChoresFixture fixture;
  late CompletionUseCases useCases;
  late AutoShareAbsentChores share;

  setUp(() {
    fixture = ChoresFixture();
    useCases = CompletionUseCases(fixture);
    share = AutoShareAbsentChores(
      families: fixture.families,
      choreSettings: fixture.settings,
      availability: fixture.availability,
      occurrences: fixture.occurrences,
      templates: fixture.chores,
      dutyGroups: fixture.chores.dutyGroups,
      reassign: useCases.reassign,
      dateKeys: fixture.dateKeys,
      inbox: useCases.inbox,
      clock: fixture.clock,
    );
  });

  /// Six unstarted chores of `cara`, one per day from the 24th.
  void sixChores() {
    for (var day = 24; day <= 29; day++) {
      seedOccurrence(
        fixture,
        anOccurrence(
          id: 'tpl_1_202610$day',
          templateId: 'tpl_1',
          dateKey: DateKey(2026, 10, day),
        ),
      );
    }
  }

  void onlyAliceAvailable() {
    fixture.backend.members[familyId] = <String, Member>{
      'alice': fixture.backend.members[familyId]!['alice']!,
      'cara': fixture.backend.members[familyId]!['cara']!,
    };
  }

  void seedAbsence({int from = 24, int to = 29}) {
    fixture.swapWorld.absences['a1'] = MemberAvailability(
      id: 'a1',
      memberId: 'cara',
      startDate: DateKey(2026, 10, from),
      endDate: DateKey(2026, 10, to),
      typeId: ChoreSettings.defaults.absenceReasons.first.id,
      reason: 'Fever',
      status: AvailabilityStatus.active,
      createdBy: 'cara',
    );
  }

  test(
    'six chores of an absent member send ONE summary row, not six',
    () async {
      onlyAliceAvailable();
      sixChores();
      seedAbsence();

      final result = await share(
        familyId: familyId,
        actorUid: 'alice',
        force: true,
      );

      expect(result.valueOrNull, 6);
      expect(useCases.inbox.sent, <String>[
        'chore_assigned_summary -> alice x6',
      ]);

      final summary = fixture.occurrences.plans.last.inbox.single;
      expect(summary.type, 'chore_assigned');
      expect(summary.toMemberId, 'alice');
      expect(summary.id, 'ib_as_tpl_1_20261024');
      expect(summary.refId, 'as_tpl_1_20261024');
      expect(summary.params['kind'], 'summary');
      expect(summary.params['count'], '6');
      expect(summary.params['from'], '2026-10-24');
      expect(summary.params['to'], '2026-10-29');
    },
  );

  test('a second run moves nothing and writes no new row', () async {
    onlyAliceAvailable();
    sixChores();
    seedAbsence();
    await share(familyId: familyId, actorUid: 'alice', force: true);
    final rowsAfterFirst = useCases.inbox.sent.length;
    final plansAfterFirst = fixture.occurrences.plans.length;

    final again = await share(
      familyId: familyId,
      actorUid: 'alice',
      force: true,
    );

    expect(again.valueOrNull, 0);
    expect(useCases.inbox.sent.length, rowsAfterFirst);
    expect(fixture.occurrences.plans.length, plansAfterFirst);
  });

  test('two recipients get one summary row each', () async {
    sixChores();
    seedAbsence();

    final result = await share(
      familyId: familyId,
      actorUid: 'alice',
      force: true,
    );

    expect(result.valueOrNull, 6);
    final rows = useCases.inbox.sent;
    expect(rows, hasLength(2));
    expect(rows.every((row) => row.contains('x3')), isTrue);
    final recipients = fixture.occurrences.plans
        .expand((plan) => plan.inbox)
        .map((row) => row.toMemberId)
        .toSet();
    expect(recipients, hasLength(2));
  });

  test('a chore moved to the actor writes no row', () async {
    onlyAliceAvailable();
    sixChores();
    seedAbsence();

    final result = await share(
      familyId: familyId,
      actorUid: 'alice',
      force: true,
    );

    expect(result.valueOrNull, 6);
    expect(useCases.inbox.sent, isEmpty);
    expect(fixture.occurrences.plans.expand((plan) => plan.inbox), isEmpty);
  });
}
