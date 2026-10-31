import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_draft.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_labels.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/rotation_member_row.dart';
import 'package:family_hub/shared/widgets/choice_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edits a [RotationDraft]: members in turn order (drag to reorder, add from
/// the active members, remove), how often the turn changes, who goes first and
/// from which day (P3-18).
///
/// Stateless: the owner keeps the draft. It is also the editor a template's
/// own rotation will use, so it knows nothing about duty groups. Every option
/// list comes from a provider or an enum; no literal id appears here.
class RotationEditor extends ConsumerWidget {
  const RotationEditor({
    required this.draft,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final RotationDraft draft;
  final ValueChanged<RotationDraft> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final formatters = ref.watch(appFormattersProvider);
    final index = ref.watch(dutyMemberIndexProvider);
    final roster = ref.watch(dutyRosterProvider);
    final candidates = [
      for (final member in roster)
        if (!draft.members.contains(member.uid)) member,
    ];
    final canAdd =
        enabled &&
        candidates.isNotEmpty &&
        draft.members.length < RotationLimits.maxMembers;
    final label = textTheme.labelLarge?.copyWith(color: t.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dutyRotationMembers, style: label),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            if (enabled) onChanged(draft.moved(oldIndex, newIndex));
          },
          children: [
            for (var i = 0; i < draft.members.length; i++)
              RotationMemberRow(
                key: ValueKey<String>(draft.members[i]),
                id: draft.members[i],
                name: memberName(index, draft.members[i]),
                avatarKey: index[draft.members[i]]?.avatarKey,
                index: enabled ? i : null,
                gone:
                    index.isNotEmpty &&
                    !(index[draft.members[i]]?.isActive ?? false),
                onRemove: enabled
                    ? () => onChanged(draft.withoutMember(draft.members[i]))
                    : null,
              ),
          ],
        ),
        if (draft.members.length < RotationLimits.minMembers)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              l10n.dutyRotationNeedTwo,
              style: textTheme.bodySmall?.copyWith(color: t.danger),
            ),
          ),
        if (canAdd) ...[
          const SizedBox(height: 8),
          Text(l10n.dutyRotationAddMember, style: label),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final member in candidates)
                ActionChip(
                  key: ValueKey<String>('add_${member.uid}'),
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(member.displayName),
                  onPressed: () => onChanged(draft.withMember(member.uid)),
                ),
            ],
          ),
        ] else if (enabled && candidates.isEmpty)
          Text(
            l10n.dutyRotationNoCandidates,
            style: textTheme.bodySmall?.copyWith(color: t.textSecondary),
          ),
        const SizedBox(height: 16),
        Text(l10n.dutyRotationCycleUnit, style: label),
        const SizedBox(height: 4),
        ChoiceWrap<CycleUnit>(
          options: [
            for (final unit in CycleUnit.values)
              if (offersCycleUnit(unit) || unit == draft.cycleUnit)
                ChoiceOption<CycleUnit>(
                  unit,
                  _unitLabel(context, unit),
                  key: ValueKey<String>('unit_${unit.id}'),
                ),
          ],
          selected: draft.cycleUnit,
          onChanged: (unit) {
            if (enabled) onChanged(draft.copyWith(cycleUnit: unit));
          },
        ),
        if (draft.cycleUnit == CycleUnit.week)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.dutyRotationWeekStart(
                formatters.weekdayName(draft.weekStartDay),
              ),
              style: textTheme.bodySmall?.copyWith(color: t.textSecondary),
            ),
          ),
        if (draft.members.length >= RotationLimits.minMembers) ...[
          const SizedBox(height: 16),
          Text(l10n.dutyRotationStartsWith, style: label),
          const SizedBox(height: 4),
          ChoiceWrap<String>(
            options: [
              for (final id in draft.members)
                ChoiceOption<String>(
                  id,
                  memberName(index, id),
                  key: ValueKey<String>('first_$id'),
                ),
            ],
            selected: draft.firstMember,
            onChanged: (id) {
              if (enabled) onChanged(draft.copyWith(startsWith: id));
            },
          ),
        ],
        const SizedBox(height: 16),
        Text(l10n.dutyRotationStartsOn, style: label),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            key: const ValueKey<String>('starts_on'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: enabled ? () => _pickDate(context) : null,
            icon: const Icon(Icons.event_outlined),
            label: Text(formatters.fullDate(dateOfKey(draft.startsOn))),
          ),
        ),
      ],
    );
  }

  String _unitLabel(BuildContext context, CycleUnit unit) {
    final l10n = context.l10n;
    return switch (unit) {
      CycleUnit.day => l10n.dutyRotationUnitDay,
      CycleUnit.week => l10n.dutyRotationUnitWeek,
      CycleUnit.month => l10n.dutyRotationUnitMonth,
      CycleUnit.occurrence => l10n.dutyRotationUnitOccurrence,
    };
  }

  Future<void> _pickDate(BuildContext context) async {
    final start = dateOfKey(draft.startsOn);
    final picked = await showDatePicker(
      context: context,
      helpText: context.l10n.dutyRotationPickDate,
      initialDate: start,
      firstDate: DateTime.utc(start.year - 1),
      lastDate: DateTime.utc(start.year + 5, 12, 31),
    );
    if (picked != null) onChanged(draft.copyWith(startsOn: keyOfDate(picked)));
  }
}
