import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalogs.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/catalog_mapping.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/group_entry_dialog.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/preset_entry_dialog.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/shared/widgets/catalog_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The three catalogs of the settings page (P3-17), each one a shared
/// `CatalogEditor`: chore groups, due-time presets and absence reasons.
///
/// Built-in rows can be renamed and turned off, never removed (the editor only
/// offers "delete" for custom rows). Turning off a group that chores still use
/// asks first; those chores keep the group, it is only hidden for new ones.
class CatalogSections extends ConsumerWidget {
  const CatalogSections({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final ChoreSettings draft;
  final ValueChanged<ChoreSettings> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formatters = ref.watch(appFormattersProvider);
    final catalogs = ChoreCatalogs(draft);
    final usedGroupIds = <String>{
      for (final record in ref.watch(templatesProvider))
        if (!record.template.isArchived) ?record.template.draft.groupId,
    };
    final recentIcons = <String>[
      for (final group in catalogs.groups) group.iconKey,
      for (final record in ref.watch(templatesProvider))
        ?record.template.draft.iconKey,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogEditor(
          key: const ValueKey<String>('groups_catalog'),
          title: l10n.choresSettingsGroupsTitle,
          addLabel: l10n.choresGroupAddTitle,
          entries: [
            for (final g in catalogs.groups) CatalogMapping.groupEntry(g),
          ],
          onEditEntry: (ctx, row) => _editGroup(ctx, row, recentIcons),
          onBeforeToggleActive: (ctx, row) =>
              _confirmGroupOff(ctx, row, usedGroupIds),
          onChanged: (rows) => onChanged(
            draft.copyWith(
              groups: CatalogMapping.groupsFrom(rows, draft.groups),
            ),
          ),
        ),
        const SizedBox(height: 24),
        CatalogEditor(
          key: const ValueKey<String>('presets_catalog'),
          title: l10n.choresSettingsPresetsTitle,
          addLabel: l10n.choresPresetAddTitle,
          // Presets read in clock order, so dragging them has no meaning.
          canReorder: false,
          entries: [
            for (final p in catalogs.presets)
              CatalogMapping.presetEntry(p, formatters.timeOfDay(p.minutes)),
          ],
          onEditEntry: (ctx, row) => _editPreset(ctx, row, formatters),
          onChanged: (rows) => onChanged(
            draft.copyWith(
              dueTimePresets: CatalogMapping.presetsFrom(
                rows,
                draft.dueTimePresets,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        CatalogEditor(
          key: const ValueKey<String>('reasons_catalog'),
          title: l10n.choresSettingsAbsenceReasonsTitle,
          entries: [
            for (final r in draft.absenceReasons) CatalogMapping.reasonEntry(r),
          ],
          onChanged: (rows) => onChanged(
            draft.copyWith(
              absenceReasons: CatalogMapping.reasonsFrom(
                rows,
                draft.absenceReasons,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<CatalogEntry?> _editGroup(
    BuildContext context,
    CatalogEntry? row,
    List<String> recentIconKeys,
  ) async {
    final existing = row?.extra;
    final base = existing is ChoreGroup
        ? existing
        : ChoreGroup(
            id: CatalogMapping.nextCustomId(draft.groups.map((g) => g.id)),
            nameBn: '',
            sortOrder: draft.groups.length,
          );
    final result = await showGroupEntryDialog(
      context,
      base: base,
      isNew: row == null,
      recentIconKeys: recentIconKeys,
    );
    return result == null ? null : CatalogMapping.groupEntry(result);
  }

  Future<CatalogEntry?> _editPreset(
    BuildContext context,
    CatalogEntry? row,
    AppFormatters formatters,
  ) async {
    final existing = row?.extra;
    final base = existing is DueTimePreset
        ? existing
        : DueTimePreset(
            id: CatalogMapping.nextCustomId(
              draft.dueTimePresets.map((p) => p.id),
            ),
            labelBn: '',
            minutes: 540,
          );
    final result = await showPresetEntryDialog(
      context,
      base: base,
      isNew: row == null,
      formatters: formatters,
    );
    return result == null
        ? null
        : CatalogMapping.presetEntry(
            result,
            formatters.timeOfDay(result.minutes),
          );
  }

  Future<bool> _confirmGroupOff(
    BuildContext context,
    CatalogEntry row,
    Set<String> usedGroupIds,
  ) async {
    // Turning a group back on, or turning off one nothing uses, is always fine.
    if (!row.active || !usedGroupIds.contains(row.id)) return true;
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.choresGroupDeactivateWarningTitle),
        content: Text(l10n.choresGroupDeactivateWarningMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('group_off_confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}
