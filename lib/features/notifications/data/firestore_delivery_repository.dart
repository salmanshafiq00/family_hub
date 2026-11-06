import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/firebase/audit_writer.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/firebase/doc_watch.dart';
import 'package:family_hub/core/firebase/firestore_guard.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/notifications/data/delivery_mappers.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';

final class FirestoreDeliveryRepository
    implements NotificationDeliveryRepository {
  FirestoreDeliveryRepository({
    required this.tx,
    required this.clock,
    FirebaseFirestore? firestore,
    this.probe,
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final TxRunner tx;
  final Clock clock;
  final FirebaseFirestore _db;
  final ServerProbe? probe;

  @override
  Stream<NotificationDeliverySettings> watch(String familyId) =>
      watchKnownDoc(_db.doc(FirestorePaths.notificationDeliveryDoc(familyId)))
          .map(DeliveryMappers.fromMap)
          .distinct();

  @override
  Future<Result<void>> save(
    String familyId,
    NotificationDeliverySettings settings,
    AuditEvent event,
  ) => guardWrite(() async {
    final path = FirestorePaths.notificationDeliveryDoc(familyId);
    final snapshot = await _db
        .doc(path)
        .get(const GetOptions(source: Source.server));
    final metadata = snapshot.exists && snapshot.data() != null
        ? BaseMapper.metadataFromMap(snapshot.data()!)
              .copyWith(updatedAt: event.at, updatedBy: event.actorId)
        : BaseMapper.createMetadata(
            uid: event.actorId,
            clock: clock,
          ).copyWith(updatedAt: event.at, updatedBy: event.actorId);
    await tx.runBatch((batch) {
      batch.set(path, DeliveryMappers.toMap(settings, metadata));
      AuditWriter.write(batch, familyId, event);
    });
  }, probe: probe ?? serverProbeFor(_db, event.actorId));
}
