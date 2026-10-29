import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';

import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// Pure functions between [ChoreOccurrence] and `choreOccurrences/{id}`.
///
/// The map is the single source of truth for the closed `occurrenceKeys()` list
/// and the contract fixture. `toMap` writes the WHOLE document, so the rules can
/// compare immutable snapshot fields against the previous version.
///
/// `fromDoc` is TOLERANT: a document with an unknown status, a malformed
/// subtask row or a missing timestamp still yields a usable occurrence instead
/// of crashing the calendar.
abstract final class OccurrenceMappers {
  static Map<String, dynamic> toMap(
    ChoreOccurrence occurrence,
    BaseDocumentMetadata meta,
  ) => <String, dynamic>{
    'templateId': occurrence.templateId,
    'templateRev': occurrence.templateRev,
    'slotKey': occurrence.slotKey,
    'dateKey': occurrence.dateKey.toString(),
    'monthKey': occurrence.monthKey.toString(),
    'dueAt': BaseMapper.dateTimeToTimestamp(occurrence.dueAt),
    'dueMinutes': occurrence.dueMinutes,
    'nameBn': occurrence.nameBn,
    'nameEn': occurrence.nameEn,
    'groupId': occurrence.groupId,
    'instructions': occurrence.instructions,
    'subtasks': <Map<String, Object?>>[
      for (final subtask in occurrence.subtasks) subtask.toMap(),
    ],
    'difficulty': occurrence.difficulty.id,
    'estimatedMinutes': occurrence.estimatedMinutes,
    'verification': occurrence.verification.id,
    'status': occurrence.status.id,
    'plannedAssigneeId': occurrence.plannedAssigneeId,
    'assigneeId': occurrence.assigneeId,
    'coverForId': occurrence.coverForId,
    'assignmentSource': occurrence.assignmentSource.id,
    'needsCover': occurrence.needsCover,
    'subtaskDone': <String, Object?>{
      for (final entry in occurrence.subtaskDone.entries)
        entry.key: entry.value.toMap(),
    },
    'completedAt': BaseMapper.dateTimeToTimestamp(occurrence.completedAt),
    'completedBy': occurrence.completedBy,
    'verifiedAt': BaseMapper.dateTimeToTimestamp(occurrence.verifiedAt),
    'verifiedBy': occurrence.verifiedBy,
    'reopenCount': occurrence.reopenCount,
    'exception': occurrence.exception?.toMap(),
    'skipReason': occurrence.skipReason?.id,
    'needsAttention': occurrence.needsAttention,
    'lastCommentAt': BaseMapper.dateTimeToTimestamp(occurrence.lastCommentAt),
    ...BaseMapper.metadataToMap(meta),
  };

