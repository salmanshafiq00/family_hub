import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/starter_packs/domain/usecases/apply_starter_pack.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one use case the wizard runs (P3-19).
///
/// It owns no provider of its own beyond the repositories every chores screen
/// already reads, so it can be overridden per test exactly like the rest.
final applyStarterPackProvider = Provider<ApplyStarterPack>(
  (ref) => ApplyStarterPack(
    settings: ref.watch(choreSettingsRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    markers: ref.watch(generationMarkerRepositoryProvider),
    regenerate: ref.watch(regenerateRangeProvider),
    families: ref.watch(familyRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);
