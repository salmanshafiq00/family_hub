import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart'
    as domain;
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The action bar of the chore detail screen (P3-15).
///
/// A control is shown only when `ref.can` allows it AND Appendix C allows it in
/// this state: a plain member never sees "Reassign", and nobody sees "Verify" on
/// their own work. The screen supplies the callbacks; this widget never calls a
/// use case.
class OccurrenceActionsBar extends ConsumerWidget {
  const OccurrenceActionsBar({
    required this.item,
    required this.completedBy,
    required this.onComplete,
    required this.onUndo,
    required this.onVerify,
    required this.onReopen,
    required this.onReassign,
    required this.onSkip,
    required this.onUnskip,
    required this.onException,
    this.onSwap,
    this.busy = false,
    super.key,
  });

  final domain.ChoreItem item;

  /// Who completed it (a manager cannot verify their own completion).
  final String? completedBy;
  final VoidCallback onComplete;
  final VoidCallback onUndo;
  final VoidCallback onVerify;
  final VoidCallback onReopen;
  final VoidCallback onReassign;
  final VoidCallback onSkip;
  final VoidCallback onUnskip;
  final VoidCallback onException;

  /// The swap entry point; null until P3-27 supplies the sheet.
  final VoidCallback? onSwap;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final uid = ref.watch(currentUidProvider);
    final status = item.status;
    final open =
        status == ChoreStatus.scheduled ||
        status == ChoreStatus.inProgress ||
        status == ChoreStatus.overdue;
    final canManage = ref.can(Permission.manageChoreOccurrences);
    final canReassign = ref.can(Permission.reassignChore);
    final mayTick = ref.can(
      item.assigneeId == uid
          ? Permission.completeOwnChore
          : Permission.completeChoreForOthers,
      ownerId: item.assigneeId,
    );
    final canVerify =
        status == ChoreStatus.completed &&
        completedBy != uid &&
        ref.can(
          Permission.verifyChore,
          ownerId: completedBy,
          // B-02: the template switch is part of the cell; without it the
          // policy always said no and Verify never appeared.
          template: permissionTemplateFor(item.verification),
        );
    final canComment = ref.can(Permission.commentOnChore);

    final actions = <Widget>[
      if (open && mayTick)
        FilledButton.icon(
          key: const ValueKey('action_complete'),
          onPressed: busy ? null : onComplete,
          icon: const Icon(Icons.check_rounded),
          label: Text(l10n.occurrenceActionComplete),
        ),
      if (status == ChoreStatus.completed && mayTick)
        OutlinedButton.icon(
          key: const ValueKey('action_undo'),
          onPressed: busy ? null : onUndo,
          icon: const Icon(Icons.undo_rounded),
          label: Text(l10n.occurrenceActionUndo),
        ),
      if (canVerify)
        FilledButton.icon(
          key: const ValueKey('action_verify'),
          onPressed: busy ? null : onVerify,
          icon: const Icon(Icons.verified_outlined),
          label: Text(l10n.occurrenceActionVerify),
        ),
      if ((status == ChoreStatus.completed && canComment) ||
          (status == ChoreStatus.verified && canManage))
        OutlinedButton.icon(
          key: const ValueKey('action_reopen'),
          onPressed: busy ? null : onReopen,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(l10n.occurrenceActionReopen),
        ),
      if (open && canReassign)
        OutlinedButton.icon(
          key: const ValueKey('action_reassign'),
          onPressed: busy ? null : onReassign,
          icon: const Icon(Icons.swap_horiz_rounded),
          label: Text(l10n.occurrenceActionReassign),
        ),
      if (open && canManage)
        OutlinedButton.icon(
          key: const ValueKey('action_skip'),
          onPressed: busy ? null : onSkip,
          icon: const Icon(Icons.remove_circle_outline_rounded),
          label: Text(l10n.occurrenceActionSkip),
        ),
      if (status == ChoreStatus.skipped && canManage)
        OutlinedButton.icon(
          key: const ValueKey('action_unskip'),
          onPressed: busy ? null : onUnskip,
          icon: const Icon(Icons.restore_rounded),
          label: Text(l10n.occurrenceActionUnskip),
        ),
      if (open && canManage)
        OutlinedButton.icon(
          key: const ValueKey('action_exception'),
          onPressed: busy ? null : onException,
          icon: const Icon(Icons.info_outline_rounded),
          label: Text(l10n.occurrenceActionException),
        ),
      if (open && mayTick && onSwap != null)
        OutlinedButton.icon(
          key: const ValueKey('action_swap'),
          onPressed: busy ? null : onSwap,
          icon: const Icon(Icons.person_search_rounded),
          label: Text(l10n.occurrenceActionSwap),
        ),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Wrap(spacing: 8, runSpacing: 8, children: actions),
        ),
      ),
    );
  }
}
