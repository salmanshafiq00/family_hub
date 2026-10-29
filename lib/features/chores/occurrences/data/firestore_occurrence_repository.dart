import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/firebase/doc_watch.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_event_mappers.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_mappers.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_paging.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_write_stager.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/generation_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// Firestore implementation of [OccurrenceRepository] and
/// [GenerationMarkerRepository] (`choreOccurrences`, `settings/choreGeneration`).
///
/// ONE listener per visible month (D-P3-8): [watchRange] is a `dateKey` range
/// bounded by [kMaxOccurrencesPerMonth] plus one probe document, so the caller
/// can tell a truncated month from a complete one without a second query.
/// Soft-deleted documents are returned (the query then needs no extra index)
/// and filtered by the caller.
///
/// Two write paths (road map 3.4): [stage] is an EVERYDAY batch (queues
/// offline, the global banner shows it) and [stageIntegrity] probes the server
/// first, because generation, regeneration and replanning must not diverge
/// between two offline devices. The staging itself lives in
/// `OccurrenceWriteStager`.
class FirestoreOccurrenceRepository
    implements OccurrenceRepository, GenerationMarkerRepository {
  FirestoreOccurrenceRepository({
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

  // ── Reads ───────────────────────────────────────────────────────────────────

  @override
  Stream<List<ChoreOccurrence>> watchRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) =>
      _rangeQuery(familyId, from: from, to: to).snapshots().map(_toOccurrences);

  @override
  Stream<ChoreOccurrence?> watchOne(String familyId, String occurrenceId) =>
      watchKnownDoc(_db.doc(_docPath(familyId, occurrenceId)))
          .map((map) => OccurrenceMappers.fromDoc(occurrenceId, map))
          .where((occurrence) => occurrence == null || !occurrence.isDeleted);

  @override
  Stream<List<OccurrenceEvent>> watchEvents(
    String familyId,
    String occurrenceId,
  ) => _db
      .collection(FirestorePaths.occurrenceEvents(familyId, occurrenceId))
      .orderBy(BaseMapper.keyCreatedAt)
      .limit(kMaxEventsPerOccurrence)
      .snapshots()
      .map(
        (snapshot) => <OccurrenceEvent>[
          for (final doc in snapshot.docs)
            ?OccurrenceEventMappers.fromDoc(occurrenceId, doc.id, doc.data()),
        ],
      );

  @override
  Stream<List<ChoreOccurrence>> watchVerifyQueue(String familyId) => _db
      .collection(FirestorePaths.choreOccurrences(familyId))
      .where('status', isEqualTo: OccurrenceStatus.completed.id)
      .orderBy('dateKey', descending: true)
      .limit(kMaxVerifyQueue)
      .snapshots()
      .map(_toOccurrences);

  @override
  Future<Result<ChoreOccurrence?>> get(String familyId, String occurrenceId) =>
      guardFirestore(() async {
        final snapshot = await _db.doc(_docPath(familyId, occurrenceId)).get();
        return OccurrenceMappers.fromDoc(occurrenceId, snapshot.data());
      });

  @override
  Future<Result<List<String>>> idsInRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) => guardFirestore(
    () async => <String>[
      for (final occurrence in await _readAll(
        _rangeQuery(familyId, from: from, to: to),
      ))
        occurrence.id,
    ],
  );

  @override
  Future<Result<List<ChoreOccurrence>>> listRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) =>
      guardFirestore(() => _readAll(_rangeQuery(familyId, from: from, to: to)));

  @override
  Future<Result<List<ChoreOccurrence>>> listByTemplate(
    String familyId,
    String templateId, {
    required DateKey from,
  }) => guardFirestore(
    () => _readAll(
      _db
          .collection(FirestorePaths.choreOccurrences(familyId))
          .where('templateId', isEqualTo: templateId)
          .where('dateKey', isGreaterThanOrEqualTo: from.toString())
          .orderBy('dateKey')
          .limit(kOccurrencePageSize),
    ),
  );

  // ── Writes ──────────────────────────────────────────────────────────────────

  @override
  Future<Result<void>> stage(String familyId, OccurrenceWritePlan plan) =>
      _stage(familyId, plan, requireServer: false);

  @override
  Future<Result<void>> stageIntegrity(
    String familyId,
    OccurrenceWritePlan plan,
  ) => _stage(familyId, plan, requireServer: true);

  Future<Result<void>> _stage(
    String familyId,
    OccurrenceWritePlan plan, {
    required bool requireServer,
  }) {
    Future<void> commit() => _tx.runBatch(
      (batch) => OccurrenceWriteStager.stage(batch, familyId, plan),
    );
    if (!requireServer) return guardWrite(commit);
    return guardWrite(
      commit,
      probe: _probe ?? serverProbeFor(_db, plan.actorId),
    );
  }

  // ── Generation marker ───────────────────────────────────────────────────────

  @override
  Stream<DateKey?> watchThrough(String familyId) =>
      watchKnownDoc(_db.doc(FirestorePaths.choreGenerationDoc(familyId)))
          .map(_epochDayOf)
          .distinct();

  @override
  Future<Result<DateKey?>> readThrough(String familyId) =>
      guardFirestore(() async {
        final snapshot = await _db
            .doc(FirestorePaths.choreGenerationDoc(familyId))
            .get();
        return _epochDayOf(snapshot.data());
      });

  @override
  Future<Result<void>> writeThrough(
    String familyId,
    DateKey through, {
    required String actorId,
  }) => guardWrite(() async {
    final path = FirestorePaths.choreGenerationDoc(familyId);
    final snapshot = await _db.doc(path).get();
    final current = snapshot.exists
        ? BaseMapper.metadataFromMap(snapshot.data() ?? <String, dynamic>{})
        : BaseMapper.createMetadata(uid: actorId, clock: _clock);
    await _tx.runBatch((batch) {
      batch.set(path, <String, dynamic>{
        'throughEpochDay': through.epochDay,
        ...BaseMapper.metadataToMap(
          current.copyWith(updatedAt: _clock.nowUtc(), updatedBy: actorId),
        ),
      }, merge: true);
    });
  }, probe: _probe ?? serverProbeFor(_db, actorId));

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _docPath(String familyId, String occurrenceId) =>
      FirestorePaths.choreOccurrenceDoc(familyId, occurrenceId);

  /// The month-window query: a single-field `dateKey` range (automatic index)
  /// ordered by day, bounded by [kMaxOccurrencesPerMonth] plus ONE probe
  /// document, so [watchRange] can report a truncated month without a second
  /// query (C-2).
  Query<Map<String, dynamic>> _rangeQuery(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) => _db
      .collection(FirestorePaths.choreOccurrences(familyId))
      .where('dateKey', isGreaterThanOrEqualTo: from.toString())
      .where('dateKey', isLessThanOrEqualTo: to.toString())
      .orderBy('dateKey')
      .limit(kMaxOccurrencesPerMonth + 1);

  /// Reads a bounded query page by page (keyset: `dateKey`, then document id),
  /// so a regeneration range never loads an unbounded result and a page that
  /// ends inside a day never skips the rest of that day (B-09). Every page uses
  /// [kOccurrencePageSize], the same limit the loop checks.
  Future<List<ChoreOccurrence>> _readAll(
    Query<Map<String, dynamic>> query,
  ) => readAllOccurrencePages<ChoreOccurrence>(
    pageSize: kOccurrencePageSize,
    read: (after, limit) async {
      final base = query.orderBy(FieldPath.documentId).limit(limit);
      final page = after == null
          ? base
          : base.startAfter(<Object?>[after.dateKey, after.id]);
      final snapshot = await page.get();
      final docs = snapshot.docs;
      final last = docs.isEmpty ? null : docs.last;
      // A document the rules cannot have written (no string `dateKey`) cannot
      // be resumed after; stop rather than repeat the same page forever.
      final rawDay = last?.get('dateKey');
      return OccurrencePage<ChoreOccurrence>(
        items: _toOccurrences(snapshot),
        next: docs.length < limit || rawDay is! String
            ? null
            : OccurrenceCursor(dateKey: rawDay, id: last!.id),
      );
    },
  );

  static DateKey? _epochDayOf(Map<String, dynamic>? map) {
    final raw = map?['throughEpochDay'];
    if (raw is! num) return null;
    final day = raw.toInt();
    return day < 0 ? null : DateKey.fromEpochDay(day);
  }

  static List<ChoreOccurrence> _toOccurrences(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) => <ChoreOccurrence>[
    for (final doc in snapshot.docs)
      ?OccurrenceMappers.fromDoc(doc.id, doc.data()),
  ];
}
