import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

/// One member in a rotation list: drag handle, avatar, name and, for somebody
/// who is no longer active, a warning with icon + text (never colour alone).
///
/// Drag and remove are optional so the same row serves the editor (both), the
/// change sheet's reorder mode (drag only) and the read-only roster (neither).
class RotationMemberRow extends StatelessWidget {
  const RotationMemberRow({
    required this.id,
    required this.name,
    this.index,
    this.avatarKey,
    this.gone = false,
    this.onRemove,
    super.key,
  });

  final String id;
  final String name;
  final String? avatarKey;

  /// The row's index inside a `ReorderableListView`; null hides the handle.
  final int? index;

  /// The member is no longer active: their turns need a cover.
  final bool gone;

  /// Null hides the remove button.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final position = index;
    final remove = onRemove;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          if (position != null)
            ReorderableDragStartListener(
              index: position,
              child: Semantics(
                label: l10n.dutyRotationMoveMember(name),
                excludeSemantics: true,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(Icons.drag_handle, color: t.textSecondary),
                ),
              ),
            ),
          AppAvatar(id: id, name: name, avatarKey: avatarKey, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: textTheme.bodyLarge?.copyWith(color: t.textPrimary),
                ),
                if (gone)
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 16, color: t.danger),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          l10n.dutyMemberGone,
                          style: textTheme.bodySmall?.copyWith(color: t.danger),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (remove != null)
            IconButton(
              tooltip: l10n.dutyRotationRemoveMember(name),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: remove,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
    );
  }
}
