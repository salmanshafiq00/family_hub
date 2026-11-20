import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/features/notifications/data/inbox_mappers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_repository.dart';

/// Firestore implementation of [InboxRepository]: ONE listener on the member's
/// own newest [kMaxInboxDocs] rows (the `(toMemberId, createdAt desc)` index).
/// Marking read or archiving is an EVERYDAY batch (queues offline).
class FirestoreInboxRepository implements InboxRepository {
  FirestoreInboxRepository({required this._tx, this._firestore});

  final TxRunner _tx;
  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<InboxItem>> watchMine(String familyId, String memberId) => _db
      .collection(FirestorePaths.inbox(familyId))
      .where('toMemberId', isEqualTo: memberId)
      .orderBy(BaseMapper.keyCreatedAt, descending: true)
      .limit(kMaxInboxDocs)
      .snapshots()
      .map(
        (s) => <InboxItem>[
          for (final doc in s.docs) ?InboxMappers.fromDoc(doc.id, doc.data()),
        ],
      );

  @override
  Future<Result<InboxItem?>> get(String familyId, String itemId) =>
      guardFirestore(() async {
        final doc = await _db
            .doc(FirestorePaths.inboxDoc(familyId, itemId))
            .get();
        return InboxMappers.fromDoc(doc.id, doc.data());
      });

  @override
  Future<Result<void>> markRead(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  }) => guardWrite(
    () => _tx.runBatch((batch) {
      for (final id in ids) {
        batch.update(
          FirestorePaths.inboxDoc(familyId, id),
          InboxMappers.readMap(actorId: actorId, at: at),
        );
      }
    }),
  );

  @override
  Future<Result<void>> archive(
    String familyId, {
    required String actorId,
    required String id,
    required DateTime at,
  }) => guardWrite(
    () => _tx.runBatch(
      (batch) => batch.update(
        FirestorePaths.inboxDoc(familyId, id),
        InboxMappers.archiveMap(actorId: actorId, at: at),
      ),
    ),
  );

  @override
  Future<Result<void>> archiveAll(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  }) => guardWrite(
    () => _tx.runBatch((batch) {
      for (final id in ids) {
        batch.update(
          FirestorePaths.inboxDoc(familyId, id),
          InboxMappers.archiveMap(actorId: actorId, at: at),
        );
      }
    }),
  );
}
