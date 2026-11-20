import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_repository.dart';

/// Archives (soft-deletes) all of the actor's own stored inbox items and
/// returns how many were cleared. Virtual rows are dismissed locally by the
/// presentation layer. Owner only.
class ClearAllInboxItems {
  const ClearAllInboxItems({
    required this.inbox,
    required this.families,
    required this.clock,
  });

  final InboxRepository inbox;
  final FamilyRepository families;
  final Clock clock;

  Future<Result<int>> call({
    required String familyId,
    required String actorUid,
    required List<InboxItem> items,
  }) async {
    final member = (await families.getMember(familyId, actorUid)).valueOrNull;
    if (member == null || !member.isActive) {
      return const Failure<int>(PermissionDenied());
    }

    // Only archive stored (non-virtual) items that belong to this member and
    // are not already archived.
    final ids = <String>[
      for (final item in items)
        if (!item.id.startsWith('v:') &&
            !item.isArchived &&
            item.toMemberId == actorUid)
          item.id,
    ];

    if (ids.isEmpty) return const Success<int>(0);

    final result = await inbox.archiveAll(
      familyId,
      actorId: actorUid,
      ids: ids,
      at: clock.nowUtc(),
    );
    return result.map((_) => ids.length);
  }
}
