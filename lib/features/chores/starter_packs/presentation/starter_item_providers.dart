import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_mapping.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_repository.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/usecases/manage_starter_items.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in `bootstrap.dart` and in tests (same pattern as templates).
final starterItemRepositoryProvider = Provider<StarterItemRepository>(
  (ref) => throw UnimplementedError(
    'starterItemRepositoryProvider must be overridden (bootstrap.dart / tests).',
  ),
);

/// The family's own starter list, live. Empty while the family has not
/// customised the built-in pack.
final starterItemsStreamProvider = StreamProvider<List<TemplateRecord>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value(const <TemplateRecord>[]);
  return ref.watch(starterItemRepositoryProvider).watch(familyId);
});

/// True when the family has its own list (the built-in pack is then unused).
final starterPackCustomisedProvider = Provider<bool>((ref) {
  final items = ref.watch(starterItemsStreamProvider);
  return items.hasValue && items.requireValue.isNotEmpty;
});

/// THE pack the wizard offers: the family's own list when it has one,
/// otherwise the built-in pack. A failed or missing list (offline, rules not
/// deployed yet) falls back to the built-in pack instead of blocking the
/// wizard.
final starterPackProvider = Provider<StarterPack>((ref) {
  final items = ref.watch(starterItemsStreamProvider);
  if (!items.hasValue || items.requireValue.isEmpty) return familyPdfPack;
  return familyPdfPack.copyWithTemplates(<StarterTemplate>[
    for (final record in items.requireValue) starterTemplateOf(record.template),
  ]);
});

final manageStarterItemsProvider = Provider<ManageStarterItems>(
  (ref) => ManageStarterItems(
    items: ref.watch(starterItemRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);
