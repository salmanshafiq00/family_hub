import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/effective_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_reopen.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_action_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/person_picker.dart';
import 'package:family_hub/shared/widgets/reason_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sheet-driven actions of the chore detail screen (P3-15).
///
/// Every method returns `null` when the person backed out, otherwise the use
/// case [Result] (R0-4: the screen shows the failure; nothing is swallowed).
///
/// Each one collects its input with the SHARED sheets (`ReasonSheet` for the
/// 3–300 character rule, D-P3-17; `PersonPicker` for the new owner) and then
/// hands the call to the use case provider. Split out of the screen so the
/// screen stays a layout file and the "which sheet asks what" rules live in one
/// place — the same rules the verify queue reuses.
extension OccurrenceActionSheets on WidgetRef {
  /// Reopen with a reason, and with the steps to redo (B-04).
  ///
  /// A chore with ticks asks WHICH steps must be done again (all of them by
  /// default); the answer is unticked in the same patch, otherwise the chore
  /// would stay `completed` and the button would look broken.  Returns null
  /// when the person cancelled a sheet (or the session ended), otherwise the
  /// use case result so the caller can show the failure.
  Future<Result<Object?>?> reopenWithSheet(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final l10n = context.l10n;
    final document = read(occurrenceProvider(occurrenceId)).value;
    // Only a chore that is COMPLETED right now has steps to redo: one whose
    // ticks were already removed is open again (`effectiveStatus`, not the
    // stored cache), and asking about its steps would be nonsense.
    final completed = document != null
        ? effectiveStatus(document) == ChoreStatus.completed
        : false;
    final ticked = <String>{
      if (completed) ...OccurrenceReopen.redoCandidates(document!),
    };
    final steps = <TemplateSubtask>[
      if (document != null)
        for (final subtask in document.subtasks)
          if (ticked.contains(subtask.id)) subtask,
    ];

    String? reason;
    List<String>? redo;
    if (steps.isEmpty) {
      reason = await showReasonSheet(
        context,
        title: l10n.occurrenceReopenTitle,
      );
    } else {
      final answer = await showReasonChecklistSheet(
        context,
        title: l10n.occurrenceReopenTitle,
        checklistTitle: l10n.occurrenceReopenStepsTitle,
        hint: l10n.occurrenceReopenStepsHint,
        options: <String>[for (final step in steps) step.title],
        selected: <bool>[for (final _ in steps) true],
      );
      if (answer != null) {
        reason = answer.reason;
        // The sheet answers with LABELS (that is what a person reads); the use
        // case needs the step ids.  Labels are unique per chore here.
        redo = <String>[
          for (final step in steps)
            if (answer.stepIds.contains(step.title)) step.id,
        ];
      }
    }
    if (reason == null || !context.mounted) return null;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    final result = await read(reopenOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      reason: reason,
      redoSubtaskIds: redo,
    );
    return result;
  }



  /// Pick a member, then a reason, then move the chore.
  Future<Result<Object?>?> reassignWithSheets(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final members = read(membersProvider).value ?? const [];
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.occurrenceReassignTitle),
        content: SingleChildScrollView(
          child: PersonPicker(
            label: context.l10n.occurrenceReassignTitle,
            options: <PersonOption>[
              for (final member in members)
                if (member.isActive)
                  PersonOption(
                    id: member.uid,
                    name: member.displayName,
                    avatarKey: member.avatarKey,
                  ),
            ],
            selectedId: null,
            onChanged: (id) {
              if (id != null) Navigator.of(dialogContext).pop(id);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.actionCancel),
          ),
        ],
      ),
    );
    if (chosen == null || !context.mounted) return null;
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceReassignReasonTitle,
    );
    if (reason == null || !context.mounted) return null;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    final result = await read(reassignOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      toMemberId: chosen,
      reason: reason,
    );
    return result;
  }

  /// Skip with a reason (manager only).
  Future<Result<Object?>?> skipWithSheet(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceSkipTitle,
    );
    if (reason == null || !context.mounted) return null;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    final result = await read(skipOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      reason: reason,
    );
    return result;
  }

  /// Record a completion exception with its note (manager only).
  Future<Result<Object?>?> exceptionWithSheet(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final note = await showReasonSheet(
      context,
      title: context.l10n.occurrenceExceptionTitle,
    );
    if (note == null || !context.mounted) return null;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    final result = await read(recordCompletionExceptionProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      note: note,
    );
    return result;
  }
}
