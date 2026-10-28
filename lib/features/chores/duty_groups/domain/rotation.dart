import 'package:family_hub/features/chores/templates/domain/template_enums.dart';

export 'package:family_hub/features/chores/templates/domain/template_enums.dart'
    show CycleUnit;
export 'package:family_hub/features/chores/templates/domain/template_rotation.dart'
    show Rotation, RotationVersion;

/// The bounds the rotation engine and the duty-group validator both use.
///
/// The stored shape itself lives in the templates domain (`Rotation`,
/// `RotationVersion`, `CycleUnit`): a template may carry its OWN rotation, so
/// the document shape is shared and only its ENGINE (P3-09) is duty-group
/// specific. Re-exporting here lets the engine, the builder, the duty-group
/// screens and the generator import one path without duplicating the classes.
abstract final class RotationLimits {
  /// A rotation with fewer than two people is not a rotation (D-P3-11).
  static const int minMembers = 2;

  /// Stored as `members` on every version (road map 3.2).
  static const int maxMembers = TemplateLimits.maxRotationMembers;

  /// `versions` on the rotation (road map 3.2).
  static const int maxVersions = TemplateLimits.maxRotationVersions;

  /// When the list is full, only a version older than this may be dropped
  /// (P3-09: "the oldest version is dropped only if its `from` is older than
  /// 400 days").
  static const int retentionDays = 400;
}
