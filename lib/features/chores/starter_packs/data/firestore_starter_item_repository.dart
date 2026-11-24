import 'dart:math' as math;

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
import 'package:family_hub/features/chores/starter_packs/data/starter_write_probe.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_repository.dart';
import 'package:family_hub/features/chores/templates/data/chore_template_mappers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:flutter/foundation.dart';

/// How many starter items one commit may carry. Firestore stops a request that
/// makes the rules evaluate more than 1,000 expressions and answers
/// PERMISSION_DENIED. One fully filled-in item already costs the rules several
/// hundred (see `templateOk` in firestore.rules), so ONE item per commit is the
/// only size with a safe margin.
const int kStarterWriteChunk = 1;

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

  /// Writes [items] and removes [removeIds].
  ///
  /// NOT one batch. The rules check every item with `templateOk`, which costs
  /// well over a hundred rule expressions, and Firestore refuses a request that
  /// evaluates more than 1,000 of them - answering PERMISSION_DENIED, which the
  /// app shows as "you do not have permission" even for an admin. Seventeen
  /// items in one batch can never fit, so the items go in chunks of
  /// [kStarterWriteChunk]; the removals and the audit entry follow in a last,
  /// small batch, so the log only says "updated" once the data is written.
  ///
  /// If a later commit is refused, the items already written are deleted again
  /// (best effort) so the family is not left with half a list, which the app
  /// would treat as "customised".
  @override
  Future<Result<void>> replaceAll(
    String familyId, {
    required List<ChoreTemplate> items,
    required List<String> removeIds,
    required AuditEvent event,
  }) async {
    final metadata = BaseMapper.createMetadata(
      uid: event.actorId,
      clock: _clock,
    ).copyWith(updatedAt: event.at, updatedBy: event.actorId);
    final written = <String>[];

    for (var i = 0; i < items.length; i += kStarterWriteChunk) {
      final chunk = items.sublist(
        i,
        math.min(i + kStarterWriteChunk, items.length),
      );
      final result = await guardWrite(
        () => _tx.runBatch((batch) {
          for (final item in chunk) {
            batch.set(
              FirestorePaths.starterPackItemDoc(familyId, item.id),
              ChoreTemplateMappers.toMap(item, metadata),
            );
          }
        }),
      );
      debugPrint(
        'STARTER_REPLACE chunk@$i of ${items.length} '
        'failure=${result.failureOrNull}',
      );
      if (result.failureOrNull != null) {
        if (i == 0) {
          await debugProbeStarterWrite(
            db: _db,
            familyId: familyId,
            sample: ChoreTemplateMappers.toMap(chunk.first, metadata),
          );
        }
        await _rollback(familyId, written);
        return result;
      }
      written.addAll(<String>[for (final item in chunk) item.id]);
    }

    final done = await guardWrite(
      () => _tx.runBatch((batch) {
        for (final id in removeIds) {
          batch.delete(FirestorePaths.starterPackItemDoc(familyId, id));
        }
        AuditWriter.write(batch, familyId, event);
      }),
    );
    debugPrint('STARTER_REPLACE audit failure=${done.failureOrNull}');
    if (done.failureOrNull != null) await _rollback(familyId, written);
    return done;
  }

  /// Deletes [ids] again after a failed [replaceAll]. Never throws: the caller
  /// already has the real failure to report.
  Future<void> _rollback(String familyId, List<String> ids) async {
    if (ids.isEmpty) return;
    await guardWrite(
      () => _tx.runBatch((batch) {
        for (final id in ids) {
          batch.delete(FirestorePaths.starterPackItemDoc(familyId, id));
        }
      }),
    );
  }

  static List<TemplateRecord> _toRecords(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => <TemplateRecord>[
    for (final doc in snapshot.docs)
      ?ChoreTemplateMappers.fromDoc(doc.id, doc.data()),
  ];
}
