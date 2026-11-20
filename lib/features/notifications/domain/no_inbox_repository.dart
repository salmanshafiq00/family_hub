import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_repository.dart';

/// The default [InboxRepository]: an empty inbox. `bootstrap.dart` overrides it
/// with Firestore; a screen test that shows the bell simply sees no unread rows.
final class NoInboxRepository implements InboxRepository {
  const NoInboxRepository();

  @override
  Stream<List<InboxItem>> watchMine(String familyId, String memberId) =>
      Stream<List<InboxItem>>.value(const <InboxItem>[]);

  @override
  Future<Result<InboxItem?>> get(String familyId, String itemId) async =>
      const Success<InboxItem?>(null);

  @override
  Future<Result<void>> markRead(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  }) async => const Failure<void>(Unknown('inbox repository not wired'));

  @override
  Future<Result<void>> archive(
    String familyId, {
    required String actorId,
    required String id,
    required DateTime at,
  }) async => const Failure<void>(Unknown('inbox repository not wired'));

  @override
  Future<Result<void>> archiveAll(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  }) async => const Failure<void>(Unknown('inbox repository not wired'));
}
