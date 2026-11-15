export 'package:family_hub/features/chores/templates/domain/template_rotation.dart';

enum AssigneeStrategy {
  rotation('rotation'),
  fixed('fixed'),
  manual('manual');

  const AssigneeStrategy(this.id);

  final String id;

  static AssigneeStrategy fromId(Object? id) {
    for (final strategy in values) {
      if (strategy.id == id) return strategy;
    }
    return AssigneeStrategy.manual;
  }
}

/// How hard the chore is, for the workload board (no ranking, D-P3-20).
enum Difficulty {
  easy('easy'),
  normal('normal'),
  hard('hard');

  const Difficulty(this.id);

  final String id;

  static Difficulty fromId(Object? id) {
    for (final value in values) {
      if (value.id == id) return value;
    }
    return Difficulty.normal;
  }
}

/// Whether finishing the chore needs a manager's verification (D-P3-9).
enum VerificationMode {
  off('off'),
  required('required');

  const VerificationMode(this.id);

  final String id;

  static VerificationMode fromId(Object? id) {
    for (final value in values) {
      if (value.id == id) return value;
    }
    return VerificationMode.off;
  }
}

/// The unit a rotation advances by (used by the rotation engine, P3-09).
enum CycleUnit {
  day('day'),
  week('week'),
  month('month'),
  occurrence('occurrence');

  const CycleUnit(this.id);

  final String id;

  static CycleUnit fromId(Object? id) {
    for (final value in values) {
      if (value.id == id) return value;
    }
    return CycleUnit.week;
  }
}

/// Limits shared by the validator and the rules (road map 3.2).
abstract final class TemplateLimits {
  static const int maxNameLength = 80;
  static const int maxSlots = 6;
  static const int maxSubtasks = 30;
  static const int maxInstructionsLength = 4000;
  static const int maxEstimatedMinutes = 600;
  static const int maxRotationVersions = 20;
  static const int maxRotationMembers = 12;
  static const int maxReminderOffsets = 5;
  static const int paletteLength = 24;

  /// The first slot of every template is always the main one.
  static const String mainSlotKey = 'main';
}
