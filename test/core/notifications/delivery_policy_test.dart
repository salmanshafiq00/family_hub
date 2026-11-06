import 'package:family_hub/core/notifications/domain/delivery_policy.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ready = DeliveryCapability(
    tokenRegistered: true,
    osPermissionGranted: true,
    memberPushEnabled: true,
  );
  const noBackend = DeliveryCapability(
    tokenRegistered: true,
    osPermissionGranted: true,
    memberPushEnabled: true,
    backendAvailable: false,
  );
  const optedOut = DeliveryCapability(
    tokenRegistered: true,
    osPermissionGranted: true,
    memberPushEnabled: false,
  );
  const noPermission = DeliveryCapability(
    tokenRegistered: true,
    osPermissionGranted: false,
    memberPushEnabled: true,
  );
  const noToken = DeliveryCapability(
    tokenRegistered: false,
    osPermissionGranted: true,
    memberPushEnabled: true,
  );
  const capabilities = <DeliveryCapability>[
    ready,
    noBackend,
    optedOut,
    noPermission,
    noToken,
  ];

  DeliveryPolicySettings settingsFor({
    required bool pushEnabled,
    required NotificationType type,
    required DeliveryMode mode,
  }) => DeliveryPolicySettings(
    pushEnabled: pushEnabled,
    modes: <String, DeliveryMode>{type.id: mode},
  );

  DeliveryReason expectedReason({
    required NotificationType type,
    required bool pushEnabled,
    required DeliveryMode chosenMode,
    required DeliveryCapability capability,
  }) {
    if (!type.pushCapable) return DeliveryReason.notPushCapable;
    if (chosenMode == DeliveryMode.normal) return DeliveryReason.normalChosen;
    if (!pushEnabled) return DeliveryReason.masterOff;
    if (!capability.backendAvailable) {
      return DeliveryReason.backendUnavailable;
    }
    if (!capability.memberPushEnabled) {
      return DeliveryReason.memberOptedOut;
    }
    if (!capability.osPermissionGranted) return DeliveryReason.noPermission;
    if (!capability.tokenRegistered) return DeliveryReason.noToken;
    return DeliveryReason.pushChosen;
  }

  test('defaults keep the master off and use recommended modes', () {
    final defaults = DeliveryPolicySettings.defaults();

    expect(defaults.pushEnabled, isFalse);
    expect(defaults.modes, hasLength(NotificationTypes.all.length));
    for (final type in NotificationTypes.all) {
      expect(defaults.modes[type.id], type.recommendedMode, reason: type.id);
    }
  });

  test('unknown ids and push settings for non-capable types are ignored', () {
    final settings = DeliveryPolicySettings(
      pushEnabled: true,
      modes: const <String, DeliveryMode>{
        'unknown_type': DeliveryMode.push,
        'chore_due': DeliveryMode.push,
      },
    );

    expect(settings.modes, isEmpty);
    final result = DeliveryPolicy.effective(
      type: NotificationTypes.byId('chore_due')!,
      settings: settings,
      capability: ready,
    );
    expect(result.mode, DeliveryMode.normal);
    expect(result.reason, DeliveryReason.notPushCapable);
  });

  test('effective mode and fallback reason cover every type and setting', () {
    for (final type in NotificationTypes.all) {
      for (final pushEnabled in <bool>[false, true]) {
        for (final chosenMode in DeliveryMode.values) {
          for (final capability in capabilities) {
            final result = DeliveryPolicy.effective(
              type: type,
              settings: settingsFor(
                pushEnabled: pushEnabled,
                type: type,
                mode: chosenMode,
              ),
              capability: capability,
            );
            final expected = expectedReason(
              type: type,
              pushEnabled: pushEnabled,
              chosenMode: chosenMode,
              capability: capability,
            );

            expect(result.reason, expected, reason: type.id);
            expect(
              result.mode,
              expected == DeliveryReason.pushChosen
                  ? DeliveryMode.push
                  : DeliveryMode.normal,
              reason: type.id,
            );
          }
        }
      }
    }
  });

  test('an omitted mode uses that type’s recommended mode', () {
    final settings = DeliveryPolicySettings(
      pushEnabled: false,
      modes: const <String, DeliveryMode>{},
    );
    final type = NotificationTypes.byId('swap_request')!;

    final result = DeliveryPolicy.effective(
      type: type,
      settings: settings,
      capability: ready,
    );

    expect(result.mode, DeliveryMode.normal);
    expect(result.reason, DeliveryReason.masterOff);
  });

  test('settings are immutable and equality is map-order independent', () {
    final source = <String, DeliveryMode>{
      'swap_request': DeliveryMode.push,
      'swap_result': DeliveryMode.normal,
    };
    final first = DeliveryPolicySettings(pushEnabled: true, modes: source);
    source['swap_request'] = DeliveryMode.normal;
    final second = DeliveryPolicySettings(
      pushEnabled: true,
      modes: const <String, DeliveryMode>{
        'swap_result': DeliveryMode.normal,
        'swap_request': DeliveryMode.push,
      },
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(
      () => first.modes['swap_request'] = DeliveryMode.normal,
      throwsUnsupportedError,
    );
    expect(first.copyWith(), first);
  });

  test('capability and result value objects support equality and copyWith', () {
    expect(ready.copyWith(), ready);
    expect(ready.copyWith(tokenRegistered: false), isNot(ready));
    expect(
      ready.copyWith(tokenRegistered: false).hashCode,
      isNot(ready.hashCode),
    );

    const result = EffectiveDelivery(
      mode: DeliveryMode.push,
      reason: DeliveryReason.pushChosen,
    );
    expect(result.copyWith(), result);
    expect(result.copyWith(mode: DeliveryMode.normal), isNot(result));
  });
}
