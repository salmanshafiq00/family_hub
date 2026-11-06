import 'package:family_hub/features/notifications/data/local_notification_prefs_store.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('local notification preferences are stored per user', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final store = LocalNotificationPrefsStore(preferences);
    final saved = MemberNotificationPrefs(pushEnabled: false);

    expect(store.load('alice'), MemberNotificationPrefs.defaults);
    expect((await store.save('alice', saved)).isSuccess, isTrue);
    expect(store.load('alice'), saved);
    expect(store.load('bob'), MemberNotificationPrefs.defaults);
  });
}
