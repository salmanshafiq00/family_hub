import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/legend_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/widgets/shared_widgets_test_support.dart';

void main() {
  for (final theme in appThemes) {
    for (final locale in sharedWidgetLocales) {
      testWidgets(
        'legend shows the real cells and their meaning in ${theme.id}/${locale.languageCode} at 2x',
        (tester) async {
          await pumpSharedWidget(
            tester,
            spec: theme,
            locale: locale,
            textScale: 2,
            width: 320,
            child: const SizedBox(height: 1400, child: LegendSheet()),
          );
          final l10n = AppLocalizations.of(
            tester.element(find.byType(LegendSheet)),
          );

          for (final text in <String>[
            l10n.calendarLegendNoChores,
            l10n.calendarCellScheduled,
            l10n.statusInProgress,
            l10n.calendarCellCompleted,
            l10n.statusOverdue,
            l10n.choreStatusSkipped,
            l10n.calendarToday,
            l10n.calendarCellSelected,
            l10n.calendarLegendMine,
            l10n.calendarLegendAvatarDescription,
            l10n.choreFlagNeedsCover,
            l10n.choreFlagNeedsAttention,
          ]) {
            expect(find.text(text), findsWidgets, reason: text);
          }

          // Eight sample cells: the very widget the grid draws.
          expect(find.byType(DayCell), findsNWidgets(8));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
