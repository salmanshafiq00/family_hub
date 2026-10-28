import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/templates/data/rotation_mappers.dart';

/// Pure functions between [DutyGroup] and `dutyGroups/{id}`.
///
/// The map is the single source of truth for the closed `dutyGroupKeys()` list
/// and the contract fixture. The rotation is written and read through
/// [RotationMappers], the same parser a template's own rotation uses.
///
/// `fromMap` is TOLERANT: a document whose rotation this build cannot read is
/// still LISTED (with no members) so a manager can open it and fix the roster,
/// instead of the group silently disappearing. The rules and
/// `DutyGroupValidator` refuse to WRITE such a document.
abstract final class DutyGroupMappers {
  static Map<String, dynamic> toMap(
    DutyGroup group,
    BaseDocumentMetadata meta,
  ) => <String, dynamic>{...group.toMap(), ...BaseMapper.metadataToMap(meta)};

  /// Reads one document. `null` when the document does not exist.
  static DutyGroup? fromDoc(String id, Map<String, dynamic>? map) =>
      map == null ? null : fromMap(id, map);

  /// Convenience alias used by the repository and the tests.
  static DutyGroup fromMap(String id, Map<String, dynamic> map) {
    final rotation = RotationMappers.fromMap(map['rotation']);
    return DutyGroup(
      id: id,
      nameBn: _string(map['nameBn'], DutyGroupLimits.maxNameLength),
      nameEn: _nullableString(map['nameEn'], DutyGroupLimits.maxNameLength),
      // An out-of-range colour is dropped, so the group uses the theme colour.
      colorIndex: _intIn(
        map['colorIndex'],
        0,
        DutyGroupLimits.paletteLength - 1,
      ),
      rotation: rotation ?? const Rotation(versions: <RotationVersion>[]),
      active: map['active'] is bool ? map['active'] as bool : true,
      sortOrder: _int(map['sortOrder']),
    );
  }

  static int _int(Object? value) => value is num ? value.toInt() : 0;

  static int? _intIn(Object? value, int min, int max) {
    if (value is! num) return null;
    final asInt = value.toInt();
    if (asInt < min || asInt > max) return null;
    return asInt;
  }

  static String _string(Object? value, int max) {
    if (value is! String) return '';
    return value.length > max ? value.substring(0, max) : value;
  }

  static String? _nullableString(Object? value, int max) {
    if (value is! String || value.isEmpty) return null;
    return value.length > max ? value.substring(0, max) : value;
  }
}
