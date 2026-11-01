import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/occurrences/domain/generation_plan.dart';

/// What one starter-pack application created (P3-19).
///
/// [generationFailure] is reported separately: the content writes are never
/// rolled back when planning fails (the wizard shows a retry), and the next
/// application resumes from the deterministic ids instead of duplicating.
final class StarterPackOutcome {
  const StarterPackOutcome({
    required this.templatesCreated,
    required this.templatesSkipped,
    required this.catalogGroupsAdded,
    required this.catalogPresetsAdded,
    required this.dutyGroupsCreated,
    required this.houseRulesAdded,
    this.generation,
    this.generationFailure,
  });

  final int templatesCreated;
  final int templatesSkipped;
  final int catalogGroupsAdded;
  final int catalogPresetsAdded;
  final int dutyGroupsCreated;
  final bool houseRulesAdded;
  final GenerationOutcome? generation;
  final AppFailure? generationFailure;

  bool get changedAnything =>
      templatesCreated > 0 ||
      catalogGroupsAdded > 0 ||
      catalogPresetsAdded > 0 ||
      dutyGroupsCreated > 0 ||
      houseRulesAdded;
}
