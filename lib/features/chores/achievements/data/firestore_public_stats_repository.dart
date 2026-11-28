import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/firebase/doc_watch.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/features/chores/achievements/data/public_stats_mappers.dart';
import 'package:family_hub/features/chores/achievements/domain/public_stats.dart';
import 'package:family_hub/features/chores/achievements/domain/public_stats_repository.dart';

final class FirestorePublicStatsRepository implements PublicStatsRepository {
  FirestorePublicStatsRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  @override
  Stream<PublicStats?> watch(String familyId, String memberId) =>
      watchKnownDoc(
        _db.doc(FirestorePaths.memberStatsPublicDoc(familyId, memberId)),
      ).map(PublicStatsMappers.fromMap).handleError((Object error) {
        if (error is FirebaseException && error.code == 'permission-denied') {
          return;
        }
        if (error is PermissionDenied) {
          return;
        }
        throw error;
      }).distinct();

  @override
  Stream<Map<String, PublicStats>> watchFamily(String familyId) => _db
      .collection(FirestorePaths.memberStatsPublicCollection(familyId))
      .limit(kMaxListenerDocs)
      .snapshots()
      .map((snapshot) {
        final result = <String, PublicStats>{};
        for (final document in snapshot.docs) {
          final stats = PublicStatsMappers.fromMap(document.data());
          if (stats != null) result[document.id] = stats;
        }
        return Map<String, PublicStats>.unmodifiable(result);
      })
      .handleError((Object error) {
        if (error is FirebaseException && error.code == 'permission-denied') {
          return;
        }
        if (error is PermissionDenied) {
          return;
        }
        throw error;
      });

  @override
  Future<Result<PublicStats?>> get(String familyId, String memberId) async {
    final loaded = await guardFirestore(
      () => _db
          .doc(FirestorePaths.memberStatsPublicDoc(familyId, memberId))
          .get(),
    );
    final failure = loaded.failureOrNull;
    if (failure != null) {
      if (failure is PermissionDenied) {
        return const Success<PublicStats?>(null);
      }
      return Failure<PublicStats?>(failure);
    }
    final snapshot = loaded.valueOrNull!;
    if (!snapshot.exists && snapshot.metadata.isFromCache) {
      return const Failure<PublicStats?>(Network());
    }
    return Success<PublicStats?>(PublicStatsMappers.fromMap(snapshot.data()));
  }
}
