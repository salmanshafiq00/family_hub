import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/app/theme/heat_ramp.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_motion.dart';
import 'package:family_hub/features/chores/calendar/presentation/painters/hatch_painter.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell_label.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_corner_marks.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_markers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// One day of the month grid (Appendix B.2, polished in P3-24).
///
/// * the date number in a pill: TODAY = a 2 dp ring, SELECTED = a filled pill
///   that grows in (two different shapes, so neither depends on colour);
/// * the markers row ([DayMarkers]);
/// * HEAT: a tint behind the cell from `summary.heatLevel` ([HeatRamp]); the
///   text on it is the primary ink (contrast-tested);
/// * HATCH: diagonal lines when every chore of the day is only planned (`/`)
///   and/or somebody is away (`\`); the number then sits on an opaque pill so
///   the lines never cross it;
/// * corner marks for "needs cover" and "needs attention" ([DayCornerMarks]);
/// * a small person mark when some of the day's chores are the viewer's own
///   while the whole family is shown;
/// * a day outside the month is dimmed, untinted, unhatched and has no markers
///   (D-P3-8).
///
/// The whole cell is one button of at least [minHeight] dp that announces
/// [dayCellLabel] as ONE sentence; every decoration is excluded from
/// semantics because that sentence already says it.
class DayCell extends StatelessWidget {
  const DayCell({
    required this.summary,
    required this.selected,
    required this.scope,
    required this.markerStyle,
    required this.formatters,
    required this.minHeight,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final DaySummary summary;
  final bool selected;
  final CalendarScope scope;
  final MarkerStyle markerStyle;
  final AppFormatters formatters;
  final double minHeight;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final ramp = HeatRamp.of(t);
    final outside = summary.isOutsideMonth;
    final tint = outside ? null : ramp.tintOf(summary.heatLevel);
    final directions = outside
        ? const <HatchDirection>{}
        : <HatchDirection>{
            if (summary.hasProjectedOnly) HatchDirection.rising,
            if (summary.unavailableMemberIds.isNotEmpty) HatchDirection.falling,
          };
    // The filled pill uses the theme's designed accent pair; the old
    // accentSoft/accentStrong pair could read as one colour on some displays.
    final numberColour = outside
        ? ramp.outsideMonthText
        : selected
        ? t.textOnAccent
        : t.textPrimary;
    final label = dayCellLabel(
      l10n: context.l10n,
      formatters: formatters,
      summary: summary,
      selected: selected,
    );
    final showMine =
        !outside && scope == CalendarScope.all && summary.mineCount > 0;
    final motion = calendarMotion(context);
    final radius = BorderRadius.circular(t.radiusSm);

    return Semantics(
      role: SemanticsRole.cell,
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: tint ?? Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey<String>('calendar_day_${summary.dateKey}'),
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: CustomPaint(
            painter: directions.isEmpty
                ? null
                : HatchPainter(
                    colour: HeatRamp.hatchLine(t, tint ?? t.background),
                    directions: directions,
                  ),
            // Passthrough keeps the tight cell width, so the content stays
            // centred exactly as before the corner marks were added.
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            _NumberPill(
                              day: formatters.number(summary.dateKey.day),
                              colour: numberColour,
                              selected: selected,
                              today: summary.isToday,
                              opaque: directions.isNotEmpty,
                              motion: motion,
                            ),
                            if (showMine)
                              PositionedDirectional(
                                top: -2,
                                end: -2,
                                child: ExcludeSemantics(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 12,
                                    color: t.accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        DayMarkers(
                          summary: summary,
                          style: markerStyle,
                          formatters: formatters,
                          ink: tint == null ? null : ramp.ink,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!outside)
                  Positioned.fill(
                    child: DayCornerMarks(
                      needsCover: summary.hasNeedsCover,
                      needsAttention: summary.hasNeedsAttention,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The date number: a ring for today, a filled pill that grows in when
/// selected, an opaque disc on a hatched day.
class _NumberPill extends StatelessWidget {
  const _NumberPill({
    required this.day,
    required this.colour,
    required this.selected,
    required this.today,
    required this.opaque,
    required this.motion,
  });

  final String day;
  final Color colour;
  final bool selected;
  final bool today;
  final bool opaque;
  final Duration motion;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return TweenAnimationBuilder<double>(
      key: ValueKey<bool>(selected),
      tween: Tween<double>(begin: selected ? 0.8 : 1, end: 1),
      duration: motion,
      curve: kCalendarCurve,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected
              ? t.accent
              : opaque
              ? t.surface
              : null,
          borderRadius: BorderRadius.circular(t.radiusPill),
          // Today keeps its ring; on the filled pill the ring switches to the
          // on-accent ink so the two shapes stay distinguishable.
          border: today
              ? Border.all(
                  color: selected ? t.textOnAccent : t.accent,
                  width: 2,
                )
              : null,
        ),
        child: Text(
          day,
          maxLines: 1,
          style: TextStyle(
            color: colour,
            fontSize: 14,
            fontWeight: selected || today ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
