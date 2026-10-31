import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_labels.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:family_hub/shared/widgets/avatar_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One row of the duty-group list (P3-18): colour, name, members, who is on
/// duty now and how many chores use the group.
class DutyGroupCard extends ConsumerWidget {
  const DutyGroupCard({required this.group, super.key});

  final DutyGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final index = ref.watch(dutyMemberIndexProvider);
    final onDuty = ref.watch(groupOnDutyProvider(group.id));
    final choreCount = ref.watch(dutyGroupTemplatesProvider(group.id)).length;
    final formatters = ref.watch(appFormattersProvider);
    final palette = t.placeholderPalette;
    final colorIndex = group.colorIndex;
    final color = colorIndex == null
        ? t.accent
        : palette[colorIndex % palette.length];
    final members = group.members;

    return AppCard(
      onTap: () => context.push(AppRoutes.choresDutyGroup(group.id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(t.radiusSm),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dutyGroupName(context, group),
                    style: textTheme.titleMedium?.copyWith(
                      color: t.textPrimary,
                    ),
                  ),
                ),
                if (!group.active) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.pause_circle_outline, size: 18, color: t.statusSkipped),
                  const SizedBox(width: 4),
                  Text(
                    l10n.dutyGroupSwitchedOff,
                    style: textTheme.labelMedium?.copyWith(
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            AvatarStack(
              members: stackMembers(index, members),
              overflowSemanticLabel: members
                  .map((id) => memberName(index, id))
                  .join(', '),
            ),
            const SizedBox(height: 8),
            Text(
              onDuty == null
                  ? l10n.dutyGroupNobodyOnDuty
                  : l10n.dutyGroupOnDutyNow(memberName(index, onDuty)),
              style: textTheme.bodyMedium?.copyWith(color: t.textPrimary),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 16,
              children: [
                Text(
                  l10n.dutyGroupMemberCount(formatters.number(members.length)),
                  style: textTheme.bodySmall?.copyWith(color: t.textSecondary),
                ),
                Text(
                  l10n.dutyGroupChoreCount(formatters.number(choreCount)),
                  style: textTheme.bodySmall?.copyWith(color: t.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
