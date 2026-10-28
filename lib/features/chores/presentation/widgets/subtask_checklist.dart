import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart'
    as domain;
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/shared/widgets/step_progress.dart';
import 'package:flutter/material.dart';

/// The step checklist of one chore (P3-15, road map P3-11).
///
/// The PARENT checkbox is the whole-chore control: ticking it ticks every step
/// and completes; unticking it undoes the completion (every step is unticked).
/// A partial chore shows the ring "3/5" next to the title. Every target is at
/// least 48 dp (a [CheckboxListTile] is), and the ring announces the progress.
class SubtaskChecklist extends StatelessWidget {
  const SubtaskChecklist({
    required this.item,
    required this.occurrence,
    required this.formatters,
    required this.onToggleParent,
    required this.onToggleSubtask,
    this.busy = false,
    super.key,
  });

  final domain.ChoreItem item;

  /// The stored document (or the projected draft): it knows which steps are
  /// ticked.
  final ChoreOccurrence occurrence;
  final AppFormatters formatters;
  final VoidCallback onToggleParent;
  final ValueChanged<String> onToggleSubtask;

  /// Disables every control while a write is in flight.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    final total = occurrence.subtasks.length;
    final complete =
        item.status == ChoreStatus.completed ||
        item.status == ChoreStatus.verified;
    final blocked =
        item.status == ChoreStatus.verified ||
        item.status == ChoreStatus.skipped;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.occurrenceStepsTitle,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: t.textPrimary),
              ),
            ),
            if (total > 0)
              StepProgress(
                done: occurrence.doneCount,
                total: total,
                formatters: formatters,
              ),
          ],
        ),
        CheckboxListTile(
          key: const ValueKey('parent_checkbox'),
          value: complete,
          onChanged: busy || blocked ? null : (_) => onToggleParent(),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            l10n.occurrenceActionComplete,
            style: TextStyle(color: t.textPrimary, fontWeight: FontWeight.w600),
          ),
          secondary: complete
              ? Icon(Icons.undo_rounded, color: t.textSecondary)
              : null,
        ),
        for (final subtask in occurrence.subtasks)
          CheckboxListTile(
            key: ValueKey('subtask_${subtask.id}'),
            value: occurrence.subtaskDone.containsKey(subtask.id),
            onChanged: busy || blocked
                ? null
                : (_) => onToggleSubtask(subtask.id),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(subtask.title, style: TextStyle(color: t.textPrimary)),
            subtitle: subtask.hint == null
                ? null
                : Text(
                    subtask.hint!,
                    style: TextStyle(color: t.textSecondary, fontSize: 12),
                  ),
            secondary: subtask.required
                ? Icon(
                    Icons.priority_high_rounded,
                    size: 16,
                    color: t.textSecondary,
                    semanticLabel: l10n.choresFailure_required,
                  )
                : null,
          ),
      ],
    );
  }
}
