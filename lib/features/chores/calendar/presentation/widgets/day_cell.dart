import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/day_cell_state.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell_label.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell_layers.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell_members.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// One date cell: a rounded surface, the date number on its exact centre, and
/// small layers around it (my-chores icon, state pip, other members).
///
/// The whole cell, gap included, is the tap target: the [kCalendarCellInset]
/// is padding INSIDE the target, not dead space between two cells.
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

  /// The height of the cell (the name is kept from the first calendar).
  final double minHeight;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final outside = summary.isOutsideMonth;
    final state = dayCellStateOf(summary);
    final style = dayCellStyleOf(
      t,
      summary: summary,
      state: state,
      selected: selected,
    );
    final pip = outside ? null : dayCellPipOf(state);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    // The avatar row needs room under the centred number: not at large text
    // and not in a short cell. The people stay in the panel and the label.
    final showMembers =
        !outside &&
        summary.total > 0 &&
        scale < 1.5 &&
        minHeight >= 40 + 14 * scale;
    final label = dayCellLabel(
      l10n: context.l10n,
      formatters: formatters,
      summary: summary,
      selected: selected,
      memberStyles: memberStyles,
    );
    final radius = BorderRadius.circular(t.radiusMd);

    final ink = InkWell(
      key: ValueKey<String>('calendar_day_${summary.dateKey}'),
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: radius,
      child: Stack(
        children: [
          DayCellNumber(
            text: formatters.number(summary.dateKey.day),
            color: style.ink,
            bold: style.bold,
          ),
          if (!outside && summary.mineCount > 0)
            DayCellMineIcon(color: style.ink),
          if (pip != null) DayCellPip(status: pip, color: style.pip),
          if (selected && summary.isToday) DayCellTodayDot(color: style.ink),
          if (showMembers)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Center(
                child: DayCellMembers(
                  loads: summary.byMember,
                  styles: memberStyles,
                  viewerId: viewerId,
                ),
              ),
            ),
        ],
      ),
    );
    final background = style.background;

    return Semantics(
      role: SemanticsRole.cell,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          height: minHeight,
          child: Padding(
            padding: const EdgeInsets.all(kCalendarCellInset),
            child: background == null
                ? Material(type: MaterialType.transparency, child: ink)
                : Material(
                    color: background,
                    shape: RoundedRectangleBorder(borderRadius: radius),
                    clipBehavior: Clip.antiAlias,
                    child: ink,
                  ),
          ),
        ),
      ),
    );
  }
}
