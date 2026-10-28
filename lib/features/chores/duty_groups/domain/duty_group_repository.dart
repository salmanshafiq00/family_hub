import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';

/// Port for `dutyGroups/{id}`.
///
/// Two write methods because the two kinds of change have different offline
/// rules (road map 3.4): editing a name/colour may queue offline, while a
/// ROTATION change is an integrity write that must reach the server before it
/// is reported as done — two devices appending versions while offline would
/// silently produce divergent rotas.
abstract interface class DutyGroupRepository {
  /// Live groups in `sortOrder` order, bounded by [DutyGroupLimits.maxGroups].
  Stream<List<DutyGroup>> watch(String familyId);

  /// One-shot read (for `sortOrder = max + 1` and the use cases).
  Future<Result<List<DutyGroup>>> list(String familyId);

  Future<Result<DutyGroup?>> get(String familyId, String groupId);

  /// Creates or updates a group and writes [event] in the same batch.
  Future<Result<void>> save(String familyId, DutyGroup group, AuditEvent event);

  /// Same document and audit in one batch, but SERVER REQUIRED (road map 3.4).
  Future<Result<void>> saveRotation(
    String familyId,
    DutyGroup group,
    AuditEvent event,
  );
}
