import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';

/// Shape checks for a stored rotation, shared by the duty-group validator, the
/// rotation builder and (P3-10) the rules mirror.
///
/// It only rejects what the engine could never evaluate. The engine owns the
/// maths; the codes are the stable ones of road map 3.6.
abstract final class RotationValidator {
  /// `null` when [rotation] can be evaluated.
  static Validation? validate(Rotation rotation) {
    final versions = rotation.versions;
    if (versions.isEmpty) {
      return const Validation('rotation', 'invalid_rotation');
    }
    if (versions.length > RotationLimits.maxVersions) {
      return const Validation('rotation', 'too_many_items');
    }

    DateKey? previousFrom;
    for (final version in versions) {
      if (previousFrom != null && !version.from.isAfter(previousFrom)) {
        // "The greatest version whose from <= day" would be ambiguous.
        return const Validation('versions', 'invalid_range');
      }
      previousFrom = version.from;

      final members = version.members;
      if (members.length < RotationLimits.minMembers) {
        return const Validation('members', 'too_few_members');
      }
      if (members.length > RotationLimits.maxMembers) {
        return const Validation('members', 'too_many_items');
      }
      if (members.toSet().length != members.length) {
        return const Validation('members', 'duplicate_id');
      }
      if (members.any((member) => member.trim().isEmpty)) {
        return const Validation('members', 'member_required');
      }
      if (version.anchorIndex < 0 || version.anchorIndex >= members.length) {
        return const Validation('rotation', 'invalid_rotation');
      }
      if (version.weekStartDay < DateTime.monday ||
          version.weekStartDay > DateTime.sunday) {
        return const Validation('weekStartDay', 'invalid_week_start');
      }
    }
    return null;
  }
}
