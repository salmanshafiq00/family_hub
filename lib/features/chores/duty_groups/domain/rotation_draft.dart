import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_validator.dart';

/// What the rotation editor edits before a group exists (P3-18): who, in which
/// order, who goes first, from which day and how often the turn changes.
///
/// Immutable. It is also what a template's "own rotation" will edit, so it
/// knows nothing about duty groups. [toRotation] builds the FIRST version;
/// later edits of a stored rotation go through `ChangeRotation`.
final class RotationDraft {
  const RotationDraft({
    required this.members,
    required this.startsOn,
    required this.cycleUnit,
    required this.weekStartDay,
    this.startsWith,
  });

  final List<String> members;

  /// The member who takes the first turn; `null` means the first in [members].
  final String? startsWith;
  final DateKey startsOn;
  final CycleUnit cycleUnit;

  /// Snapshot written into the version (C-18): a later change of the family
  /// setting never moves somebody's turn.
  final int weekStartDay;

  /// The member who really goes first.
  String? get firstMember {
    final chosen = startsWith;
    if (chosen != null && members.contains(chosen)) return chosen;
    return members.isEmpty ? null : members.first;
  }

  RotationDraft copyWith({
    List<String>? members,
    String? startsWith,
    DateKey? startsOn,
    CycleUnit? cycleUnit,
    int? weekStartDay,
    bool clearStartsWith = false,
  }) => RotationDraft(
    members: members ?? this.members,
    startsWith: clearStartsWith ? null : (startsWith ?? this.startsWith),
    startsOn: startsOn ?? this.startsOn,
    cycleUnit: cycleUnit ?? this.cycleUnit,
    weekStartDay: weekStartDay ?? this.weekStartDay,
  );

  /// Appends [memberId]; a duplicate or a full roster is ignored (the editor
  /// hides the add button then).
  RotationDraft withMember(String memberId) {
    if (members.contains(memberId) ||
        members.length >= RotationLimits.maxMembers) {
      return this;
    }
    return copyWith(members: <String>[...members, memberId]);
  }

  RotationDraft withoutMember(String memberId) {
    if (!members.contains(memberId)) return this;
    return copyWith(
      members: <String>[
        for (final member in members)
          if (member != memberId) member,
      ],
      clearStartsWith: startsWith == memberId,
    );
  }

  /// Moves a member the way `ReorderableListView.onReorder` reports it
  /// ([newIndex] is counted before the removal).
  RotationDraft moved(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= members.length) return this;
    final list = <String>[...members];
    final item = list.removeAt(oldIndex);
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    list.insert(target.clamp(0, list.length), item);
    return copyWith(members: list);
  }

  /// The first rotation version, or the first problem as a [Validation].
  Result<Rotation> toRotation() {
    final first = firstMember;
    if (first == null) {
      return const Failure<Rotation>(Validation('members', 'too_few_members'));
    }
    final rotation = Rotation(
      versions: <RotationVersion>[
        RotationVersion(
          from: startsOn,
          members: List<String>.unmodifiable(members),
          anchorDate: startsOn,
          anchorIndex: members.indexOf(first),
          cycleUnit: cycleUnit,
          weekStartDay: weekStartDay,
        ),
      ],
    );
    final invalid = RotationValidator.validate(rotation);
    return invalid == null
        ? Success<Rotation>(rotation)
        : Failure<Rotation>(invalid);
  }

  @override
  bool operator ==(Object other) =>
      other is RotationDraft &&
      other.startsWith == startsWith &&
      other.startsOn == startsOn &&
      other.cycleUnit == cycleUnit &&
      other.weekStartDay == weekStartDay &&
      other.members.length == members.length &&
      _sameOrder(other.members, members);

  @override
  int get hashCode => Object.hash(
    startsWith,
    startsOn,
    cycleUnit,
    weekStartDay,
    Object.hashAll(members),
  );

  static bool _sameOrder(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