  /// Reads one document; null when it does not exist or cannot be read.
  static ChoreOccurrence? fromDoc(String id, Map<String, dynamic>? map) {
    if (map == null) return null;
    final dateKey = _dateKey(map['dateKey']);
    final templateId = map['templateId'];
    if (dateKey == null || templateId is! String || templateId.isEmpty) {
      return null;
    }
    final monthKey =
        _monthKey(map['monthKey']) ?? MonthKey(dateKey.year, dateKey.month);
    return ChoreOccurrence(
      id: id,
      templateId: templateId,
      templateRev: _intIn(map['templateRev'], 1, 100000) ?? 1,
      slotKey: _nullableString(map['slotKey'], 12),
      dateKey: dateKey,
      monthKey: monthKey,
      dueAt:
          BaseMapper.timestampToDateTime(map['dueAt']) ??
          DateTime.utc(dateKey.year, dateKey.month, dateKey.day, 23, 59, 59),
      dueMinutes: _intIn(map['dueMinutes'], 0, 1439),
      nameBn: _string(map['nameBn'], 80),
      nameEn: _nullableString(map['nameEn'], 80),
      groupId: _nullableString(map['groupId'], 24),
      instructions: _string(map['instructions'], 4000),
      subtasks: _subtasks(map['subtasks']),
      difficulty: Difficulty.fromId(map['difficulty']),
      estimatedMinutes: _intIn(map['estimatedMinutes'], 1, 600),
      verification: VerificationMode.fromId(map['verification']),
      status: OccurrenceStatus.fromId(map['status']),
      plannedAssigneeId: _nullableString(map['plannedAssigneeId'], 64),
      assigneeId: _nullableString(map['assigneeId'], 64),
      coverForId: _nullableString(map['coverForId'], 64),
      assignmentSource: AssignmentSource.fromId(map['assignmentSource']),
      needsCover: map['needsCover'] is bool ? map['needsCover'] as bool : false,
      subtaskDone: _subtaskDone(map['subtaskDone']),
      completedAt: BaseMapper.timestampToDateTime(map['completedAt']),
      completedBy: _nullableString(map['completedBy'], 64),
      verifiedAt: BaseMapper.timestampToDateTime(map['verifiedAt']),
      verifiedBy: _nullableString(map['verifiedBy'], 64),
      reopenCount: _intIn(map['reopenCount'], 0, 1000) ?? 0,
      exception: _exception(map['exception']),
      skipReason: SkipReason.fromId(map['skipReason']),
      needsAttention: map['needsAttention'] is bool
          ? map['needsAttention'] as bool
          : false,
      lastCommentAt: BaseMapper.timestampToDateTime(map['lastCommentAt']),
      deletedAt: BaseMapper.timestampToDateTime(map['deletedAt']),
      deletedBy: _nullableString(map['deletedBy'], 64),
    );
  }

  /// The restore of one soft-deleted occurrence (a resumed template, a re-added
  /// date). B-06: ONLY the snapshot fields the replan rule allows, the cleared
  /// delete pair and the update stamps - never the whole document - so the
  /// `RESTORE` rule (rule 12) can bound the write with `affectedKeys()`. The
  /// original `createdAt/By` stay.
  static Map<String, dynamic> restoreMap(
    ChoreOccurrence occurrence, {
    required String actorId,
    required DateTime at,
  }) => <String, dynamic>{
    ..._snapshotFields(
      occurrence,
      recomputeAssignment: true,
      actorId: actorId,
      at: at,
    ),
    BaseMapper.keyDeletedAt: null,
    BaseMapper.keyDeletedBy: null,
  };

  /// The snapshot refresh of one unstarted occurrence (P3-12 replan).
  static Map<String, dynamic> replanMap(
    OccurrenceReplan replan, {
    required String actorId,
    required DateTime at,
  }) => _snapshotFields(
    replan.draft.occurrence,
    recomputeAssignment: replan.recomputeAssignment,
    actorId: actorId,
    at: at,
  );

  /// The snapshot keys shared by a replan and a restore (rules 10 and 12).
  static Map<String, dynamic> _snapshotFields(
    ChoreOccurrence draft, {
    required bool recomputeAssignment,
    required String actorId,
    required DateTime at,
  }) {
    return <String, dynamic>{
      'templateRev': draft.templateRev,
      'dueAt': BaseMapper.dateTimeToTimestamp(draft.dueAt),
      'dueMinutes': draft.dueMinutes,
      'nameBn': draft.nameBn,
      'nameEn': draft.nameEn,
      'groupId': draft.groupId,
      'instructions': draft.instructions,
      'subtasks': <Map<String, Object?>>[
        for (final subtask in draft.subtasks) subtask.toMap(),
      ],
      'difficulty': draft.difficulty.id,
      'estimatedMinutes': draft.estimatedMinutes,
      'verification': draft.verification.id,
      if (recomputeAssignment) ...<String, dynamic>{
        'plannedAssigneeId': draft.plannedAssigneeId,
        'assigneeId': draft.assigneeId,
        'assignmentSource': draft.assignmentSource.id,
        'needsCover': draft.needsCover,
      },
      BaseMapper.keyUpdatedAt: BaseMapper.dateTimeToTimestamp(at),
      BaseMapper.keyUpdatedBy: actorId,
    };
  }

