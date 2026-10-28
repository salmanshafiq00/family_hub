import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_action_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/person_picker.dart';
import 'package:family_hub/shared/widgets/reason_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The sheet-driven actions of the chore detail screen (P3-15).
///
/// Each one collects its input with the SHARED sheets (`ReasonSheet` for the
/// 3–300 character rule, D-P3-17; `PersonPicker` for the new owner) and then
/// hands the call to the use case provider. Split out of the screen so the
/// screen stays a layout file and the "which sheet asks what" rules live in one
/// place — the same rules the verify queue reuses.
extension OccurrenceActionSheets on WidgetRef {
  /// Reopen with a reason; returns true when the chore was reopened.
  Future<bool> reopenWithSheet(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceReopenTitle,
    );
    if (reason == null || !context.mounted) return false;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return false;
    final result = await read(reopenOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      reason: reason,
    );
    return result.failureOrNull == null;
  }

  /// Pick a member, then a reason, then move the chore.
  Future<bool> reassignWithSheets(
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
    if (chosen == null || !context.mounted) return false;
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceReassignReasonTitle,
    );
    if (reason == null || !context.mounted) return false;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return false;
    final result = await read(reassignOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      toMemberId: chosen,
      reason: reason,
    );
    return result.failureOrNull == null;
  }

  /// Skip with a reason (manager only).
  Future<bool> skipWithSheet(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceSkipTitle,
    );
    if (reason == null || !context.mounted) return false;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return false;
    final result = await read(skipOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      reason: reason,
    );
    return result.failureOrNull == null;
  }

  /// Record a completion exception with its note (manager only).
  Future<bool> exceptionWithSheet(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final note = await showReasonSheet(
      context,
      title: context.l10n.occurrenceExceptionTitle,
    );
    if (note == null || !context.mounted) return false;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return false;
    final result = await read(recordCompletionExceptionProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      note: note,
    );
    return result.failureOrNull == null;
  }
}

/// The body of the detail screen: header, steps, instructions and history.
///
/// Kept as a function so the screen file stays small; every piece is a widget
/// of its own (`widgets/`), which is also what the gallery and the overflow
/// tests render.
List<Widget> detailSections({
  required ChoreItem item,
  required dynamic occurrence,
  required List<dynamic> events,
  required dynamic formatters,
  required dynamic today,
  required bool busy,
  required VoidCallback onToggleParent,
  required ValueChanged<String> onToggleSubtask,
}) => <Widget>[
  // Filled by the screen (which owns the providers); see
  // `occurrence_detail_screen.dart` for the composition.
];
