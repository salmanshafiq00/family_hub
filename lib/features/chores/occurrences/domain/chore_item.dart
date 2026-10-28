import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// A badge the UI may show on a chore tile (road map P3-11).
enum ChoreFlag {
  /// Completed, the template requires verification and nobody verified yet.
  awaitingVerification,

  /// Nobody can do it: the stored flag, or the assignee is absent that day.
  needsCover,

  /// A comment asked for attention.
  needsAttention,

  /// Not written yet (a draft from the generator, D-P3-6): read-only.
  isProjected,

  /// This member is covering somebody else's chore.
  isCover,

  /// A swap request is still open (P3-26 supplies the request).
  hasPendingSwap,
}

/// How far through its subtasks a chore is. `total == 0` means the chore has no
/// subtasks, so the UI hides the counter instead of showing "0/0".
final class ChoreProgress {
  const ChoreProgress({required this.done, required this.total});

  static const ChoreProgress none = ChoreProgress(done: 0, total: 0);

  final int done;
  final int total;

  bool get hasSubtasks => total > 0;

  bool get isComplete => total > 0 && done >= total;

  @override
  bool operator ==(Object other) =>
      other is ChoreProgress && other.done == done && other.total == total;

  @override
  int get hashCode => Object.hash(done, total);

  @override
  String toString() => 'ChoreProgress($done/$total)';
}

/// ONE view-model for a materialized OR projected occurrence (P3-11).
///
/// Screens, the calendar and the workload board read this, never the stored
/// `status`: [status] is [effectiveStatus], so "completed but not verified" and
/// "overdue" are consistent everywhere. [isProjected] tells the UI to render a
/// dashed, read-only "planned" item (D-P3-6); the first action on it
/// materializes it in the same batch (P3-12).
final class ChoreItem {
  ChoreItem({
    required this.id,
    required this.templateId,
    required this.templateRev,
    required this.dateKey,
    required this.monthKey,
    required this.dueAt,
    required this.nameBn,
    required this.subtasks,
    required this.status,
    required Set<ChoreFlag> flags,
    required this.progress,
    this.isProjected = false,
    this.slotKey,
    this.dueMinutes,
    this.nameEn,
    this.groupId,
    this.instructions = '',
    this.difficulty = Difficulty.normal,
    this.estimatedMinutes,
    this.verification = VerificationMode.off,
    this.assigneeId,
    this.plannedAssigneeId,
  }) : flags = Set<ChoreFlag>.unmodifiable(flags);

  /// A stored occurrence.
  factory ChoreItem.fromOccurrence(
    ChoreOccurrence occurrence, {
    AvailabilityIndex availability = AvailabilityIndex.empty,
    bool hasPendingSwap = false,
  }) => ChoreItem._from(
    occurrence,
    isProjected: false,
    availability: availability,
    hasPendingSwap: hasPendingSwap,
  );

  /// A projected occurrence: the generator's draft, not yet written.
  ///
  /// The draft has the same snapshot and planned owner as a stored occurrence
  /// (status `scheduled`, no ticks), so the conversion is shared with
  /// [ChoreItem.fromOccurrence] and the two views can never disagree (C-9).
  factory ChoreItem.fromDraft(
    OccurrenceDraft draft, {
    AvailabilityIndex availability = AvailabilityIndex.empty,
    bool hasPendingSwap = false,
  }) => ChoreItem._from(
    draft.toOccurrence(),
    isProjected: true,
    availability: availability,
    hasPendingSwap: hasPendingSwap,
  );

