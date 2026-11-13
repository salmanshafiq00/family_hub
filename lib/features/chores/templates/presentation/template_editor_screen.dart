import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/templates/domain/template_saved.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_controller.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_state.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/editor_step_cards.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/replan_scope_dialog.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/busy_button.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'template_editor_screen_parts.dart';

/// Creates or edits one chore template (P3-16). [templateId] is null for a new
/// one (route `templates/new`).
///
/// Four steps (Basics; Schedule; Who and Steps; Instructions and Options) with
/// a progress header and Back/Next, so the form is never one long scroll.
/// Editing an existing chore first asks what to do with chores
/// that are already planned (see [showReplanScopeDialog]). A content save is
/// never rolled back when the follow-up planning fails: the screen then shows a
/// banner with Retry. Leaving with unsaved edits asks first.
class TemplateEditorScreen extends ConsumerWidget {
  const TemplateEditorScreen({this.templateId, super.key});

  final String? templateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = templateId == null
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

    if (templateId != null) {
      // The controller reads the template once when it is created, so wait
      // for the first snapshot; otherwise it would start from an empty draft.
      final stream = ref.watch(templatesStreamProvider);
      if (!stream.hasValue) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: const LoadingView(),
        );
      }
      if (ref.watch(templateProvider(templateId!)) == null) {
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: EmptyState(
            icon: Icons.search_off_rounded,
            title: l10n.choreEditorNotFound,
          ),
        );
      }
    }
    return _EditorBody(templateId: templateId, title: title);
  }
}

class _EditorBody extends ConsumerStatefulWidget {
  const _EditorBody({required this.templateId, required this.title});

  final String? templateId;
  final String title;

  @override
  ConsumerState<_EditorBody> createState() => _EditorBodyState();
}

class _EditorBodyState extends ConsumerState<_EditorBody> {
  static const int _stepCount = 4;
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = templateEditorProvider(widget.templateId);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final enabled = !state.saving && !state.archived;
    final error = state.fieldError;
    final formatters = ref.watch(appFormattersProvider);

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
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            _StepProgress(
              label: l10n.choreEditorStepOf(
                formatters.number(_step + 1),
                formatters.number(_stepCount),
              ),
              progress: (_step + 1) / _stepCount,
            ),
            Expanded(
              // AnimatedSwitcher keeps only one step in the tree, so a
              // scrollable is never ambiguous and each step starts at the top.
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: ListView(
                  key: ValueKey<int>(_step),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    if (state.archived)
                      _Banner(
                        icon: Icons.archive_outlined,
                        message: l10n.choreEditorArchivedNote,
                      ),
                    if (state.status == TemplateSaveStatus.planningFailed)
                      _Banner(
                        icon: Icons.sync_problem_rounded,
                        message: l10n.choreEditorPlanningFailed,
                        actionKey: const ValueKey<String>('planning_retry'),
                        actionLabel: l10n.actionRetry,
                        onAction: state.saving
                            ? null
                            : controller.retryPlanning,
                      ),
                    EditorStepCards(
                      step: _step,
                      state: state,
                      controller: controller,
                      enabled: enabled,
                      errorFor: errorFor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _step == _stepCount - 1
            ? _SaveBar(
                failure: state.saveFailure,
                saving: state.saving,
                // A new chore can always be saved (an empty one is reported by
                // the validator); an existing one only when something changed.
                canSave: !state.cannotSave && (state.isNew || state.isDirty),
                onSave: _save,
                onBack: _back,
              )
            : _NextBar(onBack: _step == 0 ? null : _back, onNext: _next),
      ),
    );
  }

  Future<void> _save() async {
    final provider = templateEditorProvider(widget.templateId);
    final controller = ref.read(provider.notifier);
    var scope = ReplanScope.futureOnly;
    if (!ref.read(provider).isNew) {
      final chosen = await showReplanScopeDialog(context);
      if (chosen == null) return;
      scope = chosen;
    }
    final status = await controller.save(replanScope: scope);
    if (!mounted) return;
    if (status == TemplateSaveStatus.saved) {
      Navigator.of(context).pop();
      return;
    }
    // A validation error is shown on the step that holds the field, so the
    // user does not have to hunt for it on another page.
    if (status == TemplateSaveStatus.invalid) {
      final step = _stepForField(ref.read(provider).fieldError?.field);
      if (step != null && step != _step) setState(() => _step = step);
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step < _stepCount - 1) setState(() => _step += 1);
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) setState(() => _step -= 1);
  }

  /// The step that shows the field the validator rejected.
  static int? _stepForField(String? field) => switch (field) {
    'nameBn' || 'nameEn' || 'colorIndex' || 'iconKey' => 0,
    'endDate' || 'recurrence' || 'slots' || 'startDate' => 1,
    'assignee' || 'subtasks' => 2,
    'instructions' || 'estimatedMinutes' || 'reminders' => 3,
    _ => null,
  };

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
