import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';

/// Port for the member's own inbox (P3-26).
///
/// Reads are bounded by `kMaxInboxDocs` and newest first. Creating rows is NOT
/// here: another member's action writes them inside ITS batch through
/// `OccurrenceWriteStager`. The owner only ever changes `readAt`/`archivedAt`.
abstract interface class InboxRepository {
  /// The newest items of [memberId], archived ones included (the caller hides
  /// them), at most `kMaxInboxDocs`.
  Stream<List<InboxItem>> watchMine(String familyId, String memberId);

  Future<Result<InboxItem?>> get(String familyId, String itemId);

  /// Sets `readAt` on every id in [ids] (one batch, EVERYDAY write).
  Future<Result<void>> markRead(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  });

  Future<Result<void>> archive(
    String familyId, {
    required String actorId,
    required String id,
    required DateTime at,
  });

  /// Sets `archivedAt` on every id in [ids] (one batch, EVERYDAY write).
  Future<Result<void>> archiveAll(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  });
}
