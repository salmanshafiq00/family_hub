import 'dart:async';

import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_providers.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_response_sheet.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:family_hub/features/notifications/domain/virtual_inbox.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/features/notifications/presentation/inbox_text.dart';
import 'package:family_hub/features/notifications/presentation/inbox_tile.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The member's inbox (P3-27): grouped Today / Earlier, an unread dot, tap =
/// mark read + open what it is about. Items of a module that is switched off
/// are hidden. One info row explains the Spark limit (D-P3-19): a request shows
/// up when the app is opened.
class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    InboxItem item,
  ) async {
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (item.isUnread) {
      if (item.id.startsWith('v:')) {
        final saved = await ref.read(markVirtualInboxReadProvider)(<String>[
          item.id,
        ]);
        if (!saved && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(context.l10n.errorUnknown)));
        }
      } else if (familyId != null && uid != null) {
        final result = await ref.read(markInboxReadProvider)(
          familyId: familyId,
          actorUid: uid,
          ids: <String>[item.id],
        );
        if (result.failureOrNull != null && context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(context.l10n.errorUnknown)));
        }
      }
    }
    if (!context.mounted) return;

    // The inbox is a page above the shell. Pushing a tab route on top of it
    // gives the shell a second page with the same key and the Navigator
    // assertion fails, so a row opens its target by replacing the stack.
    switch (item.type) {
      case VirtualInboxType.budgetAlert:
        if (context.mounted) {
          context.go(AppRoutes.bazarBudget);
        }
        return;
      case VirtualInboxType.pendingJoinRequests:
        if (context.mounted) {
          context.go(AppRoutes.familyMembers);
        }
        return;
      case VirtualInboxType.pendingContributionRequests:
        if (context.mounted) {
          context.go(AppRoutes.bazarFundPending);
        }
        return;
      case VirtualInboxType.contributionDue:
        if (context.mounted) {
          context.go(AppRoutes.bazarFund);
        }
        return;
      case VirtualInboxType.awaitingVerification:
        if (context.mounted) {
          context.go(AppRoutes.choresVerify);
        }
        return;
    }
    switch (item.refType) {
      case AuditRefType.swapRequest:
        final pending = ref.read(pendingSwapsProvider).value ?? const [];
        for (final request in pending) {
          if (request.id == item.refId && request.toMemberId == uid) {
            await ref.respondToSwapWithSheet(context, request);
            return;
          }
        }
      case AuditRefType.availability:
        if (context.mounted) {
          context.go(AppRoutes.choresAvailability);
        }
      case AuditRefType.occurrence:
        if (context.mounted) {
          context.go(AppRoutes.choresOccurrence(item.refId));
        }
      case AuditRefType.member:
        if (item.type == InboxType.memberApproved) {
          context.go(AppRoutes.home);
        }
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final inbox = ref.watch(inboxProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final visibleItems = ref.watch(visibleInboxItemsProvider);
    final today = ref.watch(familyDateKeysProvider);
    final now = today.today();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inboxTitle),
        actions: [
          IconButton(
            key: const Key('inbox_mark_all'),
            tooltip: l10n.inboxMarkAllRead,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () {
              final familyId = ref.read(currentFamilyIdProvider);
              final uid = ref.read(currentUidProvider);
              final unread = visibleItems
                  .where((item) => item.isUnread)
                  .toList(growable: false);
              if (unread.isEmpty) return;
              if (familyId != null && uid != null) {
                unawaited(
                  ref
                      .read(markAllReadProvider)(
                        familyId: familyId,
                        actorUid: uid,
                        items: unread,
                      )
                      .then((result) {
                        if (result.failureOrNull != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.errorUnknown)),
                          );
                        }
                      }),
                );
              }
              unawaited(
                ref
                    .read(markVirtualInboxReadProvider)(
                      unread.map((item) => item.id).toList(growable: false),
                    )
                    .then((saved) {
                      if (!saved && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.errorUnknown)),
                        );
                      }
                    }),
              );
            },
          ),
        ],
      ),
      body: inbox.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (failure, _) => ErrorView(
          message: failure is Network ? l10n.errorNetwork : l10n.errorUnknown,
          onRetry: () => ref.invalidate(inboxProvider),
        ),
        data: (_) {
          final items = visibleItems;
          final todays = <InboxItem>[];
          final earlier = <InboxItem>[];
          for (final item in items) {
            (today.dateKeyOf(item.createdAt) == now ? todays : earlier).add(
              item,
            );
          }
          // P4-24: the list keeps a readable measure on a tablet; the detail
          // it points at stays a route, so no pane is duplicated here.
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: t.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.inboxSparkNote,
                            style: TextStyle(
                              color: t.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (items.isEmpty)
                    EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: l10n.inboxEmpty,
                    ),
                  for (final group in <(String, List<InboxItem>)>[
                    (l10n.inboxToday, todays),
                    (l10n.inboxEarlier, earlier),
                  ])
                    if (group.$2.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          group.$1,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ),
                      for (final item in group.$2)
                        InboxTile(
                          item: item,
                          text: inboxTextOf(l10n, formatters, item, members),
                          onTap: () => unawaited(_open(context, ref, item)),
                        ),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
