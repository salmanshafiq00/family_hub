/// The small value types an occurrence is made of (mirrors `template_parts`).
library;

/// One tick in `subtaskDone`: when and by whom. The MAP is what makes two
/// phones safe: each phone writes only its own `subtaskDone.<id>` key, so a
/// Firestore merge keeps both ticks (D-P3-9).
final class SubtaskDone {
  const SubtaskDone({required this.at, required this.by});

  final DateTime at;
  final String by;

  Map<String, Object?> toMap() => <String, Object?>{'at': at, 'by': by};

  @override
  bool operator ==(Object other) =>
      other is SubtaskDone && other.at == at && other.by == by;

  @override
  int get hashCode => Object.hash(at, by);

  @override
  String toString() => 'SubtaskDone($by at $at)';
}

/// Why a chore was finished without its required steps (manager decision).
final class CompletionException {
  const CompletionException({
    required this.note,
    required this.by,
    required this.at,
  });

  final String note;
  final String by;
  final DateTime at;

  Map<String, Object?> toMap() => <String, Object?>{
    'note': note,
    'by': by,
    'at': at,
  };

  @override
  bool operator ==(Object other) =>
      other is CompletionException &&
      other.note == note &&
      other.by == by &&
      other.at == at;

  @override
  int get hashCode => Object.hash(note, by, at);

  @override
  String toString() => 'CompletionException($by: $note)';
}

/// Why an occurrence is skipped (`skipReason`).
enum SkipReason {
  absence('absence'),
  manager('manager');

  const SkipReason(this.id);

  final String id;

  static SkipReason? fromId(Object? id) {
    for (final reason in values) {
      if (reason.id == id) return reason;
    }
    return null;
  }
}

/// Who put the current assignee on the chore. `rotation` and `fixed` may be
/// recomputed by a replan; `manual`, `cover`, `swap` and `reassign` are a human
/// decision and are preserved.
enum AssignmentSource {
  rotation('rotation'),
  fixed('fixed'),
  manual('manual'),
  cover('cover'),
  swap('swap'),
  reassign('reassign');

  const AssignmentSource(this.id);

  final String id;

  static AssignmentSource fromId(Object? id) {
    for (final source in values) {
      if (source.id == id) return source;
    }
    return AssignmentSource.manual;
  }
}
