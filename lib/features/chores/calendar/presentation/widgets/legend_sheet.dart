import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart'
    show statusLabelOf, widgetStatusOf;
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:family_hub/shared/widgets/flag_chip.dart';
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "What the symbols mean": status shapes, then the REAL date cells (the same
/// widget the grid draws) next to what each one says.
Future<void> showLegendSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const LegendSheet(),
    );

class LegendSheet extends ConsumerWidget {
  const LegendSheet({super.key});

  /// Any day will do: the sample cells only need a number.
  static final DateKey _sample = DateKey(2026, 11, 17);

  static const double _leadingWidth = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final formatters = ref.watch(appFormattersProvider);

    Widget cell(DaySummary summary, {bool selected = false}) =>
        ExcludeSemantics(
          child: IgnorePointer(
            child: DayCell(
              summary: summary,
              selected: selected,
              formatters: formatters,
              minHeight: 48,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        );

    DaySummary of(Map<ChoreStatus, int> counts, {bool today = false}) =>
        DaySummary(
          dateKey: _sample,
          isToday: today,
          total: counts.values.fold(0, (a, b) => a + b),
          counts: counts,
        );

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
              leading: cell(DaySummary(dateKey: _sample)),
              text: l10n.calendarLegendNoChores,
            ),
            _LegendRow(
              leading: cell(of({ChoreStatus.scheduled: 1})),
              text: l10n.calendarCellScheduled,
            ),
            _LegendRow(
              leading: cell(
                of({ChoreStatus.completed: 1, ChoreStatus.scheduled: 1}),
              ),
              text: l10n.statusInProgress,
            ),
            _LegendRow(
              leading: cell(
                of({ChoreStatus.completed: 1, ChoreStatus.verified: 1}),
              ),
              text: l10n.calendarCellCompleted,
            ),
            _LegendRow(
              leading: cell(
                of({ChoreStatus.overdue: 1, ChoreStatus.scheduled: 1}),
              ),
              text: l10n.statusOverdue,
            ),
            _LegendRow(
              leading: cell(of({ChoreStatus.skipped: 1})),
              text: l10n.choreStatusSkipped,
            ),
            _LegendRow(
              leading: cell(DaySummary(dateKey: _sample, isToday: true)),
              text: l10n.calendarToday,
            ),
            _LegendRow(
              leading: cell(DaySummary(dateKey: _sample), selected: true),
              text: l10n.calendarCellSelected,
            ),
            _LegendRow(
              leading: Icon(
                Icons.person_rounded,
                color: context.tokens.accentStrong,
              ),
              text: l10n.calendarLegendMine,
            ),
            _LegendRow(
              leading: const _OtherAvatars(),
              text: l10n.calendarLegendAvatarDescription,
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

/// Two sample avatars: what "other members" look like at the bottom of a cell.
class _OtherAvatars extends StatelessWidget {
  const _OtherAvatars();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAvatar(
            id: 'calendar_legend_a',
            name: 'A',
            avatarKey: 'p0',
            size: 16,
          ),
          SizedBox(width: 2),
          AppAvatar(
            id: 'calendar_legend_b',
            name: 'B',
            avatarKey: 'p2',
            size: 16,
          ),
        ],
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
          SizedBox(
            width: LegendSheet._leadingWidth,
            child: Center(child: leading),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
