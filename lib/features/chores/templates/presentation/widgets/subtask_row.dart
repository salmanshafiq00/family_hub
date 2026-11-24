import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/draft_text_field.dart';
import 'package:family_hub/shared/widgets/reorder_move_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One step of a chore (P3-16): its controls, then its title on a line of its
/// own, so a long Bangla step on a 360 dp phone still gets the full card width.
///
/// Rule 71 keeps the non-drag move buttons beside the drag handle; the title is
/// no longer squeezed between them.
class SubtaskRow extends ConsumerWidget {
  const SubtaskRow({
    required this.index,
    required this.subtask,
    required this.enabled,
    required this.onChanged,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    super.key,
  });

  final int index;
  final TemplateSubtask subtask;
  final bool enabled;
  final ValueChanged<TemplateSubtask> onChanged;
  final VoidCallback onRemove;

  /// Rule 71: the non-drag twin of the handle.
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final hint = subtask.hint;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: t.outline),
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (enabled)
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.drag_handle_rounded, color: t.outline),
                  ),
                ),
              Expanded(
                child: Text(
                  l10n.choreSubtaskStepNumber(formatters.number(index + 1)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              ReorderMoveButtons(
                index: index,
                onMoveUp: onMoveUp,
                onMoveDown: onMoveDown,
              ),
              IconButton(
                key: ValueKey<String>('subtask_remove_${subtask.id}'),
                tooltip: l10n.choreSubtaskRemove,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: enabled ? onRemove : null,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          DraftTextField(
            key: ValueKey<String>('subtask_title_${subtask.id}'),
            value: subtask.title,
            label: l10n.choreSubtaskTitle,
            maxLength: 120,
            minLines: 1,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            enabled: enabled,
            onChanged: (text) => onChanged(subtask.copyWith(title: text)),
          ),
          SwitchListTile(
            key: ValueKey<String>('subtask_required_${subtask.id}'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            value: subtask.required,
            title: Text(l10n.choreSubtaskRequired),
            onChanged: enabled
                ? (v) => onChanged(subtask.copyWith(required: v))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DraftTextField(
              key: ValueKey<String>('subtask_hint_${subtask.id}'),
              value: hint ?? '',
              label: l10n.choreSubtaskHint,
              maxLength: 200,
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              enabled: enabled,
              // `copyWith` cannot clear a hint, so an empty text rebuilds the
              // step without one (keeps "unsaved changes" honest).
              onChanged: (text) => onChanged(
                TemplateSubtask(
                  id: subtask.id,
                  title: subtask.title,
                  required: subtask.required,
                  hint: text.isEmpty ? null : text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
