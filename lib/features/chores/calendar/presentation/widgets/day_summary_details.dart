import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart'
    show widgetStatusOf;
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:flutter/material.dart';

class DaySummaryDetails extends StatelessWidget {
  const DaySummaryDetails({
    required this.summary,
    required this.formatters,
    super.key,
  });

  final DaySummary summary;
  final AppFormatters formatters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _DayCountChip(
              label: l10n.calendarCellChores(formatters.number(summary.total)),
            ),
            _DayCountChip(
              status: ChoreStatus.completed,
              label: l10n.calendarCellProgress(
                formatters.number(summary.doneCount),
                formatters.number(summary.total),
              ),
            ),
            if (summary.openCount > 0)
              _DayCountChip(
                label: l10n.calendarDayOpenCount(
                  formatters.number(summary.openCount),
                ),
              ),
            if (summary.countOf(ChoreStatus.overdue) > 0)
              _DayCountChip(
                status: ChoreStatus.overdue,
                label: l10n.calendarCellOverdue(
                  formatters.number(summary.countOf(ChoreStatus.overdue)),
                ),
              ),
            if (summary.skippedCount > 0)
              _DayCountChip(
                status: ChoreStatus.skipped,
                label: l10n.calendarDaySkippedCount(
                  formatters.number(summary.skippedCount),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCountChip extends StatelessWidget {
  const _DayCountChip({required this.label, this.status});

  final String label;
  final ChoreStatus? status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(t.radiusPill),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          if (status != null)
            StatusGlyph(status: widgetStatusOf(status!), size: 14),
          Text(label, style: TextStyle(color: t.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
