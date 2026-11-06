import 'package:family_hub/core/notifications/domain/reminder_plan_input.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

abstract final class PlannableChoreMapper {
  static PlannableChore fromItem(ChoreItem item) => PlannableChore(
    id: item.id,
    templateId: item.templateId,
    dueAt: item.dueAt,
    dueMinutes: item.dueMinutes,
    status: _status(item.status),
    assigneeId: item.assigneeId,
    nameBn: item.nameBn,
    nameEn: item.nameEn,
    categoryHint: item.groupId,
    isProjected: item.isProjected,
    isUnavailable: item.has(ChoreFlag.needsCover),
  );

  static PlannableChoreStatus _status(ChoreStatus status) => switch (status) {
    ChoreStatus.scheduled => PlannableChoreStatus.scheduled,
    ChoreStatus.inProgress => PlannableChoreStatus.inProgress,
    ChoreStatus.overdue => PlannableChoreStatus.overdue,
    ChoreStatus.completed => PlannableChoreStatus.completed,
    ChoreStatus.verified => PlannableChoreStatus.verified,
    ChoreStatus.skipped => PlannableChoreStatus.skipped,
  };
}
