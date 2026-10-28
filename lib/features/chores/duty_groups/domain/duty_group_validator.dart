import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_validator.dart';

/// Checks a [DutyGroup] before it is saved (road map P3-09).
///
/// Returns the FIRST problem as a [Validation] with a stable code of road map
/// 3.6, or `null`: name → colour → order → rotation. PURE, so "does this
/// template use the group?" stays a repository question (P3-10).
abstract final class DutyGroupValidator {
  static Validation? validate(DutyGroup group) {
    final name = group.nameBn.trim();
    if (name.isEmpty) return const Validation('nameBn', 'required');
    if (name.length > DutyGroupLimits.maxNameLength) {
      return const Validation('nameBn', 'too_long');
    }
    if ((group.nameEn?.length ?? 0) > DutyGroupLimits.maxNameLength) {
      return const Validation('nameEn', 'too_long');
    }
    final color = group.colorIndex;
    if (color != null &&
        (color < 0 || color >= DutyGroupLimits.paletteLength)) {
      return const Validation('colorIndex', 'invalid_range');
    }
    if (group.sortOrder < 0) {
      return const Validation('sortOrder', 'invalid_range');
    }
    return RotationValidator.validate(group.rotation);
  }
}
