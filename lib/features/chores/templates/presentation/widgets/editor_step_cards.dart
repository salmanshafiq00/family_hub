import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_controller.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_state.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/assignee_editor.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_basics_section.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_options_section.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_schedule_section.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_section_card.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/instructions_editor.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/subtasks_editor.dart';
import 'package:flutter/material.dart';

/// The cards of one wizard step: Basics; Schedule; Who + Steps; Instructions +
/// Options. Only the current step's cards are built.
class EditorStepCards extends StatelessWidget {
  const EditorStepCards({
    required this.step,
    required this.state,
    required this.controller,
    required this.enabled,
    required this.errorFor,
    super.key,
  });

  final int step;
  final TemplateEditorState state;
  final TemplateEditorController controller;
  final bool enabled;

  /// The localized message for the section that holds the last failed field.
  final String? Function(Set<String> fields) errorFor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cards = switch (step) {
      0 => [
        EditorSectionCard(
          title: l10n.choreEditorSectionBasics,
          error: errorFor(const {'nameBn', 'nameEn', 'colorIndex', 'iconKey'}),
          child: EditorBasicsSection(
            draft: state.draft,
            controller: controller,
            enabled: enabled,
          ),
        ),
      ],
      1 => [
        EditorSectionCard(
          title: l10n.choreEditorSectionSchedule,
          error: errorFor(const {'slots', 'endDate', 'recurrence'}),
          child: EditorScheduleSection(
            draft: state.draft,
            controller: controller,
            enabled: enabled,
          ),
        ),
      ],
      2 => [
        EditorSectionCard(
          title: l10n.choreEditorSectionWho,
          error: errorFor(const {'assignee'}),
          child: AssigneeEditor(
            assignee: state.draft.assignee,
            enabled: enabled,
            onChanged: controller.setAssignee,
          ),
        ),
        EditorSectionCard(
          title: l10n.choreEditorSectionSteps,
          error: errorFor(const {'subtasks'}),
          child: SubtasksEditor(
            subtasks: state.draft.subtasks,
            enabled: enabled,
            onChanged: controller.setSubtasks,
          ),
        ),
      ],
      _ => [
        EditorSectionCard(
          title: l10n.choreEditorSectionInstructions,
          error: errorFor(const {'instructions'}),
          child: InstructionsEditor(
            value: state.draft.instructions,
            enabled: enabled,
            onChanged: controller.setInstructions,
          ),
        ),
        EditorSectionCard(
          title: l10n.choreEditorSectionOptions,
          error: errorFor(const {'estimatedMinutes', 'reminders'}),
          child: EditorOptionsSection(
            draft: state.draft,
            active: state.active,
            controller: controller,
            enabled: enabled,
          ),
        ),
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cards,
    );
  }
}
