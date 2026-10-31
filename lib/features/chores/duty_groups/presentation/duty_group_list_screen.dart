import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/duty_group_card.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Every duty group: who is on duty now, the members and the chores (P3-18).
///
/// Everybody can read it; only people with `manageChoreTemplates` see the
/// create button (`ref.can`, never a role test). ONE listener
/// ([dutyGroupsStreamProvider]); nothing else is read here.
class DutyGroupListScreen extends ConsumerWidget {
  const DutyGroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canManage = ref.can(Permission.manageChoreTemplates);
    final stream = ref.watch(dutyGroupsStreamProvider);
    final groups = ref.watch(dutyGroupsProvider);

    final Widget body;
    if (stream.hasError && !stream.hasValue) {
      final error = stream.error;
      body = ErrorView(
        message: l10n.choresFailureMessage(
          error is AppFailure ? error : Unknown(error),
        ),
        onRetry: () => ref.invalidate(dutyGroupsStreamProvider),
      );
    } else if (!stream.hasValue) {
      body = const LoadingView();
    } else if (groups.isEmpty) {
      body = EmptyState(
        icon: Icons.groups_outlined,
        title: l10n.dutyGroupsEmptyTitle,
        message: l10n.dutyGroupsEmptyMessage,
        actionLabel: canManage ? l10n.dutyGroupNew : null,
        onAction: canManage
            ? () => context.push(AppRoutes.choresDutyGroupNew)
            : null,
      );
    } else {
      final truncated = ref.watch(dutyGroupsTruncatedProvider);
      final formatters = ref.watch(appFormattersProvider);
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        children: [
          for (final group in groups) ...[
            DutyGroupCard(group: group),
            const SizedBox(height: 12),
          ],
          if (truncated)
            Text(l10n.dutyGroupsTruncated(formatters.number(groups.length))),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dutyGroupsTitle)),
      body: body,
      floatingActionButton: canManage && stream.hasValue && groups.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.choresDutyGroupNew),
              icon: const Icon(Icons.add),
              label: Text(l10n.dutyGroupNew),
            )
          : null,
    );
  }
}
