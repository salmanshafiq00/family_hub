import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/bazar/items_categories/domain/category.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item.dart';
import 'package:family_hub/features/bazar/items_categories/domain/text_normalizer.dart';

/// Catalog limits mirrored by `firebase/firestore.rules`.
const int maxCatalogNameLength = 60;
const int maxCatalogAliases = 10;
const int maxCatalogAliasLength = 40;
const int maxCatalogEmojiLength = 8;
const int maxCatalogImageDataLength = 24000;

/// The last valid index into the theme's `placeholderPalette`.
const int maxCatalogColorIndex = 23;

/// Validation shared by the catalog use cases.
///
/// Every function returns `null` when the value is acceptable, so a use case
/// can chain them with `??` and stop at the first problem.
AppFailure? validateNameBn(String value) {
  final name = value.trim();
  if (name.isEmpty) return const Validation('nameBn', 'required');
  if (name.runes.length > maxCatalogNameLength) {
    return const Validation('nameBn', 'too_long');
  }
  return null;
}

AppFailure? validateNameEn(String? value) {
  final name = value?.trim() ?? '';
  if (name.runes.length > maxCatalogNameLength) {
    return const Validation('nameEn', 'too_long');
  }
  return null;
}

AppFailure? validateColorIndex(int value) {
  if (value < 0 || value > maxCatalogColorIndex) {
    return const Validation('colorIndex', 'invalid');
  }
  return null;
}

/// [aliases] must already be cleaned with [cleanAliases].
AppFailure? validateAliases(List<String> aliases) {
  if (aliases.length > maxCatalogAliases) {
    return const Validation('aliases', 'too_many');
  }
  if (aliases.any((alias) => alias.runes.length > maxCatalogAliasLength)) {
    return const Validation('aliases', 'too_long');
  }
  return null;
}

AppFailure? validateEmoji(String? value) {
  final emoji = value?.trim() ?? '';
  if (emoji.runes.length > maxCatalogEmojiLength) {
    return const Validation('emoji', 'too_long');
  }
  return null;
}

AppFailure? validateImageData(String? value) {
  if ((value ?? '').length > maxCatalogImageDataLength) {
    return const Validation('imageData', 'too_long');
  }
  return null;
}

/// Trimmed aliases without empty entries, preserving order.
List<String> cleanAliases(List<String> aliases) => <String>[
  for (final alias in aliases)
    if (alias.trim().isNotEmpty) alias.trim(),
];

/// Trimmed optional text; blank becomes `null`.
String? cleanOptional(String? value) {
  final trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
}

/// The active category with [id], or `null` when it is missing/archived.
Category? activeCategory(Iterable<Category> categories, String id) {
  for (final category in categories) {
    if (category.id == id && category.active) return category;
  }
  return null;
}

/// The item with [id], active or not; `null` when it does not exist.
Item? findItem(Iterable<Item> items, String id) {
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

/// True when an active item in the same category already uses [nameBn].
bool hasDuplicateItemName(
  Iterable<Item> items,
  String nameBn, {
  String? categoryId,
  String? excludeId,
}) {
  final key = normalizeSearch(nameBn);
  return items.any(
    (item) =>
        item.active &&
        item.id != excludeId &&
        (categoryId == null || item.categoryId == categoryId) &&
        normalizeSearch(item.nameBn) == key,
  );
}
