import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_pack_wizard_screen.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-19 widget tests: the manager gate, the confidence legend and the default
/// ticks, applying with a rotation, and applying with "assign later".
void main() {
  late ChoresFixture fixture;

  setUp(() => fixture = ChoresFixture());

  Future<void> open(
    WidgetTester tester, {
    String uid = 'bob',
    Role role = Role.moderator,
  }) async {
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      home: const StarterPackWizardScreen(),
      uid: uid,
      role: role,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    final finder = find.byKey(ValueKey<String>(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('a plain member sees why they cannot add a pack', (tester) async {
    await open(tester, uid: 'cara', role: Role.member);

    expect(
      find.text('Only a Household Manager can add a starter pack.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('starter_next')), findsNothing);
  });

  testWidgets('the review shows the confidence legend and ticks only High', (
    tester,
  ) async {
    await open(tester);
    await tapKey(tester, 'starter_next');

    expect(
      find.byKey(const ValueKey<String>('starter_confidence_legend')),
      findsOneWidget,
    );
    final sweep = find.byKey(const ValueKey<String>('starter_template_sweep'));
    expect(tester.widget<Checkbox>(sweep).value, isTrue);

    final dinner = find.byKey(const ValueKey<String>('starter_template_dinner'));
    await tester.scrollUntilVisible(
      dinner,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.widget<Checkbox>(dinner).value, isFalse);
    expect(find.text('please confirm'), findsWidgets);
  });

  testWidgets('applying creates the chores, then shows Open Today', (
    tester,
  ) async {
    await open(tester);
    await tapKey(tester, 'starter_next');
    await tapKey(tester, 'starter_next');
    await tapKey(tester, 'starter_apply');

    expect(find.text('Starter pack added'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('starter_open_today')),
      findsOneWidget,
    );
    final templates = fixture.chores.templates[ChoresFixture.familyId]!;
    expect(templates.keys, contains('tpl_sweep'));
    expect(templates['tpl_dinner'], isNull);
    expect(
      fixture.chores.dutyGroups.groups[ChoresFixture.familyId],
      isNotNull,
    );
  });

  testWidgets('turning the rotation off applies with no duty group', (
    tester,
  ) async {
    await open(tester);
    await tapKey(tester, 'starter_next');
    await tapKey(tester, 'starter_next');
    expect(
      find.byKey(const ValueKey<String>('starter_use_rotation')),
      findsOneWidget,
    );
    await tapKey(tester, 'starter_use_rotation');
    await tapKey(tester, 'starter_apply');

    expect(find.text('Starter pack added'), findsOneWidget);
    expect(
      fixture.chores.dutyGroups.groups[ChoresFixture.familyId],
      anyOf(isNull, isEmpty),
    );
    final template =
        fixture.chores.templates[ChoresFixture.familyId]!['tpl_sweep']!;
    expect(template.draft.assignee.strategy, AssigneeStrategy.manual);
    expect(template.draft.assignee.dutyGroupId, isNull);
  });
}
