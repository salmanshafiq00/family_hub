import 'package:family_hub/core/notifications/domain/delivery_policy.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/presentation/notification_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fresh family policy resolves a push-capable type to masterOff', () {
    final container = ProviderContainer(
      overrides: [
        currentFamilyIdProvider.overrideWithValue(null),
        currentUidProvider.overrideWithValue(null),
        memberNotificationPrefsStoreProvider.overrideWithValue(_Store()),
      ],
    );
    addTearDown(container.dispose);

    final result = container.read(effectiveModeProvider('swap_request'));

    expect(
      result.value,
      const EffectiveDelivery(
        mode: DeliveryMode.normal,
        reason: DeliveryReason.masterOff,
      ),
    );
  });
}

final class _Store implements MemberNotificationPrefsStore {
  @override
  MemberNotificationPrefs load(String uid) => MemberNotificationPrefs.defaults;

  @override
  Future<Result<void>> save(String uid, MemberNotificationPrefs prefs) =>
      throw UnimplementedError();
}
