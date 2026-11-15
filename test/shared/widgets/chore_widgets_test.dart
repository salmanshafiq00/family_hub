import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/shared/widgets/avatar_stack.dart';
import 'package:family_hub/shared/widgets/color_swatch_picker.dart';
import 'package:family_hub/shared/widgets/flag_chip.dart';
import 'package:family_hub/shared/widgets/mini_markdown_view.dart';
import 'package:family_hub/shared/widgets/minutes_field.dart';
import 'package:family_hub/shared/widgets/status_chip.dart';
import 'package:family_hub/shared/widgets/status_glyph.dart';
import 'package:family_hub/shared/widgets/step_progress.dart';
import 'package:family_hub/shared/widgets/weekday_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shared_widgets_test_support.dart';

/// P3-04: the Phase 3 shared widgets, each in the states the roadmap asks for.
void main() {
  const bn = AppFormatters(languageCode: 'bn', useBanglaDigits: true);
  const en = AppFormatters(languageCode: 'en', useBanglaDigits: false);

  group('WeekdayChips', () {
    test('order() starts on the given day and contains 1..7', () {
      expect(WeekdayChips.order(DateTime.saturday), [6, 7, 1, 2, 3, 4, 5]);
      expect(WeekdayChips.order(DateTime.monday), [1, 2, 3, 4, 5, 6, 7]);
      expect(WeekdayChips.order(DateTime.sunday), [7, 1, 2, 3, 4, 5, 6]);
      for (var start = 1; start <= 7; start++) {
        final order = WeekdayChips.order(start);
        expect(order.toSet(), {1, 2, 3, 4, 5, 6, 7});
        expect(order.first, start);
      }
    });

    testWidgets('shows Saturday first and reports the whole new set', (
      tester,
    ) async {
      Set<int>? last;
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: WeekdayChips(
          selected: const {6},
          onChanged: (next) => last = next,
          formatters: en,
        ),
      );
      // The chips are laid out in week order: Sat, Sun, Mon, ...
      final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
      expect(chips.map((c) => (c.key as ValueKey<int>).value).toList(), [
        6,
        7,
        1,
        2,
        3,
        4,
        5,
      ]);
      expect(chips.first.selected, isTrue);
      expect(chips.elementAt(1).selected, isFalse);

      await tester.tap(find.byKey(const ValueKey<int>(7)));
      expect(last, {6, 7}, reason: 'Sunday is added to Saturday');

      await tester.tap(find.byKey(const ValueKey<int>(6)));
      expect(last, isEmpty, reason: 'tapping a selected day removes it');
    });

    testWidgets('a disabled picker takes no taps', (tester) async {
      var calls = 0;
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('bn'),
        child: WeekdayChips(
          selected: const {},
          onChanged: (_) => calls++,
          formatters: bn,
          enabled: false,
        ),
      );
      await tester.tap(find.byKey(const ValueKey<int>(1)));
      expect(calls, 0);
    });

    testWidgets('every chip reaches the 48 dp touch target', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('bn'),
        child: WeekdayChips(
          selected: const {6},
          onChanged: (_) {},
          formatters: bn,
          weekStartDay: DateTime.saturday,
        ),
      );
      for (final chip in find.byType(FilterChip).evaluate()) {
        final size = chip.size!;
        expect(size.height, greaterThanOrEqualTo(47.5));
        expect(size.width, greaterThanOrEqualTo(47.5));
      }
    });
  });

  group('StatusGlyph', () {
    testWidgets('has a semantics label for every status', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: Wrap(
          children: [
            for (final status in WidgetStatus.values)
              StatusGlyph(status: status),
          ],
        ),
      );
      for (final label in [
        'Scheduled',
        'In progress',
        'Completed',
        'Verified',
        'Overdue',
        'Skipped',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
      handle.dispose();
    });

    testWidgets('paints in both themes without error', (tester) async {
      for (final spec in appThemes) {
        await pumpSharedWidget(
          tester,
          spec: spec,
          locale: const Locale('bn'),
          child: Wrap(
            children: [
              for (final status in WidgetStatus.values)
                for (final size in StatusGlyph.allowedSizes)
                  StatusGlyph(status: status, size: size),
            ],
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('the skipped status renders at every size', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: const Row(
          children: [
            StatusGlyph(status: WidgetStatus.skipped, size: 10),
            StatusGlyph(status: WidgetStatus.skipped, size: 14),
            StatusGlyph(status: WidgetStatus.skipped, size: 18),
          ],
        ),
      );
      expect(find.byType(StatusGlyph), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  });

  group('FlagChip', () {
    testWidgets('every flag has a distinct icon and a label', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: Wrap(
          children: [for (final flag in ChoreFlag.values) FlagChip(flag: flag)],
        ),
      );
      final icons = ChoreFlag.values.map(FlagChip.iconFor).toSet();
      expect(icons, hasLength(ChoreFlag.values.length));
      expect(find.text('Needs an assignee'), findsOneWidget);
      expect(find.text('Awaiting verification'), findsOneWidget);
      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.text('Planned'), findsOneWidget);
      expect(find.text('Swap pending'), findsOneWidget);
    });
  });

  group('StepProgress', () {
    testWidgets('shows the count in Bangla digits', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('bn'),
        child: const StepProgress(done: 3, total: 5, formatters: bn),
      );
      expect(find.text('৩/৫'), findsOneWidget);
    });

    testWidgets('clamps an impossible value instead of crashing', (
      tester,
    ) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: const StepProgress(done: 9, total: 4, formatters: en),
      );
      expect(find.text('4/4'), findsOneWidget);
    });

    testWidgets('a full ring uses the success colour', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: const StepProgress(done: 2, total: 2, formatters: en),
      );
      expect(find.text('2/2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('ColorSwatchPicker', () {
    testWidgets('tapping a swatch reports its index', (tester) async {
      int? picked;
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: ColorSwatchPicker(
          selectedIndex: 0,
          onChanged: (i) => picked = i,
        ),
      );
      await tester.tap(find.byKey(const ValueKey<int>(5)));
      expect(picked, 5);
      expect(find.byType(InkResponse), findsNWidgets(24));
    });

    testWidgets('an out-of-range stored index wraps instead of crashing', (
      tester,
    ) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: ColorSwatchPicker(selectedIndex: 40, onChanged: (_) {}),
      );
      // 40 % 12 == 4: exactly one check mark is drawn.
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  group('MinutesField', () {
    testWidgets('shows the localized time and the end-of-day state', (
      tester,
    ) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('bn'),
        child: Column(
          children: [
            MinutesField(
              label: 'সময়',
              minutes: 9 * 60,
              formatters: bn,
              onChanged: (_) {},
            ),
            MinutesField(
              label: 'সময়',
              minutes: null,
              formatters: bn,
              onChanged: (_) {},
            ),
          ],
        ),
      );
      expect(find.text('সকাল ৯:০০'), findsOneWidget);
      expect(find.text('দিনের শেষে'), findsOneWidget);
    });

    testWidgets('the clear button returns null', (tester) async {
      int? value = 600;
      var cleared = false;
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: MinutesField(
          label: 'Due',
          minutes: 600,
          formatters: en,
          onChanged: (v) {
            cleared = true;
            value = v;
          },
        ),
      );
      await tester.tap(find.byIcon(Icons.clear_rounded));
      expect(cleared, isTrue);
      expect(value, isNull);
    });
  });

  group('AvatarStack', () {
    final people = [
      for (var i = 0; i < 6; i++)
        AvatarStackMember(id: 'u$i', name: 'Person $i'),
    ];

    testWidgets('shows maxVisible avatars and one "+N" bubble', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: AvatarStack(members: people, maxVisible: 4),
      );
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('no bubble when everybody fits', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: AvatarStack(members: people.take(3).toList()),
      );
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('an empty stack renders nothing', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: const AvatarStack(members: []),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('the overflow bubble is tappable when asked', (tester) async {
      var taps = 0;
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: AvatarStack(
          members: people,
          maxVisible: 2,
          onOverflowTap: () => taps++,
        ),
      );
      await tester.tap(find.text('+4'));
      expect(taps, 1);
    });
  });

  group('MiniMarkdownView', () {
    testWidgets('renders headings, bullets, numbers and bold', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: const MiniMarkdownView(
          markdown: '# Rules\n- wash **your** plate\n1. water the plants',
        ),
      );
      expect(find.text('Rules'), findsOneWidget);
      expect(find.textContaining('wash'), findsOneWidget);
      expect(find.text('1.'), findsOneWidget);
      // The bold markers never reach the screen.
      expect(find.textContaining('**'), findsNothing);
    });

    testWidgets('an empty source shows the given empty text', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: const MiniMarkdownView(markdown: '  ', emptyText: 'No rules'),
      );
      expect(find.text('No rules'), findsOneWidget);
    });

    testWidgets('selectable mode still renders the same text', (tester) async {
      await pumpSharedWidget(
        tester,
        spec: appThemes.first,
        locale: const Locale('en'),
        child: const MiniMarkdownView(markdown: 'plain', selectable: true),
      );
      expect(find.byType(SelectableText), findsOneWidget);
    });
  });
}
