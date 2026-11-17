import 'dart:async';

import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_month_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/calendar_filter_sheet.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/calendar_two_pane.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_panel.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_grid.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_grid_placeholder.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_pager.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/truncated_banner.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/weekday_header_row.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Month view (P3-22, P3-24): the grid, and the selected day's chores.
///
/// Phone: the grid with the draggable day panel over its lower part.
/// Tablet (>= [kTwoPaneMinWidth]): the grid and a permanent day panel side by
/// side ([CalendarTwoPane]). Both read the SAME providers, so the two layouts
/// never disagree.
class MonthBody extends ConsumerWidget {
  const MonthBody({required this.epoch, super.key});

  /// The month the pager's middle page shows; fixed for the screen's lifetime.
  final MonthKey epoch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(calendarFocusProvider);
    final twoPane = MediaQuery.sizeOf(context).width >= kTwoPaneMinWidth;
    final grid = _GridColumn(epoch: epoch, reserveForSheet: !twoPane);
    if (twoPane) {
      return CalendarTwoPane(
        grid: grid,
        panel: DayPanelPane(day: focus.day),
      );
    }
    return Stack(
      children: [
        Positioned.fill(child: grid),
        DayPanel(day: focus.day),
      ],
    );
  }
}

/// The weekday header, the pager of month grids and the truncated banner.
class _GridColumn extends ConsumerWidget {
  const _GridColumn({required this.epoch, required this.reserveForSheet});

  final MonthKey epoch;

  /// Leave room under the grid for the day panel at its lowest snap.
  final bool reserveForSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatters = ref.watch(appFormattersProvider);
    final focus = ref.watch(calendarFocusProvider);
    final memberStyles = ref.watch(calendarMemberStylesProvider);
    final viewerId = ref.watch(currentUidProvider);
    final weekStart = ref.watch(choreSettingsProvider).weekStartDay;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final cellHeight = 56 * scale.clamp(1.0, 2.0);
    final rows = _rowsOf(focus.month, weekStart);
    final controller = ref.read(calendarFocusProvider.notifier);
    final truncated =
        ref.watch(calendarMonthModelProvider(focus.month)).value?.truncated ??
        false;
    final height = MediaQuery.sizeOf(context).height;

    return SingleChildScrollView(
      key: const PageStorageKey<String>('calendar_month'),
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        reserveForSheet ? height * 0.3 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < kCalendarSevenColumnMinWidth
                  ? kCalendarSevenColumnMinWidth
                  : constraints.maxWidth;
              return SingleChildScrollView(
                key: const PageStorageKey<String>('calendar_month_columns'),
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      WeekdayHeaderRow(
                        weekStartDay: weekStart,
                        formatters: formatters,
                      ),
                      SizedBox(
                        height: rows * cellHeight,
                        child: MonthPager(
                          epoch: epoch,
                          month: focus.month,
                          reduceMotion: reduce,
                          onMonthChanged: controller.showMonth,
                          pageBuilder: (context, month) => MonthPage(
                            month: month,
                            weekStartDay: weekStart,
                            cellHeight: cellHeight,
                            selectedDay: focus.day,
                            memberStyles: memberStyles,
                            viewerId: viewerId,
                            onSelect: (day) {
                              unawaited(HapticFeedback.selectionClick());
                              controller.selectDay(day);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (truncated) ...[
            const SizedBox(height: 8),
            TruncatedBanner(
              onOpenFilters: () => unawaited(showCalendarFilterSheet(context)),
            ),
          ],
        ],
      ),
    );
  }

  static int _rowsOf(MonthKey month, int weekStart) {
    final lead = (month.startOfMonth.isoWeekday - weekStart + 7) % 7;
    return ((lead + month.daysInMonth) / 7).ceil();
  }
}

/// One page of the pager: placeholder, error or the grid of [month].
class MonthPage extends ConsumerWidget {
  const MonthPage({
    required this.month,
    required this.weekStartDay,
    required this.cellHeight,
    required this.selectedDay,
    required this.memberStyles,
    required this.viewerId,
    required this.onSelect,
    super.key,
  });

  final MonthKey month;
  final int weekStartDay;
  final double cellHeight;
  final DateKey selectedDay;
  final Map<String, CalendarMemberStyle> memberStyles;
  final String? viewerId;
  final ValueChanged<DateKey> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatters = ref.watch(appFormattersProvider);
    final model = ref.watch(calendarMonthModelProvider(month));
    // P4-23: the pager gives every page the height of the FOCUSED month, so a
    // neighbour with one more week (October 2026 -> November 2026) overflowed
    // that box by the extra row while the finger moved. A page is now laid out
    // at its own height and the viewport clips the last row during the swipe;
    // once a month settles the box matches its rows, so nothing stays hidden.
    Widget grid(Widget child) => OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: child,
    );
    if (model.hasValue) {
      final CalendarMonthModel value = model.requireValue;
      return grid(
        MonthGrid(
          model: value,
          selectedDay: selectedDay,
          memberStyles: memberStyles,
          viewerId: viewerId,
          formatters: formatters,
          cellHeight: cellHeight,
          onSelect: onSelect,
          onLongPress: onSelect,
        ),
      );
    }
    if (model.hasError) {
      final error = model.error;
      return ErrorView(
        message: context.l10n.choresFailureMessage(
          error is AppFailure ? error : Unknown(error),
        ),
        onRetry: () => ref.invalidate(monthOccurrencesProvider(month)),
      );
    }
    return grid(
      MonthGridPlaceholder(
        month: month,
        weekStartDay: weekStartDay,
        formatters: formatters,
        cellHeight: cellHeight,
      ),
    );
  }
}
