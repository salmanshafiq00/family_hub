import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_action_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:family_hub/shared/widgets/reason_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Chores somebody finished that need a check (P3-15).
///
/// Only chores the viewer may verify appear: their own completions are dropped
/// (`verifyItemsProvider`), and a viewer without `verifyChore` sees the
/// explanation instead of a list that cannot act. "Approve" verifies; "send
/// back" reopens with a reason the owner will see.
class VerifyQueueScreen extends ConsumerWidget {
  const VerifyQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = ref.watch(verifyItemsProvider);
    final queue = ref.watch(verifyQueueProvider);
    final allowed = ref.watch(canVerifyAnyProvider);

    final empty = EmptyState(
      icon: Icons.fact_check_outlined,
      title: l10n.verifyEmptyTitle,
      message: l10n.verifyEmptyMessage,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle)),
      body: !allowed
          ? empty
          : queue.isLoading
          ? const LoadingView()
          : items.isEmpty
          ? empty
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _VerifyRow(item: items[index]),
            ),
    );
  }
}

class _VerifyRow extends ConsumerStatefulWidget {
  const _VerifyRow({required this.item});

  final ChoreItem item;

  @override
  ConsumerState<_VerifyRow> createState() => _VerifyRowState();
}

class _VerifyRowState extends ConsumerState<_VerifyRow> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final formatters = ref.watch(appFormattersProvider);

    return ChoreTile(
      item: widget.item,
      formatters: formatters,
      onTap: () => context.push(AppRoutes.choresOccurrence(widget.item.id)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: const ValueKey('verify_send_back'),
            tooltip: l10n.verifyReopen,
            onPressed: _busy ? null : _sendBack,
            icon: Icon(Icons.undo_rounded, color: t.textSecondary),
          ),
          FilledButton(
            key: const ValueKey('verify_approve'),
            onPressed: _busy ? null : _approve,
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              backgroundColor: t.accent,
              foregroundColor: t.textOnAccent,
            ),
            child: Text(l10n.verifyApprove),
          ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return;
    setState(() => _busy = true);
    final result = await ref.read(verifyOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: widget.item.id,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    _report(result.failureOrNull);
  }

  Future<void> _sendBack() async {
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceReopenTitle,
    );
    if (reason == null || !mounted) return;
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return;
    setState(() => _busy = true);
    final result = await ref.read(reopenOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: widget.item.id,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    _report(result.failureOrNull);
  }

  void _report(AppFailure? failure) {
    if (failure == null) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.choresFailureMessage(failure))),
    );
  }
}