  /// One dotted-key patch; removed fields become `FieldValue.delete()`.
  static Map<String, dynamic> patchMap(
    OccurrencePatch patch, {
    required String actorId,
    required DateTime at,
  }) {
    final map = <String, dynamic>{
      for (final entry in patch.fields.entries) entry.key: _wire(entry.value),
    };
    for (final key in patch.removedFields) {
      map[key] = FieldValue.delete();
    }
    map[BaseMapper.keyUpdatedAt] = BaseMapper.dateTimeToTimestamp(at);
    map[BaseMapper.keyUpdatedBy] = actorId;
    return map;
  }

  /// The map a subtask grid (`subtaskDone.<id>`) writes: a plain map, so a
  /// dotted-key patch can address one box.
  static Map<String, dynamic> gridMap(SubtaskDone done) => <String, dynamic>{
    'at': BaseMapper.dateTimeToTimestamp(done.at),
    'by': done.by,
  };

  /// The same grid value read back; null when the stored row is malformed.
  static SubtaskDone? gridFromMap(Object? raw) {
    if (raw is! Map) return null;
    final at = BaseMapper.timestampToDateTime(raw['at']);
    final by = _nullableString(raw['by'], 64);
    if (at == null || by == null) return null;
    return SubtaskDone(at: at, by: by);
  }

  // ── Primitives ──────────────────────────────────────────────────────────────

  static Object? _wire(Object? value) {
    if (value is DateTime) return BaseMapper.dateTimeToTimestamp(value);
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries) '${entry.key}': _wire(entry.value),
      };
    }
    if (value is List) return <Object?>[for (final item in value) _wire(item)];
    return value;
  }

  static List<TemplateSubtask> _subtasks(Object? raw) {
    if (raw is! List) return const <TemplateSubtask>[];
    final subtasks = <TemplateSubtask>[];
    final ids = <String>{};
    for (final item in raw) {
      if (subtasks.length == TemplateLimits.maxSubtasks) break;
      if (item is! Map) continue;
      final id = _nullableString(item['id'], 16);
      final title = _string(item['title'], 120);
      if (id == null || title.isEmpty || !ids.add(id)) continue;
      subtasks.add(
        TemplateSubtask(
          id: id,
          title: title,
          required: item['required'] is bool ? item['required'] as bool : false,
          hint: _nullableString(item['hint'], 200),
        ),
      );
    }
    return subtasks;
  }

  static Map<String, SubtaskDone> _subtaskDone(Object? raw) {
    if (raw is! Map) return const <String, SubtaskDone>{};
    final done = <String, SubtaskDone>{};
    for (final entry in raw.entries) {
      if (done.length == 30) break;
      final value = entry.value;
      if (value is! Map) continue;
      final at = BaseMapper.timestampToDateTime(value['at']);
      final by = _nullableString(value['by'], 64);
      if (at == null || by == null) continue;
      done['${entry.key}'] = SubtaskDone(at: at, by: by);
    }
    return done;
  }

  static CompletionException? _exception(Object? raw) {
    if (raw is! Map) return null;
    final note = _nullableString(raw['note'], 300);
    final by = _nullableString(raw['by'], 64);
    final at = BaseMapper.timestampToDateTime(raw['at']);
    if (note == null || by == null || at == null) return null;
    return CompletionException(note: note, by: by, at: at);
  }

  static DateKey? _dateKey(Object? value) =>
      value is String ? DateKey.parse(value).valueOrNull : null;

  static MonthKey? _monthKey(Object? value) =>
      value is String ? MonthKey.parse(value).valueOrNull : null;

  static int? _intIn(Object? value, int min, int max) {
    if (value is! num) return null;
    final asInt = value.toInt();
    if (asInt < min || asInt > max) return null;
    return asInt;
  }

  static String _string(Object? value, int max) {
    if (value is! String) return '';
    return value.length > max ? value.substring(0, max) : value;
  }

  static String? _nullableString(Object? value, int max) {
    if (value is! String || value.isEmpty) return null;
    return value.length > max ? value.substring(0, max) : value;
  }
}
