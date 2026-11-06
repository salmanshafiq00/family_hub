import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/usecases/save_member_notification_prefs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('saves locally before mirroring preferences remotely', () async {
    final store = _Store();
    final sync = _Sync(store);
    final useCase = SaveMemberNotificationPrefs(store: store, sync: sync);
    final prefs = MemberNotificationPrefs(pushEnabled: false);

    final result = await useCase.call(
      uid: 'alice',
      prefs: prefs,
      familyDefaults: NotificationDefaults.defaults,
    );

    expect(result.isSuccess, isTrue);
    expect(sync.observedLocalPrefs, prefs);
    expect(store.value, prefs);
  });
}

final class _Store implements MemberNotificationPrefsStore {
  MemberNotificationPrefs value = MemberNotificationPrefs.defaults;

  @override
  MemberNotificationPrefs load(String uid) => value;

  @override
  Future<Result<void>> save(String uid, MemberNotificationPrefs prefs) async {
    value = prefs;
    return const Success<void>(null);
  }
}

final class _Sync implements NotificationPreferenceSync {
  _Sync(this.store);

  final _Store store;
  MemberNotificationPrefs? observedLocalPrefs;

  @override
  Future<Result<void>> push(String uid, MemberNotificationPrefs prefs) async {
    observedLocalPrefs = store.load(uid);
    return const Success<void>(null);
  }
}
