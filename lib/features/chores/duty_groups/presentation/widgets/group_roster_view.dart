import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_labels.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/rotation_member_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The members of a stored group, read-only, in turn order (P3-18). A member
/// who is no longer active carries the "needs a cover" warning.
///
/// A stored rotation changes only through the change sheet, so this list never
/// edits anything.
class GroupRosterView extends ConsumerWidget {
  const GroupRosterView({required this.memberIds, super.key});

  final List<String> memberIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final index = ref.watch(dutyMemberIndexProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.dutyRosterTitle,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: t.textPrimary),
        ),
        const SizedBox(height: 4),
        for (final id in memberIds)
          RotationMemberRow(
            key: ValueKey<String>('roster_$id'),
            id: id,
            name: memberName(index, id),
            avatarKey: index[id]?.avatarKey,
            gone: index.isNotEmpty && !(index[id]?.isActive ?? false),
          ),
      ],
    );
  }
}
