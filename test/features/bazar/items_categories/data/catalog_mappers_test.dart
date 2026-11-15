import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/money.dart';
import 'package:family_hub/core/utils/quantity.dart';
import 'package:family_hub/features/bazar/items_categories/data/catalog_mappers.dart';
import 'package:family_hub/features/bazar/items_categories/domain/category.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item_usage_bump.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final at = DateTime.utc(2026, 10, 18, 9);
  final meta = BaseMapper.createMetadata(uid: 'u1', clock: FakeClock(at));

  test('category round-trips through a map', () {
    const category = Category(
      id: 'c1',
      nameBn: 'মুদি',
      nameEn: 'Staples',
      colorIndex: 2,
      emoji: '🌾',
      imageData: 'abc',
      sortOrder: 3,
      active: true,
      builtIn: true,
      seedKey: 'staples',
    );
    final map = CatalogMappers.categoryToMap(category, meta);
    expect(CatalogMappers.categoryFromMap('c1', map), category);
    expect(map['createdBy'], 'u1');
    expect(map['createdAt'], BaseMapper.dateTimeToTimestamp(at));
    expect(map['schemaVersion'], 1);
  });

  test('categoryFromMap is tolerant and clamps the palette index', () {
    final empty = CatalogMappers.categoryFromMap('c1', const {});
    expect(empty.nameBn, '');
    expect(empty.nameEn, isNull);
    expect(empty.colorIndex, 0);
    expect(empty.sortOrder, 0);
    expect(empty.active, isTrue);
    expect(empty.builtIn, isFalse);
    expect(empty.seedKey, isNull);

    final odd = CatalogMappers.categoryFromMap('c2', const {
      'colorIndex': 99,
      'active': 'yes',
      'sortOrder': 'first',
    });
    expect(odd.colorIndex, 23);
    expect(odd.active, isTrue);
    expect(odd.sortOrder, 0);
  });

  test('item round-trips through a map with paisa and a timestamp', () {
    final item = Item(
      id: 'i1',
      nameBn: 'চাল',
      nameEn: 'Rice',
      categoryId: 'c1',
      defaultUnit: Unit.kg,
      aliases: const <String>['rice', 'chal'],
      emoji: '🍚',
      imageData: 'abc',
      useCount: 4,
      lastPrice: const Money.paisa(12500),
      lastUnitPrice: const Money.paisa(6500),
      lastUsedAt: at,
      active: true,
      builtIn: true,
      seedKey: 'rice',
    );
    final map = CatalogMappers.itemToMap(item, meta);
    expect(CatalogMappers.itemFromMap('i1', map), item);
    expect(map['lastPricePaisa'], 12500);
    expect(map['lastUnitPricePaisa'], 6500);
    expect(map['lastPricePaisa'], isA<int>());
    expect(map.containsKey('lastPrice'), isFalse);
  });

  test('itemFromMap maps an unknown unit to piece and repairs counters', () {
    final item = CatalogMappers.itemFromMap('i1', const {
      'nameBn': 'চাল',
      'defaultUnit': 'crate',
      'aliases': <Object?>['rice', 3, null],
      'useCount': -4,
      'lastPricePaisa': 12500,
      'lastUsedAt': '2026-10-18T09:00:00Z',
    });
    expect(item.defaultUnit, Unit.piece);
    expect(item.aliases, <String>['rice']);
    expect(item.useCount, 0);
    expect(item.lastPrice, const Money.paisa(12500));
    expect(item.lastUnitPrice, isNull);
    expect(item.lastUsedAt, at);
    expect(item.active, isTrue);
    expect(item.builtIn, isFalse);
  });

  test(
    'absent money and usage timestamps are omitted, not written as null',
    () {
      const item = Item(
        id: 'i1',
        nameBn: 'চাল',
        categoryId: 'c1',
        defaultUnit: Unit.piece,
      );
      final map = CatalogMappers.itemToMap(item, meta);
      expect(map.containsKey('lastPricePaisa'), isFalse);
      expect(map.containsKey('lastUnitPricePaisa'), isFalse);
      expect(map.containsKey('lastUsedAt'), isFalse);
      expect(map['useCount'], 0);
      expect(map['active'], isTrue);
    },
  );

  test('categoryChangeMap never touches immutable fields', () {
    const category = Category(
      id: 'c1',
      nameBn: 'মুদি',
      colorIndex: 2,
      sortOrder: 3,
      builtIn: true,
      seedKey: 'staples',
    );
    final map = CatalogMappers.categoryChangeMap(
      category.copyWith(nameBn: 'নতুন'),
      actorUid: 'u2',
      now: at,
    );
    expect(map.keys.toSet(), <String>{
      'nameBn',
      'nameEn',
      'colorIndex',
      'emoji',
      'imageData',
      'sortOrder',
      'active',
      'updatedAt',
      'updatedBy',
    });
    expect(map.containsKey('builtIn'), isFalse);
    expect(map.containsKey('seedKey'), isFalse);
    expect(map['updatedBy'], 'u2');
  });

  test('itemChangeMap leaves usage counters to itemUsageMap', () {
    const item = Item(
      id: 'i1',
      nameBn: 'চাল',
      categoryId: 'c1',
      defaultUnit: Unit.kg,
      useCount: 7,
      builtIn: true,
      seedKey: 'rice',
    );
    final map = CatalogMappers.itemChangeMap(
      item.copyWith(nameBn: 'চাল premium'),
      actorUid: 'u2',
      now: at,
    );
    expect(map.containsKey('useCount'), isFalse);
    expect(map.containsKey('lastPricePaisa'), isFalse);
    expect(map.containsKey('builtIn'), isFalse);
    expect(map.containsKey('seedKey'), isFalse);
    expect(map['updatedBy'], 'u2');
  });

  test('itemUsageMap has exactly the usage fields and an increment', () {
    final bump = ItemUsageBump(
      itemId: 'i1',
      increments: 2,
      lastPrice: const Money.paisa(13000),
      lastUnitPrice: const Money.paisa(6500),
      at: at,
    );
    final map = CatalogMappers.itemUsageMap(bump, actorUid: 'u1', now: at);
    expect(map.keys.toSet(), <String>{
      'useCount',
      'lastPricePaisa',
      'lastUnitPricePaisa',
      'lastUsedAt',
      'updatedAt',
      'updatedBy',
    });
    expect(map['useCount'], isA<FieldValue>());
    expect(map['lastPricePaisa'], 13000);
    expect(map['lastUnitPricePaisa'], 6500);
    expect(map['lastUsedAt'], BaseMapper.dateTimeToTimestamp(at));
    expect(map['updatedBy'], 'u1');
  });
}
