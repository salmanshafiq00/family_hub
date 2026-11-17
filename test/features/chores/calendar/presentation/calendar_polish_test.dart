import 'package:family_hub/app/theme/theme_builder.dart';
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_pager.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/weekday_header_row.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/week_view.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/shared/widgets/status_chip.dart' show WidgetStatus;
import 'package:family_hub/shared/widgets/status_glyph.dart';
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

  Iterable<WidgetStatus> pips(WidgetTester tester) => tester
      .widgetList<StatusGlyph>(
        find.descendant(
          of: find.byKey(ValueKey<String>('calendar_day_$day')),
          matching: find.byType(StatusGlyph),
        ),
      )
      .map((glyph) => glyph.status);

  DaySummary summaryOf(
    Map<ChoreStatus, int> counts, {
    bool today = false,
    bool past = false,
  }) => DaySummary(
    dateKey: day,
    isToday: today,
    isPast: past,
    total: counts.values.fold(0, (a, b) => a + b),
    counts: counts,
  );

  group('day cell states', () {
    for (var i = 0; i < appThemes.length; i++) {
      testWidgets('date surfaces use theme tokens (${appThemes[i].id})', (
        tester,
      ) async {
        final t = appThemes[i].tokens;

        Future<void> expectCell(
          DaySummary summary,
          Color surface,
          Color ink, {
          bool selected = false,
        }) async {
          await pumpCell(tester, summary, theme: i, selected: selected);
          final material = cellMaterial(tester, day);
          expect(material.color, surface);
          expect(
            ((material.shape! as RoundedRectangleBorder).borderRadius
                    as BorderRadius)
                .topLeft
                .x,
            t.radiusMd,
          );
          expect(dateText(tester, day).style!.color, ink);
        }

        await expectCell(
          summaryOf({ChoreStatus.scheduled: 1}),
          t.statusScheduledContainer,
          t.statusScheduledOn,
        );
        await expectCell(
          summaryOf({ChoreStatus.overdue: 1, ChoreStatus.completed: 1}),
          t.statusOverdueContainer,
          t.statusOverdueOn,
        );
        await expectCell(
          summaryOf({ChoreStatus.completed: 1}, past: true),
          t.statusCompletedContainer,
          t.statusCompletedOn,
        );
        await expectCell(
          summaryOf({ChoreStatus.skipped: 1}),
          t.statusSkippedContainer,
          t.statusSkippedOn,
        );
        await expectCell(DaySummary(dateKey: day), t.surface, t.textSecondary);
        // Today is a SOFT accent; selected is the SOLID accent.
        await expectCell(
          DaySummary(dateKey: day, isToday: true),
          t.accentSoft,
          t.accentStrong,
        );
        await expectCell(
          DaySummary(dateKey: day),
          t.accent,
          t.textOnAccent,
          selected: true,
        );
        // Selected wins over today, and today keeps a small dot.
        await expectCell(
          DaySummary(dateKey: day, isToday: true),
          t.accent,
          t.textOnAccent,
          selected: true,
        );
        expect(
          find.byKey(const Key('calendar_cell_today_dot')),
          findsOneWidget,
        );
      });
    }

    testWidgets('every state has its own pip shape, scheduled has none', (
      tester,
    ) async {
      await pumpCell(
        tester,
        summaryOf({ChoreStatus.overdue: 1, ChoreStatus.completed: 1}),
      );
      expect(pips(tester), [WidgetStatus.overdue]);

      await pumpCell(
        tester,
        summaryOf({ChoreStatus.completed: 1, ChoreStatus.verified: 1}),
      );
      expect(pips(tester), [WidgetStatus.completed]);

      await pumpCell(
        tester,
        summaryOf({ChoreStatus.completed: 1, ChoreStatus.scheduled: 1}),
      );
      expect(pips(tester), [WidgetStatus.inProgress]);

      await pumpCell(tester, summaryOf({ChoreStatus.skipped: 1}));
      expect(pips(tester), [WidgetStatus.skipped]);

      await pumpCell(tester, summaryOf({ChoreStatus.scheduled: 1}));
      expect(pips(tester), isEmpty);

      await pumpCell(tester, DaySummary(dateKey: day));
      expect(pips(tester), isEmpty);
    });

    testWidgets('the cell has no done/total footer', (tester) async {
      await pumpCell(
        tester,
        summaryOf({ChoreStatus.overdue: 1, ChoreStatus.completed: 2}),
      );
      expect(find.text('2/3'), findsNothing);
      expect(find.text('0/3'), findsNothing);
    });

    testWidgets('outside-month cells have no surface and no pip', (
      tester,
    ) async {
      await pumpCell(tester, DaySummary.outside(day));
      expect(cellMaterial(tester, day).type, MaterialType.transparency);
      expect(
        dateText(tester, day).style!.color,
        appThemes[0].tokens.textDisabled,
      );
      expect(pips(tester), isEmpty);
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

    testWidgets('a narrow phone gets the week, aligned, never sideways', (
      tester,
    ) async {
      await pump(tester, width: 340);
      expect(find.byType(WeekView), findsOneWidget);
      expect(find.byType(WeekdayHeaderRow), findsOneWidget);
      final saturday = tester.getCenter(find.text('Sat'));
      final firstWeekDate = tester.getCenter(
        find.byKey(const ValueKey<String>('calendar_day_2026-10-24')),
      );
      expect(saturday.dx, closeTo(firstWeekDate.dx, 0.1));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is SingleChildScrollView &&
              w.scrollDirection == Axis.horizontal,
        ),
        findsNothing,
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
