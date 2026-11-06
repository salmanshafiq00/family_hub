import 'package:family_hub/core/notifications/domain/notification_type.dart';

enum DeliveryReason {
  pushChosen,
  normalChosen,
  masterOff,
  notPushCapable,
  backendUnavailable,
  noPermission,
  noToken,
  memberOptedOut,
}

final class DeliveryCapability {
  const DeliveryCapability({
    required this.tokenRegistered,
    required this.osPermissionGranted,
    required this.memberPushEnabled,
    this.backendAvailable = true,
  });

  final bool tokenRegistered;
  final bool osPermissionGranted;
  final bool memberPushEnabled;
  final bool backendAvailable;

  DeliveryCapability copyWith({
    bool? tokenRegistered,
    bool? osPermissionGranted,
    bool? memberPushEnabled,
    bool? backendAvailable,
  }) => DeliveryCapability(
    tokenRegistered: tokenRegistered ?? this.tokenRegistered,
    osPermissionGranted: osPermissionGranted ?? this.osPermissionGranted,
    memberPushEnabled: memberPushEnabled ?? this.memberPushEnabled,
    backendAvailable: backendAvailable ?? this.backendAvailable,
  );

  @override
  bool operator ==(Object other) =>
      other is DeliveryCapability &&
      other.tokenRegistered == tokenRegistered &&
      other.osPermissionGranted == osPermissionGranted &&
      other.memberPushEnabled == memberPushEnabled &&
      other.backendAvailable == backendAvailable;

  @override
  int get hashCode => Object.hash(
    tokenRegistered,
    osPermissionGranted,
    memberPushEnabled,
    backendAvailable,
  );
}

final class DeliveryPolicySettings {
  DeliveryPolicySettings({
    required this.pushEnabled,
    required Map<String, DeliveryMode> modes,
  }) : modes = _validatedModes(modes);

  final bool pushEnabled;
  final Map<String, DeliveryMode> modes;

  static DeliveryPolicySettings defaults() => DeliveryPolicySettings(
    pushEnabled: false,
    modes: <String, DeliveryMode>{
      for (final type in NotificationTypes.all)
        type.id: type.recommendedMode,
    },
  );

  static Map<String, DeliveryMode> _validatedModes(
    Map<String, DeliveryMode> modes,
  ) {
    final validModes = <String, DeliveryMode>{};
    for (final entry in modes.entries) {
      final type = NotificationTypes.byId(entry.key);
      if (type == null) continue;
      if (!type.pushCapable && entry.value == DeliveryMode.push) continue;
      validModes[entry.key] = entry.value;
    }
    return Map<String, DeliveryMode>.unmodifiable(validModes);
  }

  DeliveryMode modeFor(NotificationType type) =>
      type.userMutable
      ? modes[type.id] ?? type.recommendedMode
      : type.recommendedMode;

  DeliveryPolicySettings copyWith({
    bool? pushEnabled,
    Map<String, DeliveryMode>? modes,
  }) => DeliveryPolicySettings(
    pushEnabled: pushEnabled ?? this.pushEnabled,
    modes: modes ?? this.modes,
  );

  @override
  bool operator ==(Object other) =>
      other is DeliveryPolicySettings &&
      other.pushEnabled == pushEnabled &&
      other.modes.length == modes.length &&
      modes.entries.every((entry) => other.modes[entry.key] == entry.value);

  @override
  int get hashCode => Object.hash(
    pushEnabled,
    Object.hashAllUnordered(
      modes.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}

final class EffectiveDelivery {
  const EffectiveDelivery({required this.mode, required this.reason});

  final DeliveryMode mode;
  final DeliveryReason reason;

  EffectiveDelivery copyWith({DeliveryMode? mode, DeliveryReason? reason}) =>
      EffectiveDelivery(
        mode: mode ?? this.mode,
        reason: reason ?? this.reason,
      );

  @override
  bool operator ==(Object other) =>
      other is EffectiveDelivery &&
      other.mode == mode &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(mode, reason);
}

abstract final class DeliveryPolicy {
  static EffectiveDelivery effective({
    required NotificationType type,
    required DeliveryPolicySettings settings,
    required DeliveryCapability capability,
  }) {
    if (!type.pushCapable) {
      return const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.notPushCapable,
      );
    }

    if (settings.modeFor(type) != DeliveryMode.push) {
      return const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.normalChosen,
      );
    }

    if (!settings.pushEnabled) {
      return const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.masterOff,
      );
    }
    if (!capability.backendAvailable) {
      return const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.backendUnavailable,
      );
    }
    if (!capability.memberPushEnabled) {
      return const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.memberOptedOut,
      );
    }
    if (!capability.osPermissionGranted) {
      return const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.noPermission,
      );
    }
    if (!capability.tokenRegistered) {
      return const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.noToken,
      );
    }

    return const EffectiveDelivery(
      mode: DeliveryMode.push,
      reason: DeliveryReason.pushChosen,
    );
  }
}
