import 'dart:async';

import 'package:animations/animations.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_motion.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/agenda_view.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/calendar_header.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/calendar_toolbar.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/filter_chips_row.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/legend_sheet.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_body.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_pager.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_year_picker_sheet.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/week_view.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Below this width seven cells of about 48 dp do not fit (the grid has 8 dp on
/// each side), so the month is replaced by the week (B.6). The grid never
/// scrolls sideways; it either fits or the week is shown.
const double kMonthMinWidth = 352;

/// A phone held sideways is too short for a month grid and a day panel: its
/// shortest side stays under this many dp (the Material tablet breakpoint), and
/// it gets the Week or the Agenda (P3-24).
const double kPhoneShortestSide = 600;

/// The chore calendar (P3-22 Month, P3-23 Agenda and Week). The body of
/// `ChoresHomeScreen`.
///
/// All three views share ONE selected day, ONE focused month, ONE scope and ONE
/// filter state (`calendarFocusProvider`, `calendarPrefsProvider`); switching
/// views keeps them. Each view keeps its own scroll position (`PageStorageKey`).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  /// The month pager's middle page; fixed for the screen's lifetime.
  late final MonthKey _epoch = ref
      .read(familyDateKeysProvider)
      .today()
      .monthKey;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formatters = ref.watch(appFormattersProvider);
    final focus = ref.watch(calendarFocusProvider);
    final today = ref.watch(todayKeyProvider);
    final stored = ref.watch(calendarViewProvider);
    final size = MediaQuery.sizeOf(context);
    final narrow = size.width < kMonthMinWidth;
    final landscapePhone =
        size.width > size.height && size.shortestSide < kPhoneShortestSide;
    final monthOffered = !narrow && !landscapePhone;
    final view = stored == CalendarViewKind.month && !monthOffered
        ? CalendarViewKind.week
        : stored;
    final controller = ref.read(calendarFocusProvider.notifier);
    final first = _epoch.addMonths(-kCalendarPagesEachWay);
    final last = _epoch.addMonths(kCalendarPagesEachWay);

    Future<void> pick() async {
      final chosen = await showMonthYearPickerSheet(
        context,
        current: focus.month,
        first: first,
        last: last,
        formatters: formatters,
      );
      if (chosen != null) controller.showMonth(chosen);
    }

    final weekly = view == CalendarViewKind.week;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: title, arrows, jump to today, legend.
              CalendarHeader(
                title: formatters.monthLabel(focus.month),
                showToday: focus.month != today.monthKey || focus.day != today,
                showArrows: view != CalendarViewKind.agenda,
                previousLabel: weekly
                    ? l10n.calendarPreviousWeek
                    : l10n.calendarPreviousMonth,
                nextLabel: weekly
                    ? l10n.calendarNextWeek
                    : l10n.calendarNextMonth,
                onTitle: () => unawaited(pick()),
                onPrevious: () => weekly
                    ? controller.shiftDays(-7)
                    : controller.shiftMonth(-1),
                onNext: () =>
                    weekly ? controller.shiftDays(7) : controller.shiftMonth(1),
                onToday: controller.goToToday,
                onLegend: () => unawaited(showLegendSheet(context)),
              ),
              // Row 2: view switcher, whose chores, filters.
              CalendarToolbar(
                view: view,
                enabledViews: <CalendarView>{
                  CalendarViewKind.agenda,
                  CalendarViewKind.week,
                  if (monthOffered) CalendarViewKind.month,
                },
              ),
              if (stored == CalendarViewKind.month && !monthOffered)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    narrow
                        ? l10n.calendarMonthNarrow
                        : l10n.calendarMonthLandscape,
                    key: const Key('calendar_month_narrow'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              // Only drawn while a filter is on.
              const FilterChipsRow(),
            ],
          ),
        ),
        Expanded(
          child: PageTransitionSwitcher(
            duration: calendarMotion(context, kCalendarMotionLong),
            transitionBuilder: (child, animation, secondary) =>
                FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondary,
                  // Without an explicit fill the transition reads the theme
                  // from `material_ui` (animations 3.0), which cannot see this
                  // app's `flutter/material` theme and falls back to the light
                  // M3 canvas — a white band behind the dark calendar.
                  fillColor: context.tokens.background,
                  child: child,
                ),
            child: KeyedSubtree(
              key: ValueKey<CalendarView>(view),
              child: switch (view) {
                CalendarViewKind.agenda => const AgendaView(),
                CalendarViewKind.week => const WeekView(),
                CalendarViewKind.month => MonthBody(epoch: _epoch),
              },
            ),
          ),
        ),
      ],
    );
  }
}
