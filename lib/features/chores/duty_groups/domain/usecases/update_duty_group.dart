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
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Edits the parts of a duty group that are NOT its rotation: name, colour,
/// order and the active switch (P3-09).
///
/// The rotation changes only through [ChangeRotation], so this use case can
/// never move somebody's turn by accident. An EVERYDAY write (no server probe).
class UpdateDutyGroup {
  const UpdateDutyGroup({
    required this._groups,
    required this._families,
    required this._clock,
    required this._newId,
  });

  final DutyGroupRepository _groups;
  final FamilyRepository _families;
  final Clock _clock;
  final IdGenerator _newId;

  /// [nameEn] and [colorIndex] are the editor's whole value: null clears them.
  Future<Result<DutyGroup>> call({
    required String actorUid,
    required String familyId,
    required String groupId,
    required String nameBn,
    String? nameEn,
    int? colorIndex,
    bool? active,
    int? sortOrder,
  }) async {
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.manageChoreTemplates,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<DutyGroup>(denied);

    final found = await _groups.get(familyId, groupId);
    final readFailure = found.failureOrNull;
    if (readFailure != null) return Failure<DutyGroup>(readFailure);
    final current = found.valueOrNull;
    if (current == null) {
      return const Failure<DutyGroup>(NotFound(entity: 'dutyGroup'));
    }

    final updated = DutyGroup(
      id: current.id,
      nameBn: nameBn,
      nameEn: nameEn,
      colorIndex: colorIndex,
      rotation: current.rotation,
      active: active ?? current.active,
      sortOrder: sortOrder ?? current.sortOrder,
    );
    final invalid = DutyGroupValidator.validate(updated);
    if (invalid != null) return Failure<DutyGroup>(invalid);

    final written = await _groups.save(
      familyId,
      updated,
      AuditEvent(
        id: _newId(),
        type: AuditEventType.choresDutyGroupUpdated,
        actorId: actorUid,
        refType: AuditRefType.dutyGroup,
        refId: updated.id,
        at: _clock.nowUtc(),
        params: <String, String>{'name': updated.nameBn},
      ),
    );
    final writeFailure = written.failureOrNull;
    if (writeFailure != null) return Failure<DutyGroup>(writeFailure);
    return Success<DutyGroup>(updated);
  }
}
