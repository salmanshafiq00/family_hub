import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';

/// The absence policy of `settings/rotationPolicy` (D-P3-13).
enum AbsencePolicy {
  /// A: the assignee asks somebody to cover.
  askCover('ask_cover'),

  /// B: the app suggests a cover; nothing is reassigned silently.
  autoCover('auto_cover'),

  /// C: the manager marks the occurrence skipped.
  skip('skip'),

  /// D (the default): the absent member's chores are handed to other available
  /// members (the same duty group first) without asking; a chore nobody can
  /// take lands on the Needs cover list. A manager can move any chore back.
  autoAssign('auto_assign');

  const AbsencePolicy(this.id);

  final String id;

  static AbsencePolicy fromId(Object? id) {
    for (final policy in values) {
      if (policy.id == id) return policy;
    }
    return AbsencePolicy.autoAssign;
  }
}

/// Port for the two chore settings documents.
///
/// `settings/chores` and `settings/rotationPolicy` are written separately
/// because they have different rules: chores settings are manager-only, the
/// absence policy is manager-only too but lives in a document the family was
/// created with (C-3).
abstract interface class ChoreSettingsRepository {
  /// Live `settings/chores`; an absent document yields
  /// [ChoreSettings.defaults].
  Stream<ChoreSettings> watch(String familyId);

  /// One-shot read; an absent document yields [ChoreSettings.defaults].
  Future<Result<ChoreSettings>> get(String familyId);

  /// Writes the settings and the audit entry in one server-required batch.
  Future<Result<void>> save(
    String familyId,
    ChoreSettings settings,
    AuditEvent event,
  );

  /// Live `settings/rotationPolicy`.
  Stream<AbsencePolicy> watchAbsencePolicy(String familyId);

  /// One-shot read of `settings/rotationPolicy` (default `auto_assign`).
  Future<Result<AbsencePolicy>> getAbsencePolicy(String familyId);

  /// Writes the absence policy and the audit entry in one batch.
  Future<Result<void>> saveAbsencePolicy(
    String familyId,
    AbsencePolicy policy,
    AuditEvent event,
  );
}
