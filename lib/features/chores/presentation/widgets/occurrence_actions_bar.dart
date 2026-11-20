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
    this.onNeedsCover,
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

  /// A manager moves an owned chore back to the Needs cover list.
  final VoidCallback? onNeedsCover;
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

    final actions = <_BarAction>[
      if (open && mayTick)
        _BarAction(
          const ValueKey('action_complete'),
          Icons.check_rounded,
          l10n.occurrenceActionComplete,
          onComplete,
          filled: true,
        ),
      if (status == ChoreStatus.completed && mayTick)
        _BarAction(
          const ValueKey('action_undo'),
          Icons.undo_rounded,
          l10n.occurrenceActionUndo,
          onUndo,
        ),
      if (canVerify)
        _BarAction(
          const ValueKey('action_verify'),
          Icons.verified_outlined,
          l10n.occurrenceActionVerify,
          onVerify,
          filled: true,
        ),
      if ((status == ChoreStatus.completed && canComment) ||
          (status == ChoreStatus.verified && canManage))
        _BarAction(
          const ValueKey('action_reopen'),
          Icons.refresh_rounded,
          l10n.occurrenceActionReopen,
          onReopen,
        ),
      if (open && canReassign)
        _BarAction(
          const ValueKey('action_reassign'),
          Icons.swap_horiz_rounded,
          l10n.occurrenceActionReassign,
          onReassign,
        ),
      if (open &&
          canReassign &&
          onNeedsCover != null &&
          item.assigneeId != null)
        _BarAction(
          const ValueKey('action_needs_cover'),
          Icons.person_search_outlined,
          l10n.occurrenceActionNeedsCover,
          onNeedsCover!,
        ),
      if (open && canManage)
        _BarAction(
          const ValueKey('action_skip'),
          Icons.remove_circle_outline_rounded,
          l10n.occurrenceActionSkip,
          onSkip,
        ),
      if (status == ChoreStatus.skipped && canManage)
        _BarAction(
          const ValueKey('action_unskip'),
          Icons.restore_rounded,
          l10n.occurrenceActionUnskip,
          onUnskip,
        ),
      if (open && canManage)
        _BarAction(
          const ValueKey('action_exception'),
          Icons.info_outline_rounded,
          l10n.occurrenceActionException,
          onException,
        ),
      if (open && mayTick && onSwap != null)
        _BarAction(
          const ValueKey('action_swap'),
          Icons.person_search_rounded,
          l10n.occurrenceActionSwap,
          onSwap!,
        ),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    // U-10: at most two buttons stay on the bar; with more, the first (the
    // main action) stays and the rest move into one overflow menu, so the bar
    // never covers the screen at text scale 2.0 in Bangla.
    const maxInline = 2;
    final inline = actions.length <= maxInline
        ? actions
        : actions.sublist(0, 1);
    final overflow = actions.length <= maxInline
        ? const <_BarAction>[]
        : actions.sublist(1);

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final action in inline) action.button(busy: busy),
              if (overflow.isNotEmpty)
                PopupMenuButton<int>(
                  key: const ValueKey('actions_more'),
                  tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                  icon: const Icon(Icons.more_horiz_rounded),
                  enabled: !busy,
                  onSelected: (index) => overflow[index].onPressed(),
                  itemBuilder: (context) => [
                    for (var i = 0; i < overflow.length; i++)
                      PopupMenuItem<int>(
                        key: overflow[i].key,
                        value: i,
                        child: Row(
                          children: [
                            Icon(overflow[i].icon, size: 20),
                            const SizedBox(width: 12),
                            Flexible(child: Text(overflow[i].label)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One entry of the bar: a button when it fits, a menu row when it does not.
class _BarAction {
  const _BarAction(
    this.key,
    this.icon,
    this.label,
    this.onPressed, {
    this.filled = false,
  });

  final Key key;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  Widget button({required bool busy}) {
    final handler = busy ? null : onPressed;
    return filled
        ? FilledButton.icon(
            key: key,
            onPressed: handler,
            icon: Icon(icon),
            label: Text(label),
          )
        : OutlinedButton.icon(
            key: key,
            onPressed: handler,
            icon: Icon(icon),
            label: Text(label),
          );
  }
}
