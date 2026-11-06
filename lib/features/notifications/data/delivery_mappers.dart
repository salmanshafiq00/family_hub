import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';

abstract final class DeliveryMappers {
  static NotificationDeliverySettings fromMap(Map<String, dynamic>? map) {
    if (map == null) return NotificationDeliverySettings.defaults();
    final rawModes = map['modes'];
    final modes = <String, DeliveryMode>{};
    if (rawModes is Map) {
      for (final entry in rawModes.entries) {
        if (entry.key is! String || entry.value is! String) continue;
        final type = NotificationTypes.byId(entry.key as String);
        final mode = _mode(entry.value as String);
        if (type == null || !type.pushCapable || mode == null) continue;
        modes[type.id] = mode;
      }
    }

    return NotificationDeliverySettings(
      pushEnabled: map['pushEnabled'] is bool
          ? map['pushEnabled'] as bool
          : false,
      modes: rawModes is Map && (rawModes.isEmpty || modes.isNotEmpty)
          ? modes
          : NotificationDeliverySettings.defaults().modes,
      quietRespectedByPush: map['quietRespectedByPush'] is bool
          ? map['quietRespectedByPush'] as bool
          : true,
    );
  }

  static Map<String, dynamic> toMap(
    NotificationDeliverySettings settings,
    BaseDocumentMetadata metadata,
  ) => <String, dynamic>{
    'pushEnabled': settings.pushEnabled,
    'modes': <String, String>{
      for (final entry in settings.modes.entries) entry.key: entry.value.name,
    },
    'quietRespectedByPush': settings.quietRespectedByPush,
    ...BaseMapper.metadataToMap(metadata),
  };

  static DeliveryMode? _mode(String value) => switch (value) {
    'push' => DeliveryMode.push,
    'normal' => DeliveryMode.normal,
    _ => null,
  };
}
