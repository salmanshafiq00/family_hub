import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/firebase/audit_writer.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_repository.dart';
import 'package:family_hub/features/chores/templates/data/chore_template_mappers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';

/// Firestore implementation of [StarterItemRepository]
/// (`families/{f}/starterPackItems/{seedKey}`).
///
/// An item is a chore-template document, so [ChoreTemplateMappers] writes and
/// reads it. The list query is a single-field `orderBy sortOrder` bounded by
/// [kMaxStarterItems]: no composite index, and every read has a limit.
class FirestoreStarterItemRepository implements StarterItemRepository {
  FirestoreStarterItemRepository({
    required this._tx,
    required this._clock,
    this._firestore,
  });

  final TxRunner _tx;
  final Clock _clock;
  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Query<Map<String, dynamic>> _query(String familyId) => _db
      .collection(FirestorePaths.starterPackItems(familyId))
      .orderBy('sortOrder')
      .limit(kMaxStarterItems);

  @override
  Stream<List<TemplateRecord>> watch(String familyId) =>
      _query(familyId).snapshots().map(_toRecords);

  @override
  Future<Result<List<TemplateRecord>>> list(String familyId) =>
      guardFirestore(() async => _toRecords(await _query(familyId).get()));

  @override
  Future<Result<void>> save(
    String familyId,
    ChoreTemplate item,
    AuditEvent event,
  ) => guardWrite(() async {
    final path = FirestorePaths.starterPackItemDoc(familyId, item.id);
    final snapshot = await _db.doc(path).get();
    final current = snapshot.exists
        ? BaseMapper.metadataFromMap(snapshot.data() ?? <String, dynamic>{})
        : BaseMapper.createMetadata(uid: event.actorId, clock: _clock);
    final metadata = current.copyWith(
      updatedAt: event.at,
      updatedBy: event.actorId,
    );
    await _tx.runBatch((batch) {
      batch.set(path, ChoreTemplateMappers.toMap(item, metadata));
      AuditWriter.write(batch, familyId, event);
    });
  });

  @override
  Future<Result<void>> delete(
    String familyId,
    String itemId,
    AuditEvent event,
  ) => guardWrite(() async {
    await _tx.runBatch((batch) {
      batch.delete(FirestorePaths.starterPackItemDoc(familyId, itemId));
      AuditWriter.write(batch, familyId, event);
    });
  });

  @override
  Future<Result<void>> replaceAll(
    String familyId, {
    required List<ChoreTemplate> items,
    required List<String> removeIds,
    required AuditEvent event,
  }) => guardWrite(() async {
    final metadata = BaseMapper.createMetadata(
      uid: event.actorId,
      clock: _clock,
    ).copyWith(updatedAt: event.at, updatedBy: event.actorId);
    await _tx.runBatch((batch) {
      for (final id in removeIds) {
        batch.delete(FirestorePaths.starterPackItemDoc(familyId, id));
      }
      for (final item in items) {
        batch.set(
          FirestorePaths.starterPackItemDoc(familyId, item.id),
          ChoreTemplateMappers.toMap(item, metadata),
        );
      }
      AuditWriter.write(batch, familyId, event);
    });
  });

  static List<TemplateRecord> _toRecords(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => <TemplateRecord>[
    for (final doc in snapshot.docs)
      ?ChoreTemplateMappers.fromDoc(doc.id, doc.data()),
  ];
}
