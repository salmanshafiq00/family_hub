import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/regenerate_range.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-12 / Appendix F.3 8 and 10: regenerate creates, removes and restores
/// without ever rewriting history.
void main() {
  late ChoresFixture fixture;
  late RegenerateRange regenerate;

  const familyId = ChoresFixture.familyId;
  final at = DateTime.utc(2026, 10, 24, 9);

  setUp(() {
    fixture = ChoresFixture();
    regenerate = RegenerateRange(
      occurrences: fixture.occurrences,
      templates: fixture.chores,
      dutyGroups: fixture.chores.dutyGroups,
      settings: fixture.settings,
      families: fixture.families,
      dateKeys: fixture.dateKeys,
      clock: fixture.clock,
    );
  });

  void seedTemplate({
    Recurrence recurrence = const DailyRecurrence(),
    bool active = true,
    String id = 'tpl_1',
  }) {
    (fixture.chores.templates[familyId] ??=
        <String, ChoreTemplate>{})[id] = ChoreTemplate(
      id: id,
      active: active,
      draft: aTemplate(recurrence: recurrence, startDate: DateKey(2026, 10, 1)),
    );
  }

  void seed(ChoreOccurrence occurrence) {
    (fixture.occurrences.occurrences[familyId] ??=
            <String, ChoreOccurrence>{})[occurrence.id] =
        occurrence;
  }

  test('F.3 8: future only deletes the days that no longer match', () async {
    seedTemplate(
      recurrence: const WeekdaysRecurrence(weekdays: <int>[DateTime.saturday]),
    );
    for (final day in <int>[24, 25, 26, 27]) {
      seed(
        anOccurrence(id: 'tpl_1_202610$day', dateKey: DateKey(2026, 10, day)),
      );
    }

    final result = await regenerate(
      familyId: familyId,
      actorUid: 'bob',
      from: DateKey(2026, 10, 25),
      to: DateKey(2026, 10, 31),
    );

    final outcome = result.valueOrNull!;
    expect(outcome.created, 1);
    expect(outcome.removed, 3);
    final docs = fixture.occurrences.occurrences[familyId]!;
    expect(docs['tpl_1_20261024']!.isDeleted, isFalse);
    expect(docs['tpl_1_20261025']!.isDeleted, isTrue);
    expect(docs['tpl_1_20261026']!.isDeleted, isTrue);
    expect(docs['tpl_1_20261027']!.isDeleted, isTrue);
    expect(docs['tpl_1_20261031'], isNotNull);
  });

  test('a completed or started document is never deleted', () async {
    seedTemplate(
      recurrence: const WeekdaysRecurrence(weekdays: <int>[DateTime.saturday]),
    );
    seed(
      anOccurrence(
        id: 'tpl_1_20261025',
        dateKey: DateKey(2026, 10, 25),
        status: OccurrenceStatus.completed,
        completedAt: at,
        completedBy: 'cara',
      ),
    );
    seed(
      anOccurrence(
        id: 'tpl_1_20261026',
        dateKey: DateKey(2026, 10, 26),
        subtaskDone: <String, SubtaskDone>{
          'step_1': SubtaskDone(at: at, by: 'cara'),
        },
      ),
    );
    seed(
      anOccurrence(
        id: 'tpl_1_20261027',
        dateKey: DateKey(2026, 10, 27),
        status: OccurrenceStatus.skipped,
        skipReason: SkipReason.manager,
      ),
    );
    seed(
      anOccurrence(
        id: 'tpl_1_20261028',
        dateKey: DateKey(2026, 10, 28),
        lastCommentAt: at,
      ),
    );
    seed(
      anOccurrence(
        id: 'tpl_1_20261029',
        dateKey: DateKey(2026, 10, 29),
        exception: CompletionException(note: 'done early', by: 'bob', at: at),
      ),
    );
    seed(
      anOccurrence(
        id: 'tpl_1_20261030',
        dateKey: DateKey(2026, 10, 30),
        reopenCount: 1,
      ),
    );

    final result = await regenerate(
      familyId: familyId,
      actorUid: 'bob',
      from: DateKey(2026, 10, 25),
      to: DateKey(2026, 10, 31),
    );

    expect(result.valueOrNull!.removed, 0);
    final docs = fixture.occurrences.occurrences[familyId]!;
    for (final id in <String>[
      'tpl_1_20261025',
      'tpl_1_20261026',
      'tpl_1_20261027',
      'tpl_1_20261028',
      'tpl_1_20261029',
      'tpl_1_20261030',
    ]) {
      expect(docs[id]!.isDeleted, isFalse, reason: id);
    }
  });

  test(
    'F.3 10: pause removes unstarted future days, resume restores them',
    () async {
      seedTemplate();
      for (final day in <int>[25, 26, 27]) {
        seed(
          anOccurrence(
            id: 'tpl_1_202610$day',
            dateKey: DateKey(2026, 10, day),
            status: day == 26
                ? OccurrenceStatus.completed
                : OccurrenceStatus.scheduled,
            completedAt: day == 26 ? at : null,
            completedBy: day == 26 ? 'cara' : null,
          ),
        );
      }

      fixture.chores.templates[familyId]!['tpl_1'] = ChoreTemplate(
        id: 'tpl_1',
        active: false,
        draft: aTemplate(startDate: DateKey(2026, 10, 1)),
      );
      final paused = await regenerate(
        familyId: familyId,
        actorUid: 'bob',
        from: DateKey(2026, 10, 25),
        to: DateKey(2026, 10, 27),
      );
      expect(paused.valueOrNull!.removed, 2);
      final docs = fixture.occurrences.occurrences[familyId]!;
      expect(docs['tpl_1_20261025']!.isDeleted, isTrue);
      expect(docs['tpl_1_20261026']!.isDeleted, isFalse);
      expect(docs['tpl_1_20261027']!.isDeleted, isTrue);

      fixture.chores.templates[familyId]!['tpl_1'] = ChoreTemplate(
        id: 'tpl_1',
        draft: aTemplate(startDate: DateKey(2026, 10, 1)),
      );
      final resumed = await regenerate(
        familyId: familyId,
        actorUid: 'bob',
        from: DateKey(2026, 10, 25),
        to: DateKey(2026, 10, 27),
      );

      expect(resumed.valueOrNull!.restored, 2);
      expect(resumed.valueOrNull!.created, 0);
      expect(docs['tpl_1_20261025']!.isDeleted, isFalse);
      expect(docs['tpl_1_20261027']!.isDeleted, isFalse);
    },
  );

  test('only the named template is regenerated', () async {
    seedTemplate();
    seedTemplate(id: 'tpl_2');
    seed(
      anOccurrence(
        id: 'tpl_2_20261025',
        templateId: 'tpl_2',
        dateKey: DateKey(2026, 10, 25),
      ),
    );

    final result = await regenerate(
      familyId: familyId,
      actorUid: 'bob',
      templateId: 'tpl_1',
      from: DateKey(2026, 10, 25),
      to: DateKey(2026, 10, 26),
    );

    expect(result.valueOrNull!.created, 2);
    final docs = fixture.occurrences.occurrences[familyId]!;
    expect(docs['tpl_2_20261025']!.isDeleted, isFalse);
    expect(docs.containsKey('tpl_2_20261026'), isFalse);
  });

  test('a plain member is denied and nothing is written', () async {
    seedTemplate();
    final result = await regenerate(
      familyId: familyId,
      actorUid: 'cara',
      from: DateKey(2026, 10, 25),
      to: DateKey(2026, 10, 26),
    );

    expect(result.failureOrNull, const PermissionDenied());
    expect(fixture.occurrences.plans, isEmpty);
  });

  test('an unknown template and an inverted range are rejected', () async {
    seedTemplate();
    final missing = await regenerate(
      familyId: familyId,
      actorUid: 'bob',
      templateId: 'missing',
      from: DateKey(2026, 10, 25),
      to: DateKey(2026, 10, 26),
    );
    expect(missing.failureOrNull, const NotFound(entity: 'template'));

    final inverted = await regenerate(
      familyId: familyId,
      actorUid: 'bob',
      from: DateKey(2026, 10, 27),
      to: DateKey(2026, 10, 26),
    );
    expect(inverted.failureOrNull, const Validation('range', 'invalid_range'));
  });
}
