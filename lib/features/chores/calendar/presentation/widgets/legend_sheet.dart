import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/presentation/painters/calendar_date_border_painter.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart'
    show statusLabelOf, widgetStatusOf;
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:family_hub/shared/widgets/flag_chip.dart';
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:flutter/material.dart';

/// "What the symbols mean": status shapes, availability and attention marks.
Future<void> showLegendSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const LegendSheet(),
    );

class LegendSheet extends StatelessWidget {
  const LegendSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(l10n.calendarLegend, style: textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            for (final status in ChoreStatus.values)
              _LegendRow(
                leading: StatusGlyph(status: widgetStatusOf(status), size: 18),
                text: statusLabelOf(status, l10n),
              ),
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                l10n.calendarLegendMarks,
                style: textTheme.titleSmall,
              ),
            ),
            _LegendRow(
              leading: const _AvatarLegendMark(),
              text: l10n.calendarLegendAvatarDescription,
            ),
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                l10n.calendarLegendDateStates,
                style: textTheme.titleSmall,
              ),
            ),
            _LegendRow(
              leading: const _DateSurfaceMark(scheduled: true),
              text: l10n.calendarLegendScheduledSurface,
            ),
            _LegendRow(
              leading: const _DateSurfaceMark(),
              text: l10n.calendarLegendPastSurface,
            ),
            _LegendRow(
              leading: const _DateSurfaceMark(today: true),
              text: l10n.calendarLegendTodaySurface,
            ),
            _LegendRow(
              leading: const _DateBorderMark(
                state: CalendarDateBorderState.overdue,
              ),
              text: l10n.calendarLegendOverdueBorder,
            ),
            _LegendRow(
              leading: const _DateBorderMark(
                state: CalendarDateBorderState.completed,
              ),
              text: l10n.calendarLegendCompletedBorder,
            ),
            _LegendRow(
              leading: Icon(
                FlagChip.iconFor(ChoreFlag.needsCover),
                color: FlagChip.toneFor(
                  ChoreFlag.needsCover,
                  context.tokens,
                ).foreground,
              ),
              text: FlagChip.labelFor(ChoreFlag.needsCover, l10n),
            ),
            _LegendRow(
              leading: Icon(
                FlagChip.iconFor(ChoreFlag.needsAttention),
                color: FlagChip.toneFor(
                  ChoreFlag.needsAttention,
                  context.tokens,
                ).foreground,
              ),
              text: FlagChip.labelFor(ChoreFlag.needsAttention, l10n),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarLegendMark extends StatelessWidget {
  const _AvatarLegendMark();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: 28,
      height: 28,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: t.accent, width: 2),
      ),
      child: ExcludeSemantics(
        child: AppAvatar(
          id: 'calendar_legend',
          name: context.l10n.calendarLegendYouAvatar,
          avatarKey: 'p0',
          size: 20,
        ),
      ),
    );
  }
}

class _DateSurfaceMark extends StatelessWidget {
  const _DateSurfaceMark({this.scheduled = false, this.today = false});

  final bool scheduled;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = today
        ? t.accent
        : scheduled
        ? t.statusScheduledContainer
        : t.surfaceSunken;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(t.radiusSm),
        border: today ? Border.all(color: t.textOnAccent, width: 2) : null,
      ),
    );
  }
}

class _DateBorderMark extends StatelessWidget {
  const _DateBorderMark({required this.state});

  final CalendarDateBorderState state;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = state == CalendarDateBorderState.overdue
        ? t.statusOverdueOn
        : t.statusCompletedOn;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radiusSm),
      ),
      child: CustomPaint(
        foregroundPainter: CalendarDateBorderPainter(
          state: state,
          stateColor: color,
          isToday: false,
          todayColor: t.textOnAccent,
          isSelected: false,
          selectedColor: t.accent,
          radius: t.radiusSm,
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.leading, required this.text});

  final Widget leading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          SizedBox(width: 28, child: Center(child: leading)),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
