import 'dart:async';

import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/availability/domain/member_availability.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/date_of_key.dart';
import 'package:family_hub/features/chores/presentation/member_names.dart';
import 'package:family_hub/features/chores/presentation/occurrence_action_sheets.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/swaps/presentation/needs_cover_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The chores that still need somebody (P3-27, managers): nobody owns them, or
/// the owner is away or inactive.
///
/// The list is split by WHY a chore needs a cover: one section per absence
/// reason (sick, travel, ...) and a last one for "nobody assigned", and every
/// row names the absent member and what they wrote. One tap assigns a person;
/// the comment is optional and starts with the absence reason. "Share out now"
/// hands the chores of absent members to other members at once.
class NeedsCoverBoard extends ConsumerWidget {
  const NeedsCoverBoard({super.key});

  /// The absence that explains [item], or null (nobody assigned).
  static MemberAvailability? _absenceOf(
    ChoreItem item,
    List<MemberAvailability> records,
  ) {
    final owner = item.assigneeId ?? item.plannedAssigneeId;
    if (owner == null) return null;
    for (final record in records) {
      if (record.memberId == owner &&
          !item.dateKey.isBefore(record.startDate) &&
          !item.dateKey.isAfter(record.endDate)) {
        return record;
      }
    }
    return null;
  }

  Future<void> _shareNow(BuildContext context, WidgetRef ref) async {
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return;
    final l10n = context.l10n;
    final result = await ref.read(autoShareAbsentChoresProvider)(
      familyId: familyId,
      actorUid: uid,
      force: true,
    );
    if (!context.mounted) return;
    final failure = result.failureOrNull;
    final moved = result.valueOrNull ?? 0;
    final message = failure != null
        ? l10n.choresFailureMessage(failure)
        : moved > 0
        ? l10n.needsCoverShareDone
        : l10n.needsCoverShareNone;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref,
    ChoreItem item,
    MemberAvailability? absence,
  ) async {
    final result = await ref.reassignWithSheets(
      context,
      occurrenceId: item.id,
      reasonRequired: false,
      initialReason: absence?.reason,
    );
    final failure = result?.failureOrNull;
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.choresFailureMessage(failure))),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final members = ref.watch(membersProvider).value ?? const [];
    final canAssign = ref.can(Permission.reassignChore);
    final needing = ref.watch(needsCoverItemsProvider);
    final records =
        ref.watch(availabilityProvider).value ?? const <MemberAvailability>[];
    final reasons = ref.watch(absenceReasonsProvider);
    final english = Localizations.localeOf(context).languageCode == 'en';

    String typeLabel(String id) {
      for (final reason in reasons) {
        if (reason.id == id) {
          return english && reason.labelEn != null
              ? reason.labelEn!
              : reason.labelBn;
        }
      }
      return id;
    }

    // Sections: one per absence type, in the order they first appear, then
    // "nobody assigned". Rows keep their date order inside a section.
    final sections = <String, List<ChoreItem>>{};
    final absenceOf = <String, MemberAvailability?>{};
    for (final item in needing) {
      final absence = _absenceOf(item, records);
      absenceOf[item.id] = absence;
      (sections[absence?.typeId ?? ''] ??= <ChoreItem>[]).add(item);
    }
    final keys = <String>[
      for (final key in sections.keys)
        if (key.isNotEmpty) key,
      if (sections.containsKey('')) '',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.needsCoverTitle),
        actions: [
          if (canAssign)
            IconButton(
              key: const Key('needs_cover_share_now'),
              tooltip: l10n.needsCoverShareNow,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.groups_2_outlined),
              onPressed: () => unawaited(_shareNow(context, ref)),
            ),
        ],
      ),
      body: !canAssign
          ? EmptyState(
              icon: Icons.lock_outline_rounded,
              title: l10n.needsCoverNoAccess,
            )
          : needing.isEmpty
          ? EmptyState(
              icon: Icons.verified_outlined,
              title: l10n.needsCoverEmpty,
            )
          : ListView(
              children: [
                for (final key in keys) ...[
                  Padding(
                    key: Key('needs_cover_section_$key'),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      children: [
                        Icon(
                          key.isEmpty
                              ? Icons.person_off_outlined
                              : Icons.event_busy_outlined,
                          size: 20,
                          color: t.accentStrong,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            key.isEmpty
                                ? l10n.needsCoverWhyNobody
                                : '${l10n.needsCoverWhyAbsent} · '
                                      '${typeLabel(key)}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: t.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final item in sections[key]!)
                    ListTile(
                      key: Key('needs_cover_${item.id}'),
                      minVerticalPadding: 12,
                      title: Text(item.nameBn),
                      subtitle: Text(
                        [
                          formatters.fullDate(dateOfKey(item.dateKey)),
                          if ((item.assigneeId ?? item.plannedAssigneeId) !=
                              null)
                            memberNameOf(
                              members,
                              item.assigneeId ?? item.plannedAssigneeId,
                            ),
                          if (absenceOf[item.id] != null)
                            absenceOf[item.id]!.reason,
                        ].join(' · '),
                        style: TextStyle(color: t.textSecondary),
                      ),
                      trailing: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () => unawaited(
                          _assign(context, ref, item, absenceOf[item.id]),
                        ),
                        child: Text(l10n.needsCoverAssign),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}
