import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/subtask_sync.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-11: the tick rules, and the promise that two phones merge.
void main() {
  final at = DateTime.utc(2026, 10, 24, 6);
  const actor = 'cara';

  final twoRequired = <TemplateSubtask>[
    aSubtask(id: 'step_1', required: true),
    aSubtask(id: 'step_2', required: true),
  ];

  SubtaskDone tick([String by = actor]) => SubtaskDone(at: at, by: by);

  /// Applies a patch the way Firestore does: dotted keys set, removed keys gone.
  Map<String, Object?> merge(
    Map<String, Object?> state,
    OccurrencePatch patch,
  ) {
    final next = Map<String, Object?>.of(state);
    for (final key in patch.removedFields) {
      next.remove(key);
    }
    next.addAll(patch.fields);
    return next;
  }

  group('toggleSubtask', () {
    test('the first tick writes only its own key and in_progress', () {
      final occ = anOccurrence(subtasks: twoRequired);
      final patch = SubtaskSync.toggleSubtask(
        occurrence: occ,
        subtaskId: 'step_1',
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(patch.fields['subtaskDone.step_1'], <String, Object?>{
        'at': at,
        'by': actor,
      });
      expect(patch.fields['status'], OccurrenceStatus.inProgress.id);
      expect(patch.fields['updatedBy'], actor);
      expect(patch.removedFields, isEmpty);
      expect(patch.fields.containsKey('completedAt'), isFalse);
    });

    test('the last required tick completes and stamps the actor', () {
      final occ = anOccurrence(
        subtasks: twoRequired,
        subtaskDone: <String, SubtaskDone>{'step_1': tick()},
      );
      final patch = SubtaskSync.toggleSubtask(
        occurrence: occ,
        subtaskId: 'step_2',
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(patch.fields['status'], OccurrenceStatus.completed.id);
      expect(patch.fields['completedAt'], at);
      expect(patch.fields['completedBy'], actor);
    });

    test('an optional step does not block completion', () {
      final occ = anOccurrence(
        subtasks: <TemplateSubtask>[
          ...twoRequired,
          aSubtask(id: 'extra'),
        ],
        subtaskDone: <String, SubtaskDone>{'step_1': tick()},
      );
      final patch = SubtaskSync.toggleSubtask(
        occurrence: occ,
        subtaskId: 'step_2',
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(patch.fields['status'], OccurrenceStatus.completed.id);
    });

    test('unticking a completed step reopens and clears the completion', () {
      final occ = anOccurrence(
        subtasks: twoRequired,
        subtaskDone: <String, SubtaskDone>{'step_1': tick(), 'step_2': tick()},
        status: OccurrenceStatus.completed,
        completedAt: at,
        completedBy: actor,
      );
      final patch = SubtaskSync.toggleSubtask(
        occurrence: occ,
        subtaskId: 'step_1',
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(patch.removedFields, contains('subtaskDone.step_1'));
      expect(
        patch.removedFields,
        containsAll(<String>['completedAt', 'completedBy']),
      );
      expect(patch.fields['status'], OccurrenceStatus.inProgress.id);
    });

    test('unticking the only tick returns to scheduled', () {
      final occ = anOccurrence(
        subtasks: <TemplateSubtask>[aSubtask(id: 'step_1')],
        subtaskDone: <String, SubtaskDone>{'step_1': tick()},
        completedAt: at,
        completedBy: actor,
      );
      final patch = SubtaskSync.toggleSubtask(
        occurrence: occ,
        subtaskId: 'step_1',
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(patch.fields['status'], OccurrenceStatus.scheduled.id);
      expect(patch.removedFields, contains('completedAt'));
    });

    test('a verified chore is frozen', () {
      final occ = anOccurrence(
        subtasks: twoRequired,
        verifiedAt: at,
        verifiedBy: 'bob',
      );
      expect(
        SubtaskSync.toggleSubtask(
          occurrence: occ,
          subtaskId: 'step_1',
          actorId: actor,
          at: at,
        ).failureOrNull,
        const Conflict(code: 'already_verified'),
      );
    });

    test('a skipped chore cannot be ticked', () {
      final occ = anOccurrence(
        subtasks: twoRequired,
        status: OccurrenceStatus.skipped,
      );
      expect(
        SubtaskSync.toggleSubtask(
          occurrence: occ,
          subtaskId: 'step_1',
          actorId: actor,
          at: at,
        ).failureOrNull,
        const Conflict(code: 'already_skipped'),
      );
    });

    test('a deleted chore cannot be ticked', () {
      final occ = anOccurrence(subtasks: twoRequired, deletedAt: at);
      expect(
        SubtaskSync.toggleSubtask(
          occurrence: occ,
          subtaskId: 'step_1',
          actorId: actor,
          at: at,
        ).failureOrNull,
        const Conflict(code: 'occurrence_deleted'),
      );
    });

    test('an unknown subtask is a concurrent edit', () {
      final occ = anOccurrence(subtasks: twoRequired);
      expect(
        SubtaskSync.toggleSubtask(
          occurrence: occ,
          subtaskId: 'gone',
          actorId: actor,
          at: at,
        ).failureOrNull,
        const Conflict(code: 'concurrent_edit'),
      );
    });
  });

  group('toggleParent', () {
    test('checking ticks every unticked subtask and completes', () {
      // A manager allowed finishing with `step_2` open; one step is already
      // ticked, so the parent box adds only the missing keys.
      final occ = anOccurrence(
        subtasks: <TemplateSubtask>[
          aSubtask(id: 'step_1', required: true),
          aSubtask(id: 'step_2', required: true),
          aSubtask(id: 'extra'),
        ],
        subtaskDone: <String, SubtaskDone>{'step_1': tick()},
        exception: CompletionException(note: 'clean', by: 'bob', at: at),
      );
      final patch = SubtaskSync.toggleParent(
        occurrence: occ,
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(patch.fields['subtaskDone.step_2'], isNotNull);
      expect(patch.fields['subtaskDone.extra'], isNotNull);
      expect(patch.fields.containsKey('subtaskDone.step_1'), isFalse);
      expect(patch.fields['status'], OccurrenceStatus.completed.id);
      expect(patch.fields['completedBy'], actor);
    });

    test('checking with an open required step is refused', () {
      final occ = anOccurrence(subtasks: twoRequired);
      expect(
        SubtaskSync.toggleParent(
          occurrence: occ,
          actorId: actor,
          at: at,
        ).failureOrNull,
        const Conflict(code: 'required_subtasks_open'),
      );
    });

    test('a recorded exception allows completion', () {
      final occ = anOccurrence(
        subtasks: twoRequired,
        exception: CompletionException(note: 'clean', by: 'bob', at: at),
      );
      final patch = SubtaskSync.toggleParent(
        occurrence: occ,
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(patch.fields['status'], OccurrenceStatus.completed.id);
      expect(patch.fields['subtaskDone.step_1'], isNotNull);
      expect(patch.fields['subtaskDone.step_2'], isNotNull);
    });

    test('unchecking unticks everything and returns to scheduled', () {
      final occ = anOccurrence(
        subtasks: twoRequired,
        subtaskDone: <String, SubtaskDone>{'step_1': tick(), 'step_2': tick()},
        status: OccurrenceStatus.completed,
        completedAt: at,
        completedBy: actor,
      );
      final patch = SubtaskSync.toggleParent(
        occurrence: occ,
        actorId: actor,
        at: at,
      ).valueOrNull!;

      expect(
        patch.removedFields,
        containsAll(<String>[
          'subtaskDone.step_1',
          'subtaskDone.step_2',
          'completedAt',
          'completedBy',
        ]),
      );
      expect(patch.fields['status'], OccurrenceStatus.scheduled.id);
    });

    test('a chore without subtasks uses the parent box alone', () {
      final occ = anOccurrence();
      final checked = SubtaskSync.toggleParent(
        occurrence: occ,
        actorId: actor,
        at: at,
      ).valueOrNull!;
      expect(checked.fields['status'], OccurrenceStatus.completed.id);

      final completed = occ.copyWith(
        status: OccurrenceStatus.completed,
        completedAt: at,
        completedBy: actor,
      );
      final unchecked = SubtaskSync.toggleParent(
        occurrence: completed,
        actorId: actor,
        at: at,
      ).valueOrNull!;
      expect(unchecked.fields['status'], OccurrenceStatus.scheduled.id);
      expect(unchecked.removedFields, contains('completedAt'));
    });
  });

  test('two phones ticking different boxes merge to the same document', () {
    final occ = anOccurrence(subtasks: twoRequired);
    final fromA = SubtaskSync.toggleSubtask(
      occurrence: occ,
      subtaskId: 'step_1',
      actorId: 'cara',
      at: at,
    ).valueOrNull!;
    final fromB = SubtaskSync.toggleSubtask(
      occurrence: occ,
      subtaskId: 'step_2',
      actorId: 'dave',
      at: at,
    ).valueOrNull!;

    final stateA = merge(merge(<String, Object?>{}, fromA), fromB);
    final stateB = merge(merge(<String, Object?>{}, fromB), fromA);

    Map<String, Object?> ticks(Map<String, Object?> state) => <String, Object?>{
      for (final entry in state.entries)
        if (entry.key.startsWith('subtaskDone.')) entry.key: entry.value,
    };

    // `updatedBy` is per-action bookkeeping (last writer wins); the TICKS are
    // what must merge, whatever order the two phones sync in.
    expect(ticks(stateA), ticks(stateB));
    expect(
      ticks(stateA).keys,
      containsAll(<String>['subtaskDone.step_1', 'subtaskDone.step_2']),
    );

    // Each phone saw only its own tick, so both cached `in_progress`; the
    // DERIVED status is completed and the detail screen repairs the cache.
    expect(stateA['status'], OccurrenceStatus.inProgress.id);
    final merged = occ.copyWith(
      subtaskDone: <String, SubtaskDone>{
        'step_1': tick(),
        'step_2': tick('dave'),
      },
    );
    expect(effectiveStatus(merged), ChoreStatus.completed);
  });
}
