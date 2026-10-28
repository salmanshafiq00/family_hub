import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_validator.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_builder.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// The three edits [ChangeRotation] understands.
enum RotationChange {
  add('add'),
  remove('remove'),
  reorder('reorder');

  const RotationChange(this.id);

  final String id;
}

/// Adds, removes or reorders a duty group's members from a chosen date
/// (road map P3-09), using [RotationBuilder] so nobody's turn moves before the
/// change takes effect.
///
/// An INTEGRITY write (server required, road map 3.4): two devices appending
/// versions offline would silently produce two different rotas.
class ChangeRotation {
  const ChangeRotation({
    required this._groups,
    required this._families,
    required this._clock,
    required this._newId,
  });

  final DutyGroupRepository _groups;
  final FamilyRepository _families;
  final Clock _clock;
  final IdGenerator _newId;

  /// [weekStartDay] defaults to the current version's snapshot; the editor
  /// passes `settings/chores.weekStartDay` for a fresh version.
  ///
  /// [recurrence] is required only when the rotation advances by `occurrence`
  /// (a duty group then needs the schedule it is being previewed for).
  Future<Result<DutyGroup>> call({
    required String actorUid,
    required String familyId,
    required String groupId,
    required RotationChange change,
    required DateKey effectiveFrom,
    String? memberId,
    List<String>? members,
    String? startsWith,
    int? weekStartDay,
    Recurrence? recurrence,
  }) async {
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.manageChoreTemplates,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<DutyGroup>(denied);

    final invalidInput = _validateInput(
      change,
      memberId: memberId,
      members: members,
      startsWith: startsWith,
    );
    if (invalidInput != null) return Failure<DutyGroup>(invalidInput);

    final found = await _groups.get(familyId, groupId);
    final readFailure = found.failureOrNull;
    if (readFailure != null) return Failure<DutyGroup>(readFailure);
    final group = found.valueOrNull;
    if (group == null) {
      return const Failure<DutyGroup>(NotFound(entity: 'dutyGroup'));
    }
    if (RotationEngine.versionFor(group.rotation, effectiveFrom) == null) {
      return const Failure<DutyGroup>(Validation('rotation', 'invalid_date'));
    }

    if (change == RotationChange.add) {
      final added = await _checkNewMember(familyId, memberId!.trim());
      final failure = added.failureOrNull;
      if (failure != null) return Failure<DutyGroup>(failure);
    }

    final built = _build(
      group.rotation,
      change,
      effectiveFrom: effectiveFrom,
      memberId: memberId?.trim(),
      members: members,
      startsWith: startsWith,
      weekStartDay: weekStartDay,
      recurrence: recurrence,
    );
    final buildFailure = built.failureOrNull;
    if (buildFailure != null) return Failure<DutyGroup>(buildFailure);

    final updated = group.copyWith(rotation: built.valueOrNull!);
    final invalid = DutyGroupValidator.validate(updated);
    if (invalid != null) return Failure<DutyGroup>(invalid);

    final boundary = updated.rotation.versions.last.from;
    final written = await _groups.saveRotation(
      familyId,
      updated,
      AuditEvent(
        id: _newId(),
        type: AuditEventType.choresRotationChanged,
        actorId: actorUid,
        refType: AuditRefType.dutyGroup,
        refId: updated.id,
        at: _clock.nowUtc(),
        params: <String, String>{
          'name': updated.nameBn,
          'change': change.id,
          'from': boundary.toString(),
        },
      ),
    );
    final writeFailure = written.failureOrNull;
    if (writeFailure != null) return Failure<DutyGroup>(writeFailure);
    return Success<DutyGroup>(updated);
  }

  static Result<Rotation> _build(
    Rotation rotation,
    RotationChange change, {
    required DateKey effectiveFrom,
    required String? memberId,
    required List<String>? members,
    required String? startsWith,
    required int? weekStartDay,
    required Recurrence? recurrence,
  }) {
    switch (change) {
      case RotationChange.add:
        return RotationBuilder.add(
          rotation,
          memberId: memberId!,
          effectiveFrom: effectiveFrom,
          weekStartDay: weekStartDay,
          recurrence: recurrence,
        );
      case RotationChange.remove:
        return RotationBuilder.remove(
          rotation,
          memberId: memberId!,
          effectiveFrom: effectiveFrom,
          weekStartDay: weekStartDay,
          recurrence: recurrence,
        );
      case RotationChange.reorder:
        return RotationBuilder.reorder(
          rotation,
          members: members!,
          startsWith: startsWith!,
          effectiveFrom: effectiveFrom,
          weekStartDay: weekStartDay,
        );
    }
  }

  /// The inputs the builder needs, checked before any document is read.
  static Validation? _validateInput(
    RotationChange change, {
    required String? memberId,
    required List<String>? members,
    required String? startsWith,
  }) {
    switch (change) {
      case RotationChange.add:
      case RotationChange.remove:
        if (memberId == null || memberId.trim().isEmpty) {
          return const Validation('members', 'member_required');
        }
        return null;
      case RotationChange.reorder:
        if (members == null || members.isEmpty) {
          return const Validation('members', 'member_required');
        }
        if (startsWith == null || startsWith.trim().isEmpty) {
          return const Validation('members', 'member_required');
        }
        return null;
    }
  }

  /// A new member must be an ACTIVE member of this family (D-P3-12).
  Future<Result<void>> _checkNewMember(String familyId, String memberId) async {
    final found = await _families.getMember(familyId, memberId);
    final failure = found.failureOrNull;
    if (failure != null) return Failure<void>(failure);
    final member = found.valueOrNull;
    if (member == null) {
      return const Failure<void>(NotFound(entity: 'member'));
    }
    if (!member.isActive) {
      return const Failure<void>(Conflict(code: 'rotation_member_inactive'));
    }
    return const Success<void>(null);
  }
}
