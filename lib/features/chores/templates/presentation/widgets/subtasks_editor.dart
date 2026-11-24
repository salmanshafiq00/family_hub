import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/subtask_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The steps of a chore: reorderable, each with a "required" switch and an
/// optional hint, at most [TemplateLimits.maxSubtasks] (P3-16).
///
/// A step's id is stable (`step_1`, `step_2`, ...): ticks on an occurrence are
/// keyed by it, so reordering or renaming never loses a tick. The add button
/// stops at the limit and says why, so the 31st step cannot be created.
class SubtasksEditor extends ConsumerWidget {
  const SubtasksEditor({
    required this.subtasks,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final List<TemplateSubtask> subtasks;
  final ValueChanged<List<TemplateSubtask>> onChanged;
  final bool enabled;

  /// `step_1`, `step_2`, ...: the smallest number not in [used]
  /// (matches `[a-z0-9_]{1,16}`).
  static String nextStepId(Iterable<String> used) {
    final taken = used.toSet();
    var n = 1;
    while (taken.contains('step_$n')) {
      n++;
    }
    return 'step_$n';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final full = subtasks.length >= TemplateLimits.maxSubtasks;

    void replace(int index, TemplateSubtask value) =>
        onChanged(<TemplateSubtask>[
          for (var i = 0; i < subtasks.length; i++)
            if (i == index) value else subtasks[i],
        ]);

    /// [newIndex] is the position the step ends up at, which is what both
    /// `onReorderItem` and the rule 71 move buttons report.
    void move(int oldIndex, int newIndex) {
      final list = <TemplateSubtask>[...subtasks];
      final moved = list.removeAt(oldIndex);
      list.insert(newIndex, moved);
      onChanged(list);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subtasks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.choreSubtasksEmpty,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: t.textSecondary),
            ),
          )
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            // `onReorderItem` reports the final index of the moved row.
            onReorderItem: (oldIndex, newIndex) {
              if (!enabled) return;
              move(oldIndex, newIndex);
            },
            children: [
              for (var i = 0; i < subtasks.length; i++)
                Padding(
                  key: ValueKey<String>('subtask_${subtasks[i].id}'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SubtaskRow(
                    index: i,
                    subtask: subtasks[i],
                    enabled: enabled,
                    onMoveUp: enabled && i > 0 ? () => move(i, i - 1) : null,
                    onMoveDown: enabled && i < subtasks.length - 1
                        ? () => move(i, i + 1)
                        : null,
                    onChanged: (value) => replace(i, value),
                    onRemove: () => onChanged(<TemplateSubtask>[
                      for (var j = 0; j < subtasks.length; j++)
                        if (j != i) subtasks[j],
                    ]),
                  ),
                ),
            ],
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            key: const ValueKey<String>('subtask_add'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: enabled && !full
                ? () => onChanged(<TemplateSubtask>[
                    ...subtasks,
                    TemplateSubtask(
                      id: nextStepId(subtasks.map((s) => s.id)),
                      title: '',
                    ),
                  ])
                : null,
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.choreSubtaskAdd),
          ),
        ),
        if (full)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.choreSubtaskLimit(
                formatters.number(TemplateLimits.maxSubtasks),
              ),
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: t.textSecondary),
            ),
          ),
      ],
    );
  }
}
