import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/calendar_filter_sheet.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_panel.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/quick_actions_sheet.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/presentation/widgets/today_row.dart';
import 'package:family_hub/shared/widgets/pill_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-23: day panel, Agenda, Week, filters, quick actions, legend.
/// "Today" is Saturday 2026-10-24 (fixture clock); the family default view is
/// the agenda.
void main() {
  Future<ChoresFixture> pump(
    WidgetTester tester, {
    List<ChoreOccurrence> occurrences = const <ChoreOccurrence>[],
    CalendarView? view,
    double width = 360,
    double height = 800,
    Role role = Role.member,
  }) {
    final fixture = ChoresFixture();
    if (view != null) {
      fixture.settings.settings = fixture.settings.settings.copyWith(
        defaultCalendarView: view,
      );
    }
    return pumpP3Screen(
      tester,
      home: const Scaffold(body: CalendarScreen()),
      sharedFixture: fixture,
      occurrences: occurrences,
      width: width,
      height: height,
      role: role,
    );
  }

  ChoreOccurrence on(int index, DateKey day, {String assignee = 'cara'}) =>
      anOccurrence(
        id: 'tpl_${index}_${day.compact}',
        templateId: 'tpl_$index',
        dateKey: day,
        assigneeId: assignee,
      );

  group('Agenda', () {
    testWidgets('is the default and starts with today', (tester) async {
      await pump(tester);

      expect(
        find.byKey(const ValueKey<String>('calendar_agenda_day_2026-10-24')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('calendar_view_switcher')), findsOneWidget);
    });

    testWidgets("pins today's overdue chore at the top", (tester) async {
      await pump(tester, occurrences: [on(1, DateKey(2026, 10, 24))]);

      expect(find.byKey(const Key('calendar_agenda_overdue')), findsOneWidget);
      expect(find.byType(TodayRow), findsOneWidget);
    });

    testWidgets('an earlier day keeps its overdue chore under its own date', (
      tester,
    ) async {
      await pump(tester, occurrences: [on(1, DateKey(2026, 10, 23))]);

      expect(find.byKey(const Key('calendar_agenda_overdue')), findsNothing);

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 800),
        2000,
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('calendar_agenda_day_2026-10-23')),
        findsOneWidget,
      );
    });

    testWidgets('collapses days without chores into a free-days chip', (
      tester,
    ) async {
      await pump(tester);

      expect(find.byKey(const Key('calendar_free_days')), findsWidgets);
    });

    testWidgets('scrolls up to earlier weeks and offers to load more', (
      tester,
    ) async {
      await pump(tester);

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, 1500),
        3000,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar_load_earlier')), findsOneWidget);
      expect(find.byKey(const Key('calendar_jump_today')), findsOneWidget);

      await tester.tap(find.byKey(const Key('calendar_jump_today')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calendar_jump_today')), findsNothing);
    });

    testWidgets('900 chores scroll without errors', (tester) async {
      await pump(
        tester,
        occurrences: [
          for (var i = 0; i < 900; i++)
            on(i, DateKey(2026, 10, 25).addDays(i % 20)),
        ],
      );

      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, -2000),
        3000,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('a long press offers the allowed actions', (tester) async {
      await pump(tester, occurrences: [on(1, DateKey(2026, 10, 24))]);

      await tester.longPress(find.byType(TodayRow).first);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar_quick_complete')), findsOneWidget);
      expect(find.byKey(const Key('calendar_quick_details')), findsOneWidget);
    });

    group('folds the days around today', () {
      // A past day keeps its own block only while its chores are done (an open
      // one belongs to the Overdue block), and a chore without subtasks counts
      // as done by `completedAt`.
      List<ChoreOccurrence> done(DateKey day, int index) => <ChoreOccurrence>[
        anOccurrence(
          id: 'tpl_${index}_${day.compact}',
          templateId: 'tpl_$index',
          dateKey: day,
          status: OccurrenceStatus.completed,
          completedAt: DateTime.utc(day.year, day.month, day.day, 4),
          completedBy: 'cara',
        ),
      ];

      List<ChoreOccurrence> week() => <ChoreOccurrence>[
        ...done(DateKey(2026, 10, 21), 1),
        ...done(DateKey(2026, 10, 22), 2),
        ...done(DateKey(2026, 10, 23), 3),
        on(4, DateKey(2026, 10, 24)),
        on(5, DateKey(2026, 10, 25)),
        on(6, DateKey(2026, 10, 26)),
        on(7, DateKey(2026, 10, 27)),
      ];

      Finder header(String day) =>
          find.byKey(ValueKey<String>('calendar_agenda_day_$day'));

      Finder icon(String day, IconData icon) =>
          find.descendant(of: header(day), matching: find.byIcon(icon));

      Future<void> tapDay(WidgetTester tester, String day) async {
        await tester.tap(header(day));
        await tester.pumpAndSettle();
      }

      testWidgets('opens today ±2 days and folds the rest', (tester) async {
        await pump(tester, height: 1200, occurrences: week());

        expect(icon('2026-10-26', Icons.expand_less_rounded), findsOneWidget);
        expect(icon('2026-10-27', Icons.expand_more_rounded), findsOneWidget);
        // Today, 25 and 26 show their chores; 27 keeps its header only.
        expect(find.byType(TodayRow), findsNWidgets(3));
      });

      testWidgets('opens a folded day on tap and folds it again', (
        tester,
      ) async {
        await pump(tester, height: 1200, occurrences: week());

        await tapDay(tester, '2026-10-27');
        expect(icon('2026-10-27', Icons.expand_less_rounded), findsOneWidget);
        expect(find.byType(TodayRow), findsNWidgets(4));

        await tapDay(tester, '2026-10-27');
        expect(find.byType(TodayRow), findsNWidgets(3));
      });

      testWidgets('the past days follow the same window', (tester) async {
        await pump(
          tester,
          height: 1200,
          occurrences: <ChoreOccurrence>[
            ...done(DateKey(2026, 10, 21), 1),
            ...done(DateKey(2026, 10, 22), 2),
            ...done(DateKey(2026, 10, 23), 3),
          ],
        );
        // The past scrolls upwards away from today's centre.
        await tester.fling(
          find.byType(CustomScrollView),
          const Offset(0, 1500),
          3000,
        );
        await tester.pumpAndSettle();

        expect(icon('2026-10-22', Icons.expand_less_rounded), findsOneWidget);
        expect(icon('2026-10-21', Icons.expand_more_rounded), findsOneWidget);
        expect(find.byType(TodayRow), findsNWidgets(2));

        await tapDay(tester, '2026-10-21');
        expect(find.byType(TodayRow), findsNWidgets(3));

        await tapDay(tester, '2026-10-22');
        expect(find.byType(TodayRow), findsNWidgets(2));
      });
    });
  });

  group('views share one state', () {
    testWidgets('switching to Week keeps the selected day', (tester) async {
      await pump(tester, view: CalendarViewKind.month);

      await tester.tap(
        find.byKey(const ValueKey<String>('calendar_day_2026-10-27')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();

      expect(find.textContaining('27 October 2026'), findsWidgets);
      expect(find.byType(DayCell), findsNWidgets(7));
    });

    testWidgets('a narrow screen shows the week and says why', (tester) async {
      await pump(tester, view: CalendarViewKind.month, width: 320);

      expect(find.byKey(const Key('calendar_month_narrow')), findsOneWidget);
      expect(find.byType(DayCell), findsNWidgets(7));
    });

    testWidgets('a tablet shows the week as seven columns', (tester) async {
      await pump(tester, view: CalendarViewKind.week, width: 900);

      expect(find.byType(DayCell), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('day panel', () {
    testWidgets('lists the day without a duplicate Add chore action', (
      tester,
    ) async {
      await pump(
        tester,
        view: CalendarViewKind.month,
        role: Role.admin,
        occurrences: [on(1, DateKey(2026, 10, 24))],
      );

      expect(find.byKey(const Key('calendar_day_panel')), findsOneWidget);
      expect(find.byType(TodayRow), findsOneWidget);
      expect(find.byKey(const Key('calendar_add_chore')), findsNothing);
      expect(find.text('0 of 1 done'), findsOneWidget);
      expect(find.text('Open: 1'), findsOneWidget);
    });

    testWidgets('a plain member gets no Add chore', (tester) async {
      await pump(tester, view: CalendarViewKind.month);

      expect(find.byKey(const Key('calendar_add_chore')), findsNothing);
    });

    testWidgets('the last row clears the FAB at 2x text scale', (tester) async {
      final date = DateKey(2026, 10, 24);
      await pumpP3Screen(
        tester,
        home: Scaffold(
          body: DayPanelList(day: date),
          floatingActionButton: FloatingActionButton.small(
            key: const Key('test_calendar_fab'),
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: PillBottomBar(
            items: const [
              PillNavItem(icon: Icons.home, label: 'Home'),
              PillNavItem(icon: Icons.check, label: 'Chores'),
            ],
            selectedIndex: 1,
            onSelected: (_) {},
          ),
        ),
        occurrences: [for (var i = 0; i < 24; i++) on(i, date)],
        height: 800,
        textScale: 2,
      );
      await tester.fling(find.byType(ListView), const Offset(0, -4000), 3000);
      await tester.pumpAndSettle();

      final lastRow = tester.getRect(find.byType(TodayRow).last);
      final fab = tester.getRect(find.byKey(const Key('test_calendar_fab')));
      expect(lastRow.bottom, lessThan(fab.top));
      expect(kCalendarBottomClearance, greaterThan(40 + 16));
      expect(tester.takeException(), isNull);
    });
  });

  group('filters and legend', () {
    testWidgets('a status filter shows as a removable chip', (tester) async {
      await pump(tester, occurrences: [on(1, DateKey(2026, 10, 24))]);

      await tester.tap(find.byKey(const Key('calendar_filter_button')));
      await tester.pumpAndSettle();
      final status = find.byKey(const Key('calendar_filter_status_overdue'));
      await tester.ensureVisible(status);
      await tester.tap(status);
      await tester.pumpAndSettle();

      final chip = find.byKey(const Key('calendar_chip_status_overdue'));
      expect(chip, findsOneWidget);
      Navigator.of(tester.element(find.byType(CalendarFilterSheet))).pop();
      await tester.pumpAndSettle();

      // Material 3 chips delete with `Icons.clear`; `Icons.cancel` was the
      // Material 2 default, so this finder used to match nothing.
      await tester.tap(
        find.descendant(of: chip, matching: find.byIcon(Icons.clear)),
      );
      await tester.pumpAndSettle();
      expect(chip, findsNothing);
    });

    testWidgets('a search shows as a chip', (tester) async {
      await pump(tester);

      await tester.tap(find.byKey(const Key('calendar_filter_button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('calendar_search_field')),
        'zzz',
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar_chip_query')), findsOneWidget);
    });

    testWidgets('the legend names every status', (tester) async {
      await pump(tester);

      await tester.tap(find.byKey(const Key('calendar_legend_button')));
      await tester.pumpAndSettle();

      expect(find.text('What the symbols mean'), findsOneWidget);
      expect(find.text('Overdue'), findsWidgets);
    });

    Future<void> filterByStatus(WidgetTester tester, String status) async {
      await tester.tap(find.byKey(const Key('calendar_filter_button')));
      await tester.pumpAndSettle();
      final option = find.byKey(Key('calendar_filter_status_$status'));
      await tester.ensureVisible(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(CalendarFilterSheet))).pop();
      await tester.pumpAndSettle();
    }

    Future<void> scrollToTheTop(WidgetTester tester) async {
      for (var i = 0; i < 4; i++) {
        await tester.fling(
          find.byType(CustomScrollView),
          const Offset(0, 1500),
          3000,
        );
        await tester.pumpAndSettle();
      }
    }

    testWidgets('a filter looks further back than the plain agenda', (
      tester,
    ) async {
      // 2026-10-16 is eight days back: outside the default one-week window,
      // inside the four weeks a filter reaches.
      final old = anOccurrence(
        id: 'tpl_9_20261016',
        templateId: 'tpl_9',
        dateKey: DateKey(2026, 10, 16),
        status: OccurrenceStatus.completed,
        completedAt: DateTime.utc(2026, 10, 16, 4),
        completedBy: 'cara',
      );

      await pump(tester, occurrences: [old]);
      await scrollToTheTop(tester);
      expect(
        find.byKey(const ValueKey<String>('calendar_agenda_day_2026-10-16')),
        findsNothing,
      );

      await filterByStatus(tester, 'completed');
      await scrollToTheTop(tester);

      expect(
        find.byKey(const ValueKey<String>('calendar_agenda_day_2026-10-16')),
        findsOneWidget,
      );
      // Every matching day opens while filtering, and the fold arrow goes.
      expect(find.byType(TodayRow), findsOneWidget);
    });

    testWidgets('a filter with no match says so and clears back', (
      tester,
    ) async {
      await pump(tester, occurrences: [on(1, DateKey(2026, 10, 24))]);

      await filterByStatus(tester, 'completed');

      expect(find.byKey(const Key('calendar_agenda_no_match')), findsOneWidget);

      await tester.tap(find.text('Clear filters'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar_agenda_no_match')), findsNothing);
      expect(
        find.byKey(const ValueKey<String>('calendar_agenda_day_2026-10-24')),
        findsOneWidget,
      );
    });
  });

  group('quickActionsFor', () {
    ChoreItem item(ChoreStatus status, {bool projected = false}) {
      final base = ChoreItem.fromOccurrence(
        anOccurrence(id: 'tpl_1_20261024', dateKey: DateKey(2026, 10, 24)),
      );
      return base.copyWith(status: status, isProjected: projected);
    }

    test('an open chore offers complete and details to who may complete', () {
      expect(
        quickActionsFor(item(ChoreStatus.scheduled), mayComplete: true),
        <QuickAction>[QuickAction.complete, QuickAction.details],
      );
    });

    test('somebody who may not complete only gets details', () {
      expect(
        quickActionsFor(item(ChoreStatus.scheduled), mayComplete: false),
        <QuickAction>[QuickAction.details],
      );
    });

    test('a finished chore is not completed again', () {
      expect(
        quickActionsFor(item(ChoreStatus.completed), mayComplete: true),
        <QuickAction>[QuickAction.details],
      );
    });

    test('a planned chore offers nothing', () {
      expect(
        quickActionsFor(
          item(ChoreStatus.scheduled, projected: true),
          mayComplete: true,
        ),
        isEmpty,
      );
    });
  });
}
