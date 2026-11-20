import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/presentation/affected_chores.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

void main() {
  ChoreItem item(
    String id,
    int day, {
    String who = 'cara',
    OccurrenceStatus status = OccurrenceStatus.scheduled,
  }) => ChoreItem.fromOccurrence(
    anOccurrence(
      id: id,
      dateKey: DateKey(2026, 10, day),
      assigneeId: who,
      status: status,
    ),
  );

  test('counts only the member’s open chores inside the range', () {
    final items = <ChoreItem>[
      item('a', 24),
      item('b', 25),
      item('c', 27),
      item('d', 25, who: 'dave'),
      item('e', 26, status: OccurrenceStatus.skipped),
    ];
    expect(
      affectedChoresCount(
        items,
        memberId: 'cara',
        start: DateKey(2026, 10, 24),
        end: DateKey(2026, 10, 26),
      ),
      2,
    );
  });

  test('months of a range, capped', () {
    expect(
      monthsOfRange(
        DateKey(2026, 10, 30),
        DateKey(2026, 11, 2),
      ).map((m) => m.toString()),
      ['2026-10', '2026-11'],
    );
    expect(
      monthsOfRange(DateKey(2026, 11, 20), DateKey(2027, 3, 1)),
      hasLength(3),
    );
    expect(
      monthsOfRange(DateKey(2026, 12, 30), DateKey(2027, 1, 2)).last.toString(),
      '2027-01',
    );
  });

  test('each policy has its own line', () {
    expect(policyLineOf(AbsencePolicy.askCover), PolicyLine.ask);
    expect(policyLineOf(AbsencePolicy.autoAssign), PolicyLine.share);
    expect(policyLineOf(AbsencePolicy.autoCover), PolicyLine.auto);
    expect(policyLineOf(AbsencePolicy.skip), PolicyLine.skip);
  });
}
