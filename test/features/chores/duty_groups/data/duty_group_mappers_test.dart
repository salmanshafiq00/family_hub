import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/data/duty_group_mappers.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-10: the duty-group document is exactly the closed `dutyGroupKeys()` list,
/// round-trips without loss, and reads a damaged document tolerantly.
void main() {
  final at = DateTime.utc(2026, 10, 24, 9);
  final meta = BaseMapper.createMetadata(uid: 'alice', clock: FakeClock(at));

  test('toMap writes the closed key set the rules allow', () {
    final map = DutyGroupMappers.toMap(aDutyGroup(), meta);
    expect(map.keys.toSet(), <String>{
      'nameBn',
      'nameEn',
      'colorIndex',
      'rotation',
      'active',
      'sortOrder',
      'createdAt',
      'createdBy',
      'updatedAt',
      'updatedBy',
      'schemaVersion',
      'deletedAt',
      'deletedBy',
    });
    expect(map['createdAt'], isNotNull);
    expect(map['createdBy'], 'alice');
    expect(map['schemaVersion'], 1);
  });

  test('a group round-trips through the mapper', () {
    final group = aDutyGroup(
      id: 'group_7',
      nameBn: 'রান্নাঘর ডিউটি',
      nameEn: 'Kitchen duty',
      colorIndex: 11,
      active: false,
      sortOrder: 4,
    );
    final map = DutyGroupMappers.toMap(group, meta);
    expect(DutyGroupMappers.fromMap(group.id, map), group);
  });

  test('fromDoc returns null when the document is missing', () {
    expect(DutyGroupMappers.fromDoc('group_1', null), isNull);
  });

  test('a missing rotation is tolerated as an empty roster', () {
    final group = DutyGroupMappers.fromMap('group_1', <String, dynamic>{
      'nameBn': 'দল',
    });
    expect(group.rotation.versions, isEmpty);
    expect(group.members, isEmpty);
    expect(group.active, isTrue);
    expect(group.sortOrder, 0);
    expect(group.colorIndex, isNull);
  });

  test('an unreadable version is dropped, not the whole group', () {
    final group = DutyGroupMappers.fromMap('group_1', <String, dynamic>{
      'nameBn': 'দল',
      'rotation': <String, Object?>{
        'versions': <Object?>[
          <String, Object?>{'from': 'not-a-date'},
          <String, Object?>{
            'from': '2026-09-01',
            'anchorDate': '2026-10-03',
            'members': <String>['alice', 'cara'],
            'anchorIndex': 1,
            'cycleUnit': 'fortnight',
            'weekStartDay': 6,
          },
        ],
      },
    });
    expect(group.rotation.versions, hasLength(1));
    final version = group.rotation.versions.single;
    expect(version.from, DateKey(2026, 9, 1));
    expect(version.members, <String>['alice', 'cara']);
    expect(version.anchorIndex, 1);
    // An unknown unit falls back to the default cycle, never to null.
    expect(version.cycleUnit, CycleUnit.week);
  });

  test('21 stored versions are cut to the 20 the rules allow', () {
    final versions = <Map<String, Object?>>[
      for (var i = 0; i < 21; i++)
        <String, Object?>{
          'from': '2026-09-${(i + 1).toString().padLeft(2, '0')}',
          'anchorDate': '2026-09-01',
          'members': <String>['alice', 'cara'],
          'anchorIndex': 0,
          'cycleUnit': 'week',
          'weekStartDay': 6,
        },
    ];
    final group = DutyGroupMappers.fromMap('group_1', <String, dynamic>{
      'nameBn': 'দল',
      'rotation': <String, Object?>{'versions': versions},
    });
    expect(group.rotation.versions, hasLength(RotationLimits.maxVersions));
  });

  test('an out-of-range colour is dropped and text is clamped', () {
    final group = DutyGroupMappers.fromMap('group_1', <String, dynamic>{
      'nameBn': List<String>.filled(200, 'x').join(),
      'nameEn': '',
      'colorIndex': 99,
      'rotation': aRotation().toMap(),
      'active': 'yes',
      'sortOrder': 3,
    });
    expect(group.nameBn, hasLength(DutyGroupLimits.maxNameLength));
    expect(group.nameEn, isNull);
    expect(group.colorIndex, isNull);
    expect(group.active, isTrue);
    expect(group.sortOrder, 3);
  });
}
