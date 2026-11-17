import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/domain/member_load.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../shared/widgets/shared_widgets_test_support.dart';

const _styles = <String, CalendarMemberStyle>{
  'cara': CalendarMemberStyle(name: 'Cara', avatarKey: 'p3'),
  'amy': CalendarMemberStyle(name: 'Amy', avatarKey: 'p2'),
  'zara': CalendarMemberStyle(name: 'Zara', avatarKey: 'p4'),
};

void main() {
  final day = DateKey(2026, 10, 25);

  Future<void> pumpCell(
    WidgetTester tester, {
    required Locale locale,
    required DaySummary summary,
    Map<String, CalendarMemberStyle> memberStyles = _styles,
    String? viewerId = 'cara',
    double textScale = 1,
  }) async {
    final formatters = AppFormatters(
      languageCode: locale.languageCode,
      useBanglaDigits: locale.languageCode == 'bn',
    );
    await pumpSharedWidget(
      tester,
      spec: appThemes.first,
      locale: locale,
      textScale: textScale,
      child: Semantics(
        role: SemanticsRole.table,
        container: true,
        child: Semantics(
          role: SemanticsRole.row,
          container: true,
          child: SizedBox(
            width: 72,
            child: DayCell(
              summary: summary,
              selected: false,
              memberStyles: memberStyles,
              viewerId: viewerId,
              formatters: formatters,
              minHeight: 64,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('me comes first and has the accent ring', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpCell(
      tester,
      locale: const Locale('en'),
      summary: DaySummary(
        dateKey: day,
        total: 3,
        byMember: const <MemberLoad>[
          MemberLoad(memberId: 'cara', count: 1),
          MemberLoad(memberId: 'amy', count: 1),
          MemberLoad(memberId: 'zara', count: 1),
        ],
      ),
    );

    final avatars = tester.widgetList<AppAvatar>(find.byType(AppAvatar));
    expect(avatars.map((avatar) => avatar.id), ['cara', 'amy']);
    expect(avatars.first.avatarKey, 'p3');
    final ring = tester.widget<Container>(
      find.byKey(const Key('calendar_member_cara')),
    );
    final border = (ring.decoration! as BoxDecoration).border! as Border;
    expect(border.top.width, 2);
    expect(border.top.color, appThemes.first.tokens.accent);
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('0/3'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'Assigned to Cara, Amy, Zara')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('missing and unassigned members use a neutral fallback', (
    tester,
  ) async {
    await pumpCell(
      tester,
      locale: const Locale('en'),
      memberStyles: const <String, CalendarMemberStyle>{},
      summary: DaySummary(
        dateKey: day,
        total: 1,
        byMember: const <MemberLoad>[MemberLoad(memberId: 'removed', count: 1)],
      ),
    );
    expect(find.byType(AppAvatar), findsNothing);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

    await pumpCell(
      tester,
      locale: const Locale('en'),
      summary: DaySummary(
        dateKey: day,
        total: 1,
        byMember: const <MemberLoad>[MemberLoad(memberId: null, count: 1)],
      ),
    );
    expect(find.byType(AppAvatar), findsNothing);
    expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('member cells fit at 2x in ${locale.languageCode}', (
      tester,
    ) async {
      await pumpCell(
        tester,
        locale: locale,
        textScale: 2,
        summary: DaySummary(
          dateKey: day,
          total: 3,
          counts: const <ChoreStatus, int>{ChoreStatus.completed: 2},
          byMember: const <MemberLoad>[
            MemberLoad(memberId: 'cara', count: 1),
            MemberLoad(memberId: 'amy', count: 1),
            MemberLoad(memberId: 'zara', count: 1),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
