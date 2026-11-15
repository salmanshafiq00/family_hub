import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/money.dart';
import 'package:family_hub/core/utils/quantity.dart';
import 'package:family_hub/features/bazar/items_categories/domain/catalog_validation.dart';
import 'package:family_hub/features/bazar/items_categories/domain/category.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item_usage_bump.dart';

/// Pure functions between the catalog entities and Firestore maps.
///
/// The maps are the single source of truth for `test/contract/*` and the
/// closed key sets in `firebase/firestore.rules`; keep them in sync.  Money is
/// always stored as integer `*Paisa` fields, never as a floating point value.
abstract final class CatalogMappers {
  // ── Category ──────────────────────────────────────────────────────────────

  static Map<String, dynamic> categoryToMap(
    Category c,
    BaseDocumentMetadata m,
  ) => <String, dynamic>{
    'nameBn': c.nameBn,
    'nameEn': c.nameEn,
    'colorIndex': c.colorIndex,
    'emoji': c.emoji,
    'imageData': c.imageData,
    'sortOrder': c.sortOrder,
    'active': c.active,
    'builtIn': c.builtIn,
    'seedKey': c.seedKey,
    ...BaseMapper.metadataToMap(m),
  };

  /// Tolerant read: a missing or ill-typed field falls back to its default and
  /// an out-of-range [Category.colorIndex] is clamped to the palette.
  static Category categoryFromMap(String id, Map<String, dynamic> map) {
    final color = _intFrom(map['colorIndex']);
    final active = map['active'];
    final builtIn = map['builtIn'];
    return Category(
      id: id,
      nameBn: _stringFrom(map['nameBn']),
      nameEn: _nullableString(map['nameEn']),
      colorIndex: color < 0
          ? 0
          : (color > maxCatalogColorIndex ? maxCatalogColorIndex : color),
      emoji: _nullableString(map['emoji']),
      imageData: _nullableString(map['imageData']),
      sortOrder: _intFrom(map['sortOrder']),
      active: active is bool ? active : true,
      builtIn: builtIn is bool ? builtIn : false,
      seedKey: _nullableString(map['seedKey']),
    );
  }

  /// Fields changed when a category is edited or deactivated.
  ///
  /// `createdAt`, `createdBy`, `builtIn` and `seedKey` are immutable, so they
  /// are deliberately absent: the rules reject a change to any of them.
  static Map<String, dynamic> categoryChangeMap(
    Category c, {
    required String actorUid,
    required DateTime now,
  }) => <String, dynamic>{
    'nameBn': c.nameBn,
    'nameEn': c.nameEn,
    'colorIndex': c.colorIndex,
    'emoji': c.emoji,
    'imageData': c.imageData,
    'sortOrder': c.sortOrder,
    'active': c.active,
    BaseMapper.keyUpdatedAt: BaseMapper.dateTimeToTimestamp(now),
    BaseMapper.keyUpdatedBy: actorUid,
  };

  // ── Item ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> itemToMap(
    Item i,
    BaseDocumentMetadata m,
  ) => <String, dynamic>{
    'nameBn': i.nameBn,
    'nameEn': i.nameEn,
    'categoryId': i.categoryId,
    'defaultUnit': i.defaultUnit.name,
    'aliases': <String>[...i.aliases],
    'emoji': i.emoji,
    'imageData': i.imageData,
    'useCount': i.useCount,
    // The rules' `isNonNegativeIntOrMissing` accepts a missing field, not
    // an explicit null, so absent prices are simply omitted.
    if (i.lastPrice != null) 'lastPricePaisa': i.lastPrice!.paisa,
    if (i.lastUnitPrice != null) 'lastUnitPricePaisa': i.lastUnitPrice!.paisa,
    if (i.lastUsedAt != null)
      'lastUsedAt': BaseMapper.dateTimeToTimestamp(i.lastUsedAt),
    'active': i.active,
    'builtIn': i.builtIn,
    'seedKey': i.seedKey,
    ...BaseMapper.metadataToMap(m),
  };

  /// Tolerant read: unknown units become [Unit.piece], missing counters become
  /// zero, and absent prices/timestamps stay `null`.
  static Item itemFromMap(String id, Map<String, dynamic> map) {
    final useCount = _intFrom(map['useCount']);
    final active = map['active'];
    final builtIn = map['builtIn'];
    return Item(
      id: id,
      nameBn: _stringFrom(map['nameBn']),
      nameEn: _nullableString(map['nameEn']),
      categoryId: _stringFrom(map['categoryId']),
      defaultUnit: _unitFrom(map['defaultUnit']),
      aliases: _aliasesFrom(map['aliases']),
      emoji: _nullableString(map['emoji']),
      imageData: _nullableString(map['imageData']),
      useCount: useCount < 0 ? 0 : useCount,
      lastPrice: _moneyFrom(map['lastPricePaisa']),
      lastUnitPrice: _moneyFrom(map['lastUnitPricePaisa']),
      lastUsedAt: BaseMapper.timestampToDateTime(map['lastUsedAt']),
      active: active is bool ? active : true,
      builtIn: builtIn is bool ? builtIn : false,
      seedKey: _nullableString(map['seedKey']),
    );
  }

  /// Fields changed when a manager edits or deactivates an item.
  ///
  /// Usage counters and last prices are owned by [itemUsageMap] and are left
  /// untouched by a catalog edit.
  static Map<String, dynamic> itemChangeMap(
    Item i, {
    required String actorUid,
    required DateTime now,
  }) => <String, dynamic>{
    'nameBn': i.nameBn,
    'nameEn': i.nameEn,
    'categoryId': i.categoryId,
    'defaultUnit': i.defaultUnit.name,
    'aliases': <String>[...i.aliases],
    'emoji': i.emoji,
    'imageData': i.imageData,
    'active': i.active,
    BaseMapper.keyUpdatedAt: BaseMapper.dateTimeToTimestamp(now),
    BaseMapper.keyUpdatedBy: actorUid,
  };

  /// The ONLY fields a shopping event may change on an item.
  ///
  /// `useCount` is staged as an increment so offline devices cannot lose each
  /// other's counts; the rules allow a delta of 1..40 per write.
  static Map<String, dynamic> itemUsageMap(
    ItemUsageBump bump, {
    required String actorUid,
    required DateTime now,
  }) => <String, dynamic>{
    'useCount': FieldValue.increment(bump.increments),
    if (bump.lastPrice != null) 'lastPricePaisa': bump.lastPrice!.paisa,
    if (bump.lastUnitPrice != null)
      'lastUnitPricePaisa': bump.lastUnitPrice!.paisa,
    'lastUsedAt': BaseMapper.dateTimeToTimestamp(bump.at),
    BaseMapper.keyUpdatedAt: BaseMapper.dateTimeToTimestamp(now),
    BaseMapper.keyUpdatedBy: actorUid,
  };

  // ── Tolerant primitives ───────────────────────────────────────────────────

  static int _intFrom(Object? value) => value is num ? value.toInt() : 0;

  static String _stringFrom(Object? value) => value is String ? value : '';

  static String? _nullableString(Object? value) =>
      value is String ? value : null;

  static Money? _moneyFrom(Object? value) =>
      value is int ? Money.paisa(value) : null;

  static Unit _unitFrom(Object? value) {
    if (value is String) {
      for (final unit in Unit.values) {
        if (unit.name == value) return unit;
      }
    }
    return Unit.piece;
  }

  static List<String> _aliasesFrom(Object? value) {
    if (value is! List) return const <String>[];
    return <String>[
      for (final alias in value)
        if (alias is String) alias,
    ];
  }
}
