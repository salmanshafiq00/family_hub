import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_draft.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/change_rotation.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_labels.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/rotation_member_row.dart';
import 'package:family_hub/shared/widgets/choice_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The mode-specific inputs of the change-rotation sheet (P3-18): who to add,
/// who to remove, or the new order and who goes first.
class ChangeRotationFields extends ConsumerWidget {
  const ChangeRotationFields({
    required this.mode,
    required this.members,
    required this.memberId,
    required this.order,
    required this.startsWith,
    required this.onMember,
    required this.onOrder,
    required this.onStartsWith,
    super.key,
  });

  final RotationChange mode;

  /// The members of the stored rotation, in turn order.
  final List<String> members;
  final String? memberId;
  final List<String> order;
  final String? startsWith;
  final ValueChanged<String> onMember;
  final ValueChanged<List<String>> onOrder;
  final ValueChanged<String> onStartsWith;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final index = ref.watch(dutyMemberIndexProvider);
    final roster = ref.watch(dutyRosterProvider);

    switch (mode) {
      case RotationChange.add:
        final candidates = [
          for (final member in roster)
            if (!members.contains(member.uid)) member,
        ];
        if (candidates.isEmpty) {
          return Text(
            l10n.dutyRotationNoCandidates,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          );
        }
        return ChoiceWrap<String>(
          options: [
            for (final member in candidates)
              ChoiceOption<String>(
                member.uid,
                member.displayName,
                key: ValueKey<String>('pick_${member.uid}'),
              ),
          ],
          selected: memberId,
          onChanged: onMember,
        );
      case RotationChange.remove:
        return ChoiceWrap<String>(
          options: [
            for (final id in members)
              ChoiceOption<String>(
                id,
                memberName(index, id),
                key: ValueKey<String>('pick_$id'),
              ),
          ],
          selected: memberId,
          onChanged: onMember,
        );
      case RotationChange.reorder:
        final draft = RotationDraft(
          members: order,
          startsWith: startsWith,
          startsOn: DateKey(2000, 1, 1),
          cycleUnit: CycleUnit.week,
          weekStartDay: DateTime.saturday,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) =>
                  onOrder(draft.moved(oldIndex, newIndex).members),
              children: [
                for (var i = 0; i < order.length; i++)
                  RotationMemberRow(
                    key: ValueKey<String>('order_${order[i]}'),
                    id: order[i],
                    name: memberName(index, order[i]),
                    avatarKey: index[order[i]]?.avatarKey,
                    index: i,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.dutyRotationStartsWith,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: t.textSecondary),
            ),
            const SizedBox(height: 4),
            ChoiceWrap<String>(
              options: [
                for (final id in order)
                  ChoiceOption<String>(
                    id,
                    memberName(index, id),
                    key: ValueKey<String>('first_$id'),
                  ),
              ],
              selected: draft.firstMember,
              onChanged: onStartsWith,
            ),
          ],
        );
    }
  }
}
