import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-11: one view-model for materialized and projected occurrences.
void main() {
  final at = DateTime.utc(2026, 10, 24, 6);
  final day = DateKey(2026, 10, 24);

  final subtasks = <TemplateSubtask>[
    aSubtask(id: 'step_1'),
    aSubtask(id: 'step_2'),
  ];

  test('a stored occurrence becomes a scheduled item', () {
    final item = ChoreItem.fromOccurrence(anOccurrence(subtasks: subtasks));

    expect(item.status, ChoreStatus.scheduled);
    expect(item.isProjected, isFalse);
    expect(item.assigneeId, 'cara');
    expect(item.plannedAssigneeId, 'cara');
    expect(item.progress, const ChoreProgress(done: 0, total: 2));
    expect(item.has(ChoreFlag.isProjected), isFalse);
    expect(item.flags, isEmpty);
  });

  test('progress counts only current subtasks', () {
    final item = ChoreItem.fromOccurrence(
      anOccurrence(
        subtasks: subtasks,
        subtaskDone: <String, SubtaskDone>{
          'step_1': SubtaskDone(at: at, by: 'cara'),
          'removed_step': SubtaskDone(at: at, by: 'cara'),
        },
      ),
    );

    expect(item.status, ChoreStatus.inProgress);
    expect(item.progress, const ChoreProgress(done: 1, total: 2));
  });

  test('a completed chore awaiting verification is flagged', () {
    final item = ChoreItem.fromOccurrence(
      anOccurrence(
        subtasks: subtasks,
        verification: VerificationMode.required,
        subtaskDone: <String, SubtaskDone>{
          'step_1': SubtaskDone(at: at, by: 'cara'),
          'step_2': SubtaskDone(at: at, by: 'cara'),
        },
        completedAt: at,
        completedBy: 'cara',
      ),
    );

    expect(item.status, ChoreStatus.completed);
    expect(item.has(ChoreFlag.awaitingVerification), isTrue);
  });

  test('a verified chore is not awaiting verification', () {
    final item = ChoreItem.fromOccurrence(
      anOccurrence(
        subtasks: subtasks,
        verification: VerificationMode.required,
        subtaskDone: <String, SubtaskDone>{
          'step_1': SubtaskDone(at: at, by: 'cara'),
          'step_2': SubtaskDone(at: at, by: 'cara'),
        },
        completedAt: at,
        completedBy: 'cara',
        verifiedAt: at,
        verifiedBy: 'bob',
      ),
    );

    expect(item.status, ChoreStatus.verified);
    expect(item.has(ChoreFlag.awaitingVerification), isFalse);
  });

  test('needsCover comes from the stored flag or the availability index', () {
    expect(
      ChoreItem.fromOccurrence(anOccurrence(needsCover: true))
          .has(ChoreFlag.needsCover),
      isTrue,
    );

    final absent = AvailabilityIndex(<AvailabilitySpan>[
      AvailabilitySpan(memberId: 'cara', startDate: day, endDate: day),
    ]);
    expect(
      ChoreItem.fromOccurrence(
        anOccurrence(),
        availability: absent,
      ).has(ChoreFlag.needsCover),
      isTrue,
    );
    expect(
      ChoreItem.fromOccurrence(
        anOccurrence(),
        availability: AvailabilityIndex(<AvailabilitySpan>[
          AvailabilitySpan(memberId: 'dave', startDate: day, endDate: day),
        ]),
      ).has(ChoreFlag.needsCover),
      isFalse,
    );
  });

  test('cover, attention and an open swap are separate flags', () {
    final item = ChoreItem.fromOccurrence(
      anOccurrence(coverForId: 'cara', needsAttention: true),
      hasPendingSwap: true,
    );

    expect(
      item.flags,
      containsAll(<ChoreFlag>[
        ChoreFlag.isCover,
        ChoreFlag.needsAttention,
        ChoreFlag.hasPendingSwap,
      ]),
    );
  });

  test('a draft is projected, read-only and never awaiting verification', () {
    final item = ChoreItem.fromDraft(
      anOccurrenceDraft(
        subtasks: subtasks,
        verification: VerificationMode.required,
      ),
    );

    expect(item.isProjected, isTrue);
    expect(item.has(ChoreFlag.isProjected), isTrue);
    expect(item.has(ChoreFlag.awaitingVerification), isFalse);
    expect(item.status, ChoreStatus.scheduled);
  });

  test('two identical occurrences produce equal items', () {
    final occurrence = anOccurrence(subtasks: subtasks);
    expect(
      ChoreItem.fromOccurrence(occurrence),
      ChoreItem.fromOccurrence(occurrence),
    );
    expect(
      ChoreItem.fromOccurrence(occurrence),
      isNot(ChoreItem.fromDraft(anOccurrenceDraft(subtasks: subtasks))),
    );
  });

  test('a chore without subtasks reports no progress counter', () {
    final item = ChoreItem.fromOccurrence(anOccurrence());
    expect(item.progress.hasSubtasks, isFalse);
    expect(item.progress, ChoreProgress.none);
  });
}
