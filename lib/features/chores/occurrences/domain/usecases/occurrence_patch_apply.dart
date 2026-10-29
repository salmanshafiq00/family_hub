import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// Applies a dotted-key [OccurrencePatch] to an in-memory occurrence.
///
/// A use case answers with the NEW state after it staged a patch (so the UI has
/// it before the listener catches up), and a test can assert the patch without
/// Firestore. Only the keys the plan writes are understood; an unknown key is
/// ignored on purpose, because the stored document (not this mirror) is the
/// truth.
ChoreOccurrence applyOccurrencePatch(
  ChoreOccurrence occurrence,
  OccurrencePatch patch,
) {
  var next = occurrence;
  for (final entry in patch.fields.entries) {
    next = _withField(next, entry.key, entry.value);
  }
  for (final key in patch.removedFields) {
    next = _withoutField(next, key);
  }
  return next;
}

ChoreOccurrence _withField(ChoreOccurrence o, String key, Object? value) {
  if (key.startsWith('subtaskDone.')) {
    final done = Map<String, SubtaskDone>.of(o.subtaskDone);
    done[key.substring('subtaskDone.'.length)] = _tick(value);
    return o.copyWith(subtaskDone: done);
  }
  return switch (key) {
    'status' => o.copyWith(status: OccurrenceStatus.fromId(value)),
    'completedAt' => o.copyWith(completedAt: value as DateTime?),
    'completedBy' => o.copyWith(completedBy: value as String?),
    'verifiedAt' => o.copyWith(verifiedAt: value as DateTime?),
    'verifiedBy' => o.copyWith(verifiedBy: value as String?),
    'reopenCount' => o.copyWith(reopenCount: value! as int),
    'skipReason' => o.copyWith(skipReason: SkipReason.fromId(value)),
    'exception' => o.copyWith(exception: _exception(value)),
    'assigneeId' => o.copyWith(assigneeId: value as String?),
    'plannedAssigneeId' => o.copyWith(plannedAssigneeId: value as String?),
    'assignmentSource' => o.copyWith(
      assignmentSource: AssignmentSource.fromId(value),
    ),
    'coverForId' => o.copyWith(coverForId: value as String?),
    'needsCover' => o.copyWith(needsCover: value! as bool),
    'needsAttention' => o.copyWith(needsAttention: value! as bool),
    'lastCommentAt' => o.copyWith(lastCommentAt: value as DateTime?),
    'redoSubtaskIds' => o.copyWith(redoSubtaskIds: _steps(value)),
    'deletedAt' => o.copyWith(deletedAt: value as DateTime?),
    'deletedBy' => o.copyWith(deletedBy: value as String?),
    _ => o,
  };
}

ChoreOccurrence _withoutField(ChoreOccurrence o, String key) {
  if (key.startsWith('subtaskDone.')) {
    final done = Map<String, SubtaskDone>.of(o.subtaskDone)
      ..remove(key.substring('subtaskDone.'.length));
    return o.copyWith(subtaskDone: done);
  }
  return switch (key) {
    'completedAt' => o.copyWith(completedAt: null),
    'completedBy' => o.copyWith(completedBy: null),
    'verifiedAt' => o.copyWith(verifiedAt: null),
    'verifiedBy' => o.copyWith(verifiedBy: null),
    'skipReason' => o.copyWith(skipReason: null),
    'exception' => o.copyWith(exception: null),
    'coverForId' => o.copyWith(coverForId: null),
    'redoSubtaskIds' => o.copyWith(redoSubtaskIds: const <String>[]),
    'deletedAt' => o.copyWith(deletedAt: null),
    'deletedBy' => o.copyWith(deletedBy: null),
    _ => o,
  };
}

List<String> _steps(Object? value) => value is List
    ? <String>[for (final step in value) if (step is String) step]
    : const <String>[];

SubtaskDone _tick(Object? value) {
  final map = value is Map ? value : const <Object?, Object?>{};
  final at = map['at'];
  return SubtaskDone(
    at: at is DateTime
        ? at
        : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    by: '${map['by'] ?? ''}',
  );
}

CompletionException? _exception(Object? value) {
  if (value is! Map) return null;
  final note = value['note'];
  final by = value['by'];
  final at = value['at'];
  if (note is! String || by is! String || at is! DateTime) return null;
  return CompletionException(note: note, by: by, at: at);
}
