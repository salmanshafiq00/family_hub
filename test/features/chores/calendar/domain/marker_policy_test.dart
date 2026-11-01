import 'package:family_hub/features/chores/calendar/domain/marker_policy.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar_test_support.dart';

void main() {
  test('no chores, no markers', () {
    expect(MarkerPolicy.pick(const []), MarkerPick.none);
  });

  test('urgency order is overdue, in progress, scheduled, done, verified, '
      'skipped', () {
    final ranks = <ChoreStatus>[
      ChoreStatus.overdue,
      ChoreStatus.inProgress,
      ChoreStatus.scheduled,
      ChoreStatus.completed,
      ChoreStatus.verified,
      ChoreStatus.skipped,
    ].map(MarkerPolicy.urgencyRank).toList();
    expect(ranks, [0, 1, 2, 3, 4, 5]);
  });

  test('three or fewer chores show one marker each, most urgent first', () {
    final pick = MarkerPolicy.pick([
      aChoreItem('a', kToday, status: ChoreStatus.completed),
      aChoreItem('b', kToday, status: ChoreStatus.overdue),
      aChoreItem('c', kToday),
    ]);
    expect(pick.markers, [
      ChoreStatus.overdue,
      ChoreStatus.scheduled,
      ChoreStatus.completed,
    ]);
    expect(pick.extra, 0);
  });

  test('more than three chores collapse the least urgent into +N', () {
    final pick = MarkerPolicy.pick([
      for (var i = 0; i < 5; i++) aChoreItem('s$i', kToday),
      aChoreItem('d', kToday, status: ChoreStatus.verified),
      aChoreItem('o', kToday, status: ChoreStatus.overdue),
    ]);
    expect(pick.markers, [
      ChoreStatus.overdue,
      ChoreStatus.scheduled,
      ChoreStatus.scheduled,
    ]);
    expect(pick.extra, 4);
  });

  test('seven chores of one status read three markers and +4', () {
    final pick = MarkerPolicy.pick([
      for (var i = 0; i < 7; i++) aChoreItem('s$i', kToday),
    ]);
    expect(pick.markers.length, 3);
    expect(pick.extra, 4);
  });

  test('picking does not reorder or change the input', () {
    final items = [
      aChoreItem('a', kToday, status: ChoreStatus.completed),
      aChoreItem('b', kToday, status: ChoreStatus.overdue),
    ];
    MarkerPolicy.pick(items);
    expect(items.first.id, 'a');
  });
}
