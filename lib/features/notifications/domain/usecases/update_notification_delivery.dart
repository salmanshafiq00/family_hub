import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:family_hub/features/notifications/domain/notification_settings_validator.dart';

final class UpdateNotificationDelivery {
  const UpdateNotificationDelivery({
    required this.families,
    required this.repository,
    required this.clock,
    required this.newId,
  });

  final FamilyRepository families;
  final NotificationDeliveryRepository repository;
  final Clock clock;
  final IdGenerator newId;

  Future<Result<void>> call({
    required String actorUid,
    required String familyId,
    required NotificationDeliverySettings settings,
  }) async {
    final permission = await requirePermission(
      families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.editFamilySettings,
    );
    final denied = permission.failureOrNull;
    if (denied != null) return Failure<void>(denied);

    final invalid = NotificationSettingsValidator.delivery(settings);
    if (invalid != null) return Failure<void>(invalid);

    return repository.save(
      familyId,
      settings,
      AuditEvent(
        id: newId(),
        type: AuditEventType.familyNotificationDeliveryUpdated,
        actorId: actorUid,
        refType: AuditRefType.notificationSettings,
        refId: familyId,
        at: clock.nowUtc(),
      ),
    );
  }
}
