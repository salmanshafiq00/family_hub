import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/bazar/budgets/presentation/budget_providers.dart';
import 'package:family_hub/features/bazar/contributions/presentation/contribution_providers.dart';
import 'package:family_hub/features/bazar/settings/presentation/bazar_settings_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_repository.dart';
import 'package:family_hub/features/notifications/domain/no_inbox_repository.dart';
import 'package:family_hub/features/notifications/domain/inbox_visibility.dart';
import 'package:family_hub/features/notifications/domain/usecases/archive_inbox_item.dart';
import 'package:family_hub/features/notifications/domain/usecases/clear_all_inbox_items.dart';
import 'package:family_hub/features/notifications/domain/usecases/mark_all_read.dart';
import 'package:family_hub/features/notifications/domain/usecases/mark_inbox_read.dart';
import 'package:family_hub/features/notifications/domain/virtual_inbox.dart';
import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/modules/module_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in `bootstrap.dart` and in tests; the default inbox is empty.
final inboxRepositoryProvider = Provider<InboxRepository>(
  (ref) => const NoInboxRepository(),
);

/// MY newest inbox items (archived ones hidden): ONE listener, at most
/// `kMaxInboxDocs`, newest first.
final inboxProvider = StreamProvider<List<InboxItem>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  final uid = ref.watch(currentUidProvider);
  if (familyId == null || uid == null) {
    return Stream.value(const <InboxItem>[]);
  }
  return ref
      .watch(inboxRepositoryProvider)
      .watchMine(familyId, uid)
      .map(
        (items) => <InboxItem>[
          for (final item in items)
            if (!item.isArchived) item,
        ],
      );
});

const String _virtualReadKeyPrefix = 'virtual_inbox_read';

String _virtualReadKey(String uid, String monthKey) =>
    '$_virtualReadKeyPrefix.$uid.$monthKey';

/// Derived reminders and approvals are local-only; read state is saved on this
/// device under the viewer and current month.
final virtualInboxProvider = Provider<List<InboxItem>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const <InboxItem>[];

  final dateKeys = ref.watch(familyDateKeysProvider);
  final today = dateKeys.today();
  final monthKey = today.monthKey.toString();
  final modules = ref.watch(moduleFlagsProvider);
  final canApproveMembers = ref.can(Permission.approveMembers);
  final canReviewContributions = ref.can(Permission.recordContribution);
  final canVerify = ref.watch(canVerifyAnyProvider);

  final List<Member> members = canApproveMembers
      ? ref.watch(membersProvider).value ?? const <Member>[]
      : const <Member>[];
  final pendingJoins = members
      .where((member) => member.status == MembershipStatus.pending)
      .length;

  int? budgetPercent;
  var pendingContributions = 0;
  var contributionDue = false;
  if (modules.isEnabled('bazar')) {
    final alerts = ref.watch(budgetAlertsProvider);
    final budget = alerts.firstOrNull;
    final percentBp = budget?.status.percentBp;
    if (percentBp != null) budgetPercent = (percentBp + 50) ~/ 100;

    final month = today.monthKey;
    final settings = ref.watch(bazarSettingsProvider);
    if (canReviewContributions) {
      pendingContributions = ref
          .watch(pendingContributionsProvider(month))
          .length;
    }
    if (today.day >= settings.contributionDueDay) {
      contributionDue = ref
          .watch(contributionStatusProvider(month))
          .any(
            (status) => status.memberId == uid && status.remaining.paisa > 0,
          );
    }
  }

  final verificationCount = modules.isEnabled('chores') && canVerify
      ? ref.watch(verifyQueueCountProvider)
      : 0;
  final prefs = ref.watch(sharedPreferencesProvider);
  final acknowledged =
      prefs.getStringList(_virtualReadKey(uid, monthKey))?.toSet() ??
      const <String>{};

  return VirtualInbox.build(
    monthKey: monthKey,
    viewerId: uid,
    now: ref.watch(clockProvider).nowUtc(),
    acknowledgedIds: acknowledged,
    budgetPercent: modules.isEnabled('bazar') ? budgetPercent : null,
    pendingJoinRequests: pendingJoins,
    pendingContributionRequests: pendingContributions,
    contributionDue: contributionDue,
    awaitingVerification: verificationCount,
  );
});

/// Stored rows plus virtual reminders, filtered by module availability.
final visibleInboxItemsProvider = Provider<List<InboxItem>>((ref) {
  final modules = ref.watch(moduleFlagsProvider);
  return buildVisibleInboxItems(
    stored: ref.watch(inboxProvider).value ?? const <InboxItem>[],
    virtual: ref.watch(virtualInboxProvider),
    choresEnabled: modules.isEnabled('chores'),
    bazarEnabled: modules.isEnabled('bazar'),
  );
});

/// Stored unread plus unacknowledged virtual items, for the bell and badges.
final unreadInboxCountProvider = Provider<int>(
  (ref) => ref
      .watch(visibleInboxItemsProvider)
      .where((item) => item.isUnread)
      .length,
);

final markInboxReadProvider = Provider<MarkInboxRead>(
  (ref) => MarkInboxRead(
    inbox: ref.watch(inboxRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final markAllReadProvider = Provider<MarkAllRead>(
  (ref) => MarkAllRead(ref.watch(markInboxReadProvider)),
);

final markVirtualInboxReadProvider =
    Provider<Future<bool> Function(List<String>)>(
      (ref) => (ids) async {
        final uid = ref.read(currentUidProvider);
        if (uid == null || ids.isEmpty) return true;
        final month = ref
            .read(familyDateKeysProvider)
            .today()
            .monthKey
            .toString();
        final prefs = ref.read(sharedPreferencesProvider);
        final key = _virtualReadKey(uid, month);
        final readIds = prefs.getStringList(key)?.toSet() ?? <String>{};
        readIds.addAll(ids.where((id) => id.startsWith('v:')));
        final saved = await prefs.setStringList(key, readIds.toList()..sort());
        if (!saved) return false;
        ref.invalidate(virtualInboxProvider);
        return true;
      },
    );

final archiveInboxItemProvider = Provider<ArchiveInboxItem>(
  (ref) => ArchiveInboxItem(
    inbox: ref.watch(inboxRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

final clearAllInboxItemsProvider = Provider<ClearAllInboxItems>(
  (ref) => ClearAllInboxItems(
    inbox: ref.watch(inboxRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);
