import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/firebase/audit_writer.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/firebase/doc_watch.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/core/permissions/role.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/dashboard/data/dashboard_policy_mappers.dart';
import 'package:family_hub/features/dashboard/domain/card_access.dart';
import 'package:family_hub/features/dashboard/domain/dashboard_policy.dart';
import 'package:family_hub/features/dashboard/domain/dashboard_policy_repository.dart';

final class FirestoreDashboardPolicyRepository
    implements DashboardPolicyRepository {
  FirestoreDashboardPolicyRepository({
    required this.tx,
    required this.clock,
    FirebaseFirestore? firestore,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final TxRunner tx;
  final Clock clock;
  final FirebaseFirestore _db;

  @override
  Stream<DashboardPolicy> watchPolicy(String familyId) => guardStream(
    watchKnownDoc(_db.doc(FirestorePaths.dashboardSettingsDoc(familyId)))
        .map(DashboardPolicyMappers.policyFromMap),
  );

  @override
  Future<Result<DashboardPolicy>> savePolicy(
    String familyId,
    Map<Role, Map<String, CardAccess>> roles,
    AuditEvent event,
  ) async {
    var saved = DashboardPolicy.defaults;
    final result = await guardWrite(() async {
      final snapshot = await _db
          .doc(FirestorePaths.dashboardSettingsDoc(familyId))
          .get(const GetOptions(source: Source.server));
      final data = snapshot.data();
      final version = snapshot.exists
          ? DashboardPolicyMappers.policyFromMap(data).version + 1
          : 1;
      saved = DashboardPolicy(roles: roles, version: version);
      final metadata = snapshot.exists && data != null
          ? BaseMapper.metadataFromMap(data)
                .copyWith(updatedAt: event.at, updatedBy: event.actorId)
          : BaseMapper.createMetadata(
              uid: event.actorId,
              clock: clock,
            ).copyWith(updatedAt: event.at, updatedBy: event.actorId);

      await tx.runBatch((batch) {
        batch.set(
          FirestorePaths.dashboardSettingsDoc(familyId),
          DashboardPolicyMappers.policyToMap(saved, metadata),
        );
        AuditWriter.write(batch, familyId, event);
      });
    }, probe: serverProbeFor(_db, event.actorId));
    final failure = result.failureOrNull;
    return failure != null
        ? Failure<DashboardPolicy>(failure)
        : Success<DashboardPolicy>(saved);
  }
}
