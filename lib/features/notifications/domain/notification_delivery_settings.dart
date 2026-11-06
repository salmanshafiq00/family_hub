import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/notifications/domain/delivery_policy.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';

final class NotificationDeliverySettings {
  NotificationDeliverySettings({
    this.pushEnabled = false,
    Map<String, DeliveryMode> modes = const <String, DeliveryMode>{},
    this.quietRespectedByPush = true,
  }) : modes = Map<String, DeliveryMode>.unmodifiable(modes);

  final bool pushEnabled;
  final Map<String, DeliveryMode> modes;
  final bool quietRespectedByPush;

  static NotificationDeliverySettings defaults() =>
      NotificationDeliverySettings(
        modes: <String, DeliveryMode>{
          for (final type in NotificationTypes.all)
            if (type.pushCapable) type.id: type.recommendedMode,
        },
      );

  DeliveryPolicySettings toPolicySettings() =>
      DeliveryPolicySettings(pushEnabled: pushEnabled, modes: modes);

  NotificationDeliverySettings copyWith({
    bool? pushEnabled,
    Map<String, DeliveryMode>? modes,
    bool? quietRespectedByPush,
  }) => NotificationDeliverySettings(
    pushEnabled: pushEnabled ?? this.pushEnabled,
    modes: modes ?? this.modes,
    quietRespectedByPush: quietRespectedByPush ?? this.quietRespectedByPush,
  );

  @override
  bool operator ==(Object other) =>
      other is NotificationDeliverySettings &&
      other.pushEnabled == pushEnabled &&
      other.quietRespectedByPush == quietRespectedByPush &&
      other.modes.length == modes.length &&
      modes.entries.every((entry) => other.modes[entry.key] == entry.value);

  @override
  int get hashCode => Object.hash(
    pushEnabled,
    quietRespectedByPush,
    Object.hashAllUnordered(
      modes.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

abstract interface class NotificationDeliveryRepository {
  Stream<NotificationDeliverySettings> watch(String familyId);

  Future<Result<void>> save(
    String familyId,
    NotificationDeliverySettings settings,
    AuditEvent event,
  );
}
