import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

const String _probeId = 'zprobe';

/// TEMPORARY diagnosis, debug builds only. Delete this file and its call in
/// `FirestoreStarterItemRepository.replaceAll` once Customise works.
///
/// It asks the REAL rules, one question at a time, why a starter item was
/// refused, and prints the answers as `STARTER_PROBE ...` lines:
///  1. who the server thinks the caller is (project, token claim, member doc);
///  2. whether a `starterPackItems` rule exists and lets this caller delete
///     (a delete of a missing document is judged by the rules all the same);
///  3. which GROUP of the real item's fields makes a write fail, by replacing
///     one group of fields at a time with neutral values.
/// Every probe document is deleted again.
Future<void> debugProbeStarterWrite({
  required FirebaseFirestore db,
  required String familyId,
  required Map<String, dynamic> sample,
}) async {
  if (!kDebugMode) return;
  try {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdTokenResult(true);
    debugPrint(
      'STARTER_PROBE project=${Firebase.app().options.projectId} '
      'uid=${user?.uid} claim=${token?.claims?['email_verified']}',
    );
    final uid = user?.uid;
    if (uid == null) return;
    final ref = db.doc(FirestorePaths.starterPackItemDoc(familyId, _probeId));

    debugPrint('STARTER_PROBE delete ${await _try(ref.delete)}');

    // Start from the REAL item and swap ONE group of fields for neutral
    // values at a time: the variant that is accepted names the culprit group.
    // (The rules read some keys directly, e.g. `d.subtasks.size()`, so no
    // variant may drop a key.)
    final neutral = <String, Map<String, dynamic>>{
      'names': <String, dynamic>{'nameBn': 'probe', 'nameEn': null},
      'group+icon+colour': <String, dynamic>{
        'groupId': null,
        'iconKey': null,
        'colorIndex': null,
      },
      'instructions': <String, dynamic>{'instructions': ''},
      'subtasks': <String, dynamic>{'subtasks': <Object?>[]},
      'slots': <String, dynamic>{
        'slots': <Map<String, dynamic>>[
          <String, dynamic>{'key': 'main'},
        ],
      },
      'assignee+reminders': <String, dynamic>{
        'assignee': <String, dynamic>{'strategy': 'manual'},
        'reminders': <String, dynamic>{},
        'difficulty': 'normal',
        'verification': 'off',
      },
      'flags': <String, dynamic>{
        'estimatedMinutes': null,
        'endDate': null,
        'active': true,
        'archivedAt': null,
        'sortOrder': 0,
        'builtIn': false,
        'seedKey': null,
      },
      'recurrence+date': <String, dynamic>{
        'recurrence': <String, dynamic>{'kind': 'daily'},
        'startDate': '2000-01-01',
      },
      'meta': <String, dynamic>{
        'createdBy': uid,
        'updatedBy': uid,
        'schemaVersion': 1,
        'deletedAt': null,
        'deletedBy': null,
      },
    };
    final full = await _try(() => ref.set(sample));
    debugPrint('STARTER_PROBE FULL real item $full');
    await _try(ref.delete);
    for (final entry in neutral.entries) {
      final data = <String, dynamic>{...sample, ...entry.value};
      debugPrint(
        'STARTER_PROBE neutral ${entry.key} -> ${await _try(() => ref.set(data))}',
      );
      await _try(ref.delete);
    }
    final all = <String, dynamic>{
      ...sample,
      for (final group in neutral.values) ...group,
    };
    debugPrint(
      'STARTER_PROBE ALL neutral -> ${await _try(() => ref.set(all))}',
    );
    await _try(ref.delete);
    debugPrint('STARTER_PROBE createdBy=${sample['createdBy']} uid=$uid');
    debugPrint('STARTER_PROBE keys=${sample.keys.toList()..sort()}');
  } on Object catch (error) {
    debugPrint('STARTER_PROBE failed: $error');
  }
}

Future<String> _try(Future<void> Function() write) async {
  try {
    await write().timeout(const Duration(seconds: 10));
    return 'OK';
  } on FirebaseException catch (error) {
    return 'REFUSED(${error.code})';
  } on Object catch (error) {
    return 'ERROR($error)';
  }
}
