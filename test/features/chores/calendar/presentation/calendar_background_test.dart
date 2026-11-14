import 'package:animations/animations.dart';
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// The view transition fills its slot with `Theme.of(context).canvasColor`.
/// animations 3.0 reads that theme through `material_ui`, which cannot see this
/// app's `flutter/material` theme, so without an explicit `fillColor` it fell
/// back to the light M3 canvas: a white band behind the dark calendar.
void main() {
  testWidgets('the view transition fills with the theme background', (
    tester,
  ) async {
    await pumpP3Screen(
      tester,
      home: const Scaffold(body: CalendarScreen()),
      themeIndex: 1,
      width: 360,
      height: 796,
      occurrences: <ChoreOccurrence>[
        anOccurrence(
          id: 'tpl_1_20261024',
          templateId: 'tpl_1',
          dateKey: DateKey(2026, 10, 24),
        ),
      ],
    );

    final fill = tester.widget<ColoredBox>(
      find
          .descendant(
            of: find.byType(FadeThroughTransition),
            matching: find.byType(ColoredBox),
          )
          .first,
    );
    expect(fill.color, appThemes[1].tokens.background);
  });
}
