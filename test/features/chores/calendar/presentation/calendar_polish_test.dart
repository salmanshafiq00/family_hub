import 'package:family_hub/app/theme/theme_builder.dart';
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/calendar/presentation/painters/calendar_date_border_painter.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_pager.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/weekday_header_row.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/week_view.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// Calendar date states, reduced motion, two-pane and landscape.
void main() {
  final day = DateKey(2026, 10, 27);

  Future<void> pumpCell(
    WidgetTester tester,
    DaySummary summary, {
    int theme = 0,
    bool selected = false,
  }) async {
    final spec = appThemes[theme];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildThemeData(spec),
        locale: const Locale('en'),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          // P4-23: a DayCell claims the semantics `cell` role, which Flutter
          // only accepts inside a `row` inside a `table`; the real grid
          // (MonthGrid) provides both, so the harness has to as well.
          body: Semantics(
            role: SemanticsRole.table,
            container: true,
            child: Semantics(
              role: SemanticsRole.row,
              container: true,
              child: SizedBox(
                width: 60,
                child: DayCell(
                  summary: summary,
                  selected: selected,
                  formatters: const AppFormatters(
                    languageCode: 'en',
                    useBanglaDigits: false,
                  ),
                  minHeight: 56,
                  onTap: () {},
                  onLongPress: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Material cellMaterial(WidgetTester tester, DateKey date) =>
      tester.widget<Material>(
        find
            .ancestor(
              of: find.byKey(ValueKey<String>('calendar_day_$date')),
              matching: find.byType(Material),
            )
            .first,
      );

  Text dateText(WidgetTester tester, DateKey date) => tester.widget<Text>(
    find.descendant(
      of: find.byKey(ValueKey<String>('calendar_day_$date')),
      matching: find.text('${date.day}'),
    ),
  );

  CalendarDateBorderPainter borderPainter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is CustomPaint &&
                      widget.foregroundPainter is CalendarDateBorderPainter,
                ),
              )
              .foregroundPainter!
          as CalendarDateBorderPainter;

  group('day cell states', () {
    for (var i = 0; i < appThemes.length; i++) {
      testWidgets('date surfaces use theme tokens (${appThemes[i].id})', (
        tester,
      ) async {
        final tokens = appThemes[i].tokens;
        await pumpCell(
          tester,
          DaySummary(
            dateKey: day,
            isPast: true,
            total: 1,
            counts: const <ChoreStatus, int>{ChoreStatus.completed: 1},
          ),
          theme: i,
        );
        final pastCell = cellMaterial(tester, day);
        expect(pastCell.color, tokens.surfaceSunken);
        expect(
          ((pastCell.shape! as RoundedRectangleBorder).borderRadius
                  as BorderRadius)
              .topLeft
              .x,
          tokens.radiusMd,
        );
        expect(dateText(tester, day).style!.color, tokens.textSecondary);

        await pumpCell(
          tester,
          DaySummary(
            dateKey: day,
            total: 1,
            counts: const <ChoreStatus, int>{ChoreStatus.scheduled: 1},
          ),
          theme: i,
        );
        expect(
          cellMaterial(tester, day).color,
          tokens.statusScheduledContainer,
        );
        expect(dateText(tester, day).style!.color, tokens.statusScheduledOn);

        await pumpCell(
          tester,
          DaySummary(dateKey: day, isToday: true),
          theme: i,
        );
        expect(cellMaterial(tester, day).color, tokens.accent);
        expect(dateText(tester, day).style!.color, tokens.textOnAccent);
      });
    }

    testWidgets('overdue and completed use different border treatments', (
      tester,
    ) async {
      await pumpCell(
        tester,
        DaySummary(
          dateKey: day,
          total: 2,
          counts: const <ChoreStatus, int>{
            ChoreStatus.overdue: 1,
            ChoreStatus.completed: 1,
          },
        ),
      );
      expect(borderPainter(tester).state, CalendarDateBorderState.overdue);
      expect(
        borderPainter(tester).stateColor,
        appThemes[0].tokens.statusOverdueOn,
      );

      await pumpCell(
        tester,
        DaySummary(
          dateKey: day,
          total: 2,
          counts: const <ChoreStatus, int>{
            ChoreStatus.completed: 1,
            ChoreStatus.verified: 1,
          },
        ),
      );
      expect(borderPainter(tester).state, CalendarDateBorderState.completed);
      expect(
        borderPainter(tester).stateColor,
        appThemes[0].tokens.statusCompletedOn,
      );
    });

    testWidgets('selected and outside-month cells keep their state', (
      tester,
    ) async {
      await pumpCell(tester, DaySummary(dateKey: day), selected: true);
      expect(borderPainter(tester).isSelected, isTrue);

      await pumpCell(tester, DaySummary.outside(day));
      expect(cellMaterial(tester, day).color, appThemes[0].tokens.surface);
      expect(find.text('1/0'), findsNothing);
    });

    testWidgets('past empty dates keep the distinct past surface', (
      tester,
    ) async {
      await pumpCell(tester, DaySummary(dateKey: day, isPast: true));

      expect(
        cellMaterial(tester, day).color,
        appThemes[0].tokens.surfaceSunken,
      );
      expect(find.text('1/0'), findsNothing);
    });

    testWidgets('the label names progress and every nonvisual indicator', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpCell(
        tester,
        DaySummary(
          dateKey: day,
          isPast: true,
          total: 3,
          counts: const <ChoreStatus, int>{
            ChoreStatus.completed: 1,
            ChoreStatus.overdue: 1,
            ChoreStatus.scheduled: 1,
          },
          hasProjectedOnly: true,
          unavailableMemberIds: const <String>{'dave'},
          hasNeedsCover: true,
          hasNeedsAttention: true,
        ),
      );

      expect(
        find.bySemanticsLabel(
          RegExp(r'past date.*3 chores.*1 of 3 done.*1 overdue.*planned'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('the screen', () {
    Future<ChoresFixture> pump(
      WidgetTester tester, {
      double width = 360,
      double height = 800,
      List<ChoreOccurrence> occurrences = const <ChoreOccurrence>[],
    }) {
      final fixture = ChoresFixture();
      fixture.settings.settings = ChoreSettings.defaults.copyWith(
        defaultCalendarView: CalendarViewKind.month,
      );
      return pumpP3Screen(
        tester,
        home: const Scaffold(body: CalendarScreen()),
        sharedFixture: fixture,
        occurrences: occurrences,
        width: width,
        height: height,
        languageCode: 'en',
      );
    }

    Finder cell(int d) =>
        find.byKey(ValueKey<String>('calendar_day_${DateKey(2026, 10, d)}'));

    testWidgets('a phone has the draggable panel, a tablet the pane', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byKey(const Key('calendar_day_panel')), findsOneWidget);
      expect(find.byKey(const Key('calendar_day_pane')), findsNothing);

      await pump(tester, width: 900);
      expect(find.byKey(const Key('calendar_day_pane')), findsOneWidget);
      expect(find.byKey(const Key('calendar_day_panel')), findsNothing);
    });

    testWidgets('the tablet pane follows the selected day', (tester) async {
      await pump(
        tester,
        width: 900,
        occurrences: [
          anOccurrence(
            id: 'tpl_1_20261027',
            templateId: 'tpl_1',
            dateKey: DateKey(2026, 10, 27),
            assigneeId: 'cara',
          ),
        ],
      );

      await tester.tap(cell(27));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const Key('calendar_day_pane')),
          matching: find.textContaining('1 chore'),
        ),
        findsWidgets,
      );
    });

    testWidgets('a phone held sideways gets the week, not the month', (
      tester,
    ) async {
      await pump(tester, width: 800, height: 360);

      expect(find.byType(WeekView), findsOneWidget);
      expect(find.byKey(const Key('calendar_month_narrow')), findsOneWidget);
    });

    testWidgets('month and week columns stay aligned while scrolling narrow', (
      tester,
    ) async {
      await pump(tester, width: 340);
      expect(find.byType(WeekdayHeaderRow), findsOneWidget);
      final saturday = tester.getCenter(find.text('Sat'));
      final firstMonthDate = tester.getCenter(
        find.byKey(const ValueKey<String>('calendar_day_2026-09-26')),
      );
      expect(saturday.dx, closeTo(firstMonthDate.dx, 0.1));

      await pump(tester, width: 320);
      final firstWeekDate = tester.getCenter(
        find.byKey(const ValueKey<String>('calendar_day_2026-10-24')),
      );
      expect(
        tester.getCenter(find.text('Sat')).dx,
        closeTo(firstWeekDate.dx, 0.1),
      );
      expect(
        find.byKey(const PageStorageKey<String>('calendar_week_columns')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion disables calendar transitions', (tester) async {
      await pump(tester);

      await tester.tap(cell(27));
      await tester.pumpAndSettle();

      expect(
        tester.widget<MonthPager>(find.byType(MonthPager)).reduceMotion,
        isTrue,
      );
      final todaySwitcher = tester.widget<AnimatedSwitcher>(
        find.ancestor(
          of: find.byKey(const Key('calendar_today_pill')),
          matching: find.byType(AnimatedSwitcher),
        ),
      );
      expect(todaySwitcher.duration, Duration.zero);
    });

    testWidgets('the display sheet no longer exposes workload heat', (
      tester,
    ) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('calendar_display_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calendar_heat_switch')), findsNothing);
      expect(find.byKey(const Key('calendar_heat_legend')), findsNothing);
    });

    testWidgets('the legend sheet explains status and attention marks', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.byKey(const Key('calendar_legend_button')));
      await tester.pumpAndSettle();

      expect(find.text('Day cell marks'), findsOneWidget);
      expect(find.byKey(const Key('calendar_heat_legend')), findsNothing);
    });

    testWidgets('900 items: the month model is built once, not per tap', (
      tester,
    ) async {
      await pump(
        tester,
        occurrences: [
          for (var i = 0; i < 900; i++)
            anOccurrence(
              id: 'tpl_${i}_${DateKey(2026, 10, 1 + i % 28).compact}',
              templateId: 'tpl_$i',
              dateKey: DateKey(2026, 10, 1 + i % 28),
              assigneeId: 'cara',
            ),
        ],
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(CalendarScreen)),
      );
      var builds = 0;
      final sub = container.listen(
        calendarMonthModelProvider(MonthKey(2026, 10)),
        (_, _) => builds++,
      );
      addTearDown(sub.close);
      await tester.pumpAndSettle();
      final settled = builds;

      // Selecting days never changes the items, scope or filters.
      await tester.tap(cell(5));
      await tester.pumpAndSettle();
      await tester.tap(cell(12));
      await tester.pumpAndSettle();

      expect(builds, settled);
      expect(tester.takeException(), isNull);
    });
  });
}
