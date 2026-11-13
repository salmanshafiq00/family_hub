import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_controller.dart';
import 'package:family_hub/features/chores/templates/presentation/template_labels.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/draft_text_field.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/icon_key_picker.dart';
import 'package:family_hub/shared/widgets/choice_wrap.dart';
import 'package:family_hub/shared/widgets/color_swatch_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section 1 of the template editor: names, chore group, icon and colour.
///
/// The group list is the family's ACTIVE groups; the group the chore already
/// has stays on the list even when it was turned off since, so opening an old
/// chore never silently changes it.
class EditorBasicsSection extends ConsumerWidget {
  const EditorBasicsSection({
    required this.draft,
    required this.controller,
    required this.enabled,
    this.nameError,
    super.key,
  });

  final TemplateDraft draft;
  final TemplateEditorController controller;
  final bool enabled;
  final String? nameError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final catalogs = ref.watch(choreCatalogsProvider);
    final current = catalogs.groupOf(draft.groupId);
    final groups = <ChoreGroup>[
      for (final g in catalogs.groups)
        if (g.active || g.id == current.id) g,
    ];
    final recentIcons = <String>[
      for (final record in ref.watch(templatesProvider))
        ?record.template.draft.iconKey,
      for (final group in catalogs.groups) group.iconKey,
    ];
    final label = Theme.of(context).textTheme.labelLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DraftTextField(
          key: const ValueKey<String>('name_bn'),
          value: draft.nameBn,
          label: l10n.choreEditorNameBn,
          maxLength: 80,
          enabled: enabled,
          onChanged: controller.setNameBn,
        ),
        const SizedBox(height: 12),
        DraftTextField(
          key: const ValueKey<String>('name_en'),
          value: draft.nameEn ?? '',
          label: l10n.choreEditorNameEn,
          maxLength: 80,
          enabled: enabled,
          onChanged: controller.setNameEn,
        ),
        const SizedBox(height: 16),
        Text(l10n.choreEditorGroup, style: label),
        const SizedBox(height: 8),
        ChoiceWrap<String>(
          selected: current.id,
          onChanged: (id) {
            if (enabled) controller.setGroupId(id);
          },
          options: [
            for (final g in groups)
              ChoiceOption<String>(
                g.id,
                localizedName(context, g.nameBn, g.nameEn),
                key: ValueKey<String>('group_${g.id}'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(l10n.choreEditorIcon, style: label),
        const SizedBox(height: 8),
        IconKeyPicker(
          selected: draft.iconKey ?? current.iconKey,
          recentKeys: recentIcons,
          enabled: enabled,
          onChanged: controller.setIconKey,
        ),
        const SizedBox(height: 16),
        Text(l10n.choreEditorColor, style: label),
        const SizedBox(height: 8),
        ColorSwatchPicker(
          selectedIndex: draft.colorIndex ?? current.colorIndex,
          onChanged: (i) {
            if (enabled) controller.setColorIndex(i);
          },
        ),
      ],
    );
  }
}
