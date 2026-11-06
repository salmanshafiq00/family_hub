import 'dart:convert';

import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/notifications/data/notification_defaults_mappers.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class LocalNotificationPrefsStore
    implements MemberNotificationPrefsStore {
  const LocalNotificationPrefsStore(this._preferences);

  final SharedPreferences _preferences;

  String _key(String uid) => 'notification_prefs_$uid';

  @override
  MemberNotificationPrefs load(String uid) {
    final encoded = _preferences.getString(_key(uid));
    if (encoded == null) return MemberNotificationPrefs.defaults;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        return MemberNotificationPrefs.defaults;
      }
      return NotificationDefaultsMappers.memberPrefsFromMap(decoded);
    } on FormatException {
      return MemberNotificationPrefs.defaults;
    }
  }

  @override
  Future<Result<void>> save(String uid, MemberNotificationPrefs prefs) async {
    try {
      final saved = await _preferences.setString(
        _key(uid),
        jsonEncode(NotificationDefaultsMappers.memberPrefsToMap(prefs)),
      );
      return saved
          ? const Success<void>(null)
          : Failure<void>(
              Unknown(
                StateError('Notification preferences were not saved locally.'),
              ),
            );
    } on Exception catch (error) {
      return Failure<void>(Unknown(error));
    }
  }
}
