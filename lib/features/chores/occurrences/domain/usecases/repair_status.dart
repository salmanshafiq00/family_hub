import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_action.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Recomputes the stored `status` cache from the document's own facts
/// (D-P3-9, C-13).
///
/// The UI always reads `effectiveStatus`; the stored field only exists so a
/// query can filter on it (the verification queue). Two phones that tick
/// different subtasks can leave it behind, so the detail screen calls this once
/// on open and it writes ONLY `status` — idempotent, and a no-op when the value
/// already matches.
///
/// It never completes, never unticks and never clears anything else: a mismatch
/// is repaired, not re-judged. ANY active member may run it (it only makes the
/// cache agree with what everybody already sees).
///
/// EVERYDAY write; offline it simply stays queued.
class RepairStatus {
  const RepairStatus({
    required this._occurrences,
    required this._templates,
    required this._families,
    required this._dutyGroups,
    required this._settings,
    required this._dateKeys,
    required this._clock,
  });

  final OccurrenceRepository _occurrences;
  final TemplateRepository _templates;
  final FamilyRepository _families;
  final DutyGroupRepository _dutyGroups;
  final ChoreSettingsRepository _settings;
  final FamilyDateKeys _dateKeys;
  final Clock _clock;

  /// True when [occurrence]'s stored status disagrees with the derived one.
  static bool needsRepair(ChoreOccurrence occurrence) =>
      !occurrence.isDeleted &&
      occurrence.status != _storedFor(effectiveStatus(occurrence));

  Future<Result<ChoreOccurrence>> call({
    required String familyId,
    required String actorUid,
    required String occurrenceId,
  }) async {
    final loaded = await loadOccurrenceContext(
      occurrences: _occurrences,
      templates: _templates,
      families: _families,
      dutyGroups: _dutyGroups,
      choreSettings: _settings,
      dateKeys: _dateKeys,
      familyId: familyId,
      occurrenceId: occurrenceId,
      actorUid: actorUid,
    );
    final loadFailure = loaded.failureOrNull;
    if (loadFailure != null) return Failure<ChoreOccurrence>(loadFailure);
    final context = loaded.valueOrNull!;

    final permitted = await requireActiveMember(
      _families,
      familyId: familyId,
      actorUid: actorUid,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<ChoreOccurrence>(denied);

    final occurrence = context.occurrence;
    if (!needsRepair(occurrence)) {
      return Success<ChoreOccurrence>(occurrence);
    }

    final at = _clock.nowUtc();
    final patch = OccurrencePatch(
      occurrenceId: occurrenceId,
      fields: <String, Object?>{
        'status': _storedFor(effectiveStatus(occurrence)).id,
        'updatedAt': at,
        'updatedBy': actorUid,
      },
    );
    final staged = await _occurrences.stage(
      familyId,
      OccurrenceWritePlan(
        actorId: actorUid,
        at: at,
        patches: <OccurrencePatch>[patch],
      ),
    );
    final writeFailure = staged.failureOrNull;
    if (writeFailure != null) return Failure<ChoreOccurrence>(writeFailure);
    return Success<ChoreOccurrence>(
      occurrence.copyWith(status: _storedFor(effectiveStatus(occurrence))),
    );
  }

  /// The stored value that matches a derived status (`overdue` is never
  /// stored; it is an open chore whose deadline passed).
  static OccurrenceStatus _storedFor(ChoreStatus status) => switch (status) {
    ChoreStatus.scheduled => OccurrenceStatus.scheduled,
    ChoreStatus.inProgress => OccurrenceStatus.inProgress,
    ChoreStatus.completed => OccurrenceStatus.completed,
    ChoreStatus.verified => OccurrenceStatus.verified,
    ChoreStatus.skipped => OccurrenceStatus.skipped,
    ChoreStatus.overdue => OccurrenceStatus.inProgress,
  };
}
