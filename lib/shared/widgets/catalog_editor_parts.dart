part of 'catalog_editor.dart';

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.index,
    required this.showHandle,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
    super.key,
  });

  final CatalogEntry entry;
  final int index;
  final bool showHandle;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  /// Rule 71: the non-drag twin of the handle. Null where the row cannot go.
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  /// Null where the row cannot be deleted (a protected built-in).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final label = entry.labelBn;
    final detail = entry.detail;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: showHandle
          ? ReorderableDragStartListener(
              index: index,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.drag_handle_rounded, color: tokens.outline),
              ),
            )
          : null,
      title: Text(
        label,
        style: entry.active
            ? null
            : TextStyle(
                color: tokens.textDisabled,
                decoration: TextDecoration.lineThrough,
              ),
      ),
      subtitle: detail == null ? null : Text(detail),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderMoveButtons(
            index: index,
            onMoveUp: onMoveUp,
            onMoveDown: onMoveDown,
          ),
          PopupMenuButton<String>(
            tooltip: l10n.catalogEditorActions,
            onSelected: (action) => switch (action) {
              'edit' => onEdit(),
              'toggle' => onToggleActive(),
              'delete' => onDelete?.call(),
              _ => null,
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
              PopupMenuItem(
                value: 'toggle',
                child: Text(
                  entry.active
                      ? l10n.catalogEditorDeactivate
                      : l10n.catalogEditorActivate,
                ),
              ),
              if (onDelete != null)
                PopupMenuItem(value: 'delete', child: Text(l10n.actionDelete)),
            ],
          ),
        ],
      ),
    );
  }
}
