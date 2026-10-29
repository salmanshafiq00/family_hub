import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_parts.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

export 'package:family_hub/features/chores/occurrences/domain/occurrence_parts.dart';

const Object _unset = Object();

/// `copyWith`'s nullable fields: no argument keeps the value, `null` clears it.
T? _pick<T>(Object? value, T? current) =>
    identical(value, _unset) ? current : value as T?;

/// One stored occurrence (`choreOccurrences/{id}`), road map 3.2.
///
/// The document is a SNAPSHOT: the template's name, subtasks, instructions and
/// verification are copied at creation, so editing a template never rewrites
/// history. [status] is a CACHE; read `effectiveStatus` instead (D-P3-9).
final class ChoreOccurrence {
  ChoreOccurrence({
    required this.id,
    required this.templateId,
    required this.templateRev,
    required this.dateKey,
    required this.monthKey,
    required this.dueAt,
    required this.nameBn,
    required this.subtasks,
    this.slotKey,
    this.dueMinutes,
    this.nameEn,
    this.groupId,
    this.instructions = '',
    this.difficulty = Difficulty.normal,
    this.estimatedMinutes,
    this.verification = VerificationMode.off,
    this.status = OccurrenceStatus.scheduled,
    this.plannedAssigneeId,
    this.assigneeId,
    this.coverForId,
    this.assignmentSource = AssignmentSource.manual,
    this.needsCover = false,
    this.subtaskDone = const <String, SubtaskDone>{},
    this.completedAt,
    this.completedBy,
    this.verifiedAt,
    this.verifiedBy,
    this.reopenCount = 0,
    this.exception,
    this.skipReason,
    this.needsAttention = false,
    this.lastCommentAt,
    this.redoSubtaskIds = const <String>[],
    this.deletedAt,
    this.deletedBy,
  }) : assert(
         monthKey.year == dateKey.year && monthKey.month == dateKey.month,
         'monthKey must match dateKey',
       );

  final String id;
  final String templateId;

  /// The template revision the snapshot came from (P3-12 `templateRev`).
  final int templateRev;

  /// null for the `main` slot.
  final String? slotKey;
  final DateKey dateKey;
  final MonthKey monthKey;

  /// UTC instant the chore is due; the end of the family day when the slot has
  /// no `dueMinutes`.
  final DateTime dueAt;
  final int? dueMinutes;

  // ── Snapshots (immutable outside a replan) ──────────────────────────────
  final String nameBn;
  final String? nameEn;
  final String? groupId;
  final String instructions;
  final List<TemplateSubtask> subtasks;
  final Difficulty difficulty;
  final int? estimatedMinutes;
  final VerificationMode verification;

  // ── State ───────────────────────────────────────────────────────────────
  final OccurrenceStatus status;
  final String? plannedAssigneeId;
  final String? assigneeId;
  final String? coverForId;
  final AssignmentSource assignmentSource;
  final bool needsCover;
  final Map<String, SubtaskDone> subtaskDone;
  final DateTime? completedAt;
  final String? completedBy;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final int reopenCount;
  final CompletionException? exception;
  final SkipReason? skipReason;
  final bool needsAttention;
  final DateTime? lastCommentAt;

  /// The steps a “Reopen” asked to redo (B-04, road map Appendix C).
  ///
  /// The same reopen unticks them, so the derived status can never disagree
  /// with the decision. A document without this field holds no decision.
  final List<String> redoSubtaskIds;
  final DateTime? deletedAt;
  final String? deletedBy;

  bool get isDeleted => deletedAt != null;

  /// The subtasks a completion must tick: required ones, else every subtask.
  List<TemplateSubtask> get requiredSubtasks {
    final required = <TemplateSubtask>[
      for (final subtask in subtasks)
        if (subtask.required) subtask,
    ];
    return required.isEmpty ? subtasks : required;
  }

  /// Ticked CURRENT subtasks (a stale key after a replan is not progress).
  int get doneCount {
    var done = 0;
    for (final subtask in subtasks) {
      if (subtaskDone.containsKey(subtask.id)) done++;
    }
    return done;
  }

