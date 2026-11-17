import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/features/chores/calendar/domain/day_cell_state.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/shared/widgets/centered_label.dart';
import 'package:family_hub/shared/widgets/status_chip.dart' show WidgetStatus;
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:flutter/material.dart';

/// How a date cell is painted: its surface, its ink and its pip colour.
///
/// Surface priority (first match wins): selected > today > outside the month >
/// the day's state. Colour is never the only cue: the state also has a pip
/// SHAPE (see [dayCellPipOf]) and a screen-reader label.
final class DayCellStyle {
  const DayCellStyle({
    required this.background,
    required this.ink,
    required this.pip,
    required this.bold,
  });

  /// Null: no surface (a date outside the month).
  final Color? background;

  /// The date number and the "my chores" icon.
  final Color ink;

  /// The state pip.
  final Color pip;
  final bool bold;
}

/// The paint of a cell (see [DayCellStyle] for the priority).
DayCellStyle dayCellStyleOf(
  AppTokens t, {
  required DaySummary summary,
  required DayCellState state,
  required bool selected,
}) {
  if (selected) {
    return DayCellStyle(
      background: t.accent,
      ink: t.textOnAccent,
      pip: t.textOnAccent,
      bold: true,
    );
  }
  if (summary.isToday) {
    return DayCellStyle(
      background: t.accentSoft,
      ink: t.accentStrong,
      pip: t.accentStrong,
      bold: true,
    );
  }
  if (summary.isOutsideMonth) {
    return DayCellStyle(
      background: null,
      ink: t.textDisabled,
      pip: t.textDisabled,
      bold: false,
    );
  }
  return switch (state) {
    DayCellState.overdue => DayCellStyle(
      background: t.statusOverdueContainer,
      ink: t.statusOverdueOn,
      pip: t.statusOverdueOn,
      bold: false,
    ),
    DayCellState.done => DayCellStyle(
      background: t.statusCompletedContainer,
      ink: t.statusCompletedOn,
      pip: t.statusCompletedOn,
      bold: false,
    ),
    DayCellState.inProgress || DayCellState.scheduled => DayCellStyle(
      background: t.statusScheduledContainer,
      ink: t.statusScheduledOn,
      pip: t.statusScheduledOn,
      bold: false,
    ),
    DayCellState.skipped => DayCellStyle(
      background: t.statusSkippedContainer,
      ink: t.statusSkippedOn,
      pip: t.statusSkippedOn,
      bold: false,
    ),
    DayCellState.none => DayCellStyle(
      background: t.surface,
      ink: t.textSecondary,
      pip: t.textSecondary,
      bold: false,
    ),
  };
}

/// The pip shape of a state; null when the cell has no pip (scheduled is a
/// quiet tint on purpose, so overdue stands out).
WidgetStatus? dayCellPipOf(DayCellState state) => switch (state) {
  DayCellState.overdue => WidgetStatus.overdue,
  DayCellState.inProgress => WidgetStatus.inProgress,
  DayCellState.done => WidgetStatus.completed,
  DayCellState.skipped => WidgetStatus.skipped,
  DayCellState.scheduled || DayCellState.none => null,
};

/// The date number, always on the exact centre of the cell. It is its own
/// layer, so nothing else in the cell can push it up or down.
class DayCellNumber extends StatelessWidget {
  const DayCellNumber({
    required this.text,
    required this.color,
    required this.bold,
    super.key,
  });

  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: CenteredLabel(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "I have a chore this day": the person icon, top-start.
class DayCellMineIcon extends StatelessWidget {
  const DayCellMineIcon({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 3,
      start: 3,
      child: ExcludeSemantics(
        child: Icon(
          Icons.person_rounded,
          key: const Key('calendar_cell_mine'),
          size: 12,
          color: color,
        ),
      ),
    );
  }
}

/// The state pip, top-end. It reuses [StatusGlyph], so a pip is the same
/// shape here, in the legend and in the day panel.
class DayCellPip extends StatelessWidget {
  const DayCellPip({required this.status, required this.color, super.key});

  final WidgetStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 3,
      end: 3,
      child: ExcludeSemantics(
        child: StatusGlyph(
          key: const Key('calendar_cell_pip'),
          status: status,
          colourOverride: color,
        ),
      ),
    );
  }
}

/// A small dot, top-centre, that marks today when today is also selected (the
/// selected surface would otherwise hide that it is today).
class DayCellTodayDot extends StatelessWidget {
  const DayCellTodayDot({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4,
      left: 0,
      right: 0,
      child: ExcludeSemantics(
        child: Center(
          child: SizedBox.square(
            dimension: 5,
            child: DecoratedBox(
              key: const Key('calendar_cell_today_dot'),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}
