import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/duty_groups/domain/absence_resolver.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_id.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_engine.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/family/domain/member.dart';

/// Turns templates into the occurrences they imply (P3-12, D-P3-6).
///
/// The SAME function serves the persisted generator (`EnsureOccurrences`) and
/// the calendar projection (P3-21), so a projected day and a materialized day
/// can never disagree (C-9). It is pure: no clock, no Firestore, no random id;
/// the family zone comes in through [FamilyDateKeys].
///
/// The road-map card's `settings` argument is deliberately absent: the
/// generation horizon is applied by `EnsureOccurrences`, and no other setting
/// changes a draft, so the argument would be unused.
abstract final class OccurrenceGenerator {
  /// One draft per active template × firing day × slot, in template order.
  static List<OccurrenceDraft> drafts({
    required List<ChoreTemplate> templates,
    required List<DutyGroup> dutyGroups,
    required List<Member> members,
    required DateKeyRange range,
    required FamilyDateKeys dateKeys,
    AvailabilityIndex availabilityIndex = AvailabilityIndex.empty,
    AbsencePolicy policy = AbsencePolicy.askCover,
  }) {
    final groups = <String, DutyGroup>{
      for (final group in dutyGroups) group.id: group,
    };
    final drafts = <OccurrenceDraft>[];
    for (final template in templates) {
      if (!template.isGenerating) continue;
      final content = template.draft;
      final days = RecurrenceEngine.datesIn(
        content.recurrence,
        range,
        startDate: content.startDate,
        endDate: content.endDate,
      );
      for (final day in days) {
        for (final slot in content.slots) {
          drafts.add(
            _draft(
              template: template,
              slot: slot,
              day: day,
              groups: groups,
              members: members,
              availabilityIndex: availabilityIndex,
              policy: policy,
              dateKeys: dateKeys,
            ),
          );
        }
      }
    }
    return List<OccurrenceDraft>.unmodifiable(drafts);
  }

  static OccurrenceDraft _draft({
    required ChoreTemplate template,
    required TemplateSlot slot,
    required DateKey day,
    required Map<String, DutyGroup> groups,
    required List<Member> members,
    required AvailabilityIndex availabilityIndex,
    required AbsencePolicy policy,
    required FamilyDateKeys dateKeys,
  }) {
    final content = template.draft;
    final dueMinutes = slot.dueMinutes;
    final dueAt = dueMinutes == null
        ? dateKeys.endOfDay(day)
        : dateKeys.instantOf(day, dueMinutes);

    final spec = content.assignee;
    final (String?, AssignmentSource) assignment = switch (spec.strategy) {
      AssigneeStrategy.manual => (null, AssignmentSource.manual),
      AssigneeStrategy.fixed => (spec.fixedMemberId, AssignmentSource.fixed),
      AssigneeStrategy.rotation => (
        _plannedByRotation(spec, content, groups, day),
        AssignmentSource.rotation,
      ),
    };
    final planned = assignment.$1;
    final source = assignment.$2;

    // A manual, unassigned template is NOT "needs cover": nobody was planned.
    // Everything else (fixed or rotation) goes through the absence resolver, so
    // a disabled member or an approved absence is flagged the same way.
    final decision = source == AssignmentSource.manual
        ? const AssignmentDecision(assigneeId: null, needsCover: false)
        : AbsenceResolver.resolve(
            planned: planned,
            day: day,
            availabilityIndex: availabilityIndex,
            policy: policy,
            members: members,
          );

    return OccurrenceDraft(
      ChoreOccurrence(
        id: OccurrenceId.of(template.id, day, slotKey: slot.key).value,
        templateId: template.id,
        templateRev: template.revision,
        slotKey: slot.isMain ? null : slot.key,
        dateKey: day,
        monthKey: day.monthKey,
        dueAt: dueAt,
        dueMinutes: dueMinutes,
        nameBn: content.nameBn,
        nameEn: content.nameEn,
        groupId: content.groupId,
        instructions: content.instructions,
        subtasks: content.subtasks,
        difficulty: content.difficulty,
        estimatedMinutes: content.estimatedMinutes,
        verification: content.verification,
        plannedAssigneeId: planned,
        assigneeId: decision.assigneeId,
        assignmentSource: source,
        needsCover: decision.needsCover,
      ),
    );
  }

  /// The group's rotation when it is active, else the template's own rotation.
  static Rotation? _rotationFor(
    AssigneeSpec spec,
    Map<String, DutyGroup> groups,
  ) {
    final groupId = spec.dutyGroupId;
    if (groupId != null) {
      final group = groups[groupId];
      if (group != null && group.active) return group.rotation;
    }
    return spec.rotation;
  }

  static String? _plannedByRotation(
    AssigneeSpec spec,
    TemplateDraft content,
    Map<String, DutyGroup> groups,
    DateKey day,
  ) {
    final rotation = _rotationFor(spec, groups);
    if (rotation == null) return null;
    return RotationEngine.planned(
      rotation,
      day,
      recurrence: content.recurrence,
      startDate: content.startDate,
      endDate: content.endDate,
    );
  }
}
