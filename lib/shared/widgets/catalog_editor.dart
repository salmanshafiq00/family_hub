import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/shared/widgets/catalog_entry_dialog.dart';
import 'package:family_hub/shared/widgets/reorder_move_buttons.dart';
import 'package:flutter/material.dart';

part 'catalog_editor_parts.dart';

/// One editable row of a [CatalogEditor].
///
/// The same shape serves chore groups, due-time presets and absence reasons
/// (road map 3.2), so P3-17 edits three lists with one widget instead of three
/// near-identical screens.
@immutable
class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.labelBn,
    this.labelEn,
    this.active = true,
    this.builtIn = false,
    this.detail,
    this.extra,
  });

  /// Stable machine id (`kitchen`, `morning`, …). Never shown.
  final String id;

  final String labelBn;
  final String? labelEn;

  /// Inactive rows stay in the list but are no longer offered as a choice.
  final bool active;

  /// Built-in rows can be edited and deactivated; deleting one is allowed only
  /// when the editor sets [CatalogEditor.canDeleteBuiltIn].
  final bool builtIn;

  /// A short secondary line (for a preset: the time; for a group: the colour).
  /// Already formatted by the caller.
  final String? detail;
  final Object? extra;

  CatalogEntry copyWith({
    String? labelBn,
    String? labelEn,
    bool? active,
    String? detail,
    Object? extra,
  }) => CatalogEntry(
    id: id,
    labelBn: labelBn ?? this.labelBn,
    labelEn: labelEn ?? this.labelEn,
    active: active ?? this.active,
    builtIn: builtIn,
    detail: detail ?? this.detail,
    extra: extra ?? this.extra,
  );

  @override
  bool operator ==(Object other) =>
      other is CatalogEntry &&
      other.id == id &&
      other.labelBn == labelBn &&
      other.labelEn == labelEn &&
      other.active == active &&
      other.builtIn == builtIn &&
      other.detail == detail &&
      other.extra == extra;

  @override
  int get hashCode =>
      Object.hash(id, labelBn, labelEn, active, builtIn, detail, extra);
}

/// Reorderable, add/edit/deactivate list of [CatalogEntry] rows (P3-04).
///
/// The editor is a pure view: it holds no state and never writes anywhere. It
/// reports the WHOLE new list through [onChanged] for every action (reorder,
/// add, rename, deactivate), so the caller keeps one list and one use case.
/// Rows are drag handles plus an action menu; every action target is 48 dp.
class CatalogEditor extends StatelessWidget {
  const CatalogEditor({
    required this.entries,
    required this.onChanged,
    this.title,
    this.addLabel,
    this.emptyLabel,
    this.canReorder = true,
    this.canDeleteBuiltIn = false,
    this.onEditEntry,
    this.onBeforeToggleActive,
    super.key,
  });

  final List<CatalogEntry> entries;

  /// Called with the full new list after every action.
  final ValueChanged<List<CatalogEntry>> onChanged;

  final String? title;

  /// Label of the add button; defaults to the localized "Add".
  final String? addLabel;

  /// Shown when the list is empty.
  final String? emptyLabel;

  final bool canReorder;

  /// Offers "delete" for a built-in row too (chore groups: a family may want
  /// its own set). The caller is responsible for the confirmation.
  final bool canDeleteBuiltIn;

  final Future<CatalogEntry?> Function(BuildContext, CatalogEntry?)?
  onEditEntry;
  final Future<bool> Function(BuildContext, CatalogEntry)? onBeforeToggleActive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
        ],
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              emptyLabel ?? l10n.catalogEditorEmpty,
              style: TextStyle(color: tokens.textSecondary),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: entries.length,
            // `onReorderItem` already reports the final index of the moved row
            // (the deprecated `onReorder` did not), so no off-by-one shift.
            onReorderItem: _move,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _Row(
                key: ValueKey<String>(entry.id),
                entry: entry,
                index: index,
                showHandle: canReorder,
                // Rule 71: the drag handle needs a non-drag twin, and a
                // screen reader can only use the buttons.
                onMoveUp: canReorder && index > 0
                    ? () => _move(index, index - 1)
                    : null,
                onMoveDown: canReorder && index < entries.length - 1
                    ? () => _move(index, index + 1)
                    : null,
                onEdit: () => _edit(context, entry),
                onToggleActive: () => _handleToggle(context, entry),
                onDelete: entry.builtIn && !canDeleteBuiltIn
                    ? null
                    : () => _remove(entry),
              );
            },
          ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => _add(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(addLabel ?? l10n.actionAdd),
          ),
        ),
      ],
    );
  }

  /// Moves a row to [newIndex], the index it ends up at - what both
  /// `onReorderItem` and the move buttons report.
  void _move(int oldIndex, int newIndex) {
    final next = <CatalogEntry>[...entries];
    final moved = next.removeAt(oldIndex);
    next.insert(newIndex, moved);
    onChanged(next);
  }

  void _replace(CatalogEntry before, CatalogEntry after) => onChanged([
    for (final e in entries)
      if (e.id == before.id) after else e,
  ]);

  void _remove(CatalogEntry entry) =>
      onChanged(entries.where((e) => e.id != entry.id).toList());

  /// Adds a row with a stable `custom_N` id (never `builtIn`).
  void _add(BuildContext context) => _edit(context, null);

  Future<void> _handleToggle(BuildContext context, CatalogEntry entry) async {
    if (onBeforeToggleActive != null) {
      final allowed = await onBeforeToggleActive!(context, entry);
      if (!allowed) return;
    }
    _replace(entry, entry.copyWith(active: !entry.active));
  }

  Future<void> _edit(BuildContext context, CatalogEntry? existing) async {
    if (onEditEntry != null) {
      final custom = await onEditEntry!(context, existing);
      if (custom == null) return;
      if (existing == null) {
        onChanged([...entries, custom]);
      } else {
        _replace(existing, custom);
      }
      return;
    }
    final result = await showCatalogEntryDialog(context, entry: existing);
    if (result == null) return;
    if (existing == null) {
      final id = _nextCustomId();
      onChanged([
        ...entries,
        CatalogEntry(id: id, labelBn: result.bn, labelEn: result.en),
      ]);
      return;
    }
    _replace(
      existing,
      existing.copyWith(labelBn: result.bn, labelEn: result.en),
    );
  }

  /// `custom_1`, `custom_2`, … — the smallest number not in use.
  String _nextCustomId() {
    final used = entries.map((e) => e.id).toSet();
    var n = 1;
    while (used.contains('custom_$n')) {
      n++;
    }
    return 'custom_$n';
  }
}