  factory ChoreItem._from(
    ChoreOccurrence occurrence, {
    required bool isProjected,
    required AvailabilityIndex availability,
    required bool hasPendingSwap,
  }) {
    final status = effectiveStatus(occurrence);
    final assignee = occurrence.assigneeId;
    final flags = <ChoreFlag>{
      if (!isProjected &&
          status == ChoreStatus.completed &&
          occurrence.verification == VerificationMode.required &&
          occurrence.verifiedAt == null)
        ChoreFlag.awaitingVerification,
      if (occurrence.needsCover ||
          (assignee != null &&
              availability.isUnavailable(assignee, occurrence.dateKey)))
        ChoreFlag.needsCover,
      if (occurrence.needsAttention) ChoreFlag.needsAttention,
      if (isProjected) ChoreFlag.isProjected,
      if (occurrence.coverForId != null) ChoreFlag.isCover,
      if (hasPendingSwap) ChoreFlag.hasPendingSwap,
    };
    return ChoreItem(
      id: occurrence.id,
      templateId: occurrence.templateId,
      templateRev: occurrence.templateRev,
      slotKey: occurrence.slotKey,
      dateKey: occurrence.dateKey,
      monthKey: occurrence.monthKey,
      dueAt: occurrence.dueAt,
      dueMinutes: occurrence.dueMinutes,
      nameBn: occurrence.nameBn,
      nameEn: occurrence.nameEn,
      groupId: occurrence.groupId,
      instructions: occurrence.instructions,
      subtasks: occurrence.subtasks,
      difficulty: occurrence.difficulty,
      estimatedMinutes: occurrence.estimatedMinutes,
      verification: occurrence.verification,
      status: status,
      flags: flags,
      assigneeId: assignee,
      plannedAssigneeId: occurrence.plannedAssigneeId,
      progress: ChoreProgress(
        done: occurrence.doneCount,
        total: occurrence.subtasks.length,
      ),
      isProjected: isProjected,
    );
  }

  final String id;
  final bool isProjected;
  final String templateId;
  final int templateRev;

  /// null for the `main` slot.
  final String? slotKey;
  final DateKey dateKey;
  final MonthKey monthKey;
  final DateTime dueAt;
  final int? dueMinutes;
  final String nameBn;
  final String? nameEn;
  final String? groupId;
  final String instructions;
  final List<TemplateSubtask> subtasks;
  final Difficulty difficulty;
  final int? estimatedMinutes;
  final VerificationMode verification;
  final ChoreStatus status;
  final Set<ChoreFlag> flags;

  /// The current owner; null means unassigned ("needs an assignee").
  final String? assigneeId;

  /// Who the rotation planned, even when somebody else covers it.
  final String? plannedAssigneeId;
  final ChoreProgress progress;

  bool has(ChoreFlag flag) => flags.contains(flag);

  @override
  bool operator ==(Object other) =>
      other is ChoreItem &&
      other.id == id &&
      other.isProjected == isProjected &&
      other.templateId == templateId &&
      other.templateRev == templateRev &&
      other.slotKey == slotKey &&
      other.dateKey == dateKey &&
      other.monthKey == monthKey &&
      other.dueAt == dueAt &&
      other.dueMinutes == dueMinutes &&
      other.nameBn == nameBn &&
      other.nameEn == nameEn &&
      other.groupId == groupId &&
      other.instructions == instructions &&
      _sameList(other.subtasks, subtasks) &&
      other.difficulty == difficulty &&
      other.estimatedMinutes == estimatedMinutes &&
      other.verification == verification &&
      other.status == status &&
      other.flags.length == flags.length &&
      other.flags.containsAll(flags) &&
      other.assigneeId == assigneeId &&
      other.plannedAssigneeId == plannedAssigneeId &&
      other.progress == progress;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    id,
    isProjected,
    templateId,
    templateRev,
    slotKey,
    dateKey,
    monthKey,
    dueAt,
    dueMinutes,
    nameBn,
    nameEn,
    groupId,
    instructions,
    Object.hashAll(subtasks),
    difficulty,
    estimatedMinutes,
    verification,
    status,
    Object.hashAllUnordered(flags),
    assigneeId,
    plannedAssigneeId,
    progress,
  ]);

  static bool _sameList<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'ChoreItem($id, ${status.id}, projected: $isProjected, '
      'assignee: $assigneeId)';
}
