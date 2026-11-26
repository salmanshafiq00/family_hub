import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/create_template.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/pause_template.dart';
import 'package:family_hub/features/chores/templates/presentation/template_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-16: the template list (grouping, filters, search, gated actions).
void main() {
  const familyId = ChoresFixture.familyId;

  Future<ChoresFixture> seeded() async {
    final fixture = ChoresFixture();
    final create = CreateTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    final pause = PauseTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    final group = ChoreSettings.defaults.groups.first.id;
    await create(
      actorUid: 'alice',
      familyId: familyId,
      draft: aTemplate(nameEn: 'Wash the dishes', groupId: group),
    );
    await create(
      actorUid: 'alice',
      familyId: familyId,
      draft: aTemplate(nameEn: 'Mop the floor', groupId: group),
    );
    final third = await create(
      actorUid: 'alice',
      familyId: familyId,
      draft: aTemplate(nameEn: 'Water the plants', groupId: group),
    );
    await pause(
      actorUid: 'alice',
      familyId: familyId,
      templateId: third.valueOrNull!.id,
    );
    return fixture;
  }

  testWidgets('shows active chores by default, paused under its filter', (
    tester,
  ) async {
    final fixture = await seeded();
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      role: Role.admin,
      uid: 'alice',
      home: const TemplateListScreen(),
    );

    expect(find.text('Wash the dishes'), findsOneWidget);
    expect(find.text('Mop the floor'), findsOneWidget);
    expect(find.text('Water the plants'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('filter_paused')));
    await tester.pump();
    expect(find.text('Water the plants'), findsOneWidget);
    expect(find.text('Wash the dishes'), findsNothing);
  });

  testWidgets('search narrows the list', (tester) async {
    final fixture = await seeded();
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      role: Role.admin,
      uid: 'alice',
      home: const TemplateListScreen(),
    );

    await tester.enterText(
      find.byKey(const ValueKey<String>('template_search')),
      'mop',
    );
    await tester.pump();
    expect(find.text('Mop the floor'), findsOneWidget);
    expect(find.text('Wash the dishes'), findsNothing);
  });

  testWidgets('only a manager gets the New chore button', (tester) async {
    final fixture = await seeded();
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      home: const TemplateListScreen(),
    );
    expect(find.byKey(const ValueKey<String>('template_new')), findsNothing);
  });

  testWidgets('a manager sees the New chore button', (tester) async {
    final fixture = await seeded();
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      role: Role.admin,
      uid: 'alice',
      home: const TemplateListScreen(),
    );
    expect(find.byKey(const ValueKey<String>('template_new')), findsOneWidget);
  });

  testWidgets('pausing a chore removes its unstarted future days', (
    tester,
  ) async {
    final fixture = ChoresFixture();
    final create = CreateTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    final created = await create(
      actorUid: 'alice',
      familyId: familyId,
      draft: aTemplate(nameEn: 'Clean living room'),
    );
    final template = created.valueOrNull!;
    final occurrence = anOccurrence(
      id: '${template.id}_20261025',
      templateId: template.id,
      dateKey: DateKey(2026, 10, 25),
      nameEn: 'Clean living room',
    );

    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      occurrences: <ChoreOccurrence>[occurrence],
      role: Role.admin,
      uid: 'alice',
      home: const TemplateListScreen(),
    );

    await tester.longPress(find.text('Clean living room'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('sheet_pause')));
    await tester.pumpAndSettle();

    final stored = fixture.occurrences.occurrences[familyId]![occurrence.id]!;
    expect(stored.isDeleted, isTrue);
  });
}
