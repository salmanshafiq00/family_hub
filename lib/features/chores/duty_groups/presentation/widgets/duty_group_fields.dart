import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/shared/widgets/color_swatch_picker.dart';
import 'package:flutter/material.dart';

/// The name, colour and (for a stored group) active switch of the duty-group
/// editor (P3-18). The owner keeps the controllers and the values.
class DutyGroupFields extends StatelessWidget {
  const DutyGroupFields({
    required this.nameBn,
    required this.nameEn,
    required this.colorIndex,
    required this.onColor,
    this.enabled = true,
    this.active,
    this.onActive,
    super.key,
  });

  final TextEditingController nameBn;
  final TextEditingController nameEn;
  final int colorIndex;
  final ValueChanged<int> onColor;
  final bool enabled;

  /// Null hides the switch (a new group is always active).
  final bool? active;
  final ValueChanged<bool>? onActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final switchValue = active;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey<String>('name_bn'),
          controller: nameBn,
          enabled: enabled,
          maxLength: DutyGroupLimits.maxNameLength,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: l10n.dutyGroupNameBn),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const ValueKey<String>('name_en'),
          controller: nameEn,
          enabled: enabled,
          maxLength: DutyGroupLimits.maxNameLength,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: l10n.dutyGroupNameEn),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.choresGroupColor,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        ColorSwatchPicker(
          selectedIndex: colorIndex,
          onChanged: onColor,
          enabled: enabled,
        ),
        if (switchValue != null)
          SwitchListTile(
            key: const ValueKey<String>('active_switch'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.dutyGroupActive),
            subtitle: Text(l10n.dutyGroupActiveSubtitle),
            value: switchValue,
            onChanged: enabled ? onActive : null,
          ),
      ],
    );
  }
}
