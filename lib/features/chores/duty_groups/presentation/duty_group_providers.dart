import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/change_rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/create_duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/update_duty_group.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in `bootstrap.dart` and in tests (same pattern as Bazar).
final dutyGroupRepositoryProvider = Provider<DutyGroupRepository>(
  (ref) => throw UnimplementedError(
    'dutyGroupRepositoryProvider must be overridden (bootstrap.dart / tests).',
  ),
);

/// The live `dutyGroups` list, in `sortOrder` order.
///
/// ONE listener for the whole feature (D-P3-8 discipline): the rota board, the
/// group editor and the manage hub all read this list and filter in memory.
final _dutyGroupsStreamProvider = StreamProvider<List<DutyGroup>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value(const <DutyGroup>[]);
  return ref.watch(dutyGroupRepositoryProvider).watch(familyId);
});

/// Every group (including the inactive ones), synchronously.
final dutyGroupsProvider = Provider<List<DutyGroup>>(
  (ref) => ref.watch(_dutyGroupsStreamProvider).value ?? const <DutyGroup>[],
);

/// True when the listener hit [kMaxDutyGroups]: the list is incomplete and a
/// screen must say so instead of silently hiding groups.
final dutyGroupsTruncatedProvider = Provider<bool>(
  (ref) => ref.watch(dutyGroupsProvider).length >= kMaxDutyGroups,
);

/// `id -> group`, so a screen holding an id never re-scans the list.
final dutyGroupIndexProvider = Provider<Map<String, DutyGroup>>((ref) {
  final groups = ref.watch(dutyGroupsProvider);
  return <String, DutyGroup>{for (final group in groups) group.id: group};
});

/// One group by id; null when it does not exist (or is not loaded yet).
final dutyGroupProvider = Provider.family<DutyGroup?, String>(
  (ref, id) => ref.watch(dutyGroupIndexProvider)[id],
);

/// The groups a new template may point at (not switched off).
final activeDutyGroupsProvider = Provider<List<DutyGroup>>(
  (ref) => <DutyGroup>[
    for (final group in ref.watch(dutyGroupsProvider))
      if (group.active) group,
  ],
);

/// The chores of one duty group: the single source of truth is the TEMPLATE's
/// `assignee.dutyGroupId`, because a group stores no template list.
///
/// Archived templates are left out (they can never fire again), paused ones are
/// included: they still point at the group and may be resumed.
///
/// Named `dutyGroupTemplatesProvider` on purpose: `groupTemplatesProvider`
/// already exists in `template_providers.dart` and means a chore CATEGORY
/// (`template.groupId`), a different id space.
final dutyGroupTemplatesProvider = Provider.family<List<ChoreTemplate>, String>(
  (ref, groupId) => <ChoreTemplate>[
    for (final record in ref.watch(templatesProvider))
      if (!record.template.isArchived &&
          record.template.draft.assignee.dutyGroupId == groupId)
        record.template,
  ],
);

/// Who the group's rotation names today, or `null` when nobody is planned
/// (before the first version, an empty roster, or the group is not loaded yet).
///
/// "Today" is the FAMILY's calendar day (H12), never the phone's zone.
final groupOnDutyProvider = Provider.family<String?, String>((ref, groupId) {
  final group = ref.watch(dutyGroupProvider(groupId));
  if (group == null) return null;
  final today = ref.watch(familyDateKeysProvider).today();
  return RotationEngine.planned(group.rotation, today);
});

// ── Use cases ─────────────────────────────────────────────────────────────────

final createDutyGroupProvider = Provider<CreateDutyGroup>(
  (ref) => CreateDutyGroup(
    groups: ref.watch(dutyGroupRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

final updateDutyGroupProvider = Provider<UpdateDutyGroup>(
  (ref) => UpdateDutyGroup(
    groups: ref.watch(dutyGroupRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);

final changeRotationProvider = Provider<ChangeRotation>(
  (ref) => ChangeRotation(
    groups: ref.watch(dutyGroupRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    clock: ref.watch(clockProvider),
    newId: ref.watch(idGeneratorProvider),
  ),
);
