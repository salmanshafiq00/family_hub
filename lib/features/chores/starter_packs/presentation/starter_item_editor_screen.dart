import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_item_editor_controller.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_item_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_state.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_basics_section.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_schedule_section.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_section_card.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/instructions_editor.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/subtasks_editor.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adds or edits ONE line of the family's starter pack. [itemId] is null for
/// a new line.
///
/// Same form as the chore editor (names, group, icon, colour, repeat, times,
/// steps, instructions) on a single scrolling page; there is no person, date
/// range or reminder because a pack line is only a suggestion.
class StarterItemEditorScreen extends ConsumerWidget {
  const StarterItemEditorScreen({this.itemId, super.key});

  final String? itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = itemId == null
        ? l10n.choreEditorTitleNew
        : l10n.choreEditorTitleEdit;

    if (!ref.can(Permission.manageChoreTemplates)) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: l10n.choreTemplatesNotAllowed,
        ),
      );
    }
    if (itemId != null) {
      // The controller reads the line once, so wait for the first snapshot.
      final items = ref.watch(starterItemsStreamProvider);
      if (!items.hasValue && !items.hasError) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: const LoadingView(),
        );
      }
      if (ref.watch(starterPackProvider).templateBySeedKey(itemId!) == null) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: EmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.choreEditorNotFound,
          ),
        );
      }
    }
    return _Body(itemId: itemId, title: title);
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.itemId, required this.title});

  final String? itemId;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = starterItemEditorProvider(itemId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final enabled = !state.saving;
    final error = state.fieldError;

    String? errorFor(Set<String> fields) =>
        error != null && fields.contains(error.field)
        ? l10n.choresFailureMessage(error)
        : null;

    return PopScope(
      canPop: !state.isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmDiscard(context);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            EditorSectionCard(
              title: l10n.choreEditorSectionBasics,
              error: errorFor(const {
                'nameBn',
                'nameEn',
                'colorIndex',
                'iconKey',
              }),
              child: EditorBasicsSection(
                draft: state.draft,
                controller: controller,
                enabled: enabled,
              ),
            ),
            EditorSectionCard(
              title: l10n.choreEditorSectionSchedule,
              error: errorFor(const {'slots', 'recurrence'}),
              child: EditorScheduleSection(
                draft: state.draft,
                controller: controller,
                enabled: enabled,
                showDates: false,
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
            EditorSectionCard(
              title: l10n.choreEditorSectionInstructions,
              error: errorFor(const {'instructions'}),
              child: InstructionsEditor(
                value: state.draft.instructions,
                enabled: enabled,
                onChanged: controller.setInstructions,
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.saveFailure case final failure?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.choresFailureMessage(failure),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    key: const ValueKey<String>('starter_item_save'),
                    onPressed: state.saving || !(state.isNew || state.isDirty)
                        ? null
                        : () => _save(context, controller),
                    child: state.saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.actionSave),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    StarterItemEditorController controller,
  ) async {
    final status = await controller.save();
    if (status == TemplateSaveStatus.saved && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  static Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.choresSettingsDiscardTitle),
        content: Text(l10n.choresSettingsDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('discard_confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    return leave ?? false;
  }
}
