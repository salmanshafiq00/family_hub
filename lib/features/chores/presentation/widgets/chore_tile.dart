import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart'
    as domain;
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/presentation/chore_icons.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:family_hub/shared/widgets/flag_chip.dart' as chips;
import 'package:family_hub/shared/widgets/status_chip.dart';
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// THE chore row of Phase 3: Today, the day panel, the agenda and the verify
/// queue all render this widget, so a chore looks the same everywhere (P3-15).
///
/// Content: the group icon, the name, the due time, the assignee avatar, "3/5"
/// and the flags. A projected item is dashed and says "planned"; a chore
/// somebody covers says "covering for X". The row is one 48 dp+ tap target and
/// announces status + name + due time as ONE label (never colour alone).
class ChoreTile extends ConsumerWidget {
  const ChoreTile({
    required this.item,
    required this.formatters,
    required this.onTap,
    this.trailing,
    this.dense = false,
    super.key,
  });

  final domain.ChoreItem item;
  final AppFormatters formatters;
  final VoidCallback onTap;

  /// An optional action at the end of the row (for example "Approve").
  final Widget? trailing;

  /// One line instead of two (a calendar panel).
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final members = ref.watch(membersProvider).value ?? const [];
    final assignee = item.assigneeId == null
        ? null
        : members.where((m) => m.uid == item.assigneeId).firstOrNull;
    final planned = item.plannedAssigneeId == null
        ? null
        : members.where((m) => m.uid == item.plannedAssigneeId).firstOrNull;

    return Semantics(
      button: true,
      label: _semantic(l10n),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(t.radiusMd),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: item.isProjected ? t.surfaceSunken : t.surface,
              borderRadius: BorderRadius.circular(t.radiusMd),
              border: Border.all(
                color: item.isProjected ? t.accentSoft : t.divider,
              ),
            ),
            child: Row(
              children: [
                Icon(choreIconFor(item), size: 20, color: t.accentStrong),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _name(context),
                        maxLines: dense ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!dense) ...[
                        const SizedBox(height: 4),
                        _SubLine(
                          item: item,
                          formatters: formatters,
                          coveringName: item.has(domain.ChoreFlag.isCover)
                              ? planned?.displayName
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusGlyph(status: widgetStatusOf(item.status), size: 14),
                if (item.progress.hasSubtasks) ...[
                  const SizedBox(width: 6),
                  Text(
                    l10n.choreStepsCount(
                      formatters.number(item.progress.done),
                      formatters.number(item.progress.total),
                    ),
                    style: TextStyle(
                      color: t.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (assignee != null) ...[
                  const SizedBox(width: 8),
                  AppAvatar(
                    id: assignee.uid,
                    name: assignee.displayName,
                    avatarKey: assignee.avatarKey,
                    size: 26,
                    semanticLabel: assignee.displayName,
                  ),
                ],
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _name(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'bn'
      ? item.nameBn
      : (item.nameEn ?? item.nameBn);

  String _semantic(AppLocalizations l10n) {
    final parts = <String>[
      _nameLabel(l10n),
      statusLabelOf(item.status, l10n),
      if (item.dueMinutes != null)
        l10n.choreDueTime(formatters.timeOfDay(item.dueMinutes!)),
      if (item.progress.hasSubtasks)
        l10n.choreStepsCount(
          formatters.number(item.progress.done),
          formatters.number(item.progress.total),
        ),
      if (item.isProjected) l10n.choreFlagPlanned,
      for (final flag in item.flags)
        if (flag != domain.ChoreFlag.isProjected)
          chips.FlagChip.labelFor(sharedFlag(flag), l10n),
    ];
    return parts.join(', ');
  }

  String _nameLabel(AppLocalizations l10n) => l10n.localeName.startsWith('bn')
      ? item.nameBn
      : (item.nameEn ?? item.nameBn);
}

/// The second line: due time, the covering note and the flags.
class _SubLine extends StatelessWidget {
  const _SubLine({
    required this.item,
    required this.formatters,
    required this.coveringName,
  });

  final domain.ChoreItem item;
  final AppFormatters formatters;
  final String? coveringName;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (item.dueMinutes != null)
          Text(
            l10n.choreDueTime(formatters.timeOfDay(item.dueMinutes!)),
            style: TextStyle(color: t.textSecondary, fontSize: 12),
          ),
        if (coveringName != null)
          Text(
            l10n.occurrenceCoveringFor(coveringName!),
            style: TextStyle(color: t.info, fontSize: 12),
          ),
        if (item.isProjected)
          const chips.FlagChip(flag: chips.ChoreFlag.planned, compact: true),
        for (final flag in item.flags)
          if (flag != domain.ChoreFlag.isProjected)
            chips.FlagChip(flag: sharedFlag(flag), compact: true),
      ],
    );
  }
}

/// The domain's flag set mapped onto the shared widget's enum.
chips.ChoreFlag sharedFlag(domain.ChoreFlag flag) => switch (flag) {
  domain.ChoreFlag.needsCover => chips.ChoreFlag.needsCover,
  domain.ChoreFlag.awaitingVerification => chips.ChoreFlag.awaitingVerification,
  domain.ChoreFlag.needsAttention => chips.ChoreFlag.needsAttention,
  domain.ChoreFlag.isProjected => chips.ChoreFlag.planned,
  domain.ChoreFlag.isCover => chips.ChoreFlag.needsCover,
  domain.ChoreFlag.hasPendingSwap => chips.ChoreFlag.swapPending,
};

/// The shared widget's status for a derived [ChoreStatus].
WidgetStatus widgetStatusOf(ChoreStatus status) => switch (status) {
  ChoreStatus.scheduled => WidgetStatus.scheduled,
  ChoreStatus.inProgress => WidgetStatus.inProgress,
  ChoreStatus.completed => WidgetStatus.completed,
  ChoreStatus.verified => WidgetStatus.verified,
  ChoreStatus.overdue => WidgetStatus.overdue,
  ChoreStatus.skipped => WidgetStatus.skipped,
};

/// The localized name of a [ChoreStatus].
String statusLabelOf(ChoreStatus status, AppLocalizations l10n) =>
    switch (status) {
      ChoreStatus.scheduled => l10n.statusScheduled,
      ChoreStatus.inProgress => l10n.statusInProgress,
      ChoreStatus.completed => l10n.statusCompleted,
      ChoreStatus.verified => l10n.statusVerified,
      ChoreStatus.overdue => l10n.statusOverdue,
      ChoreStatus.skipped => l10n.choreStatusSkipped,
    };

/// True when the viewer may complete [item] (assignee, manager, or the family
/// switch) — used by a swipe action to hide what cannot work.
bool mayComplete(WidgetRef ref, domain.ChoreItem item) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return false;
  final own = item.assigneeId == uid;
  return ref.can(
    own ? Permission.completeOwnChore : Permission.completeChoreForOthers,
    ownerId: item.assigneeId,
  );
}
