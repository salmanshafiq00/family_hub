import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/notifications/domain/delivery_policy.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:family_hub/features/notifications/domain/usecases/save_member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/usecases/update_notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/usecases/update_notification_delivery.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationDeliveryRepositoryProvider =
    Provider<NotificationDeliveryRepository>(
      (ref) => throw UnimplementedError(
        'notificationDeliveryRepositoryProvider must be overridden in bootstrap.dart.',
      ),
    );

final notificationDefaultsRepositoryProvider =
    Provider<NotificationDefaultsRepository>(
      (ref) => throw UnimplementedError(
        'notificationDefaultsRepositoryProvider must be overridden in bootstrap.dart.',
      ),
    );

final memberNotificationPrefsStoreProvider =
    Provider<MemberNotificationPrefsStore>(
      (ref) => throw UnimplementedError(
        'memberNotificationPrefsStoreProvider must be overridden in bootstrap.dart.',
      ),
    );

final notificationPreferenceSyncProvider = Provider<NotificationPreferenceSync>(
  (ref) => throw UnimplementedError(
    'notificationPreferenceSyncProvider must be overridden in bootstrap.dart.',
  ),
);

final deliveryPolicyProvider = StreamProvider.autoDispose
    .family<NotificationDeliverySettings, String>(
      (ref, familyId) =>
          ref.watch(notificationDeliveryRepositoryProvider).watch(familyId),
    );

final familyDefaultsProvider = StreamProvider.autoDispose
    .family<NotificationDefaults, String>(
      (ref, familyId) =>
          ref.watch(notificationDefaultsRepositoryProvider).watch(familyId),
    );

final updateNotificationDeliveryProvider = Provider<UpdateNotificationDelivery>(
  (ref) => UpdateNotificationDelivery(
    families: ref.watch(familyRepositoryProvider),
    repository: ref.watch(notificationDeliveryRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

final updateNotificationDefaultsProvider = Provider<UpdateNotificationDefaults>(
  (ref) => UpdateNotificationDefaults(
    families: ref.watch(familyRepositoryProvider),
    repository: ref.watch(notificationDefaultsRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

final saveMemberNotificationPrefsProvider =
    Provider<SaveMemberNotificationPrefs>(
      (ref) => SaveMemberNotificationPrefs(
        store: ref.watch(memberNotificationPrefsStoreProvider),
        sync: ref.watch(notificationPreferenceSyncProvider),
      ),
    );

final memberPrefsProvider =
    NotifierProvider<
      MemberNotificationPrefsController,
      MemberNotificationPrefs
    >(MemberNotificationPrefsController.new);

final reminderSettingsProvider = Provider<AsyncValue<ReminderSettings>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  final prefs = ref.watch(memberPrefsProvider);
  if (familyId == null) {
    return AsyncData<ReminderSettings>(
      prefs.resolve(NotificationDefaults.defaults),
    );
  }
  return ref
      .watch(familyDefaultsProvider(familyId))
      .whenData((defaults) => prefs.resolve(defaults));
});

final notificationDeliveryCapabilityProvider = Provider<DeliveryCapability>(
  (ref) => DeliveryCapability(
    tokenRegistered: false,
    osPermissionGranted: false,
    memberPushEnabled: ref.watch(memberPrefsProvider).pushEnabled,
  ),
);

final effectiveModeProvider =
    Provider.family<AsyncValue<EffectiveDelivery>, String>((ref, typeId) {
      final type = NotificationTypes.byId(typeId);
      if (type == null) {
        return const AsyncData<EffectiveDelivery>(
          EffectiveDelivery(
            mode: DeliveryMode.normal,
            reason: DeliveryReason.notPushCapable,
          ),
        );
      }

      final familyId = ref.watch(currentFamilyIdProvider);
      if (familyId == null) {
        return AsyncData<EffectiveDelivery>(
          DeliveryPolicy.effective(
            type: type,
            settings: NotificationDeliverySettings.defaults()
                .toPolicySettings(),
            capability: ref.watch(notificationDeliveryCapabilityProvider),
          ),
        );
      }
      final capability = ref.watch(notificationDeliveryCapabilityProvider);
      return ref
          .watch(deliveryPolicyProvider(familyId))
          .whenData(
            (settings) => DeliveryPolicy.effective(
              type: type,
              settings: settings.toPolicySettings(),
              capability: capability,
            ),
          );
    });

class MemberNotificationPrefsController
    extends Notifier<MemberNotificationPrefs> {
  @override
  MemberNotificationPrefs build() {
    final uid = ref.watch(currentUidProvider);
    return uid == null
        ? MemberNotificationPrefs.defaults
        : ref.watch(memberNotificationPrefsStoreProvider).load(uid);
  }

  Future<Result<void>> save({
    required MemberNotificationPrefs prefs,
    required NotificationDefaults familyDefaults,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return const Failure<void>(NoCurrentUser());

    state = prefs;
    final result = await ref
        .read(saveMemberNotificationPrefsProvider)
        .call(uid: uid, prefs: prefs, familyDefaults: familyDefaults);
    state = ref.read(memberNotificationPrefsStoreProvider).load(uid);
    return result;
  }
}
