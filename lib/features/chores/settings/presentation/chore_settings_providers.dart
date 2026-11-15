import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalogs.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/settings/domain/usecases/update_chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/usecases/update_rotation_policy.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in `bootstrap.dart` and in tests (same pattern as Bazar).
final choreSettingsRepositoryProvider = Provider<ChoreSettingsRepository>(
  (ref) => throw UnimplementedError(
    'choreSettingsRepositoryProvider must be overridden '
    '(bootstrap.dart / tests).',
  ),
);

/// The live `settings/chores` document. A missing document, or the first frame
/// before the listener fires, still yields the defaults, so no screen needs a
/// special "no settings yet" state.
final _choreSettingsStreamProvider = StreamProvider<ChoreSettings>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value(ChoreSettings.defaults);
  return ref.watch(choreSettingsRepositoryProvider).watch(familyId);
});

/// Synchronous settings for anything that needs a value now.
final choreSettingsProvider = Provider<ChoreSettings>(
  (ref) =>
      ref.watch(_choreSettingsStreamProvider).value ?? ChoreSettings.defaults,
);

/// Every lookup over the catalogs (groups, presets, reasons), tolerant of
/// unknown ids.
final choreCatalogsProvider = Provider<ChoreCatalogs>(
  (ref) => ChoreCatalogs(ref.watch(choreSettingsProvider)),
);

/// Groups in display order, active only — what a chore editor offers.
final choreGroupsProvider = Provider<List<ChoreGroup>>(
  (ref) => ref.watch(choreCatalogsProvider).activeGroups,
);

/// The icon a family chose for one group, or `null` when the catalog has no
/// row for it (the caller then falls back to the built-in group icons).
///
/// The calendar, the tile and the detail header read THIS, so renaming a group
/// or picking another icon in the settings screen changes every chore of it.
final choreGroupIconKeyProvider = Provider.family<String?, String>(
  (ref, groupId) =>
      ref.watch(choreCatalogsProvider).groupOrNull(groupId)?.iconKey,
);

/// Due-time presets in clock order, active only.
final dueTimePresetsProvider = Provider<List<DueTimePreset>>(
  (ref) => ref.watch(choreCatalogsProvider).activePresets,
);

/// Absence reasons in the family's order, active only.
final absenceReasonsProvider = Provider<List<AbsenceReason>>(
  (ref) => ref.watch(choreCatalogsProvider).activeAbsenceReasons,
);

/// The live `settings/rotationPolicy` absence policy (default `ask_cover`).
final _absencePolicyStreamProvider = StreamProvider<AbsencePolicy>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value(AbsencePolicy.askCover);
  return ref
      .watch(choreSettingsRepositoryProvider)
      .watchAbsencePolicy(familyId);
});

/// Synchronous absence policy.
final rotationPolicyProvider = Provider<AbsencePolicy>(
  (ref) =>
      ref.watch(_absencePolicyStreamProvider).value ?? AbsencePolicy.askCover,
);

final updateChoreSettingsProvider = Provider<UpdateChoreSettings>(
  (ref) => UpdateChoreSettings(
    settings: ref.watch(choreSettingsRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

final updateRotationPolicyProvider = Provider<UpdateRotationPolicy>(
  (ref) => UpdateRotationPolicy(
    settings: ref.watch(choreSettingsRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);
