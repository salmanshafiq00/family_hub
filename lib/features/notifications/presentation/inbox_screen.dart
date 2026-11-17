import 'dart:async';

import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/presentation/inbox_open_action.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/features/notifications/presentation/inbox_text.dart';
import 'package:family_hub/features/notifications/presentation/inbox_tile.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The member's inbox (P3-27): grouped Today / Earlier, an unread dot, tap =
/// mark read + open what it is about. Items of a module that is switched off
/// are hidden. One info row explains the Spark limit (D-P3-19): a request shows
/// up when the app is opened.
class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({this.focusItemId, super.key});

  /// Opens this row once the list has loaded (a local notification tap).
  final String? focusItemId;

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  bool _focusHandled = false;

  @override
  Widget build(BuildContext context) {
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
          final focusId = widget.focusItemId;
          if (!_focusHandled && focusId != null) {
            final focused = items
                .where((item) => item.id == focusId)
                .firstOrNull;
            if (focused != null) {
              _focusHandled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  unawaited(ref.openInboxItem(context, focused));
                }
              });
            }
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
                          onTap: () =>
                              unawaited(ref.openInboxItem(context, item)),
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
