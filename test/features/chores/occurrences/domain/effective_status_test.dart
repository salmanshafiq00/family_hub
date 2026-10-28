import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-11 / D-P3-9: the stored status is a cache; these are the only rules that
/// decide what a screen shows.
void main() {
  final at = DateTime.utc(2026, 10, 24, 6);
  SubtaskDone tick() => SubtaskDone(at: at, by: 'cara');

  final required = <TemplateSubtask>[
    aSubtask(id: 'step_1', required: true),
    aSubtask(id: 'step_2', required: true),
  ];
  final optionalOnly = <TemplateSubtask>[
    aSubtask(id: 'step_1'),
    aSubtask(id: 'step_2'),
  ];

  test('a stored skip wins over everything', () {
    expect(
      effectiveStatus(
        anOccurrence(status: OccurrenceStatus.skipped, completedAt: at),
      ),
      ChoreStatus.skipped,
    );
    expect(
      effectiveStatus(
        anOccurrence(skipReason: SkipReason.absence, completedAt: at),
      ),
      ChoreStatus.skipped,
    );
  });

  test('a verification timestamp wins over completion', () {
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: required,
          subtaskDone: <String, SubtaskDone>{
            'step_1': tick(),
            'step_2': tick(),
          },
          completedAt: at,
          verifiedAt: at,
          verifiedBy: 'bob',
        ),
      ),
      ChoreStatus.verified,
    );
  });

  test('a chore without subtasks is completed by completedAt', () {
    expect(effectiveStatus(anOccurrence()), ChoreStatus.scheduled);
    expect(
      effectiveStatus(anOccurrence(completedAt: at, completedBy: 'cara')),
      ChoreStatus.completed,
    );
  });

  test('an exception without completion stays scheduled', () {
    expect(
      effectiveStatus(
        anOccurrence(
          exception: CompletionException(note: 'done', by: 'bob', at: at),
        ),
      ),
      ChoreStatus.scheduled,
    );
  });

  test('optional-only subtasks need every tick', () {
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: optionalOnly,
          subtaskDone: <String, SubtaskDone>{'step_1': tick()},
        ),
      ),
      ChoreStatus.inProgress,
    );
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: optionalOnly,
          subtaskDone: <String, SubtaskDone>{
            'step_1': tick(),
            'step_2': tick(),
          },
        ),
      ),
      ChoreStatus.completed,
    );
  });

  test('the required set decides completion, not the optional steps', () {
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: <TemplateSubtask>[
            ...required,
            aSubtask(id: 'extra'),
          ],
          subtaskDone: <String, SubtaskDone>{
            'step_1': tick(),
            'step_2': tick(),
          },
        ),
      ),
      ChoreStatus.completed,
    );
  });

  test('an open required step is in_progress', () {
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: required,
          subtaskDone: <String, SubtaskDone>{'step_1': tick()},
        ),
      ),
      ChoreStatus.inProgress,
    );
  });

  test('a recorded exception completes a chore with an open required step', () {
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: required,
          subtaskDone: <String, SubtaskDone>{'step_1': tick()},
          completedAt: at,
          completedBy: 'bob',
          exception: CompletionException(
            note: 'already clean',
            by: 'bob',
            at: at,
          ),
        ),
      ),
      ChoreStatus.completed,
    );
  });

  test('a stale completedAt without its ticks is ignored', () {
    expect(
      effectiveStatus(
        anOccurrence(subtasks: required, completedAt: at, completedBy: 'cara'),
      ),
      ChoreStatus.scheduled,
    );
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: required,
          subtaskDone: <String, SubtaskDone>{'step_1': tick()},
          completedAt: at,
          completedBy: 'cara',
        ),
      ),
      ChoreStatus.inProgress,
    );
  });

  test('a stale tick key is not progress', () {
    expect(
      effectiveStatus(
        anOccurrence(
          subtasks: required,
          subtaskDone: <String, SubtaskDone>{'removed_step': tick()},
        ),
      ),
      ChoreStatus.scheduled,
    );
  });

  test('any subset of ticks yields a consistent status (property)', () {
    // 2 required + 1 optional: completed only when both required are ticked.
    final subtasks = <TemplateSubtask>[...required, aSubtask(id: 'extra')];
    for (var mask = 0; mask < 8; mask++) {
      final done = <String, SubtaskDone>{
        if (mask & 1 != 0) 'step_1': tick(),
        if (mask & 2 != 0) 'step_2': tick(),
        if (mask & 4 != 0) 'extra': tick(),
      };
      final expected = mask & 3 == 3
          ? ChoreStatus.completed
          : mask == 0
          ? ChoreStatus.scheduled
          : ChoreStatus.inProgress;
      expect(
        effectiveStatus(anOccurrence(subtasks: subtasks, subtaskDone: done)),
        expected,
        reason: 'mask $mask',
      );
    }
  });

  group('isOverdue', () {
    final due = DateTime.utc(2026, 10, 24, 3);

    test('is false at the deadline and inside the grace period', () {
      final occ = anOccurrence(dueAt: due);
      expect(isOverdue(occ, due, 0), isFalse);
      expect(isOverdue(occ, due.add(const Duration(minutes: 29)), 30), isFalse);
    });

    test('is true past dueAt + grace', () {
      final occ = anOccurrence(dueAt: due);
      expect(isOverdue(occ, due.add(const Duration(minutes: 1)), 0), isTrue);
      expect(isOverdue(occ, due.add(const Duration(minutes: 31)), 30), isTrue);
    });

    test('is false once the chore is completed, verified or skipped', () {
      final later = due.add(const Duration(days: 1));
      expect(
        isOverdue(anOccurrence(dueAt: due, completedAt: at), later, 0),
        isFalse,
      );
      expect(
        isOverdue(anOccurrence(dueAt: due, verifiedAt: at), later, 0),
        isFalse,
      );
      expect(
        isOverdue(
          anOccurrence(dueAt: due, status: OccurrenceStatus.skipped),
          later,
          0,
        ),
        isFalse,
      );
    });
  });
}
