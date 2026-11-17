import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_month_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// The rows of day cells of one month (P3-22). Pure drawing: it takes the model
/// and callbacks, never a provider.
///
/// P3-24: every week is its own `RepaintBoundary` (a selection change repaints
/// one row, not the month) and its own semantics ROW, so a screen reader can
/// move through the grid by row and column.
///
/// P4-23: the TABLE role is set here, not by the caller. Flutter requires every
/// child of a table node to be a row, and the pager between the caller and this
/// grid adds its own scrollable node, which broke that rule.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    required this.model,
    required this.selectedDay,
    required this.memberStyles,
    required this.viewerId,
    required this.formatters,
    required this.cellHeight,
    required this.onSelect,
    required this.onLongPress,
    super.key,
  });

  final CalendarMonthModel model;
  final DateKey selectedDay;
  final Map<String, CalendarMemberStyle> memberStyles;
  final String? viewerId;
  final AppFormatters formatters;
  final double cellHeight;
  final ValueChanged<DateKey> onSelect;
  final ValueChanged<DateKey> onLongPress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      role: SemanticsRole.table,
      container: true,
      label: context.l10n.calendarGridLabel,
      child: Column(
        children: [
          for (final week in model.weeks)
            RepaintBoundary(
              child: Semantics(
                role: SemanticsRole.row,
                container: true,
                child: Row(
                  children: [
                    for (final summary in week)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: DayCell(
                            summary: summary,
                            selected: summary.dateKey == selectedDay,
                            memberStyles: memberStyles,
                            viewerId: viewerId,
                            formatters: formatters,
                            minHeight: cellHeight,
                            onTap: () => onSelect(summary.dateKey),
                            onLongPress: () => onLongPress(summary.dateKey),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
