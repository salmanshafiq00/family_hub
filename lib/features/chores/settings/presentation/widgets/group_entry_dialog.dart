import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/icon_key_picker.dart';
import 'package:family_hub/shared/widgets/color_swatch_picker.dart';
import 'package:flutter/material.dart';

/// Asks for a chore group's names, colour and icon (P3-17). Returns the edited
/// group (same id, same `builtIn`, same `active`), or null when cancelled.
Future<ChoreGroup?> showGroupEntryDialog(
  BuildContext context, {
  required ChoreGroup base,
  required bool isNew,
  List<String> recentIconKeys = const <String>[],
}) => showDialog<ChoreGroup>(
  context: context,
  builder: (_) => _GroupEntryDialog(
    base: base,
    isNew: isNew,
    recentIconKeys: recentIconKeys,
  ),
);

class _GroupEntryDialog extends StatefulWidget {
  const _GroupEntryDialog({
    required this.base,
    required this.isNew,
    required this.recentIconKeys,
  });

  final ChoreGroup base;
  final bool isNew;
  final List<String> recentIconKeys;

  @override
  State<_GroupEntryDialog> createState() => _GroupEntryDialogState();
}

class _GroupEntryDialogState extends State<_GroupEntryDialog> {
  late final TextEditingController _bn = TextEditingController(
    text: widget.base.nameBn,
  );
  late final TextEditingController _en = TextEditingController(
    text: widget.base.nameEn ?? '',
  );
  late int _color = widget.base.colorIndex;
  late String _icon = widget.base.iconKey;

  @override
  void dispose() {
    _bn.dispose();
    _en.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      scrollable: true,
      title: Text(
        widget.isNew ? l10n.choresGroupAddTitle : l10n.choresGroupEditTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const ValueKey<String>('group_name_bn'),
            controller: _bn,
            autofocus: true,
            maxLength: 40,
            decoration: InputDecoration(labelText: l10n.catalogEditorLabelBn),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
            key: const ValueKey<String>('group_name_en'),
            controller: _en,
            maxLength: 40,
            decoration: InputDecoration(labelText: l10n.catalogEditorLabelEn),
          ),
          const SizedBox(height: 8),
          Text(l10n.choresGroupColor),
          const SizedBox(height: 8),
          ColorSwatchPicker(
            selectedIndex: _color,
            onChanged: (i) => setState(() => _color = i),
          ),
          const SizedBox(height: 16),
          Text(l10n.choresGroupIcon),
          const SizedBox(height: 8),
          IconKeyPicker(
            selected: _icon,
            recentKeys: widget.recentIconKeys,
            onChanged: (key) => setState(() => _icon = key),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const ValueKey<String>('group_dialog_save'),
          onPressed: _bn.text.trim().isEmpty ? null : _submit,
          child: Text(l10n.actionSave),
        ),
      ],
    );
  }

  void _submit() {
    final en = _en.text.trim();
    Navigator.of(context).pop(
      ChoreGroup(
        id: widget.base.id,
        nameBn: _bn.text.trim(),
        nameEn: en.isEmpty ? null : en,
        colorIndex: _color,
        iconKey: _icon,
        sortOrder: widget.base.sortOrder,
        active: widget.base.active,
        builtIn: widget.base.builtIn,
      ),
    );
  }
}
