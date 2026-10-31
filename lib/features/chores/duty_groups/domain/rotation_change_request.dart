import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_builder.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/change_rotation.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';

/// One edit of a stored rotation, exactly as `ChangeRotation` receives it
/// (P3-18).
///
/// The change sheet collects it and shows [preview]; the controller then hands
/// the same values to the use case, so the "after the change" preview and the
/// stored result can never disagree (both go through [RotationBuilder]).
final class RotationChangeRequest {
  const RotationChangeRequest({
    required this.change,
    required this.effectiveFrom,
    this.memberId,
    this.members,
    this.startsWith,
  });

  final RotationChange change;
  final DateKey effectiveFrom;

  /// The member to add or remove.
  final String? memberId;

  /// The full new order (reorder only).
  final List<String>? members;

  /// Who goes first at the boundary (reorder only).
  final String? startsWith;

  /// The rotation this change would produce, or why it is not possible.
  Result<Rotation> preview(Rotation current, {Recurrence? recurrence}) {
    switch (change) {
      case RotationChange.add:
        return RotationBuilder.add(
          current,
          memberId: memberId ?? '',
          effectiveFrom: effectiveFrom,
          recurrence: recurrence,
        );
      case RotationChange.remove:
        return RotationBuilder.remove(
          current,
          memberId: memberId ?? '',
          effectiveFrom: effectiveFrom,
          recurrence: recurrence,
        );
      case RotationChange.reorder:
        return RotationBuilder.reorder(
          current,
          members: members ?? const <String>[],
          startsWith: startsWith ?? '',
          effectiveFrom: effectiveFrom,
        );
    }
  }
}
