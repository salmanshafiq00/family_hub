import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/presentation/widgets/today_row.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-22: the Month view. "Today" is Saturday 2026-10-24 (fixture clock).
void main() {
  Future<ChoresFixture> pump(
    WidgetTester tester, {
    List<ChoreOccurrence> occurrences = const <ChoreOccurrence>[],
    ChoresFixture? fixture,
    double width = 360,
    double textScale = 1.0,
    String languageCode = 'en',
  }) {
    // These tests are about the month; the family default is the agenda.
    final used = fixture ?? ChoresFixture();
    used.settings.settings = used.settings.settings.copyWith(
      defaultCalendarView: CalendarViewKind.month,
    );
    return pumpP3Screen(
      tester,
      home: const Scaffold(body: CalendarScreen()),
      sharedFixture: used,
      occurrences: occurrences,
      width: width,
      textScale: textScale,
      languageCode: languageCode,
    );
  }

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(CalendarScreen)));

  Finder cell(int year, int month, int day) =>
      find.byKey(ValueKey<String>('calendar_day_${DateKey(year, month, day)}'));

  ChoreOccurrence on(int index, DateKey day, {String? assignee}) =>
      anOccurrence(
        id: 'tpl_${index}_${day.compact}',
        templateId: 'tpl_$index',
        dateKey: day,
        assigneeId: assignee ?? 'cara',
      );

  group('Month view', () {
    testWidgets('shows the month, the week start and today', (tester) async {
      await pump(tester);

      expect(find.text('October 2026'), findsOneWidget);
      // Saturday is the family's default week start.
      final first = tester.getTopLeft(find.text('Sat').first).dx;
      final last = tester.getTopLeft(find.text('Fri').first).dx;
      expect(first, lessThan(last));
      expect(cell(2026, 10, 24), findsOneWidget);
      // On today the Today pill is not offered.
      expect(find.byKey(const Key('calendar_today_pill')), findsNothing);
    });

    testWidgets('a Sunday week start puts Sunday first', (tester) async {
      final fixture = ChoresFixture();
      fixture.settings.settings = ChoreSettings.defaults.copyWith(
        weekStartDay: 7,
      );
      await pump(tester, fixture: fixture);

      final sun = tester.getTopLeft(find.text('Sun').first).dx;
      final sat = tester.getTopLeft(find.text('Sat').first).dx;
      expect(sun, lessThan(sat));
    });

    testWidgets('a leap February has a 29th', (tester) async {
      await pump(tester);

      containerOf(tester)
          .read(calendarFocusProvider.notifier)
          .showMonth(MonthKey(2028, 2));
      await tester.pumpAndSettle();

      expect(find.text('February 2028'), findsOneWidget);
      expect(cell(2028, 2, 29), findsOneWidget);
    });

    testWidgets('swiping moves to the next month', (tester) async {
      await pump(tester);

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1500);
      await tester.pumpAndSettle();

      expect(find.text('November 2026'), findsOneWidget);
      expect(
        containerOf(tester).read(focusedMonthProvider),
        MonthKey(2026, 11),
      );
    });

    testWidgets('the arrows and the Today pill move the month', (tester) async {
      await pump(tester);

      await tester.tap(find.byKey(const Key('calendar_next')));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.byKey(const Key('calendar_today_pill')), findsOneWidget);

      await tester.tap(find.byKey(const Key('calendar_today_pill')));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.byKey(const Key('calendar_today_pill')), findsNothing);
    });

    testWidgets('the picker jumps to another month and year', (tester) async {
      await pump(tester);

      await tester.tap(find.byKey(const Key('calendar_title')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calendar_picker_next_year')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('calendar_picker_month_3')));
      await tester.pumpAndSettle();

      expect(find.text('March 2027'), findsOneWidget);
    });

    testWidgets('a day of the next month moves the page', (tester) async {
      await pump(tester);

      // The October grid starts on Saturday 26 September.
      await tester.tap(cell(2026, 9, 27));
      await tester.pumpAndSettle();

      expect(find.text('September 2026'), findsOneWidget);
      expect(
        containerOf(tester).read(selectedDayProvider),
        DateKey(2026, 9, 27),
      );
    });
  });

  group('day cell member summaries', () {
    testWidgets('a busy day shows my icon, no footer and no status glyph', (
      tester,
    ) async {
      final day = DateKey(2026, 10, 27);
      await pump(tester, occurrences: [for (var i = 0; i < 5; i++) on(i, day)]);

      // My chores: the person icon, never my avatar.
      expect(
        find.descendant(
          of: cell(2026, 10, 27),
          matching: find.byKey(const Key('calendar_cell_mine')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: cell(2026, 10, 27),
          matching: find.byType(AppAvatar),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: cell(2026, 10, 27), matching: find.text('0/5')),
        findsNothing,
      );
      // A scheduled day is a quiet tint: no pip.
      expect(
        find.descendant(
          of: cell(2026, 10, 27),
          matching: find.byType(StatusGlyph),
        ),
        findsNothing,
      );
    });

    testWidgets('a day outside the month carries no avatars or footer', (
      tester,
    ) async {
      await pump(tester, occurrences: [on(1, DateKey(2026, 11, 1))]);

      expect(
        find.descendant(
          of: cell(2026, 11, 1),
          matching: find.byType(AppAvatar),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: cell(2026, 11, 1), matching: find.text('0/1')),
        findsNothing,
      );
    });

    testWidgets('a cell announces its day as one sentence', (tester) async {
      final handle = tester.ensureSemantics();
      final day = DateKey(2026, 10, 27);
      await pump(tester, occurrences: [for (var i = 0; i < 3; i++) on(i, day)]);

      expect(
        find.bySemanticsLabel(
          RegExp(r'^27 October, Tuesday, scheduled.*3 chores.*0 of 3 done'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('the selected day', () {
    testWidgets('lists the chores of the tapped day', (tester) async {
      final day = DateKey(2026, 10, 27);
      await pump(
        tester,
        occurrences: [on(1, day), on(2, day), on(3, DateKey(2026, 10, 28))],
      );

      await tester.tap(cell(2026, 10, 27));
      await tester.pumpAndSettle();

      expect(find.byType(TodayRow), findsNWidgets(2));
    });

    testWidgets('an empty day says so', (tester) async {
      await pump(tester);

      await tester.tap(cell(2026, 10, 29));
      await tester.pumpAndSettle();

      expect(find.text('No chores this day'), findsOneWidget);
    });

    testWidgets('the member chip shows the whole family', (tester) async {
      final day = DateKey(2026, 10, 27);
      await pump(
        tester,
        occurrences: [
          on(1, day),
          on(2, day, assignee: 'dave'),
        ],
      );
      await tester.tap(cell(2026, 10, 27));
      await tester.pumpAndSettle();
      expect(find.byType(TodayRow), findsNWidgets(1));

      await tester.tap(find.byKey(const Key('calendar_member_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calendar_member_menu_family')));
      await tester.pumpAndSettle();

      expect(find.byType(TodayRow), findsNWidgets(2));
      expect(find.byIcon(Icons.groups_rounded), findsWidgets);
    });

    testWidgets('the member chip can show one other member', (tester) async {
      final day = DateKey(2026, 10, 27);
      await pump(
        tester,
        occurrences: [
          on(1, day),
          on(2, day, assignee: 'dave'),
        ],
      );
      await tester.tap(cell(2026, 10, 27));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('calendar_member_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('calendar_member_menu_dave')));
      await tester.pumpAndSettle();

      expect(find.byType(TodayRow), findsNWidgets(1));
      expect(
        containerOf(tester).read(calendarFiltersProvider).memberIds,
        <String>{'dave'},
      );
    });

    testWidgets('the display button is gone and the bell is not in the grid', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byKey(const Key('calendar_display_button')), findsNothing);
      expect(find.byKey(const Key('inbox_bell')), findsNothing);
      expect(find.byKey(const Key('calendar_legend_button')), findsOneWidget);
      expect(find.byKey(const Key('calendar_filter_button')), findsOneWidget);
    });
  });

  group('limits', () {
    testWidgets('a truncated month shows the banner', (tester) async {
      await pump(
        tester,
        occurrences: [
          for (var i = 0; i <= 900; i++) on(i, DateKey(2026, 10, 1 + i % 28)),
        ],
      );

      expect(
        find.byKey(const Key('calendar_truncated_banner')),
        findsOneWidget,
      );
    });

    testWidgets('cells are at least 48 dp tall and 48 dp wide at 360', (
      tester,
    ) async {
      await pump(tester);

      // The whole cell is the tap target; the visual gap is inside it.
      final size = tester.getSize(
        find.ancestor(of: cell(2026, 10, 24), matching: find.byType(DayCell)),
      );
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    });

    for (final language in <String>['en', 'bn']) {
      testWidgets('no overflow at text scale 2.0 ($language)', (tester) async {
        await pump(
          tester,
          occurrences: [
            for (var i = 0; i < 4; i++) on(i, DateKey(2026, 10, 27)),
          ],
          textScale: 2,
          languageCode: language,
        );

        expect(tester.takeException(), isNull);
      });
    }
  });
}
