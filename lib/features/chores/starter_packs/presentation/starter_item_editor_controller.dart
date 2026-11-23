import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_item_providers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_saved.dart';
import 'package:family_hub/features/chores/templates/domain/template_validator.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_controller.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_state.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The editor of one starter-pack line; `null` means a new line.
///
/// It IS a [TemplateEditorController] (so the chore editor's form sections work
/// on it unchanged) that loads from and saves to the family's starter list
/// instead of `choreTemplates`: no planning, no active switch, no replan.
final starterItemEditorProvider = NotifierProvider.autoDispose
    .family<StarterItemEditorController, TemplateEditorState, String?>(
      StarterItemEditorController.new,
    );

class StarterItemEditorController extends TemplateEditorController {
  StarterItemEditorController(super.templateId);

  @override
  TemplateEditorState build() {
    final today = ref.read(familyDateKeysProvider).today();
    final line = templateId == null
        ? null
        : ref.read(starterPackProvider).templateBySeedKey(templateId!);
    final groups = ref.read(choreGroupsProvider);
    final draft =
        line?.toDraft(startDate: today) ??
        TemplateDraft(
          nameBn: '',
          recurrence: const DailyRecurrence(),
          startDate: today,
          groupId: groups.isEmpty ? null : groups.first.id,
        );
    return TemplateEditorState(
      draft: draft,
      savedDraft: draft,
      templateId: templateId,
      active: true,
      savedActive: true,
    );
  }

  @override
  Future<TemplateSaveStatus> save({
    ReplanScope replanScope = ReplanScope.futureOnly,
  }) async {
    if (state.saving) return TemplateSaveStatus.idle;

    final invalid = TemplateValidator.validate(state.draft);
    if (invalid != null) {
      state = state.copyWith(
        fieldError: invalid,
        status: TemplateSaveStatus.invalid,
        clearSaveFailure: true,
      );
      return TemplateSaveStatus.invalid;
    }
    final uid = ref.read(currentUidProvider);
    final familyId = ref.read(currentFamilyIdProvider);
    if (uid == null || familyId == null) {
      return _failed(const Unknown('no_session'));
    }

    state = state.copyWith(
      saving: true,
      status: TemplateSaveStatus.idle,
      clearFieldError: true,
      clearSaveFailure: true,
    );
    try {
      final result = await ref
          .read(manageStarterItemsProvider)
          .save(
            actorUid: uid,
            familyId: familyId,
            draft: state.draft,
            itemId: templateId,
          );
      final failure = result.failureOrNull;
      if (failure != null) return _failed(failure);
      state = state.copyWith(
        savedDraft: state.draft,
        saving: false,
        status: TemplateSaveStatus.saved,
      );
      return TemplateSaveStatus.saved;
    } on Object catch (error) {
      return _failed(Unknown(error));
    }
  }

  TemplateSaveStatus _failed(AppFailure failure) {
    state = state.copyWith(
      saving: false,
      saveFailure: failure,
      status: TemplateSaveStatus.failed,
    );
    return TemplateSaveStatus.failed;
  }
}
