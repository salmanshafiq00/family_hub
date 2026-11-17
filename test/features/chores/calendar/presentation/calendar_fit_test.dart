import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/domain/member_load.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_summary_details.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/month_body.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/widgets/shared_widgets_test_support.dart';
import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// The calendar redesign: the grid fits the screen (no sideways scroll, no row
/// hidden by the day panel), the date number is dead-centre and the panel's
/// count chips centre their text. "Today" is Saturday 2026-10-24.
void main() {
  group('the month fits the screen', () {
    // (year, month, rows with a Saturday week start): a 4-week month, 28 / 29
    // / 30 / 31 days, and the 6-week month (October 2026 starts on a Thursday).
    const months = <(int, int, int)>[
      (2025, 2, 4),
      (2026, 2, 5),
      (2028, 2, 5),
      (2026, 4, 5),
      (2026, 11, 5),
      (2026, 10, 6),
    ];
    const sizes = <Size>[Size(360, 800), Size(411, 914)];

    for (final size in sizes) {
      for (final (year, month, rows) in months) {
        testWidgets(
          '$year-$month (${rows * 7} cells) at ${size.width.toInt()} x ${size.height.toInt()}',
          (tester) async {
            final fixture = ChoresFixture();
            fixture.settings.settings = ChoreSettings.defaults.copyWith(
              defaultCalendarView: CalendarViewKind.month,
            );
            await pumpP3Screen(
              tester,
              home: const Scaffold(body: CalendarScreen()),
              sharedFixture: fixture,
              width: size.width,
              height: size.height,
            );
            final container = ProviderScope.containerOf(
              tester.element(find.byType(CalendarScreen)),
            );
            container
                .read(calendarFocusProvider.notifier)
                .showMonth(MonthKey(year, month));
            await tester.pumpAndSettle();

            // All seven weekday labels are on the screen.
            for (final name in const [
              'Sat',
              'Sun',
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
            ]) {
              final rect = tester.getRect(find.text(name).first);
              expect(rect.left, greaterThanOrEqualTo(0), reason: name);
              expect(rect.right, lessThanOrEqualTo(size.width), reason: name);
              expect(rect.top, greaterThanOrEqualTo(0), reason: name);
              expect(rect.bottom, lessThanOrEqualTo(size.height), reason: name);
            }
            // Nothing scrolls sideways.
            expect(
              find.byWidgetPredicate(
                (w) =>
                    w is SingleChildScrollView &&
                    w.scrollDirection == Axis.horizontal,
              ),
              findsNothing,
            );
            // Every row is there, whole, and above the collapsed day panel.
            final cells = find.byType(DayCell);
            expect(cells, findsNWidgets(rows * 7));
            // The panel's first snap is a fraction of the Month body.
            final body = tester.getRect(find.byType(MonthBody));
            final panelTop = body.bottom - dayPanelRestingHeight(body.height);
            for (final element in cells.evaluate()) {
              final rect = tester.getRect(find.byWidget(element.widget));
              expect(rect.left, greaterThanOrEqualTo(-0.01));
              expect(rect.right, lessThanOrEqualTo(size.width + 0.01));
              expect(rect.bottom, lessThanOrEqualTo(panelTop + 0.5));
              // The whole column is the tap target (>= 48 dp wide).
              expect(rect.width, greaterThanOrEqualTo(48));
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });

  group('the date number is dead-centre', () {
    final day = DateKey(2026, 10, 25);

    Future<void> pumpCell(
      WidgetTester tester,
      DaySummary summary, {
      required String languageCode,
      bool selected = false,
    }) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: Locale(languageCode),
        child: Semantics(
          role: SemanticsRole.table,
          container: true,
          child: Semantics(
            role: SemanticsRole.row,
            container: true,
            child: SizedBox(
              width: 49,
              child: DayCell(
                summary: summary,
                selected: selected,
                memberStyles: const {},
                viewerId: 'cara',
                formatters: AppFormatters(
                  languageCode: languageCode,
                  useBanglaDigits: languageCode == 'bn',
                ),
                minHeight: 60,
                onTap: () {},
                onLongPress: () {},
              ),
            ),
          ),
        ),
      );
    }

    for (final languageCode in const ['en', 'bn']) {
      testWidgets('with and without pip, my icon and avatars ($languageCode)', (
        tester,
      ) async {
        final text = languageCode == 'bn' ? '২৫' : '25';
        final variants = <DaySummary>[
          DaySummary(dateKey: day),
          DaySummary(
            dateKey: day,
            total: 3,
            counts: const {ChoreStatus.overdue: 1, ChoreStatus.scheduled: 2},
            mineCount: 1,
            byMember: const [
              MemberLoad(memberId: 'cara', count: 1),
              MemberLoad(memberId: 'amy', count: 1),
              MemberLoad(memberId: 'bob', count: 1),
            ],
          ),
        ];
        for (final summary in variants) {
          await pumpCell(tester, summary, languageCode: languageCode);
          final cell = tester.getCenter(
            find.byKey(ValueKey<String>('calendar_day_$day')),
          );
          final number = tester.getCenter(find.text(text));
          expect(number.dx, closeTo(cell.dx, 0.5));
          expect(number.dy, closeTo(cell.dy, 0.5));
        }
      });
    }
  });

  testWidgets('the panel count chips centre their text', (tester) async {
    await pumpSharedWidget(
      tester,
      spec: appThemes.first,
      locale: const Locale('bn'),
      child: DaySummaryDetails(
        summary: DaySummary(
          dateKey: DateKey(2026, 10, 25),
          total: 3,
          counts: const {ChoreStatus.completed: 1, ChoreStatus.scheduled: 2},
        ),
        formatters: const AppFormatters(
          languageCode: 'bn',
          useBanglaDigits: true,
        ),
      ),
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(DaySummaryDetails)),
    );
    final label = find.text(l10n.calendarCellChores('৩'));
    final chip = find
        .ancestor(of: label, matching: find.byType(Container))
        .first;
    expect(tester.getCenter(label).dy, closeTo(tester.getCenter(chip).dy, 0.5));
  });
}
