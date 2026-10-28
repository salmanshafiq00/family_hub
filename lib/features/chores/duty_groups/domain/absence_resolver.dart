import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/duty_groups/domain/cover_picker.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/family/domain/member.dart';

/// What the generator writes on an occurrence from the rotation and an absence
/// (road map P3-09).
///
/// [assigneeId] null means "nobody can do it" and needs a manager; a manual,
/// unassigned template also has no assignee but is NOT "needs cover".
final class AssignmentDecision {
  const AssignmentDecision({
    this.assigneeId,
    required this.needsCover,
    this.suggestedCoverId,
  });

  final String? assigneeId;
  final bool needsCover;
  final String? suggestedCoverId;

  @override
  bool operator ==(Object other) =>
      other is AssignmentDecision &&
      other.assigneeId == assigneeId &&
      other.needsCover == needsCover &&
      other.suggestedCoverId == suggestedCoverId;

  @override
  int get hashCode => Object.hash(assigneeId, needsCover, suggestedCoverId);

  @override
  String toString() =>
      'AssignmentDecision($assigneeId, needsCover: $needsCover, '
      'suggested: $suggestedCoverId)';
}

/// Turns "the rotation planned X" into "who is actually doing it" (P3-09).
///
/// The planner NEVER moves on to the next person because of an absence: that
/// would shift the rota for everybody (D-P3-12). Instead it keeps X and marks
/// the day as needing cover, or suggests somebody else under policy B — but
/// nothing is reassigned until that person accepts (P3-26).
abstract final class AbsenceResolver {
  /// [planned] is [RotationEngine.planned]'s answer; [members] is the family
  /// roster (a planned uid missing from it counts as inactive).
  ///
  /// [windowLoad] is the optional weighted workload the cover picker uses.
  static AssignmentDecision resolve({
    required String? planned,
    required DateKey day,
    required AvailabilityIndex availabilityIndex,
    required AbsencePolicy policy,
    required List<Member> members,
    Map<String, int> windowLoad = const <String, int>{},
  }) {
    if (planned == null) {
      return const AssignmentDecision(assigneeId: null, needsCover: false);
    }

    final member = _memberById(members, planned);
    // An inactive/disabled member (or one no longer on the roster) can never
    // be the assignee: the day is unassigned and needs a manager (D-P3-12).
    if (member == null || !member.isActive) {
      return AssignmentDecision(
        assigneeId: null,
        needsCover: true,
        suggestedCoverId: policy == AbsencePolicy.autoCover
            ? _suggest(planned, day, members, availabilityIndex, windowLoad)
            : null,
      );
    }

    final unavailable = availabilityIndex.isUnavailable(planned, day);
    if (!unavailable) {
      return AssignmentDecision(assigneeId: planned, needsCover: false);
    }

    // Policy C is "the manager will skip it": the person stays planned and the
    // item is NOT flagged (F.2 case 18).
    if (policy == AbsencePolicy.skip) {
      return AssignmentDecision(assigneeId: planned, needsCover: false);
    }
    return AssignmentDecision(
      assigneeId: planned,
      needsCover: true,
      suggestedCoverId: policy == AbsencePolicy.autoCover
          ? _suggest(planned, day, members, availabilityIndex, windowLoad)
          : null,
    );
  }

  static String? _suggest(
    String planned,
    DateKey day,
    List<Member> members,
    AvailabilityIndex availabilityIndex,
    Map<String, int> windowLoad,
  ) => CoverPicker.pick(
    candidates: <String>[
      for (final member in members)
        if (member.isActive) member.uid,
    ],
    day: day,
    windowLoad: windowLoad,
    unavailable: availabilityIndex,
    // The unavailable person cannot cover their own chore.
    exclude: <String>{planned},
  );

  static Member? _memberById(List<Member> members, String uid) {
    for (final member in members) {
      if (member.uid == uid) return member;
    }
    return null;
  }
}
