import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/features/chores/calendar/presentation/painters/calendar_date_border_painter.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/legend_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/widgets/shared_widgets_test_support.dart';

void main() {
  for (final theme in appThemes) {
    for (final locale in sharedWidgetLocales) {
      testWidgets(
        'legend explains avatars and date states in ${theme.id}/${locale.languageCode} at 2x',
        (tester) async {
          await pumpSharedWidget(
            tester,
            spec: theme,
            locale: locale,
            textScale: 2,
            width: 320,
            child: const SizedBox(height: 1000, child: LegendSheet()),
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(LegendSheet)),
          );

          expect(
            find.text(l10n.calendarLegendAvatarDescription),
            findsOneWidget,
          );
          expect(
            find.text(l10n.calendarLegendScheduledSurface),
            findsOneWidget,
          );
          expect(find.text(l10n.calendarLegendPastSurface), findsOneWidget);
          expect(find.text(l10n.calendarLegendTodaySurface), findsOneWidget);
          expect(find.text(l10n.calendarLegendOverdueBorder), findsOneWidget);
          expect(find.text(l10n.calendarLegendCompletedBorder), findsOneWidget);

          final painters = tester
              .widgetList<CustomPaint>(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is CustomPaint &&
                      widget.foregroundPainter is CalendarDateBorderPainter,
                ),
              )
              .map(
                (paint) =>
                    paint.foregroundPainter! as CalendarDateBorderPainter,
              )
              .toList();
          expect(
            painters.map((painter) => painter.state),
            containsAll(<CalendarDateBorderState>[
              CalendarDateBorderState.overdue,
              CalendarDateBorderState.completed,
            ]),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
