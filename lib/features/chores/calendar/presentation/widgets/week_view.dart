import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/date_ranges.dart';
import 'package:family_hub/features/chores/calendar/domain/week_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_summary_details.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/weekday_header_row.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/week_columns.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/widgets/day_part_section.dart';
import 'package:family_hub/features/chores/presentation/widgets/today_row.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// From this width the week is seven columns (B.6).
const double kWeekColumnsMinWidth = 840;

/// The week of the selected day (P3-23).
///
/// Phone: a strip of seven day cells and the selected
/// day's chores below, by day part. Tablet (>= 840 dp): seven columns, one per
/// day. Both read ONE `WeekModel`, so they never disagree with the month grid.
class WeekView extends ConsumerWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(selectedDayProvider);
    final weekStart = ref.watch(choreSettingsProvider).weekStartDay;
    // Keyed on the first day of the week, so moving inside the week reuses it.
    final anchor = startOfWeek(selected, weekStart);
    final model = ref.watch(weekModelProvider(anchor));

    if (model.hasValue) {
      return LayoutBuilder(
        builder: (context, box) => box.maxWidth >= kWeekColumnsMinWidth
            ? WeekColumns(week: model.requireValue)
            : _WeekStrip(week: model.requireValue, selected: selected),
      );
    }
    if (model.hasError) {
      final error = model.error;
      return ErrorView(
        message: l10n.choresFailureMessage(
          error is AppFailure ? error : Unknown(error),
        ),
        onRetry: () =>
            ref.invalidate(monthOccurrencesProvider(selected.monthKey)),
      );
    }
    return const LoadingView();
  }
}

class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.week, required this.selected});

  final WeekModel week;
  final DateKey selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final memberStyles = ref.watch(calendarMemberStylesProvider);
    final viewerId = ref.watch(currentUidProvider);
    final controller = ref.read(calendarFocusProvider.notifier);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final cellHeight = 56 * scale.clamp(1.0, 2.0);
    final day = week.days.firstWhere(
      (d) => d.dateKey == selected,
      orElse: () => week.days.first,
    );
    final date = DateTime.utc(
      day.dateKey.year,
      day.dateKey.month,
      day.dateKey.day,
    );

    return SingleChildScrollView(
      key: const PageStorageKey<String>('calendar_week'),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, kCalendarBottomClearance),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // P4-23: [DayCell] claims the semantics `cell` role and Flutter only
          // accepts cell -> row -> table, so the strip is a one-row table.
          // Without it TalkBack gets a cell with no table to navigate and the
          // debug assertion fires.
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < kCalendarSevenColumnMinWidth
                  ? kCalendarSevenColumnMinWidth
                  : constraints.maxWidth;
              return SingleChildScrollView(
                key: const PageStorageKey<String>('calendar_week_columns'),
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      WeekdayHeaderRow(
                        weekStartDay: week.range.start.isoWeekday,
                        formatters: formatters,
                      ),
                      Semantics(
                        role: SemanticsRole.table,
                        container: true,
                        label: l10n.calendarGridLabel,
                        child: Semantics(
                          role: SemanticsRole.row,
                          container: true,
                          child: Row(
                            children: [
                              for (final d in week.days)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: DayCell(
                                      summary: d.summary,
                                      selected: d.dateKey == selected,
                                      memberStyles: memberStyles,
                                      viewerId: viewerId,
                                      formatters: formatters,
                                      minHeight: cellHeight,
                                      onTap: () =>
                                          controller.selectDay(d.dateKey),
                                      onLongPress: () =>
                                          controller.selectDay(d.dateKey),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                l10n.calendarDayHeader(
                  '${formatters.fullDate(date)}, '
                  '${formatters.weekdayName(day.dateKey.isoWeekday)}',
                  formatters.number(day.items.length),
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (day.summary.total > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: DaySummaryDetails(
                summary: day.summary,
                formatters: formatters,
              ),
            ),
          if (day.items.isEmpty)
            EmptyState(
              icon: Icons.event_available_rounded,
              title: l10n.calendarDayEmptyTitle,
              message: l10n.calendarDayEmptyMessage,
            )
          else
            for (final (part, group) in day.parts) ...[
              DayPartSection(part: part, count: group.length),
              for (final item in group) TodayRow(item: item),
            ],
        ],
      ),
    );
  }
}
