import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/calendar/presentation/painters/calendar_date_border_painter.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell_footer.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell_label.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell_members.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// One rounded date cell with member and completion summaries.
class DayCell extends StatelessWidget {
  const DayCell({
    required this.summary,
    required this.selected,
    required this.formatters,
    required this.minHeight,
    required this.onTap,
    required this.onLongPress,
    this.memberStyles = const <String, CalendarMemberStyle>{},
    this.viewerId,
    super.key,
  });

  final DaySummary summary;
  final bool selected;
  final AppFormatters formatters;
  final Map<String, CalendarMemberStyle> memberStyles;
  final String? viewerId;
  final double minHeight;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final outside = summary.isOutsideMonth;
    final state = _borderState(summary);
    final background = summary.isToday
        ? t.accent
        : outside
        ? t.surface
        : summary.isPast
        ? t.surfaceSunken
        : !summary.isPast && summary.total > 0
        ? t.statusScheduledContainer
        : t.surface;
    final numberColor = summary.isToday
        ? t.textOnAccent
        : outside
        ? t.textDisabled
        : summary.isPast
        ? t.textSecondary
        : !summary.isPast && summary.total > 0
        ? t.statusScheduledOn
        : t.textPrimary;
    final label = dayCellLabel(
      l10n: context.l10n,
      formatters: formatters,
      summary: summary,
      selected: selected,
      memberStyles: memberStyles,
    );
    final radius = BorderRadius.circular(t.radiusMd);

    return Semantics(
      role: SemanticsRole.cell,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey<String>('calendar_day_${summary.dateKey}'),
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: CustomPaint(
            foregroundPainter: CalendarDateBorderPainter(
              state: state,
              stateColor: state == CalendarDateBorderState.overdue
                  ? t.statusOverdueOn
                  : t.statusCompletedOn,
              isToday: summary.isToday,
              todayColor: t.textOnAccent,
              isSelected: selected,
              selectedColor: summary.isToday ? t.textOnAccent : t.accent,
              radius: t.radiusMd,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      formatters.number(summary.dateKey.day),
                      maxLines: 1,
                      style: TextStyle(
                        color: numberColor,
                        fontSize: 14,
                        fontWeight: summary.isToday || selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    if (!outside && summary.total > 0) ...[
                      const SizedBox(height: 2),
                      DayCellMembers(
                        loads: summary.byMember,
                        styles: memberStyles,
                        viewerId: viewerId,
                      ),
                    ],
                    if (!outside && summary.total > 0) ...[
                      const SizedBox(height: 2),
                      DayCellFooter(
                        summary: summary,
                        formatters: formatters,
                        color: numberColor,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  CalendarDateBorderState _borderState(DaySummary summary) {
    if (summary.countOf(ChoreStatus.overdue) > 0) {
      return CalendarDateBorderState.overdue;
    }
    final nonSkipped = summary.total - summary.countOf(ChoreStatus.skipped);
    return nonSkipped > 0 && summary.doneCount == nonSkipped
        ? CalendarDateBorderState.completed
        : CalendarDateBorderState.none;
  }
}
