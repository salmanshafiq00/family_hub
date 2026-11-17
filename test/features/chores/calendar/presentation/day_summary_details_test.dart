import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_summary_details.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/widgets/shared_widgets_test_support.dart';

void main() {
  for (final theme in appThemes) {
    for (final locale in sharedWidgetLocales) {
      testWidgets(
        'day status counts fit in ${theme.id}/${locale.languageCode} at 2x',
        (tester) async {
          final formatters = AppFormatters(
            languageCode: locale.languageCode,
            useBanglaDigits: locale.languageCode == 'bn',
          );
          await pumpSharedWidget(
            tester,
            spec: theme,
            locale: locale,
            textScale: 2,
            child: DaySummaryDetails(
              summary: DaySummary(
                dateKey: DateKey(2026, 10, 25),
                total: 5,
                counts: const <ChoreStatus, int>{
                  ChoreStatus.completed: 1,
                  ChoreStatus.verified: 1,
                  ChoreStatus.scheduled: 1,
                  ChoreStatus.overdue: 1,
                  ChoreStatus.skipped: 1,
                },
              ),
              formatters: formatters,
            ),
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(DaySummaryDetails)),
          );

          expect(
            find.text(l10n.calendarCellChores(formatters.number(5))),
            findsOneWidget,
          );
          expect(
            find.text(
              l10n.calendarCellProgress(
                formatters.number(2),
                formatters.number(5),
              ),
            ),
            findsOneWidget,
          );
          expect(
            find.text(l10n.calendarDayOpenCount(formatters.number(2))),
            findsOneWidget,
          );
          expect(
            find.text(l10n.calendarCellOverdue(formatters.number(1))),
            findsOneWidget,
          );
          expect(
            find.text(l10n.calendarDaySkippedCount(formatters.number(1))),
            findsOneWidget,
          );
          expect(find.byType(StatusGlyph), findsNWidgets(3));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
