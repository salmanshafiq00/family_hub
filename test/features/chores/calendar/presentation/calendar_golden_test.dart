@Tags(['golden'])
library;

import 'dart:io';

import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/widgets/shared_widgets_test_support.dart';
import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-24 goldens (B.9-23): month (5-row and 6-row), agenda, week, day
/// panel and the tablet two-pane, in both themes and both languages.
///
/// Generated on Linux CI only (ADR 0005): run the `Update goldens` workflow,
/// unzip the artifact at the repo root and commit
/// `test/features/chores/calendar/goldens/`. Until the images exist the tests
/// are skipped with a reason.
void main() {
  setUpAll(loadBundledFonts);
  final generated =
      autoUpdateGoldenFiles ||
      Directory('test/features/chores/calendar/goldens').existsSync();

  const shotKey = Key('calendar_golden');

  ChoreOccurrence on(int i, DateKey d, {String who = 'cara'}) => anOccurrence(
    id: 'tpl_${i}_${d.compact}',
    templateId: 'tpl_$i',
    dateKey: d,
    assigneeId: who,
  );

  /// A busy but plausible month around 2026-10-24 and 2026-11.
  List<ChoreOccurrence> data() => [
    for (var d = 1; d <= 30; d++)
      for (var i = 0; i < (d % 5) + 1; i++)
        on(i, DateKey(2026, 10, d), who: i.isEven ? 'cara' : 'dave'),
    for (var d = 1; d <= 30; d++) on(0, DateKey(2026, 11, d)),
  ];

  Future<void> shoot(
    WidgetTester tester,
    String name, {
    required CalendarViewKind view,
    required int theme,
    required String lang,
    MonthKey? month,
    double width = 360,
    double height = 800,
  }) async {
    final fixture = ChoresFixture();
    fixture.settings.settings = ChoreSettings.defaults.copyWith(
      defaultCalendarView: view,
    );
    await pumpP3Screen(
      tester,
      home: const RepaintBoundary(
        key: shotKey,
        child: Scaffold(body: CalendarScreen()),
      ),
      sharedFixture: fixture,
      occurrences: data(),
      width: width,
      height: height,
      themeIndex: theme,
      languageCode: lang,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(CalendarScreen)),
    );
    await container
        .read(calendarPrefsProvider.notifier)
        .setScope(CalendarScopeKind.all);
    if (month != null) {
      container.read(calendarFocusProvider.notifier).showMonth(month);
    }
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(shotKey),
      matchesGoldenFile('../goldens/${name}_${appThemes[theme].id}_$lang.png'),
    );
  }

  group(
    'calendar goldens',
    () {
      for (var theme = 0; theme < appThemes.length; theme++) {
        for (final lang in <String>['bn', 'en']) {
          testWidgets('month, 6 rows (${appThemes[theme].id}/$lang)', (
            tester,
          ) async {
            await shoot(
              tester,
              'month6',
              view: CalendarViewKind.month,
              theme: theme,
              lang: lang,
              month: MonthKey(2026, 10),
            );
          });
          testWidgets('month, 5 rows (${appThemes[theme].id}/$lang)', (
            tester,
          ) async {
            await shoot(
              tester,
              'month5',
              view: CalendarViewKind.month,
              theme: theme,
              lang: lang,
              month: MonthKey(2026, 11),
            );
          });
          testWidgets('agenda (${appThemes[theme].id}/$lang)', (tester) async {
            await shoot(
              tester,
              'agenda',
              view: CalendarViewKind.agenda,
              theme: theme,
              lang: lang,
            );
          });
          testWidgets('week (${appThemes[theme].id}/$lang)', (tester) async {
            await shoot(
              tester,
              'week',
              view: CalendarViewKind.week,
              theme: theme,
              lang: lang,
            );
          });
          testWidgets('day panel (${appThemes[theme].id}/$lang)', (
            tester,
          ) async {
            await shoot(
              tester,
              'day_panel',
              view: CalendarViewKind.month,
              theme: theme,
              lang: lang,
            );
          });
          testWidgets('tablet two-pane (${appThemes[theme].id}/$lang)', (
            tester,
          ) async {
            await shoot(
              tester,
              'two_pane',
              view: CalendarViewKind.month,
              theme: theme,
              lang: lang,
              width: 1000,
            );
          });
        }
      }
    },
    skip: generated
        ? null
        : 'goldens not generated yet - run the Update goldens workflow',
  );
}
