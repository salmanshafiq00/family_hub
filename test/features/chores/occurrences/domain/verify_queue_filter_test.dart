import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/verify_queue_filter.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// B-03: the verification queue keeps only chores that really wait for a check.
void main() {
  final done = DateTime.utc(2026, 10, 24, 4);

  test('keeps a completed chore that requires verification', () {
    final o = anOccurrence(
      verification: VerificationMode.required,
      status: OccurrenceStatus.completed,
      completedAt: done,
      completedBy: 'cara',
    );
    expect(verifiableOccurrences([o], viewerUid: 'bob'), [o]);
  });

  test('drops a chore that needs no verification', () {
    final o = anOccurrence(
      status: OccurrenceStatus.completed,
      completedAt: done,
      completedBy: 'cara',
    );
    expect(verifiableOccurrences([o], viewerUid: 'bob'), isEmpty);
  });

  test('drops the viewer\'s own completion', () {
    final o = anOccurrence(
      verification: VerificationMode.required,
      status: OccurrenceStatus.completed,
      completedAt: done,
      completedBy: 'bob',
    );
    expect(verifiableOccurrences([o], viewerUid: 'bob'), isEmpty);
  });

  test('drops an already verified chore', () {
    final o = anOccurrence(
      verification: VerificationMode.required,
      status: OccurrenceStatus.verified,
      completedAt: done,
      completedBy: 'cara',
      verifiedAt: done,
    );
    expect(verifiableOccurrences([o], viewerUid: 'bob'), isEmpty);
  });

  test('uses the DERIVED status, not the stored cache', () {
    // Stored `completed`, but no completion and no steps: not completed.
    final o = anOccurrence(
      verification: VerificationMode.required,
      status: OccurrenceStatus.completed,
      completedBy: 'cara',
    );
    expect(verifiableOccurrences([o], viewerUid: 'bob'), isEmpty);
  });
}