  ChoreOccurrence copyWith({
    String? id,
    String? templateId,
    int? templateRev,
    Object? slotKey = _unset,
    DateKey? dateKey,
    MonthKey? monthKey,
    DateTime? dueAt,
    Object? dueMinutes = _unset,
    String? nameBn,
    Object? nameEn = _unset,
    Object? groupId = _unset,
    String? instructions,
    List<TemplateSubtask>? subtasks,
    Difficulty? difficulty,
    Object? estimatedMinutes = _unset,
    VerificationMode? verification,
    OccurrenceStatus? status,
    Object? plannedAssigneeId = _unset,
    Object? assigneeId = _unset,
    Object? coverForId = _unset,
    AssignmentSource? assignmentSource,
    bool? needsCover,
    Map<String, SubtaskDone>? subtaskDone,
    Object? completedAt = _unset,
    Object? completedBy = _unset,
    Object? verifiedAt = _unset,
    Object? verifiedBy = _unset,
    int? reopenCount,
    Object? exception = _unset,
    Object? skipReason = _unset,
    bool? needsAttention,
    Object? lastCommentAt = _unset,
    List<String>? redoSubtaskIds,
    Object? deletedAt = _unset,
    Object? deletedBy = _unset,
  }) => ChoreOccurrence(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    templateRev: templateRev ?? this.templateRev,
    slotKey: _pick(slotKey, this.slotKey),
    dateKey: dateKey ?? this.dateKey,
    monthKey: monthKey ?? this.monthKey,
    dueAt: dueAt ?? this.dueAt,
    dueMinutes: _pick(dueMinutes, this.dueMinutes),
    nameBn: nameBn ?? this.nameBn,
    nameEn: _pick(nameEn, this.nameEn),
    groupId: _pick(groupId, this.groupId),
    instructions: instructions ?? this.instructions,
    subtasks: subtasks ?? this.subtasks,
    difficulty: difficulty ?? this.difficulty,
    estimatedMinutes: _pick(estimatedMinutes, this.estimatedMinutes),
    verification: verification ?? this.verification,
    status: status ?? this.status,
    plannedAssigneeId: _pick(plannedAssigneeId, this.plannedAssigneeId),
    assigneeId: _pick(assigneeId, this.assigneeId),
    coverForId: _pick(coverForId, this.coverForId),
    assignmentSource: assignmentSource ?? this.assignmentSource,
    needsCover: needsCover ?? this.needsCover,
    subtaskDone: subtaskDone ?? this.subtaskDone,
    completedAt: _pick(completedAt, this.completedAt),
    completedBy: _pick(completedBy, this.completedBy),
    verifiedAt: _pick(verifiedAt, this.verifiedAt),
    verifiedBy: _pick(verifiedBy, this.verifiedBy),
    reopenCount: reopenCount ?? this.reopenCount,
    exception: _pick(exception, this.exception),
    skipReason: _pick(skipReason, this.skipReason),
    needsAttention: needsAttention ?? this.needsAttention,
    lastCommentAt: _pick(lastCommentAt, this.lastCommentAt),
    redoSubtaskIds: redoSubtaskIds ?? this.redoSubtaskIds,
    deletedAt: _pick(deletedAt, this.deletedAt),
    deletedBy: _pick(deletedBy, this.deletedBy),
  );

  @override
  bool operator ==(Object other) =>
      other is ChoreOccurrence &&
      other.id == id &&
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
      other.plannedAssigneeId == plannedAssigneeId &&
      other.assigneeId == assigneeId &&
      other.coverForId == coverForId &&
      other.assignmentSource == assignmentSource &&
      other.needsCover == needsCover &&
      _sameMap(other.subtaskDone, subtaskDone) &&
      other.completedAt == completedAt &&
      other.completedBy == completedBy &&
      other.verifiedAt == verifiedAt &&
      other.verifiedBy == verifiedBy &&
      other.reopenCount == reopenCount &&
      other.exception == exception &&
      other.skipReason == skipReason &&
      other.needsAttention == needsAttention &&
      other.lastCommentAt == lastCommentAt &&
      _sameList(other.redoSubtaskIds, redoSubtaskIds) &&
      other.deletedAt == deletedAt &&
      other.deletedBy == deletedBy;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    id,
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
    plannedAssigneeId,
    assigneeId,
    coverForId,
    assignmentSource,
    needsCover,
    Object.hashAllUnordered(<int>[
      for (final entry in subtaskDone.entries)
        Object.hash(entry.key, entry.value),
    ]),
    completedAt,
    completedBy,
    verifiedAt,
    verifiedBy,
    reopenCount,
    exception,
    skipReason,
    needsAttention,
    lastCommentAt,
    Object.hashAll(redoSubtaskIds),
    deletedAt,
    deletedBy,
  ]);

  static bool _sameList<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameMap(Map<String, SubtaskDone> a, Map<String, SubtaskDone> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'ChoreOccurrence($id, ${status.id}, ${subtaskDone.length} ticks, '
      'assignee: $assigneeId)';
}
