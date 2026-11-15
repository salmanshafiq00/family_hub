import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_validator.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// Checks a [TemplateDraft] before it is saved (road map P3-07).
///
/// Returns the FIRST problem as a [Validation] with a stable code of road map
/// 3.6, or `null`. The order is fixed so the message is predictable:
/// name → schedule → slots → subtasks → assignee → text/time fields.
///
/// It is PURE: it never reads a repository, so "does this group exist?" is not
/// its question (P3-10 checks existence; here only the id's FORMAT is checked,
/// because an unknown group falls back to "other" in the catalogs).
abstract final class TemplateValidator {
  /// `null` when [d] may be saved.
  static Validation? validate(TemplateDraft d) {
    // ── Name ────────────────────────────────────────────────────────────────
    final name = d.nameBn.trim();
    if (name.isEmpty) return const Validation('nameBn', 'required');
    if (name.length > TemplateLimits.maxNameLength) {
      return const Validation('nameBn', 'too_long');
    }
    if ((d.nameEn?.length ?? 0) > TemplateLimits.maxNameLength) {
      return const Validation('nameEn', 'too_long');
    }

    // ── Schedule ────────────────────────────────────────────────────────────
    if (d.endDate != null && d.endDate!.isBefore(d.startDate)) {
      return const Validation('endDate', 'invalid_range');
    }
    final schedule = RecurrenceValidator.validate(
      d.recurrence,
      startDate: d.startDate,
      endDate: d.endDate,
    );
    if (schedule.errors.isNotEmpty) return schedule.errors.first;

    // ── Slots ───────────────────────────────────────────────────────────────
    final slots = d.slots;
    if (slots.isEmpty) return const Validation('slots', 'no_dates');
    if (slots.length > TemplateLimits.maxSlots) {
      return const Validation('slots', 'too_many_slots');
    }
    if (!slots.first.isMain) {
      return const Validation('slots', 'invalid_recurrence');
    }
    final keys = <String>{};
    for (final slot in slots) {
      if (!_slotKey.hasMatch(slot.key)) {
        return const Validation('slots', 'invalid_recurrence');
      }
      if (!keys.add(slot.key)) {
        return const Validation('slots', 'duplicate_slot');
      }
      if ((slot.labelBn?.length ?? 0) > 30 ||
          (slot.labelEn?.length ?? 0) > 30) {
        return const Validation('slots', 'too_long');
      }
      final minutes = slot.dueMinutes;
      if (minutes != null && (minutes < 0 || minutes > 1439)) {
        return const Validation('slots', 'invalid_time');
      }
    }
    // Only the main slot may exist without a label; a second slot needs one so
    // the family can tell "সকাল" from "দুপুর" in the day panel.
    for (final slot in slots.skip(1)) {
      if ((slot.labelBn ?? '').trim().isEmpty) {
        return const Validation('slots', 'slot_name_required');
      }
    }

    // ── Subtasks ────────────────────────────────────────────────────────────
    if (d.subtasks.length > TemplateLimits.maxSubtasks) {
      return const Validation('subtasks', 'too_many_subtasks');
    }
    final subtaskIds = <String>{};
    for (final subtask in d.subtasks) {
      if (!_subtaskId.hasMatch(subtask.id)) {
        return const Validation('subtasks', 'invalid_recurrence');
      }
      if (!subtaskIds.add(subtask.id)) {
        return const Validation('subtasks', 'duplicate_id');
      }
      final title = subtask.title.trim();
      if (title.isEmpty) return const Validation('subtasks', 'required');
      if (title.length > 120) {
        return const Validation('subtasks', 'too_long');
      }
      if ((subtask.hint?.length ?? 0) > 200) {
        return const Validation('subtasks', 'too_long');
      }
    }

    // ── Assignee ────────────────────────────────────────────────────────────
    final assigneeError = _validateAssignee(d.assignee);
    if (assigneeError != null) return assigneeError;

    // ── Text and time ───────────────────────────────────────────────────────
    if (d.instructions.length > TemplateLimits.maxInstructionsLength) {
      return const Validation('instructions', 'too_long');
    }
    final estimated = d.estimatedMinutes;
    if (estimated != null &&
        (estimated < 1 || estimated > TemplateLimits.maxEstimatedMinutes)) {
      return const Validation('estimatedMinutes', 'invalid_minutes');
    }
    if ((d.iconKey?.length ?? 0) > 24) {
      return const Validation('iconKey', 'too_long');
    }
    final color = d.colorIndex;
    if (color != null && (color < 0 || color >= TemplateLimits.paletteLength)) {
      return const Validation('colorIndex', 'invalid_range');
    }

    // ── Reminders (stored now, used in Phase 4) ─────────────────────────────
    final reminders = d.reminders;
    if (reminders.offsetsMinutes.length > TemplateLimits.maxReminderOffsets) {
      return const Validation('reminders', 'too_many_items');
    }
    for (final offset in reminders.offsetsMinutes) {
      if (offset < 1 || offset > 1440) {
        return const Validation('reminders', 'invalid_minutes');
      }
    }
    if (reminders.overdueAfterMinutes < 1 ||
        reminders.overdueAfterMinutes > 1440) {
      return const Validation('reminders', 'invalid_minutes');
    }

    return null;
  }

