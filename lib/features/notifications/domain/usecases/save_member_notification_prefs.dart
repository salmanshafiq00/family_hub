import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_settings_validator.dart';

final class SaveMemberNotificationPrefs {
  const SaveMemberNotificationPrefs({required this.store, required this.sync});

  final MemberNotificationPrefsStore store;
  final NotificationPreferenceSync sync;

  Future<Result<void>> call({
    required String uid,
    required MemberNotificationPrefs prefs,
    required NotificationDefaults familyDefaults,
  }) async {
    final invalid = NotificationSettingsValidator.memberPrefs(
      prefs,
      familyDefaults,
    );
    if (invalid != null) return Failure<void>(invalid);

    final local = await store.save(uid, prefs);
    final localFailure = local.failureOrNull;
    if (localFailure != null) return Failure<void>(localFailure);
    return sync.push(uid, prefs);
  }
}
