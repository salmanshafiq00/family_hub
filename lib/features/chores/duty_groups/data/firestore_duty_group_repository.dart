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
import 'package:family_hub/features/chores/duty_groups/data/duty_group_mappers.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';

/// Firestore implementation of [DutyGroupRepository] (`dutyGroups`).
///
/// The list query is a single-field `orderBy sortOrder` on a family-scoped
/// collection, so it needs no composite index. It is bounded by
/// [kMaxDutyGroups] (C-2 discipline: every collection read has a limit).
///
/// [save] is an EVERYDAY write (batch, no probe): renaming a group while
/// offline must work and sync later. [saveRotation] is an INTEGRITY write and
/// requires the server first (road map 3.4), because two devices appending
/// versions offline would silently produce divergent rotas.
class FirestoreDutyGroupRepository implements DutyGroupRepository {
  FirestoreDutyGroupRepository({
    required this._tx,
    required this._clock,
    this._firestore,
    this._probe,
  });

  final TxRunner _tx;
  final Clock _clock;
  final FirebaseFirestore? _firestore;
  final ServerProbe? _probe;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  Query<Map<String, dynamic>> _query(String familyId) => _db
      .collection(FirestorePaths.dutyGroups(familyId))
      .orderBy('sortOrder')
      .limit(kMaxDutyGroups);

  @override
  Stream<List<DutyGroup>> watch(String familyId) =>
      _query(familyId).snapshots().map(_toGroups);

  @override
  Future<Result<List<DutyGroup>>> list(String familyId) =>
      guardFirestore(() async {
        final snapshot = await _query(familyId).get();
        return _toGroups(snapshot);
      });

  @override
  Future<Result<DutyGroup?>> get(String familyId, String groupId) =>
      guardFirestore(() async {
        final snapshot = await _db
            .doc(FirestorePaths.dutyGroupDoc(familyId, groupId))
            .get();
        return DutyGroupMappers.fromDoc(groupId, snapshot.data());
      });

  @override
  Future<Result<void>> save(
    String familyId,
    DutyGroup group,
    AuditEvent event,
  ) => _write(familyId, group, event, requireServer: false);

  @override
  Future<Result<void>> saveRotation(
    String familyId,
    DutyGroup group,
    AuditEvent event,
  ) => _write(familyId, group, event, requireServer: true);

  /// Reads the existing metadata (or creates it), stamps `updatedAt/By`, then
  /// batches the document with its audit entry.
  Future<Result<void>> _write(
    String familyId,
    DutyGroup group,
    AuditEvent event, {
    required bool requireServer,
  }) {
    final path = FirestorePaths.dutyGroupDoc(familyId, group.id);
    Future<void> commit() async {
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
        // removed from the group really disappears and the rules see the shape
        // the mapper wrote.
        batch.set(path, DutyGroupMappers.toMap(group, metadata));
        AuditWriter.write(batch, familyId, event);
      });
    }

    if (!requireServer) return guardWrite(commit);
    return guardWrite(
      commit,
      probe: _probe ?? serverProbeFor(_db, event.actorId),
    );
  }

  static List<DutyGroup> _toGroups(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => <DutyGroup>[
    for (final doc in snapshot.docs)
      ?DutyGroupMappers.fromDoc(doc.id, doc.data()),
  ];
}
