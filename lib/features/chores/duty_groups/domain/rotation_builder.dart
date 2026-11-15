import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_boundaries.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_validator.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';

/// Creates the NEXT rotation version without moving anybody's turn before the
/// change takes effect (road map P3-09 / Appendix F.2).
///
/// A change never edits a version in place: it appends a version effective from
/// the next cycle boundary, whose anchor is exactly the person the OLD rotation
/// planned for that boundary. Days before the boundary therefore keep the old
/// version and the same answer (the property test of P3-09), and the change is
/// visible from the boundary onward.
abstract final class RotationBuilder {
  /// Appends [memberId] at the end of the rotation, effective at the next cycle
  /// boundary on or after [effectiveFrom].
  ///
  /// [weekStartDay] defaults to the current version's snapshot; pass the
  /// family's current setting when creating a new version.
  static Result<Rotation> add(
    Rotation rotation, {
    required String memberId,
    required DateKey effectiveFrom,
    int? weekStartDay,
    Recurrence? recurrence,
  }) {
    final current = _currentVersion(rotation, effectiveFrom);
    if (current == null) return const Failure(_invalidDate);
    if (current.members.contains(memberId)) {
      return const Failure(Validation('members', 'duplicate_id'));
    }
    if (current.members.length >= RotationLimits.maxMembers) {
      return const Failure(Validation('members', 'too_many_items'));
    }
    final unsupported = _occurrenceCheck(current, recurrence);
    if (unsupported != null) return Failure(unsupported);

    final boundary = RotationBoundaries.next(current, effectiveFrom);
    final planned = RotationEngine.planned(
      rotation,
      boundary,
      recurrence: recurrence,
    );
    final members = <String>[...current.members, memberId];
    final anchorIndex = planned == null ? 0 : members.indexOf(planned);
    return _withVersion(
      rotation,
      _versionFrom(
        current,
        from: boundary,
        members: members,
        anchorIndex: anchorIndex < 0 ? 0 : anchorIndex,
        weekStartDay: weekStartDay,
      ),
    );
  }

  /// Removes [memberId] from the next version on.
  ///
  /// When the removed person was due at the boundary, the next person in the
  /// OLD order takes that turn; everyone else keeps their relative order.
  static Result<Rotation> remove(
    Rotation rotation, {
    required String memberId,
    required DateKey effectiveFrom,
    int? weekStartDay,
    Recurrence? recurrence,
  }) {
    final current = _currentVersion(rotation, effectiveFrom);
    if (current == null) return const Failure(_invalidDate);
    if (!current.members.contains(memberId)) {
      return const Failure(Validation('members', 'invalid_rotation'));
    }
    if (current.members.length <= RotationLimits.minMembers) {
      return const Failure(Validation('members', 'too_few_members'));
    }
    final unsupported = _occurrenceCheck(current, recurrence);
    if (unsupported != null) return Failure(unsupported);

    final boundary = RotationBoundaries.next(current, effectiveFrom);
    final planned = RotationEngine.planned(
      rotation,
      boundary,
      recurrence: recurrence,
    );
    final members = <String>[
      for (final member in current.members)
        if (member != memberId) member,
    ];
    final anchorIndex = _anchorAfterRemoval(
      current.members,
      members,
      memberId,
      planned,
    );
    return _withVersion(
      rotation,
      _versionFrom(
        current,
        from: boundary,
        members: members,
        anchorIndex: anchorIndex,
        weekStartDay: weekStartDay,
      ),
    );
  }

  /// Replaces the member order with [members], starting with [startsWith] at
  /// the next cycle boundary.
  ///
  /// Reordering cannot add or drop anybody: the set must be unchanged.
  static Result<Rotation> reorder(
    Rotation rotation, {
    required List<String> members,
    required String startsWith,
    required DateKey effectiveFrom,
    int? weekStartDay,
  }) {
    final current = _currentVersion(rotation, effectiveFrom);
    if (current == null) return const Failure(_invalidDate);
    if (members.length != current.members.length ||
        members.toSet().length != members.length ||
        !members.toSet().containsAll(current.members)) {
      return const Failure(Validation('members', 'invalid_rotation'));
    }
    final startIndex = members.indexOf(startsWith);
    if (startIndex < 0) {
      return const Failure(Validation('members', 'member_required'));
    }
    if (current.members.length < RotationLimits.minMembers) {
      return const Failure(Validation('members', 'too_few_members'));
    }

    final boundary = RotationBoundaries.next(current, effectiveFrom);
    return _withVersion(
      rotation,
      _versionFrom(
        current,
        from: boundary,
        members: members,
        anchorIndex: startIndex,
        weekStartDay: weekStartDay,
      ),
    );
  }

