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
import 'package:family_hub/features/chores/templates/data/chore_template_mappers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';

/// Firestore implementation of [TemplateRepository] (`choreTemplates`).
///
/// The list query is a single-field `orderBy sortOrder` on a family-scoped
/// collection, so it needs no composite index. It is bounded by
/// [kMaxChoreTemplates] (C-2 discipline: every collection read has a limit);
/// a family past that is already far outside the design.
///
/// Writes are EVERYDAY (batch, no probe): creating a chore while offline must
/// work and sync later, and the rules - not a server round trip - guarantee the
/// shape and the `revision`/`seedKey` invariants.
class FirestoreChoreTemplateRepository implements TemplateRepository {
  FirestoreChoreTemplateRepository({
    required this._tx,
    required this._clock,
    this._firestore,
  });

  final TxRunner _tx;
  final Clock _clock;
  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  /// The one bounded query both readers use: orderBy sortOrder is a
  /// single-field order on a family-scoped collection, so it needs no
  /// composite index, and limit keeps every read bounded (CLAUDE.md rule 11).
  Query<Map<String, dynamic>> _query(String familyId) => _db
      .collection(FirestorePaths.choreTemplates(familyId))
      .orderBy('sortOrder')
      .limit(kMaxChoreTemplates);

  @override
  Stream<List<TemplateRecord>> watch(String familyId) =>
      _query(familyId).snapshots().map(_toRecords);

  @override
  Future<Result<List<TemplateRecord>>> list(String familyId) =>
      guardFirestore(() async {
        final snapshot = await _query(familyId).get();
        return _toRecords(snapshot);
      });

  @override
  Future<Result<TemplateRecord?>> get(String familyId, String templateId) =>
      guardFirestore(() async {
        final snapshot = await _db
            .doc(FirestorePaths.choreTemplateDoc(familyId, templateId))
            .get();
        return ChoreTemplateMappers.fromDoc(templateId, snapshot.data());
      });

  @override
  Future<Result<void>> save(
    String familyId,
    ChoreTemplate template,
    AuditEvent event,
  ) => guardWrite(() async {
    final path = FirestorePaths.choreTemplateDoc(familyId, template.id);
    final snapshot = await _db.doc(path).get();
    final current = snapshot.exists
        ? BaseMapper.metadataFromMap(snapshot.data() ?? <String, dynamic>{})
        : BaseMapper.createMetadata(uid: event.actorId, clock: _clock);
    final metadata = current.copyWith(
      updatedAt: event.at,
      updatedBy: event.actorId,
    );

    await _tx.runBatch((batch) {
      // `set` without merge: the document is replaced as a whole, so a field
      // removed from the draft really disappears and the rules compare
      // `revision` / `seedKey` against the previous document.
      batch.set(path, ChoreTemplateMappers.toMap(template, metadata));
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
