import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/presentation/template_labels.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/draft_text_field.dart';
import 'package:family_hub/shared/widgets/minutes_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The times of day a chore is due at, up to [TemplateLimits.maxSlots] (P3-16).
///
/// Each slot picks one of the family's ACTIVE due-time presets (chips from
/// `dueTimePresetsProvider`) or any custom time with a [MinutesField]; "end of
/// day" is the empty time. A slot's due time is stored as minutes, so a preset
/// that is later turned off never changes a chore that already used its time:
/// the stored minutes simply show in the custom field.
///
/// The first slot is always `main` and cannot be removed. A slot added here
/// gets a key `s2`, `s3`, ... that never changes afterwards, because the key is
/// part of every occurrence id (D-P3-3); renaming a slot only changes its label.
class SlotsEditor extends ConsumerWidget {
  const SlotsEditor({
    required this.slots,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final List<TemplateSlot> slots;
  final ValueChanged<List<TemplateSlot>> onChanged;
  final bool enabled;

  /// A key not used by [slots]: `s2`, `s3`, ... (matches `[a-z0-9]{1,12}`).
  static String nextSlotKey(Iterable<String> used) {
    final taken = used.toSet();
    var n = 2;
    while (taken.contains('s$n')) {
      n++;
    }
    return 's$n';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final presets = ref.watch(dueTimePresetsProvider);
    final formatters = ref.watch(appFormattersProvider);
    final canAdd = enabled && slots.length < TemplateLimits.maxSlots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < slots.length; i++)
          Padding(
            key: ValueKey<String>('slot_${slots[i].key}'),
            padding: const EdgeInsets.only(bottom: 12),
            child: _SlotCard(
              index: i,
              slot: slots[i],
              presets: presets,
              formatters: formatters,
              enabled: enabled,
              onChanged: (slot) => onChanged(<TemplateSlot>[
                for (var j = 0; j < slots.length; j++)
                  if (j == i) slot else slots[j],
              ]),
              onRemove: slots[i].isMain || !enabled
                  ? null
                  : () => onChanged(<TemplateSlot>[
                      for (var j = 0; j < slots.length; j++)
                        if (j != i) slots[j],
                    ]),
            ),
          ),
        if (canAdd)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              key: const ValueKey<String>('slot_add'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => onChanged(<TemplateSlot>[
                ...slots,
                TemplateSlot(
                  key: nextSlotKey(slots.map((s) => s.key)),
                  dueMinutes: presets.isEmpty ? null : presets.first.minutes,
                ),
              ]),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.choreSlotAdd),
            ),
          )
        else if (slots.length >= TemplateLimits.maxSlots)
          Text(
            l10n.choreSlotLimit(formatters.number(TemplateLimits.maxSlots)),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: t.textSecondary),
          ),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    required this.index,
    required this.slot,
    required this.presets,
    required this.formatters,
    required this.enabled,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final TemplateSlot slot;
  final List<DueTimePreset> presets;
  final AppFormatters formatters;
  final bool enabled;
  final ValueChanged<TemplateSlot> onChanged;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: t.outline),
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.choreSlotTitle(formatters.number(index + 1)),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (onRemove != null)
                IconButton(
                  key: ValueKey<String>('slot_remove_${slot.key}'),
                  tooltip: l10n.choreSlotRemove,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          // The main slot may stay unnamed; a second one needs a label so the
          // family can tell the times apart in the day list.
          DraftTextField(
            key: ValueKey<String>('slot_label_${slot.key}'),
            value: slot.labelBn ?? '',
            label: index == 0
                ? l10n.choreSlotLabel
                : l10n.choreSlotLabelRequired,
            maxLength: 30,
            enabled: enabled,
            onChanged: (text) => onChanged(
              TemplateSlot(
                key: slot.key,
                labelBn: text.trim().isEmpty ? null : text,
                labelEn: slot.labelEn,
                dueMinutes: slot.dueMinutes,
              ),
            ),
          ),
          if (index > 0 && (slot.labelBn ?? '').trim().isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.choreSlotLabelNeeded,
                key: ValueKey<String>('slot_label_needed_${slot.key}'),
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: t.textSecondary),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final preset in presets)
                ChoiceChip(
                  key: ValueKey<String>('slot_${slot.key}_preset_${preset.id}'),
                  label: Text(
                    localizedName(context, preset.labelBn, preset.labelEn),
                  ),
                  selected: slot.dueMinutes == preset.minutes,
                  showCheckmark: true,
                  onSelected: enabled
                      ? (_) =>
                            onChanged(slot.copyWith(dueMinutes: preset.minutes))
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 8),
          MinutesField(
            key: ValueKey<String>('slot_${slot.key}_minutes'),
            label: l10n.choreSlotDueTime,
            minutes: slot.dueMinutes,
            formatters: formatters,
            enabled: enabled,
            onChanged: (m) => onChanged(
              m == null
                  ? slot.copyWith(clearDueMinutes: true)
                  : slot.copyWith(dueMinutes: m),
            ),
          ),
        ],
      ),
    );
  }
}
