import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:flutter/material.dart';

/// Asks before switching a group off because chores still point at it.
///
/// A separate file keeps the editor under the file-size limit; both dialogs
/// are pure UI and take no controller.
Future<bool?> showDeactivateGroupDialog(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.dutyGroupDeactivateTitle),
      content: Text(l10n.dutyGroupDeactivateMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const ValueKey<String>('confirm_deactivate'),
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(l10n.dutyGroupDeactivateConfirm),
        ),
      ],
    ),
  );
}

/// Asks before a soft delete: the group is switched off, never erased.
Future<bool?> showDeleteGroupDialog(
  BuildContext context, {
  required String nameBn,
}) {
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(l10n.dutyGroupDeleteTitle),
      content: Text(l10n.dutyGroupDeleteMessage(nameBn)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const ValueKey<String>('confirm_delete'),
          style: FilledButton.styleFrom(backgroundColor: context.tokens.danger),
          onPressed: () => Navigator.of(dialog).pop(true),
          child: Text(l10n.dutyGroupDelete),
        ),
      ],
    ),
  );
}
