import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_item_providers.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/starter_list_row.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The family's starter pack as a list a manager can change: add, edit,
/// delete, and reset to the built-in list.
///
/// While the family has no list of its own the screen shows the built-in
/// lines read-only with a "Customise" button that copies them in.
class StarterPackListScreen extends ConsumerWidget {
  const StarterPackListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BUILD MARKER (temporary diagnosis): if this never prints while the screen
    // is on screen, the screen was not rebuilt after `customise` and the list
    // still shows the built-in pack even though the write went through.
    debugPrint('STARTER_LIST_BUILD');
    final l10n = context.l10n;
    final t = context.tokens;
    final canManage = ref.can(Permission.manageChoreTemplates);
    final items = ref.watch(starterItemsStreamProvider);
    final customised = ref.watch(starterPackCustomisedProvider);
    final pack = ref.watch(starterPackProvider);

    final Widget body;
    if (!canManage) {
      body = EmptyState(
        icon: Icons.lock_outline_rounded,
        title: l10n.starterListTitle,
        message: l10n.starterPackManagersOnly,
      );
    } else if (items.hasError && !items.hasValue) {
      body = ErrorView(
        message: l10n.choresFailure_unknown,
        retryLabel: l10n.actionRetry,
        onRetry: () => ref.invalidate(starterItemsStreamProvider),
      );
    } else if (!items.hasValue) {
      body = const LoadingView(lines: 4);
    } else {
      body = ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customised
                      ? l10n.starterListCustomNote
                      : l10n.starterListBuiltInNote,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: t.textSecondary),
                ),
                if (!customised) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: const ValueKey<String>('starter_list_customise'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => _customise(context, ref),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l10n.starterListCustomise),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final line in pack.templates)
            StarterListRow(
              line: line,
              editable: customised,
              onEdit: () =>
                  context.push(AppRoutes.choresStarterItemEdit(line.seedKey)),
              onDelete: () => _delete(context, ref, line.seedKey),
            ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.starterListTitle),
        actions: [
          if (canManage && customised)
            IconButton(
              key: const ValueKey<String>('starter_list_reset'),
              tooltip: l10n.starterListReset,
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: () => _reset(context, ref),
            ),
        ],
      ),
      body: body,
      floatingActionButton: canManage && customised
          ? FloatingActionButton.extended(
              key: const ValueKey<String>('starter_list_add'),
              onPressed: () => context.push(AppRoutes.choresStarterItemNew),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.actionAdd),
            )
          : null,
    );
  }

  Future<void> _customise(BuildContext context, WidgetRef ref) => _run(
    context,
    ref,
    (uid, familyId) => ref
        .read(manageStarterItemsProvider)
        .customise(
          actorUid: uid,
          familyId: familyId,
          base: ref.read(starterPackProvider),
        ),
  );

  Future<void> _delete(BuildContext context, WidgetRef ref, String id) async {
    final l10n = context.l10n;
    final ok = await _confirm(
      context,
      title: l10n.starterListDeleteTitle,
      message: l10n.starterListDeleteMessage,
      action: l10n.actionDelete,
    );
    if (!ok || !context.mounted) return;
    await _run(
      context,
      ref,
      (uid, familyId) => ref
          .read(manageStarterItemsProvider)
          .delete(actorUid: uid, familyId: familyId, itemId: id),
    );
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await _confirm(
      context,
      title: l10n.starterListResetTitle,
      message: l10n.starterListResetMessage,
      action: l10n.starterListReset,
    );
    if (!ok || !context.mounted) return;
    await _run(
      context,
      ref,
      (uid, familyId) => ref
          .read(manageStarterItemsProvider)
          .reset(actorUid: uid, familyId: familyId),
    );
  }

  /// Runs one use case and shows its failure, if any, as a snack bar.
  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<Result<Object?>> Function(String uid, String familyId) action,
  ) async {
    final uid = ref.read(currentUidProvider);
    final familyId = ref.read(currentFamilyIdProvider);
    if (uid == null || familyId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    debugPrint('STARTER_LIST_ACTION start uid=$uid family=$familyId');
    final result = await action(uid, familyId);
    final failure = result.failureOrNull;
    debugPrint('STARTER_LIST_ACTION failure=$failure');
    if (failure != null) {
      // The write is atomic - Firestore rejects the whole batch - so say plainly
      // that nothing changed instead of leaving a silently stale list.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.starterListSaveFailed(l10n.choresFailureMessage(failure)),
          ),
        ),
      );
    }
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('starter_list_confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
