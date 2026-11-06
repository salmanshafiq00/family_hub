import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/features/notifications/data/notification_defaults_mappers.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';

final class FirestoreNotificationPrefSync
    implements NotificationPreferenceSync {
  FirestoreNotificationPrefSync({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  @override
  Future<Result<void>> push(String uid, MemberNotificationPrefs prefs) {
    if (_auth.currentUser?.uid != uid) {
      return Future<Result<void>>.value(const Failure<void>(NoCurrentUser()));
    }
    final notifications = <String, Object>{
      ...NotificationDefaultsMappers.memberPrefsToMap(prefs),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    return guardWrite(
      () => _db.doc(FirestorePaths.userDoc(uid)).set(
        <String, Object>{
          'preferences': <String, Object>{'notifications': notifications},
        },
        SetOptions(
          mergeFields: <Object>[
            FieldPath(const <String>['preferences', 'notifications']),
          ],
        ),
      ),
    );
  }
}
