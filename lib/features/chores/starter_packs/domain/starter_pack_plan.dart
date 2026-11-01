import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// Everything one starter-pack application would do, decided before any write.
///
/// The plan is pure: the same family, selection and rotation always produce the
/// same groups, presets, rules and `tpl_<seedKey>` ids. That is what makes a
/// second run idempotent and a half-finished run resumable (P3-19).
final class StarterPackPlan {
  const StarterPackPlan({
    required this.groups,
    required this.dueTimePresets,
    required this.catalogGroupsAdded,
    required this.catalogPresetsAdded,
    required this.houseRules,
    required this.houseRulesAdded,
    required this.toCreate,
    required this.templatesSkipped,
    required this.dutyGroupId,
    required this.createDutyGroup,
  });

  /// The catalogs AFTER adding only the missing ids; family edits are kept.
  final List<ChoreGroup> groups;
  final List<DueTimePreset> dueTimePresets;

  final int catalogGroupsAdded;
  final int catalogPresetsAdded;

  final String houseRules;
  final bool houseRulesAdded;

  /// The pack lines whose deterministic ids are not stored yet.
  final List<StarterTemplate> toCreate;
  final int templatesSkipped;

  /// `duty_<pack id>`; the id every seeded template points at.
  final String dutyGroupId;
  final bool createDutyGroup;

  /// True when a second apply would write nothing; the use case reports
  /// `Conflict('starter_pack_applied')` instead of a silent success.
  bool get nothingNew =>
      toCreate.isEmpty &&
      catalogGroupsAdded == 0 &&
      catalogPresetsAdded == 0 &&
      !houseRulesAdded &&
      !createDutyGroup;
}

/// Builds [StarterPackPlan]s and checks the wizard's rotation (P3-19).
abstract final class StarterPackPlanner {
  /// The same rules as the duty-group editor: 2–12 unique, non-empty members
  /// and a first member who is in the list.
  static Validation? validateRotation(StarterRotationConfig? rotation) {
    if (rotation == null) return null;
    final members = rotation.memberIds;
    if (members.length < 2) {
      return const Validation('members', 'too_few_members');
    }
    if (members.length > TemplateLimits.maxRotationMembers) {
      return const Validation('members', 'too_many_items');
    }
    if (members.toSet().length != members.length) {
      return const Validation('members', 'duplicate_id');
    }
    if (members.any((member) => member.trim().isEmpty)) {
      return const Validation('members', 'member_required');
    }
    if (!members.contains(rotation.firstMemberId)) {
      return const Validation('members', 'member_required');
    }
    return null;
  }

  static StarterPackPlan plan({
    required StarterPack pack,
    required ChoreSettings current,
    required List<ChoreTemplate> storedTemplates,
    required List<DutyGroup> storedGroups,
    required List<StarterTemplate> selected,
    StarterRotationConfig? rotation,
    String? houseRules,
    bool addHouseRules = true,
  }) {
    final groups = <ChoreGroup>[...current.groups];
    final groupIds = <String>{for (final group in groups) group.id};
    var nextGroupOrder = _nextOrder(groups.map((group) => group.sortOrder));
    var catalogGroupsAdded = 0;
    for (final seed in pack.groups) {
      if (!groupIds.add(seed.id)) continue;
      groups.add(seed.copyWith(sortOrder: nextGroupOrder++));
      catalogGroupsAdded++;
    }

    final presets = <DueTimePreset>[...current.dueTimePresets];
    final presetIds = <String>{for (final preset in presets) preset.id};
    var catalogPresetsAdded = 0;
    for (final seed in pack.dueTimePresets) {
      if (!presetIds.add(seed.id)) continue;
      presets.add(seed);
      catalogPresetsAdded++;
    }

    final rules = (houseRules ?? pack.houseRulesBn).trim();
    final houseRulesAdded =
        addHouseRules && rules.isNotEmpty && current.houseRules.trim().isEmpty;

    final existingIds = <String>{
      for (final template in storedTemplates) template.id,
    };
    final existingSeeds = <String>{
      for (final template in storedTemplates)
        if (template.seedKey != null) template.seedKey!,
    };
    final toCreate = <StarterTemplate>[
      for (final template in selected)
        if (!existingIds.contains(template.templateId) &&
            !existingSeeds.contains(template.seedKey))
          template,
    ];

    final dutyGroupId = 'duty_${pack.id}';
    final dutyGroupExists = storedGroups.any(
      (group) => group.id == dutyGroupId,
    );

    return StarterPackPlan(
      groups: groups,
      dueTimePresets: presets,
      catalogGroupsAdded: catalogGroupsAdded,
      catalogPresetsAdded: catalogPresetsAdded,
      houseRules: rules,
      houseRulesAdded: houseRulesAdded,
      toCreate: toCreate,
      templatesSkipped: selected.length - toCreate.length,
      dutyGroupId: dutyGroupId,
      createDutyGroup:
          rotation != null && toCreate.isNotEmpty && !dutyGroupExists,
    );
  }

  /// `max + 1`, or 0 for an empty list.
  static int _nextOrder(Iterable<int> orders) {
    var next = 0;
    for (final order in orders) {
      if (order >= next) next = order + 1;
    }
    return next;
  }
}
