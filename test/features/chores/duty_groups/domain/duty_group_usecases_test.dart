import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/change_rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/create_duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/update_duty_group.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-09: duty-group use cases against the in-memory backend — the permission
/// matrix, validation order, write kind (everyday vs integrity) and audit.
void main() {
  late ChoresFixture fixture;
  late CreateDutyGroup create;
  late UpdateDutyGroup update;
  late ChangeRotation change;

  setUp(() {
    fixture = ChoresFixture();
    final groups = fixture.chores.dutyGroups;
    create = CreateDutyGroup(
      groups: groups,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    update = UpdateDutyGroup(
      groups: groups,
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    change = ChangeRotation(
      groups: groups,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
  });

  const familyId = ChoresFixture.familyId;
  DateKey day(int month, int date) => DateKey(2026, month, date);

  Future<DutyGroup> seed({Rotation? rotation}) async {
    final result = await create(
      actorUid: 'bob',
      familyId: familyId,
      nameBn: 'রান্নাঘর ডিউটি',
      nameEn: 'Kitchen duty',
      colorIndex: 1,
      rotation: rotation ?? aRotation(),
    );
    return result.valueOrNull!;
  }

  group('CreateDutyGroup', () {
    test('a Household Manager creates with sortOrder max + 1', () async {
      final first = await seed();
      expect(
        fixture.chores.dutyGroups.events.single.type,
        AuditEventType.choresDutyGroupCreated,
      );
      final second = await seed();
      expect(first.sortOrder, 0);
      expect(second.sortOrder, 1);
      expect(first.rotation.versions, hasLength(1));
      expect(fixture.chores.dutyGroups.events, hasLength(2));
    });

    test('a plain member is denied and nothing is written', () async {
      final result = await create(
        actorUid: 'cara',
        familyId: familyId,
        nameBn: 'দল',
        rotation: aRotation(),
      );
      expect(result.failureOrNull, const PermissionDenied());
      expect(fixture.chores.dutyGroups.writes, 0);
    });

    test('a pending member is denied', () async {
      final result = await create(
        actorUid: 'erin',
        familyId: familyId,
        nameBn: 'দল',
        rotation: aRotation(),
      );
      expect(result.failureOrNull, const PermissionDenied());
    });

    test('a one-member rotation is not a rotation', () async {
      final result = await create(
        actorUid: 'bob',
        familyId: familyId,
        nameBn: 'দল',
        rotation: aRotation(members: <String>['cara']),
      );
      expect(
        result.failureOrNull,
        const Validation('members', 'too_few_members'),
      );
      expect(fixture.chores.dutyGroups.writes, 0);
    });

    test('a blank name is refused before the write', () async {
      final result = await create(
        actorUid: 'bob',
        familyId: familyId,
        nameBn: '   ',
        rotation: aRotation(),
      );
      expect(result.failureOrNull, const Validation('nameBn', 'required'));
      expect(fixture.chores.dutyGroups.writes, 0);
    });

    test('the 50-group cap is enforced', () async {
      fixture.chores.dutyGroups.groups[familyId] = <String, DutyGroup>{
        for (var i = 0; i < DutyGroupLimits.maxGroups; i++)
          'g$i': aDutyGroup(id: 'g$i', sortOrder: i),
      };
      final result = await create(
        actorUid: 'bob',
        familyId: familyId,
        nameBn: 'দল',
        rotation: aRotation(),
      );
      expect(
        result.failureOrNull,
        const Validation('dutyGroups', 'too_many_items'),
      );
    });
  });

  group('UpdateDutyGroup', () {
    test('changes name, colour and active, keeping the rotation', () async {
      final group = await seed();
      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        nameBn: 'সাপ্তাহিক ডিউটি',
        nameEn: null,
        colorIndex: 3,
        active: false,
      );
      final updated = result.valueOrNull!;
      expect(updated.nameBn, 'সাপ্তাহিক ডিউটি');
      expect(updated.nameEn, isNull);
      expect(updated.colorIndex, 3);
      expect(updated.active, isFalse);
      expect(updated.rotation, group.rotation);
      expect(
        fixture.chores.dutyGroups.events.last.type,
        AuditEventType.choresDutyGroupUpdated,
      );
    });

    test('an unknown group is NotFound', () async {
      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        groupId: 'missing',
        nameBn: 'দল',
      );
      expect(result.failureOrNull, const NotFound(entity: 'dutyGroup'));
    });

    test('a plain member is denied', () async {
      final group = await seed();
      final result = await update(
        actorUid: 'cara',
        familyId: familyId,
        groupId: group.id,
        nameBn: 'দল',
      );
      expect(result.failureOrNull, const PermissionDenied());
    });

    test('a repository failure is passed through', () async {
      final group = await seed();
      fixture.chores.dutyGroups.nextSaveFailure = const Network();
      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        nameBn: 'দল',
      );
      expect(result.failureOrNull, const Network());
    });

    test('deactivating a group a template still uses warns first', () async {
      final group = await seed();
      fixture.chores.templates[familyId] = <String, ChoreTemplate>{
        'tpl_1': _aChore('tpl_1', group.id),
      };
      final writesBefore = fixture.chores.dutyGroups.writes;

      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        nameBn: group.nameBn,
        active: false,
      );

      expect(result.failureOrNull, const Conflict(code: 'last_group_in_use'));
      expect(fixture.chores.dutyGroups.writes, writesBefore);
    });

    test('the warning can be confirmed and then deactivates', () async {
      final group = await seed();
      fixture.chores.templates[familyId] = <String, ChoreTemplate>{
        'tpl_1': _aChore('tpl_1', group.id),
      };
      final writesBefore = fixture.chores.dutyGroups.writes;

      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        nameBn: group.nameBn,
        active: false,
        confirmDeactivate: true,
      );

      expect(result.valueOrNull!.active, isFalse);
      expect(fixture.chores.dutyGroups.writes, writesBefore + 1);
    });

    test('an archived template does not block deactivation', () async {
      final group = await seed();
      fixture.chores.templates[familyId] = <String, ChoreTemplate>{
        'tpl_1': _aChore('tpl_1', group.id, archived: true),
      };

      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        nameBn: group.nameBn,
        active: false,
      );

      expect(result.valueOrNull!.active, isFalse);
    });

    test('a template of another group does not block deactivation', () async {
      final group = await seed();
      fixture.chores.templates[familyId] = <String, ChoreTemplate>{
        'tpl_1': _aChore('tpl_1', 'group_other'),
      };

      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        nameBn: group.nameBn,
        active: false,
      );

      expect(result.valueOrNull!.active, isFalse);
    });
  });

  group('ChangeRotation', () {
    test('add appends a version and uses the integrity write', () async {
      final group = await seed();
      final writesBefore = fixture.chores.dutyGroups.writes;
      final result = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.add,
        effectiveFrom: day(10, 24),
        memberId: 'bob',
      );

      final updated = result.valueOrNull!;
      expect(updated.rotation.versions, hasLength(2));
      expect(updated.rotation.versions.last.from, day(10, 24));
      expect(updated.rotation.versions.last.members, contains('bob'));
      expect(fixture.chores.dutyGroups.rotationWrites, 1);
      expect(fixture.chores.dutyGroups.writes, writesBefore);

      final event = fixture.chores.dutyGroups.events.last;
      expect(event.type, AuditEventType.choresRotationChanged);
      expect(event.params['change'], 'add');
      expect(event.params['from'], '2026-10-24');
    });

    test('a new member must be an active family member', () async {
      final group = await seed();
      final pending = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.add,
        effectiveFrom: day(10, 24),
        memberId: 'erin',
      );
      expect(
        pending.failureOrNull,
        const Conflict(code: 'rotation_member_inactive'),
      );

      final unknown = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.add,
        effectiveFrom: day(10, 24),
        memberId: 'zoe',
      );
      expect(unknown.failureOrNull, const NotFound(entity: 'member'));
      expect(fixture.chores.dutyGroups.rotationWrites, 0);
    });

    test('remove takes the last two down to one only if allowed', () async {
      final group = await seed(
        rotation: aRotation(members: <String>['cara', 'dave']),
      );
      final result = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.remove,
        effectiveFrom: day(10, 24),
        memberId: 'dave',
      );
      expect(
        result.failureOrNull,
        const Validation('members', 'too_few_members'),
      );
    });

    test('reorder starts with the chosen member at the boundary', () async {
      final group = await seed();
      final result = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.reorder,
        effectiveFrom: day(10, 24),
        members: <String>['dave', 'alice', 'cara'],
        startsWith: 'dave',
      );
      final updated = result.valueOrNull!;
      expect(updated.rotation.versions.last.anchorIndex, 0);
      expect(RotationEngine.planned(updated.rotation, day(10, 24)), 'dave');
    });

    test('a date before the first version is refused', () async {
      final group = await seed();
      final result = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.add,
        effectiveFrom: day(8, 1),
        memberId: 'bob',
      );
      expect(
        result.failureOrNull,
        const Validation('rotation', 'invalid_date'),
      );
    });

    test('a plain member is denied', () async {
      final group = await seed();
      final result = await change(
        actorUid: 'cara',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.add,
        effectiveFrom: day(10, 24),
        memberId: 'bob',
      );
      expect(result.failureOrNull, const PermissionDenied());
    });

    test('the missing member id is reported before any read', () async {
      final result = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: 'missing',
        change: RotationChange.remove,
        effectiveFrom: day(10, 24),
      );
      expect(
        result.failureOrNull,
        const Validation('members', 'member_required'),
      );
    });

    test('a read failure is passed through', () async {
      final group = await seed();
      fixture.chores.dutyGroups.nextReadFailure = const Network();
      final result = await change(
        actorUid: 'bob',
        familyId: familyId,
        groupId: group.id,
        change: RotationChange.add,
        effectiveFrom: day(10, 24),
        memberId: 'bob',
      );
      expect(result.failureOrNull, const Network());
    });
  });

  test('the in-memory backend lists groups in sortOrder', () async {
    await seed();
    await seed();
    final listed = await fixture.chores.dutyGroups.list(familyId);
    expect(listed.valueOrNull!.map((group) => group.sortOrder), <int>[0, 1]);
  });
}

/// A template whose rotation points at [groupId].
ChoreTemplate _aChore(String id, String groupId, {bool archived = false}) =>
    ChoreTemplate(
      id: id,
      draft: aTemplate(
        assignee: AssigneeSpec(
          strategy: AssigneeStrategy.rotation,
          dutyGroupId: groupId,
        ),
      ),
      active: !archived,
      archivedAt: archived ? DateTime.utc(2026, 10, 1) : null,
    );
