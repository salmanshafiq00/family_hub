/// A bazar category (`families/{f}/bazarCategories/{id}`).
///
/// Categories are deactivated, never deleted.  [colorIndex] indexes the theme's
/// placeholder palette (0–23); the document never stores a hex colour.
final class Category {
  const Category({
    required this.id,
    required this.nameBn,
    this.nameEn,
    required this.colorIndex,
    this.emoji,
    this.imageData,
    required this.sortOrder,
    this.active = true,
    this.builtIn = false,
    this.seedKey,
  });

  final String id;
  final String nameBn;
  final String? nameEn;
  final int colorIndex;
  final String? emoji;

  /// Base64 image data, at most 24 000 characters (enforced by the rules).
  final String? imageData;
  final int sortOrder;
  final bool active;
  final bool builtIn;
  final String? seedKey;

  /// The label for the current language, falling back to the other one.
  String displayName({required bool bangla}) {
    final bn = nameBn.trim();
    final en = (nameEn ?? '').trim();
    if (bangla) return bn.isNotEmpty ? bn : en;
    return en.isNotEmpty ? en : bn;
  }

  Category copyWith({
    String? nameBn,
    String? nameEn,
    int? colorIndex,
    String? emoji,
    String? imageData,
    int? sortOrder,
    bool? active,
    bool? builtIn,
    String? seedKey,
  }) => Category(
    id: id,
    nameBn: nameBn ?? this.nameBn,
    nameEn: nameEn ?? this.nameEn,
    colorIndex: colorIndex ?? this.colorIndex,
    emoji: emoji ?? this.emoji,
    imageData: imageData ?? this.imageData,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
    builtIn: builtIn ?? this.builtIn,
    seedKey: seedKey ?? this.seedKey,
  );

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.nameBn == nameBn &&
      other.nameEn == nameEn &&
      other.colorIndex == colorIndex &&
      other.emoji == emoji &&
      other.imageData == imageData &&
      other.sortOrder == sortOrder &&
      other.active == active &&
      other.builtIn == builtIn &&
      other.seedKey == seedKey;

  @override
  int get hashCode => Object.hash(
    id,
    nameBn,
    nameEn,
    colorIndex,
    emoji,
    imageData,
    sortOrder,
    active,
    builtIn,
    seedKey,
  );

  @override
  String toString() => 'Category($id, $nameBn)';
}
