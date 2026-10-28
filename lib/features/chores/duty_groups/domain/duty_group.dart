import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';

/// A stored duty group (`dutyGroups/{id}`), road map 3.2.
///
/// A duty group is one roster with one rotation: whoever it names on a day owns
/// every template whose `assignee.dutyGroupId` points here. The group stores NO
/// template list (single source of truth = the template's `dutyGroupId`), so
/// adding a chore to a group is a template edit and can never leave a stale
/// copy behind.
///
/// Groups are never deleted: [active] = false keeps the history and lets the
/// family switch the group back on (P3-10).
final class DutyGroup {
  const DutyGroup({
    required this.id,
    required this.nameBn,
    required this.rotation,
    this.nameEn,
    this.colorIndex,
    this.active = true,
    this.sortOrder = 0,
  });

  final String id;
  final String nameBn;
  final String? nameEn;

  /// Index into `placeholderPalette` (0 … 11); null means "pick one".
  final int? colorIndex;

  /// A calendar-based rotation with at least one version.
  final Rotation rotation;

  final bool active;
  final int sortOrder;

  /// The members of the latest stored version (the order the roster shows).
  List<String> get members => rotation.versions.isEmpty
      ? const <String>[]
      : rotation.versions.last.members;

  DutyGroup copyWith({
    String? nameBn,
    String? nameEn,
    int? colorIndex,
    Rotation? rotation,
    bool? active,
    int? sortOrder,
    bool clearNameEn = false,
    bool clearColorIndex = false,
  }) => DutyGroup(
    id: id,
    nameBn: nameBn ?? this.nameBn,
    nameEn: clearNameEn ? null : (nameEn ?? this.nameEn),
    colorIndex: clearColorIndex ? null : (colorIndex ?? this.colorIndex),
    rotation: rotation ?? this.rotation,
    active: active ?? this.active,
    sortOrder: sortOrder ?? this.sortOrder,
  );

  /// The document body; the mapper (P3-10) adds the base metadata fields.
  Map<String, Object?> toMap() => <String, Object?>{
    'nameBn': nameBn,
    'nameEn': nameEn,
    'colorIndex': colorIndex,
    'rotation': rotation.toMap(),
    'active': active,
    'sortOrder': sortOrder,
  };

  @override
  bool operator ==(Object other) =>
      other is DutyGroup &&
      other.id == id &&
      other.nameBn == nameBn &&
      other.nameEn == nameEn &&
      other.colorIndex == colorIndex &&
      other.rotation == rotation &&
      other.active == active &&
      other.sortOrder == sortOrder;

  @override
  int get hashCode =>
      Object.hash(id, nameBn, nameEn, colorIndex, rotation, active, sortOrder);

  @override
  String toString() =>
      'DutyGroup($id, $nameBn, ${rotation.versions.length} versions, '
      'active: $active)';
}

/// The bounds of road map 3.2 the validator, the rules and the providers share.
abstract final class DutyGroupLimits {
  static const int maxNameLength = 80;

  /// `dutyGroupsProvider` is capped at this many documents (road map 3.5);
  /// keep this equal to `kMaxDutyGroups` in `core/firebase/query_limits.dart`.
  static const int maxGroups = 50;

  static const int paletteLength = 12;
}