  /// Changes how often the turn advances, from the next cycle boundary on.
  ///
  /// The boundary is the CURRENT unit's next boundary (a weekly rota changes on
  /// a week start), and whoever the old rotation planned for that day takes the
  /// first turn under the new cadence — so the changeover never skips anybody.
  ///
  /// `occurrence` is refused: it needs a template schedule, which a group does
  /// not have (the group editor offers day/week/month only).
  static Result<Rotation> cycle(
    Rotation rotation, {
    required CycleUnit cycleUnit,
    required DateKey effectiveFrom,
    int? weekStartDay,
  }) {
    if (cycleUnit == CycleUnit.occurrence) {
      return const Failure(Validation('rotation', 'invalid_rotation'));
    }
    final current = _currentVersion(rotation, effectiveFrom);
    if (current == null) return const Failure(_invalidDate);
    if (current.cycleUnit == cycleUnit) {
      return const Failure(Validation('rotation', 'invalid_rotation'));
    }

    final boundary = RotationBoundaries.next(current, effectiveFrom);
    final planned = RotationEngine.planned(rotation, boundary);
    final anchorIndex = planned == null ? 0 : current.members.indexOf(planned);
    return _withVersion(
      rotation,
      _versionFrom(
        current,
        from: boundary,
        members: current.members,
        anchorIndex: anchorIndex < 0 ? 0 : anchorIndex,
        weekStartDay: weekStartDay,
        cycleUnit: cycleUnit,
      ),
    );
  }

  static RotationVersion? _currentVersion(
    Rotation rotation,
    DateKey effectiveFrom,
  ) => RotationEngine.versionFor(rotation, effectiveFrom);

  static RotationVersion _versionFrom(
    RotationVersion current, {
    required DateKey from,
    required List<String> members,
    required int anchorIndex,
    int? weekStartDay,
    CycleUnit? cycleUnit,
  }) => RotationVersion(
    from: from,
    members: List<String>.unmodifiable(members),
    // Anchor on the boundary itself: cycle 0 gives the person the old version
    // planned for that day.
    anchorDate: from,
    anchorIndex: anchorIndex,
    cycleUnit: cycleUnit ?? current.cycleUnit,
    weekStartDay: weekStartDay ?? current.weekStartDay,
  );

  /// Keeps the version list sorted and bounded, then re-runs the shape checks.
  static Result<Rotation> _withVersion(
    Rotation rotation,
    RotationVersion version,
  ) {
    final versions = <RotationVersion>[
      for (final existing in rotation.versions)
        if (existing.from != version.from) existing,
      version,
    ]..sort((a, b) => a.from.compareTo(b.from));

    if (versions.length > RotationLimits.maxVersions) {
      final oldest = versions.first;
      final retentionStart = version.from.addDays(
        -RotationLimits.retentionDays,
      );
      if (oldest.from.isBefore(retentionStart)) {
        versions.removeAt(0);
      } else {
        return const Failure(Validation('rotation', 'too_many_items'));
      }
    }

    final candidate = Rotation(
      versions: List<RotationVersion>.unmodifiable(versions),
    );
    final invalid = RotationValidator.validate(candidate);
    return invalid == null
        ? Success<Rotation>(candidate)
        : Failure<Rotation>(invalid);
  }

  /// Index (in [members]) of the person who takes the boundary turn.
  static int _anchorAfterRemoval(
    List<String> oldMembers,
    List<String> members,
    String removed,
    String? planned,
  ) {
    if (planned == null) return 0;
    if (planned != removed) {
      final index = members.indexOf(planned);
      return index < 0 ? 0 : index;
    }
    final removedIndex = oldMembers.indexOf(removed);
    for (var step = 1; step <= oldMembers.length; step++) {
      final candidate = oldMembers[(removedIndex + step) % oldMembers.length];
      if (candidate == removed) continue;
      final index = members.indexOf(candidate);
      if (index >= 0) return index;
    }
    return 0;
  }

  /// The `occurrence` unit needs a schedule to count firing days.
  ///
  /// A duty group can own templates with different schedules, so the caller
  /// must name the schedule it is editing; without one the boundary cannot be
  /// evaluated and the change is refused instead of guessing.
  static AppFailure? _occurrenceCheck(
    RotationVersion version,
    Recurrence? recurrence,
  ) => version.cycleUnit == CycleUnit.occurrence && recurrence == null
      ? const Validation('rotation', 'invalid_rotation')
      : null;

  static const Validation _invalidDate = Validation('rotation', 'invalid_date');
}
