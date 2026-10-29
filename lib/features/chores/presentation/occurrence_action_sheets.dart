import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_action_providers.dart';
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
  /// Reopen with a reason. Returns null when the person cancelled a sheet (or
  /// the session ended), otherwise the use case result so the caller can show
  /// the failure.
  Future<Result<Object?>?> reopenWithSheet(
    BuildContext context, {
    required String occurrenceId,
  }) async {
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceReopenTitle,
    );
    if (reason == null || !context.mounted) return null;
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    final result = await read(reopenOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: occurrenceId,
      reason: reason,
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
