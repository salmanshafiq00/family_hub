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
  'bob': CalendarMemberStyle(name: 'Bob', avatarKey: 'p5'),
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
    double height = 64,
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
              minHeight: height,
              onTap: () {},
              onLongPress: () {},
            ),
          ),
        ),
      ),
    );
  }

  DaySummary summary(List<String?> ids, {int mine = 0}) => DaySummary(
    dateKey: day,
    total: ids.length,
    counts: <ChoreStatus, int>{ChoreStatus.scheduled: ids.length},
    mineCount: mine,
    byMember: <MemberLoad>[
      for (final id in ids) MemberLoad(memberId: id, count: 1),
    ],
  );

  testWidgets('me is the person icon on top, never in the avatar row', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpCell(
      tester,
      locale: const Locale('en'),
      summary: summary(['cara', 'amy', 'zara', 'bob'], mine: 1),
    );

    expect(find.byKey(const Key('calendar_cell_mine')), findsOneWidget);
    final avatars = tester.widgetList<AppAvatar>(find.byType(AppAvatar));
    // Others by member id (never by load): amy, bob; zara is the "+1".
    expect(avatars.map((avatar) => avatar.id), ['amy', 'bob']);
    expect(find.byKey(const Key('calendar_member_cara')), findsNothing);
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('0/4'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp(r'Assigned to Cara, Amy, Zara, Bob')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('no person icon when the viewer has no chore that day', (
    tester,
  ) async {
    await pumpCell(
      tester,
      locale: const Locale('en'),
      summary: summary(['amy']),
    );
    expect(find.byKey(const Key('calendar_cell_mine')), findsNothing);
    expect(find.byKey(const Key('calendar_member_amy')), findsOneWidget);
  });

  testWidgets('missing and unassigned members use a neutral fallback', (
    tester,
  ) async {
    await pumpCell(
      tester,
      locale: const Locale('en'),
      memberStyles: const <String, CalendarMemberStyle>{},
      summary: summary(['removed']),
    );
    expect(find.byType(AppAvatar), findsNothing);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

    await pumpCell(
      tester,
      locale: const Locale('en'),
      summary: summary([null]),
    );
    expect(find.byType(AppAvatar), findsNothing);
    expect(find.byIcon(Icons.person_outline_rounded), findsNothing);
  });

  testWidgets('the avatar row is hidden at text scale 1.5 and above', (
    tester,
  ) async {
    await pumpCell(
      tester,
      locale: const Locale('en'),
      textScale: 1.5,
      height: 100,
      summary: summary(['cara', 'amy'], mine: 1),
    );
    expect(find.byType(AppAvatar), findsNothing);
    // The information stays in the screen-reader label.
    expect(find.byKey(const Key('calendar_cell_mine')), findsOneWidget);
  });

  testWidgets('the avatar row is hidden in a cell too short for it', (
    tester,
  ) async {
    await pumpCell(
      tester,
      locale: const Locale('en'),
      height: 44,
      summary: summary(['amy']),
    );
    expect(find.byType(AppAvatar), findsNothing);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('member cells fit at 2x in ${locale.languageCode}', (
      tester,
    ) async {
      await pumpCell(
        tester,
        locale: locale,
        textScale: 2,
        summary: summary(['cara', 'amy', 'zara'], mine: 1),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
