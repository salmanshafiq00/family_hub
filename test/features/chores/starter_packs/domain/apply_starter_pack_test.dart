import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/regenerate_range.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack_outcome.dart';
import 'package:family_hub/features/chores/starter_packs/domain/usecases/apply_starter_pack.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-19: [ApplyStarterPack] against the in-memory backend — idempotence,
/// "Medium is unticked", family edits win, the rotation choice and the audit.
void main() {
  late ChoresFixture fixture;
  late ApplyStarterPack apply;

  const familyId = ChoresFixture.familyId;
  const rotation = StarterRotationConfig(
    memberIds: <String>['alice', 'bob', 'cara'],
    firstMemberId: 'bob',
  );
  final high = <String>{
    for (final template in familyPdfPack.highConfidence) template.seedKey,
  };

  setUp(() {
    fixture = ChoresFixture();
    final regenerate = RegenerateRange(
      occurrences: fixture.occurrences,
      templates: fixture.chores,
      dutyGroups: fixture.chores.dutyGroups,
      settings: fixture.settings,
      families: fixture.families,
      dateKeys: fixture.dateKeys,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    apply = ApplyStarterPack(
      settings: fixture.settings,
      templates: fixture.chores,
      dutyGroups: fixture.chores.dutyGroups,
      markers: fixture.occurrences,
      regenerate: regenerate,
      families: fixture.families,
      dateKeys: fixture.dateKeys,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
  });

  Future<StarterPackOutcome> run({
    Set<String>? selection,
    StarterRotationConfig? rotationConfig = rotation,
    String actorUid = 'bob',
  }) async {
    final result = await apply(
      actorUid: actorUid,
      familyId: familyId,
      selectedSeedKeys: selection ?? high,
      rotation: rotationConfig,
    );
    return result.valueOrNull!;
  }

  test('creates the high-confidence lines, the duty group and the audit', () async {
    final outcome = await run();

    expect(outcome.templatesCreated, high.length);
    expect(outcome.templatesSkipped, 0);
    expect(outcome.dutyGroupsCreated, 1);
    expect(outcome.houseRulesAdded, isTrue);
    expect(outcome.generationFailure, isNull);
    expect(outcome.generation!.created, greaterThan(0));

    final templates = fixture.chores.templates[familyId]!;
    expect(templates.keys, containsAll(<String>['tpl_sweep', 'tpl_fridge_weekly']));
    expect(templates['tpl_dinner'], isNull, reason: 'Medium is unticked');
    final sweep = templates['tpl_sweep']!;
    expect(sweep.builtIn, isTrue);
    expect(sweep.seedKey, 'sweep');
    expect(sweep.draft.assignee.strategy, AssigneeStrategy.rotation);
    expect(sweep.draft.assignee.dutyGroupId, 'duty_family_pdf');

    final groups = fixture.chores.dutyGroups.groups[familyId]!;
    expect(groups['duty_family_pdf']!.members, rotation.memberIds);

    expect(
      fixture.settings.events.single.type,
      AuditEventType.choresStarterPackApplied,
    );
    expect(fixture.settings.settings.houseRules, familyPdfPack.houseRulesBn);
    expect(fixture.chores.events, hasLength(high.length));
    expect(fixture.occurrences.occurrences[familyId], isNotEmpty);
  });

  test('a second apply creates nothing and reports starter_pack_applied', () async {
    await run();
    final writes = fixture.chores.writes;
    final saves = fixture.settings.saves;
    final occurrences = fixture.occurrences.occurrences[familyId]!.length;
    final again = await apply(
      actorUid: 'bob',
      familyId: familyId,
      selectedSeedKeys: high,
      rotation: rotation,
    );

    expect(again.failureOrNull, const Conflict(code: 'starter_pack_applied'));
    expect(fixture.chores.writes, writes);
    expect(fixture.settings.saves, saves);
    expect(fixture.occurrences.occurrences[familyId], hasLength(occurrences));
  });

  test('only the selected lines are created; a Medium line stays unticked', () async {
    expect(high, isNot(contains('dinner')));
    final outcome = await run(selection: <String>{'sweep'});

    expect(outcome.templatesCreated, 1);
    expect(fixture.chores.templates[familyId]!.keys, <String>['tpl_sweep']);
    expect(fixture.chores.templates[familyId]!['tpl_dinner'], isNull);
    expect(fixture.chores.templates[familyId]!['tpl_doormat'], isNull);
  });

  test('a family-edited group keeps its name while missing groups are added', () async {
    fixture.settings.settings = ChoreSettings.defaults.copyWith(
      groups: <ChoreGroup>[
        const ChoreGroup(id: 'cleaning', nameBn: 'আমাদের ঝাড়ু দল'),
      ],
    );

    final outcome = await run();

    final groups = fixture.settings.settings.groups;
    expect(
      groups.singleWhere((group) => group.id == 'cleaning').nameBn,
      'আমাদের ঝাড়ু দল',
    );
    expect(outcome.catalogGroupsAdded, greaterThan(0));
  });

  test('without a rotation the duty group is skipped and chores wait for an assignee', () async {
    final outcome = await run(rotationConfig: null);

    expect(outcome.dutyGroupsCreated, 0);
    expect(
      fixture.chores.dutyGroups.groups[familyId]?['duty_family_pdf'],
      isNull,
    );
    final template = fixture.chores.templates[familyId]!['tpl_sweep']!;
    expect(template.draft.assignee.strategy, AssigneeStrategy.manual);
    expect(template.draft.assignee.dutyGroupId, isNull);
  });

  test('a family-edited template is skipped, not overwritten', () async {
    fixture.chores.templates[familyId] = <String, ChoreTemplate>{
      'tpl_sweep': ChoreTemplate(
        id: 'tpl_sweep',
        draft: aTemplate(nameBn: 'আমাদের নিজের ঝাড়ু'),
        builtIn: true,
        seedKey: 'sweep',
      ),
    };

    final outcome = await run();

    expect(outcome.templatesCreated, high.length - 1);
    expect(outcome.templatesSkipped, 1);
    expect(
      fixture.chores.templates[familyId]!['tpl_sweep']!.draft.nameBn,
      'আমাদের নিজের ঝাড়ু',
    );
  });

  test('a plain member is denied before anything is written', () async {
    final result = await apply(
      actorUid: 'cara',
      familyId: familyId,
      selectedSeedKeys: high,
      rotation: rotation,
    );

    expect(result.failureOrNull, const PermissionDenied());
    expect(fixture.settings.saves, 0);
    expect(fixture.chores.writes, 0);
    expect(fixture.chores.dutyGroups.groups, isEmpty);
  });

  test('a one-member rotation is rejected before anything is written', () async {
    final result = await apply(
      actorUid: 'bob',
      familyId: familyId,
      selectedSeedKeys: high,
      rotation: const StarterRotationConfig(
        memberIds: <String>['alice'],
        firstMemberId: 'alice',
      ),
    );

    expect(
      result.failureOrNull,
      const Validation('members', 'too_few_members'),
    );
    expect(fixture.settings.saves, 0);
  });
}
