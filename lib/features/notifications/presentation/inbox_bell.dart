import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/shared/widgets/centered_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The bell with the unread count (P3-27), for the Chores app bar and the
/// Manage hub. The count is a number inside a badge, never colour alone.
class InboxBell extends ConsumerWidget {
  const InboxBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final count = ref.watch(unreadInboxCountProvider);
    final formatters = ref.watch(appFormattersProvider);
    return IconButton(
      key: const Key('inbox_bell'),
      tooltip: l10n.inboxBellLabel(formatters.number(count)),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: () => context.push(AppRoutes.inbox),
      icon: Badge(
        isLabelVisible: count > 0,
        label: CenteredLabel(count > 99 ? '99+' : formatters.number(count)),
        child: const Icon(Icons.notifications_none_rounded),
      ),
    );
  }
}
