import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/domain/member_load.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar_test_support.dart';

void main() {
  final day = DateKey(2026, 10, 25);

  DaySummary summary(List<ChoreItem> visible, {String? viewerId = 'cara'}) =>
      DaySummary.of(
        dateKey: day,
        isToday: false,
        isPast: true,
        visible: visible,
        viewerId: viewerId,
        mineCount: 0,
        unavailableMemberIds: const <String>{},
      );

  test('empty days have no member loads or status counts', () {
    final result = summary(const <ChoreItem>[]);

    expect(result.byMember, isEmpty);
    expect(result.doneCount, 0);
    expect(result.openCount, 0);
    expect(result.skippedCount, 0);
    expect(result.mostUrgent, isNull);
  });

  test('groups multiple chores for one member', () {
    final result = summary([
      aChoreItem('a', day, assignee: 'cara'),
      aChoreItem('b', day, assignee: 'cara'),
      aChoreItem('c', day, assignee: 'cara'),
    ]);

    expect(result.byMember, const <MemberLoad>[
      MemberLoad(memberId: 'cara', count: 3),
    ]);
  });

  test('viewer is first, other members are sorted, unassigned is last', () {
    final chores = [
      aChoreItem('z', day, assignee: 'zara'),
      aChoreItem('c', day, assignee: 'cara'),
      aChoreItem('a', day, assignee: 'amy'),
      aChoreItem('u', day, assignee: null),
    ];

    expect(summary(chores).byMember, const <MemberLoad>[
      MemberLoad(memberId: 'cara', count: 1),
      MemberLoad(memberId: 'amy', count: 1),
      MemberLoad(memberId: 'zara', count: 1),
      MemberLoad(memberId: null, count: 1),
    ]);
    expect(summary(chores, viewerId: null).byMember.first.memberId, 'amy');
  });

  test('done, open, skipped and most urgent are derived from counts', () {
    final result = summary([
      aChoreItem('done', day, status: ChoreStatus.completed),
      aChoreItem('verified', day, status: ChoreStatus.verified),
      aChoreItem('open', day, status: ChoreStatus.inProgress),
      aChoreItem('late', day, status: ChoreStatus.overdue),
      aChoreItem('skip', day, status: ChoreStatus.skipped),
    ]);

    expect(result.doneCount, 2);
    expect(result.openCount, 2);
    expect(result.skippedCount, 1);
    expect(result.mostUrgent, ChoreStatus.overdue);
  });

  test('member loads participate in equality and hash collections', () {
    final first = summary([aChoreItem('same', day, assignee: 'cara')]);
    final same = summary([aChoreItem('same', day, assignee: 'cara')]);
    final reassigned = summary([aChoreItem('same', day, assignee: 'dave')]);

    expect(first, same);
    expect(first.hashCode, same.hashCode);
    expect(first, isNot(reassigned));
    expect(<DaySummary>{first, same, reassigned}, hasLength(2));
  });

  test('thirty chores stay grouped by member without losing assignments', () {
    final result = summary([
      for (var i = 0; i < 30; i++)
        aChoreItem(
          'chore_$i',
          day,
          assignee: i % 3 == 0
              ? 'cara'
              : i % 3 == 1
              ? 'amy'
              : null,
        ),
    ]);

    expect(result.byMember, const <MemberLoad>[
      MemberLoad(memberId: 'cara', count: 10),
      MemberLoad(memberId: 'amy', count: 10),
      MemberLoad(memberId: null, count: 10),
    ]);
  });
}
