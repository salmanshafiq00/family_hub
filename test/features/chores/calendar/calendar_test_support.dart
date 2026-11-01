import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_enums.dart';

import '../chores_test_helpers.dart';

/// Today in the calendar tests: Saturday 24 October 2026 (Appendix F).
final DateKey kToday = DateKey(2026, 10, 24);

/// A [ChoreItem] on [day] for the calendar tests. [status] is the DISPLAY
/// status (the provider derives overdue before the models see it).
ChoreItem aChoreItem(
  String id,
  DateKey day, {
  ChoreStatus status = ChoreStatus.scheduled,
  String? assignee = 'cara',
  Difficulty difficulty = Difficulty.normal,
  String? groupId = 'kitchen',
  String nameBn = 'বাসন ধোয়া',
  String? nameEn = 'Wash the dishes',
  int? dueMinutes = 540,
  bool needsAttention = false,
  bool needsCover = false,
  bool projected = false,
}) {
  final base = ChoreItem.fromOccurrence(
    anOccurrence(
      id: id,
      templateId: id,
      dateKey: day,
      assigneeId: assignee,
      plannedAssigneeId: assignee,
      difficulty: difficulty,
      groupId: groupId,
      nameBn: nameBn,
      nameEn: nameEn,
      dueMinutes: dueMinutes,
      needsAttention: needsAttention,
      needsCover: needsCover,
    ),
  );
  return base.copyWith(status: status, isProjected: projected);
}
