import 'package:family_hub/core/notifications/domain/reminder_plan_input.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/presentation/plannable_chore_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar/calendar_test_support.dart';

void main() {
  test('maps effective status, due metadata, assignment, and names', () {
    final item = aChoreItem(
      'occurrence',
      kToday,
      status: ChoreStatus.inProgress,
      dueMinutes: 600,
      assignee: 'member',
      groupId: 'kitchen',
    );

    final mapped = PlannableChoreMapper.fromItem(item);

    expect(mapped.id, 'occurrence');
    expect(mapped.templateId, 'occurrence');
    expect(mapped.dueMinutes, 600);
    expect(mapped.status, PlannableChoreStatus.inProgress);
    expect(mapped.assigneeId, 'member');
    expect(mapped.nameBn, 'বাসন ধোয়া');
    expect(mapped.nameEn, 'Wash the dishes');
    expect(mapped.categoryHint, 'kitchen');
    expect(mapped.isProjected, isFalse);
    expect(mapped.isUnavailable, isFalse);
  });

  test('overdue and unavailable chores remain ineligible planner inputs', () {
    final overdue = PlannableChoreMapper.fromItem(
      aChoreItem('late', kToday, status: ChoreStatus.overdue),
    );
    final unavailable = PlannableChoreMapper.fromItem(
      aChoreItem('away', kToday, needsCover: true),
    );

    expect(overdue.status, PlannableChoreStatus.overdue);
    expect(overdue.isOpen, isFalse);
    expect(unavailable.isUnavailable, isTrue);
  });
}