  static Validation? _validateAssignee(AssigneeSpec a) {
    switch (a.strategy) {
      case AssigneeStrategy.manual:
        return null;

      case AssigneeStrategy.fixed:
        final member = a.fixedMemberId;
        if (member == null || member.trim().isEmpty) {
          return const Validation('assignee', 'member_required');
        }
        return null;

      case AssigneeStrategy.rotation:
        // A duty group OR the template's own rotation, never neither.
        final group = a.dutyGroupId;
        if (group != null && group.trim().isNotEmpty) {
          if (!_catalogId.hasMatch(group)) {
            return const Validation('assignee', 'invalid_rotation');
          }
          return null;
        }
        final rotation = a.rotation;
        if (rotation == null) {
          return const Validation('assignee', 'invalid_rotation');
        }
        return _validateRotation(rotation);
    }
  }

  /// The shape rules the ROTATION ENGINE (P3-09) relies on. The engine owns
  /// the maths; this only rejects what could never be evaluated.
  static Validation? _validateRotation(Rotation r) {
    if (r.versions.isEmpty) {
      return const Validation('assignee', 'invalid_rotation');
    }
    if (r.versions.length > TemplateLimits.maxRotationVersions) {
      return const Validation('assignee', 'too_many_items');
    }
    for (final version in r.versions) {
      if (version.members.length < 2) {
        return const Validation('assignee', 'too_few_members');
      }
      if (version.members.length > TemplateLimits.maxRotationMembers) {
        return const Validation('assignee', 'too_many_items');
      }
      if (version.members.toSet().length != version.members.length) {
        return const Validation('assignee', 'invalid_rotation');
      }
      if (version.anchorIndex < 0 ||
          version.anchorIndex >= version.members.length) {
        return const Validation('assignee', 'invalid_rotation');
      }
      if (version.weekStartDay < DateTime.monday ||
          version.weekStartDay > DateTime.sunday) {
        return const Validation('assignee', 'invalid_week_start');
      }
    }
    // Versions must be strictly increasing by `from`, or "the greatest
    // version whose `from` <= day" would be ambiguous.
    for (var i = 1; i < r.versions.length; i++) {
      if (!r.versions[i].from.isAfter(r.versions[i - 1].from)) {
        return const Validation('assignee', 'invalid_rotation');
      }
    }
    return null;
  }

  /// `main` or `[a-z0-9]{1,12}` (D-P3-3).
  static final RegExp _slotKey = RegExp(r'^[a-z0-9]{1,12}$');

  /// `[a-z0-9_]{1,16}` (road map 3.2).
  static final RegExp _subtaskId = RegExp(r'^[a-z0-9_]{1,16}$');

  /// A catalog id (group / duty group).
  static final RegExp _catalogId = RegExp(r'^[a-z0-9_]{1,24}$');
}
