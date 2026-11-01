import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// How sure the decoded PDF is about one line (Appendix A.1).
///
/// The wizard ticks [high] lines by default; [medium] and [low] are offered
/// unticked with a "please confirm" flag (road map C-14, Appendix G Q1).
enum Confidence {
  high('high'),
  medium('medium'),
  low('low');

  const Confidence(this.id);

  /// Stable machine id (also the ARB key suffix).
  final String id;
}

/// One line of a starter pack, before it becomes a template.
///
/// It holds NO identity or bookkeeping: [toDraft] builds the content and the
/// use case adds the deterministic `tpl_<seedKey>` id, `builtIn = true` and
/// `seedKey`. A pack line is therefore safe to preview in the wizard and can
/// never change what an existing template stores.
final class StarterTemplate {
  const StarterTemplate({
    required this.seedKey,
    required this.nameBn,
    required this.confidence,
    required this.recurrence,
    this.nameEn,
    this.groupId,
    this.slots = const <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey),
    ],
    this.instructions = '',
    this.subtasks = const <TemplateSubtask>[],
    this.verification = VerificationMode.off,
  });

  /// `[a-z0-9_]{1,24}`; the template id is `tpl_<seedKey>`.
  final String seedKey;
  final String nameBn;
  final String? nameEn;

  /// A catalog group id (`cleaning`, `cooking`, …).
  final String? groupId;

  final Recurrence recurrence;
  final List<TemplateSlot> slots;
  final String instructions;
  final List<TemplateSubtask> subtasks;
  final VerificationMode verification;
  final Confidence confidence;

  /// The deterministic id the apply use case writes (`tpl_sweep`, …).
  String get templateId => 'tpl_$seedKey';

  /// The draft stored on the template. [dutyGroupId] is the rotation the family
  /// chose in the wizard; null means "assign later" (`AssigneeSpec.manual`).
  TemplateDraft toDraft({
    required DateKey startDate,
    String? dutyGroupId,
  }) => TemplateDraft(
    nameBn: nameBn,
    nameEn: nameEn,
    groupId: groupId,
    recurrence: recurrence,
    slots: slots,
    assignee: dutyGroupId == null
        ? AssigneeSpec.manual
        : AssigneeSpec(
            strategy: AssigneeStrategy.rotation,
            dutyGroupId: dutyGroupId,
          ),
    instructions: instructions,
    subtasks: subtasks,
    verification: verification,
    startDate: startDate,
  );

  @override
  bool operator ==(Object other) =>
      other is StarterTemplate &&
      other.seedKey == seedKey &&
      other.nameBn == nameBn &&
      other.nameEn == nameEn &&
      other.groupId == groupId &&
      other.recurrence == recurrence &&
      other.slots.length == slots.length &&
      other.instructions == instructions &&
      other.subtasks.length == subtasks.length &&
      other.verification == verification &&
      other.confidence == confidence;

  @override
  int get hashCode => Object.hash(
    seedKey,
    nameBn,
    nameEn,
    groupId,
    recurrence,
    Object.hashAll(slots),
    instructions,
    Object.hashAll(subtasks),
    verification,
    confidence,
  );

  @override
  String toString() => 'StarterTemplate($seedKey, ${confidence.id})';
}

/// The duty group a pack would create (Q8: one group for the daily chores).
final class StarterDutyGroup {
  const StarterDutyGroup({
    required this.nameBn,
    this.nameEn,
    this.colorIndex,
  });

  final String nameBn;
  final String? nameEn;
  final int? colorIndex;
}

/// The rotation the family chose in step 3.
final class StarterRotationConfig {
  const StarterRotationConfig({
    required this.memberIds,
    required this.firstMemberId,
    this.cycleUnit = CycleUnit.week,
  });

  /// 2 … 12 unique active member uids.
  final List<String> memberIds;

  /// Who takes the first turn; must be one of [memberIds].
  final String firstMemberId;

  /// Default week (Q8); the wizard also offers day/month.
  final CycleUnit cycleUnit;
}

/// A starter pack: data only, never code (Appendix A.2).
final class StarterPack {
  const StarterPack({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.groups,
    required this.dueTimePresets,
    required this.templates,
    this.dutyGroup,
    this.houseRulesBn = '',
    this.houseRulesEn = '',
  });

  /// Stable id; the duty group id is `duty_<id>`.
  final String id;

  /// ARB keys, resolved by the wizard (the domain owns no copy).
  final String titleKey;
  final String descriptionKey;

  /// Catalog rows merged by id when the family's settings do not have them.
  final List<ChoreGroup> groups;
  final List<DueTimePreset> dueTimePresets;

  final List<StarterTemplate> templates;
  final StarterDutyGroup? dutyGroup;

  /// House rules from the PDF (Appendix A.1), offered as editable text.
  final String houseRulesBn;
  final String houseRulesEn;

  /// The lines the wizard ticks by default.
  List<StarterTemplate> get highConfidence => <StarterTemplate>[
    for (final template in templates)
      if (template.confidence == Confidence.high) template,
  ];

  StarterTemplate? templateBySeedKey(String seedKey) {
    for (final template in templates) {
      if (template.seedKey == seedKey) return template;
    }
    return null;
  }
}
