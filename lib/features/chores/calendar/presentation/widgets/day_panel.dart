import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_summary_details.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/widgets/day_part_section.dart';
import 'package:family_hub/features/chores/presentation/widgets/today_row.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The snap points of the day panel, as a fraction of the screen (B.5).
const List<double> kDayPanelSnaps = <double>[0.28, 0.55, 0.92];

/// The selected day's chores in a bottom sheet the person drags between three
/// heights (P3-23). Header: the date and count. Rows: the same `TodayRow` as
/// everywhere, grouped by day part.
///
/// On a tablet the same list is shown permanently beside the grid by
/// [DayPanelPane] (P3-24).
class DayPanel extends ConsumerWidget {
  const DayPanel({required this.day, super.key});

  final DateKey day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return DraggableScrollableSheet(
      key: const Key('calendar_day_panel'),
      initialChildSize: kDayPanelSnaps.first,
      minChildSize: kDayPanelSnaps.first,
      maxChildSize: kDayPanelSnaps.last,
      snap: true,
      snapSizes: kDayPanelSnaps,
      builder: (context, controller) => Material(
        color: t.surfaceRaised,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(t.radiusLg)),
        ),
        clipBehavior: Clip.antiAlias,
        child: DayPanelList(day: day, controller: controller, handle: true),
      ),
    );
  }
}

/// The permanent day panel of the tablet two-pane layout (P3-24): the same
/// content as [DayPanel], in a raised surface that does not move.
class DayPanelPane extends ConsumerWidget {
  const DayPanelPane({required this.day, super.key});

  final DateKey day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    return Semantics(
      container: true,
      label: context.l10n.calendarDayPanelLabel,
      child: Material(
        key: const Key('calendar_day_pane'),
        color: t.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusLg),
        ),
        clipBehavior: Clip.antiAlias,
        child: DayPanelList(day: day),
      ),
    );
  }
}

/// The header and the chores of [day]. [controller] is the sheet's scroll
/// controller (null in the permanent pane); [handle] draws the drag handle.
class DayPanelList extends ConsumerWidget {
  const DayPanelList({
    required this.day,
    this.controller,
    this.handle = false,
    super.key,
  });

  final DateKey day;
  final ScrollController? controller;
  final bool handle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final formatters = ref.watch(appFormattersProvider);
    final items = ref.watch(dayPanelItemsProvider(day));
    final summary = ref
        .watch(calendarMonthModelProvider(day.monthKey))
        .value
        ?.summaryOf(day);
    final date = DateTime.utc(day.year, day.month, day.day);
    final count = items.hasValue ? items.requireValue.length : 0;

    final Widget body;
    if (items.hasValue) {
      final list = items.requireValue;
      body = list.isEmpty
          ? EmptyState(
              icon: Icons.event_available_rounded,
              title: l10n.calendarDayEmptyTitle,
              message: l10n.calendarDayEmptyMessage,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (part, group) in groupByDayPart(list)) ...[
                  DayPartSection(part: part, count: group.length),
                  for (final item in group) TodayRow(item: item),
                ],
              ],
            );
    } else if (items.hasError) {
      final error = items.error;
      body = ErrorView(
        message: l10n.choresFailureMessage(
          error is AppFailure ? error : Unknown(error),
        ),
        onRetry: () => ref.invalidate(monthOccurrencesProvider(day.monthKey)),
      );
    } else {
      body = const SizedBox(height: 120, child: LoadingView());
    }

    return ListView(
      controller: controller,
      // The sheet's own controller drives the drag; the pane scrolls itself.
      primary: false,
      padding: EdgeInsets.fromLTRB(
        12,
        handle ? 0 : 12,
        12,
        kCalendarBottomClearance,
      ),
      children: [
        if (handle)
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: t.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.calendarDayHeader(
                  '${formatters.fullDate(date)}, '
                  '${formatters.weekdayName(day.isoWeekday)}',
                  formatters.number(count),
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (summary != null && summary.total > 0) ...[
          const SizedBox(height: 8),
          DaySummaryDetails(summary: summary, formatters: formatters),
        ],
        const SizedBox(height: 8),
        body,
      ],
    );
  }
}
