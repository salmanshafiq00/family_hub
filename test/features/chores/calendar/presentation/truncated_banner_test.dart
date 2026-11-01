import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/truncated_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/widgets/shared_widgets_test_support.dart';

/// P3-21: the "too many chores in this month" banner (C-2, B.9-24).
void main() {
  for (final locale in sharedWidgetLocales) {
    for (final scale in <double>[1, 2]) {
      testWidgets(
        'shows the message and opens the filters (${locale.languageCode}, '
        'x$scale)',
        (tester) async {
          var opened = 0;
          await pumpSharedWidget(
            tester,
            child: TruncatedBanner(onOpenFilters: () => opened++),
            spec: appThemes.first,
            locale: locale,
            textScale: scale,
          );

          expect(find.byKey(const Key('calendar_truncated_banner')), findsOneWidget);
          expect(tester.takeException(), isNull);

          final action = find.byKey(
            const Key('calendar_truncated_banner_action'),
          );
          expect(tester.getSize(action).height, greaterThanOrEqualTo(48));
          await tester.tap(action);
          expect(opened, 1);
        },
      );
    }
  }
}
