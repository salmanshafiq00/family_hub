import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack_outcome.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// The three choices of the wizard; applying is a state inside [who].
enum StarterPackWizardStep { pick, review, who }

/// The immutable wizard state (P3-19).
final class StarterPackWizardState {
  const StarterPackWizardState({
    required this.step,
    required this.selectedSeedKeys,
    required this.houseRules,
    required this.addHouseRules,
    required this.useRotation,
    required this.rotationMemberIds,
    required this.firstMemberId,
    required this.cycleUnit,
    this.applying = false,
    this.failure,
    this.outcome,
  });

  final StarterPackWizardStep step;
  final Set<String> selectedSeedKeys;
  final String houseRules;
  final bool addHouseRules;
  final bool useRotation;
  final List<String> rotationMemberIds;
  final String? firstMemberId;
  final CycleUnit cycleUnit;
  final bool applying;
  final AppFailure? failure;

  /// Non-null after a successful apply: the screen shows the result.
  final StarterPackOutcome? outcome;

  bool get done => outcome != null;

  int get stepNumber => step.index + 1;

  StarterPackWizardState copyWith({
    StarterPackWizardStep? step,
    Set<String>? selectedSeedKeys,
    String? houseRules,
    bool? addHouseRules,
    bool? useRotation,
    List<String>? rotationMemberIds,
    String? firstMemberId,
    CycleUnit? cycleUnit,
    bool? applying,
    AppFailure? failure,
    StarterPackOutcome? outcome,
    bool clearFailure = false,
    bool clearOutcome = false,
  }) => StarterPackWizardState(
    step: step ?? this.step,
    selectedSeedKeys: selectedSeedKeys ?? this.selectedSeedKeys,
    houseRules: houseRules ?? this.houseRules,
    addHouseRules: addHouseRules ?? this.addHouseRules,
    useRotation: useRotation ?? this.useRotation,
    rotationMemberIds: rotationMemberIds ?? this.rotationMemberIds,
    firstMemberId: firstMemberId ?? this.firstMemberId,
    cycleUnit: cycleUnit ?? this.cycleUnit,
    applying: applying ?? this.applying,
    failure: clearFailure ? null : (failure ?? this.failure),
    outcome: clearOutcome ? null : (outcome ?? this.outcome),
  );
}
