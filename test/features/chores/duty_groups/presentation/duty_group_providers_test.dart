import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-10: the duty-group providers over the in-memory repositories, with the
/// family id and the clock overridden (no Firebase, no widget tree).
void main() {
  const familyId = ChoresFixture.familyId;
  late ChoresFixture fixture;

  setUp(() {
    fixture = ChoresFixture();
    fixture.chores.dutyGroups.groups[familyId] = <String, DutyGroup>{
      'group_1': aDutyGroup(id: 'group_1', sortOrder: 0),
      'group_2': aDutyGroup(id: 'group_2', sortOrder: 1, active: false),
    };
    fixture.chores.templates[familyId] = <String, ChoreTemplate>{
      'tpl_a': _template('tpl_a', dutyGroupId: 'group_1', sortOrder: 0),
      'tpl_b': _template(
        'tpl_b',
        dutyGroupId: 'group_1',
        sortOrder: 1,
        active: false,
      ),
      'tpl_c': _template(
        'tpl_c',
        dutyGroupId: 'group_1',
        sortOrder: 2,
        archived: true,
      ),
      'tpl_d': _template('tpl_d', dutyGroupId: null, sortOrder: 3),
      'tpl_e': _template('tpl_e', dutyGroupId: 'group_2', sortOrder: 4),
    };
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        dutyGroupRepositoryProvider.overrideWithValue(
          fixture.chores.dutyGroups,
        ),
        templateRepositoryProvider.overrideWithValue(fixture.chores),
        currentFamilyIdProvider.overrideWithValue(familyId),
        familyRepositoryProvider.overrideWithValue(fixture.families),
        clockProvider.overrideWithValue(fixture.clock),
        familyDateKeysProvider.overrideWithValue(
          FamilyDateKeys(clock: fixture.clock),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('dutyGroupsProvider lists the groups in sortOrder', () async {
    final container = makeContainer();
    container.listen(dutyGroupsProvider, (_, _) {});
    await container.pump();

    expect(
      container.read(dutyGroupsProvider).map((group) => group.id),
      <String>['group_1', 'group_2'],
    );
    expect(container.read(dutyGroupsTruncatedProvider), isFalse);
  });

  test(
    'dutyGroupProvider and activeDutyGroupsProvider filter by id/active',
    () async {
      final container = makeContainer();
      container.listen(dutyGroupsProvider, (_, _) {});
      await container.pump();

      expect(container.read(dutyGroupProvider('group_1'))?.nameBn, isNotEmpty);
      expect(container.read(dutyGroupProvider('missing')), isNull);
      expect(
        container.read(activeDutyGroupsProvider).map((group) => group.id),
        <String>['group_1'],
      );
    },
  );

  test('dutyGroupTemplatesProvider follows the template dutyGroupId', () async {
    final container = makeContainer();
    container.listen(dutyGroupsProvider, (_, _) {});
    container.listen(templatesProvider, (_, _) {});
    await container.pump();

    // Archived and paused templates: archived is out, paused still points here.
    expect(
      container.read(dutyGroupTemplatesProvider('group_1')).map((t) => t.id),
      <String>['tpl_a', 'tpl_b'],
    );
    expect(
      container.read(dutyGroupTemplatesProvider('group_2')).map((t) => t.id),
      <String>['tpl_e'],
    );
  });

  test('groupOnDutyProvider names the member planned today', () async {
    final container = makeContainer();
    container.listen(dutyGroupsProvider, (_, _) {});
    await container.pump();

    // 2026-10-24 is three Saturday weeks after the 2026-10-03 anchor, so the
    // rotation is back at anchorIndex 0.
    expect(container.read(groupOnDutyProvider('group_1')), 'alice');
    expect(container.read(groupOnDutyProvider('missing')), isNull);
  });

  test('the use-case providers are wired to both repositories', () async {
    final container = makeContainer();
    final update = container.read(updateDutyGroupProvider);

    final result = await update(
      actorUid: 'bob',
      familyId: familyId,
      groupId: 'group_1',
      nameBn: 'নতুন নাম',
      active: false,
      confirmDeactivate: true,
    );

    expect(result.valueOrNull?.nameBn, 'নতুন নাম');
    expect(result.valueOrNull?.active, isFalse);
    expect(
      fixture.chores.dutyGroups.groups[familyId]!['group_1']?.active,
      isFalse,
    );
  });
}

/// A template that points at [dutyGroupId] (or none).
ChoreTemplate _template(
  String id, {
  required String? dutyGroupId,
  required int sortOrder,
  bool active = true,
  bool archived = false,
}) => ChoreTemplate(
  id: id,
  draft: aTemplate(
    assignee: AssigneeSpec(
      strategy: dutyGroupId == null
          ? AssigneeStrategy.manual
          : AssigneeStrategy.rotation,
      dutyGroupId: dutyGroupId,
    ),
  ),
  active: active && !archived,
  archivedAt: archived ? DateTime.utc(2026, 10, 1) : null,
  sortOrder: sortOrder,
);
