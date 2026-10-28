import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_validator.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Creates a duty group with its first rotation version (P3-09).
///
/// Order: permission → validation → repository write. A group needs at least
/// two members, because a one-person "rotation" is a fixed assignee in
/// disguise (use `AssigneeStrategy.fixed` for that).
///
/// An EVERYDAY write: creating a group while offline may queue (road map 3.4).
class CreateDutyGroup {
  const CreateDutyGroup({
    required this._groups,
    required this._families,
    required this._clock,
    required this._newId,
  });

  final DutyGroupRepository _groups;
  final FamilyRepository _families;
  final Clock _clock;
  final IdGenerator _newId;

  Future<Result<DutyGroup>> call({
    required String actorUid,
    required String familyId,
    required String nameBn,
    String? nameEn,
    int? colorIndex,
    required Rotation rotation,
  }) async {
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.manageChoreTemplates,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<DutyGroup>(denied);

    final listed = await _groups.list(familyId);
    final readFailure = listed.failureOrNull;
    if (readFailure != null) return Failure<DutyGroup>(readFailure);
    final existing = listed.valueOrNull ?? const <DutyGroup>[];
    if (existing.length >= DutyGroupLimits.maxGroups) {
      return const Failure<DutyGroup>(
        Validation('dutyGroups', 'too_many_items'),
      );
    }

    final group = DutyGroup(
      id: _newId(),
      nameBn: nameBn,
      nameEn: nameEn,
      colorIndex: colorIndex,
      rotation: rotation,
      sortOrder: _nextSortOrder(existing),
    );
    final invalid = DutyGroupValidator.validate(group);
    if (invalid != null) return Failure<DutyGroup>(invalid);

    final written = await _groups.save(
      familyId,
      group,
      AuditEvent(
        id: _newId(),
        type: AuditEventType.choresDutyGroupCreated,
        actorId: actorUid,
        refType: AuditRefType.dutyGroup,
        refId: group.id,
        at: _clock.nowUtc(),
        params: <String, String>{'name': group.nameBn},
      ),
    );
    final writeFailure = written.failureOrNull;
    if (writeFailure != null) return Failure<DutyGroup>(writeFailure);
    return Success<DutyGroup>(group);
  }

  static int _nextSortOrder(List<DutyGroup> groups) {
    var max = -1;
    for (final group in groups) {
      if (group.sortOrder > max) max = group.sortOrder;
    }
    return max + 1;
  }
}
