import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/shared/widgets/catalog_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'shared_widgets_test_support.dart';

/// P3-04: the generic `{id, labelBn, labelEn?, active}` list editor used three
/// times by the chore settings screen (groups, due-time presets, reasons).
void main() {
  const kitchen = CatalogEntry(
    id: 'kitchen',
    labelBn: 'রান্নাঘর',
    builtIn: true,
  );
  const bathroom = CatalogEntry(
    id: 'bathroom',
    labelBn: 'বাথরুম',
    labelEn: 'Bathroom',
    builtIn: true,
  );
  const custom = CatalogEntry(id: 'custom_1', labelBn: 'ছাদ');

  /// Pumps an editor that reflects every change back into itself, so a test
  /// sees the list a real screen would.
  Future<List<List<CatalogEntry>>> pumpEditor(
    WidgetTester tester, {
    List<CatalogEntry> initial = const [kitchen, bathroom, custom],
    bool canDeleteBuiltIn = false,
  }) async {
    final states = <List<CatalogEntry>>[initial];
    await pumpSharedWidget(
      tester,
      spec: appThemes.first,
      locale: const Locale('bn'),
      child: StatefulBuilder(
        builder: (context, setState) => CatalogEditor(
          entries: states.last,
          canDeleteBuiltIn: canDeleteBuiltIn,
          onChanged: (next) => setState(() => states.add(next)),
        ),
      ),
    );
    return states;
  }

  Future<void> openMenu(WidgetTester tester, int row) async {
    await tester.tap(find.byType(PopupMenuButton<String>).at(row));
    await tester.pumpAndSettle();
  }

  testWidgets('lists every row in order', (tester) async {
    await pumpEditor(tester);
    expect(find.text('রান্নাঘর'), findsOneWidget);
    expect(find.text('বাথরুম'), findsOneWidget);
    expect(find.text('ছাদ'), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle_rounded), findsNWidgets(3));
  });

  testWidgets('reordering reports the whole list in the new order', (
    tester,
  ) async {
    final states = await pumpEditor(tester);
    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    // Moving the third row to the front: the callback already reports the
    // final index (no off-by-one shift for a down-move either).
    list.onReorderItem!(2, 0);
    await tester.pumpAndSettle();
    expect(states.last.map((e) => e.id).toList(), [
      'custom_1',
      'kitchen',
      'bathroom',
    ]);
  });

  testWidgets('every drag has a Move up / Move down twin (rule 71)', (
    tester,
  ) async {
    final states = await pumpEditor(tester);

    bool enabled(String key) =>
        tester
            .widget<IconButton>(find.byKey(ValueKey<String>(key)))
            .onPressed !=
        null;

    // The edge rows keep their disabled twin so the rows do not jump sideways.
    expect(enabled('move_up_0'), isFalse);
    expect(enabled('move_down_0'), isTrue);
    expect(enabled('move_up_2'), isTrue);
    expect(enabled('move_down_2'), isFalse);
    expect(
      find.byTooltip('উপরে নিন'),
      findsNWidgets(3),
      reason: 'a screen reader needs the label, not only the arrow',
    );

    await tester.tap(find.byKey(const ValueKey<String>('move_down_0')));
    await tester.pumpAndSettle();
    expect(states.last.map((e) => e.id).toList(), [
      'bathroom',
      'kitchen',
      'custom_1',
    ]);

    await tester.tap(find.byKey(const ValueKey<String>('move_up_2')));
    await tester.pumpAndSettle();
    expect(states.last.map((e) => e.id).toList(), [
      'bathroom',
      'custom_1',
      'kitchen',
    ]);
  });

  testWidgets('deactivating keeps the row but marks it off', (tester) async {
    final states = await pumpEditor(tester);
    await openMenu(tester, 0);
    await tester.tap(find.text('বন্ধ করুন'));
    await tester.pumpAndSettle();

    final kitchenNow = states.last.firstWhere((e) => e.id == 'kitchen');
    expect(kitchenNow.active, isFalse);
    expect(states.last, hasLength(3), reason: 'deactivate must not delete');
    expect(find.text('রান্নাঘর'), findsOneWidget);
  });

  testWidgets('a deactivated row can be activated again', (tester) async {
    final states = await pumpEditor(
      tester,
      initial: const [
        CatalogEntry(id: 'a', labelBn: 'ক', active: false),
        kitchen,
      ],
    );
    await openMenu(tester, 0);
    await tester.tap(find.text('আবার চালু করুন'));
    await tester.pumpAndSettle();
    expect(states.last.first.active, isTrue);
  });

  testWidgets('a built-in row offers no delete', (tester) async {
    await pumpEditor(tester);
    await openMenu(tester, 0);
    expect(find.text('সম্পাদনা'), findsOneWidget);
    expect(find.text('বন্ধ করুন'), findsOneWidget);
    expect(
      find.text('মুছুন'),
      findsNothing,
      reason: 'built-in presets/reasons are protected by default',
    );
  });

  testWidgets('canDeleteBuiltIn offers delete on a built-in row', (
    tester,
  ) async {
    final states = await pumpEditor(tester, canDeleteBuiltIn: true);
    await openMenu(tester, 0);
    await tester.tap(find.text('মুছুন'));
    await tester.pumpAndSettle();
    expect(states.last.map((e) => e.id), isNot(contains('kitchen')));
  });

  testWidgets('a custom row can be deleted', (tester) async {
    final states = await pumpEditor(tester);
    await openMenu(tester, 2);
    await tester.tap(find.text('মুছুন'));
    await tester.pumpAndSettle();
    expect(states.last.map((e) => e.id), isNot(contains('custom_1')));
    expect(states.last, hasLength(2));
  });

  testWidgets('renaming replaces only that row', (tester) async {
    final states = await pumpEditor(tester);
    await openMenu(tester, 1);
    await tester.tap(find.text('সম্পাদনা'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.first, 'গোসলখানা');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(states.last[1].id, 'bathroom');
    expect(states.last[1].labelBn, 'গোসলখানা');
    expect(states.last[1].builtIn, isTrue, reason: 'builtIn survives an edit');
    expect(states.last[0].labelBn, 'রান্নাঘর');
  });

  testWidgets('adding uses the first free custom_N id', (tester) async {
    final states = await pumpEditor(tester);
    await tester.tap(find.text('যোগ করুন'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    // Save is disabled until the Bangla name is typed.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await tester.enterText(fields.first, 'বারান্দা');
    await tester.enterText(fields.last, 'Balcony');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    final added = states.last.last;
    expect(added.id, 'custom_2', reason: 'custom_1 is already taken');
    expect(added.labelBn, 'বারান্দা');
    expect(added.labelEn, 'Balcony');
    expect(added.active, isTrue);
    expect(added.builtIn, isFalse);
  });

  testWidgets('an empty list shows the empty text and the add button', (
    tester,
  ) async {
    await pumpEditor(tester, initial: const []);
    expect(find.text('এখনও কিছু নেই।'), findsOneWidget);
    expect(find.text('যোগ করুন'), findsOneWidget);
  });
}
