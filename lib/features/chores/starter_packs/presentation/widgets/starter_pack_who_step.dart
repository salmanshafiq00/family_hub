import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:family_hub/shared/widgets/choice_wrap.dart';
import 'package:family_hub/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Step 3: the rotation (P3-19, Appendix G Q8) or "assign later".
///
/// The widget owns no state: every switch and chip calls back into the wizard
/// controller, so leaving the step and coming back never loses a choice.
class StarterPackWhoStep extends StatelessWidget {
  const StarterPackWhoStep({
    required this.members,
    required this.useRotation,
    required this.rotationMemberIds,
    required this.firstMemberId,
    required this.cycleUnit,
    required this.onUseRotation,
    required this.onToggleMember,
    required this.onFirstMember,
    required this.onCycleUnit,
    super.key,
  });

  /// The active roster, in the family repository's order.
  final List<Member> members;

  final bool useRotation;
  final List<String> rotationMemberIds;
  final String? firstMemberId;
  final CycleUnit cycleUnit;

  final ValueChanged<bool> onUseRotation;
  final ValueChanged<String> onToggleMember;
  final ValueChanged<String> onFirstMember;
  final ValueChanged<CycleUnit> onCycleUnit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final canRotate = members.length >= 2;
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: t.textSecondary);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        Text(l10n.starterPackWhoBody, style: bodyStyle),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SwitchListTile(
            key: const ValueKey<String>('starter_use_rotation'),
            value: useRotation,
            onChanged: canRotate ? onUseRotation : null,
            title: Text(l10n.starterPackRotationSwitch),
            subtitle: canRotate ? null : Text(l10n.starterPackRotationNeedsTwo),
          ),
        ),
        if (members.isEmpty) ...<Widget>[
          const SizedBox(height: 12),
          Text(l10n.starterPackNoMembers, style: bodyStyle),
        ],
        if (!useRotation) ...<Widget>[
          const SizedBox(height: 12),
          AppCard(
            color: t.surfaceSunken,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline_rounded, color: t.textSecondary),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.starterPackNoRotationInfo)),
              ],
            ),
          ),
        ] else ...<Widget>[
          SectionHeader(
            title: l10n.starterPackMembersTitle,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              for (final member in members)
                FilterChip(
                  key: ValueKey<String>('starter_member_${member.uid}'),
                  label: Text(member.displayName),
                  selected: rotationMemberIds.contains(member.uid),
                  onSelected: (_) => onToggleMember(member.uid),
                ),
            ],
          ),
          SectionHeader(
            title: l10n.starterPackFirstMemberTitle,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
          ),
          ChoiceWrap<String>(
            selected: firstMemberId,
            onChanged: onFirstMember,
            options: <ChoiceOption<String>>[
              for (final member in members)
                if (rotationMemberIds.contains(member.uid))
                  ChoiceOption<String>(
                    member.uid,
                    member.displayName,
                    key: ValueKey<String>('starter_first_${member.uid}'),
                  ),
            ],
          ),
          SectionHeader(
            title: l10n.starterPackCycleTitle,
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
          ),
          ChoiceWrap<CycleUnit>(
            selected: cycleUnit,
            onChanged: onCycleUnit,
            options: <ChoiceOption<CycleUnit>>[
              ChoiceOption<CycleUnit>(
                CycleUnit.day,
                l10n.dutyRotationUnitDay,
                key: const ValueKey<String>('starter_cycle_day'),
              ),
              ChoiceOption<CycleUnit>(
                CycleUnit.week,
                l10n.dutyRotationUnitWeek,
                key: const ValueKey<String>('starter_cycle_week'),
              ),
              ChoiceOption<CycleUnit>(
                CycleUnit.month,
                l10n.dutyRotationUnitMonth,
                key: const ValueKey<String>('starter_cycle_month'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
