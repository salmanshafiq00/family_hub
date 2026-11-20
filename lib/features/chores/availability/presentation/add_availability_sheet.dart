import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/availability/domain/member_availability.dart';
import 'package:family_hub/features/chores/availability/presentation/affected_chores.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_items_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/date_of_key.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Records an absence (P3-27): type chips, a date range, a reason, and a live
/// preview of how many chores it touches and what the family policy does about
/// them. After saving an ACTIVE absence the policy runs (P3-26); a pending one
/// waits for a manager. Returns null when the person backed out.
extension AddAvailabilitySheet on WidgetRef {
  Future<Result<Object?>?> addAvailabilityWithSheet(
    BuildContext context, {
    required String memberId,
  }) async {
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    final input = await showModalBottomSheet<AvailabilityInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddSheet(memberId: memberId),
    );
    if (input == null) return null;
    final id = randomId();
    final added = await read(addAvailabilityProvider)(
      familyId: familyId,
      actorUid: uid,
      availabilityId: id,
      memberId: memberId,
      startDate: input.start,
      endDate: input.end,
      typeId: input.typeId,
      reason: input.reason,
    );
    var failure = added.failureOrNull;
    if (failure == null &&
        added.valueOrNull?.status == AvailabilityStatus.active) {
      failure = (await read(applyAbsencePolicyProvider)(
        familyId: familyId,
        actorUid: uid,
        availabilityId: id,
      )).failureOrNull;
    }
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.choresFailureMessage(failure))),
      );
    }
    return added;
  }
}

/// What the sheet collects.
typedef AvailabilityInput = ({
  DateKey start,
  DateKey end,
  String typeId,
  String reason,
});

/// The sentence that tells what the family policy will do (P3-27).
String policyLineText(AppLocalizations l10n, PolicyLine line) => switch (line) {
  PolicyLine.ask => l10n.availabilityPolicyAsk,
  PolicyLine.auto => l10n.availabilityPolicyAuto,
  PolicyLine.skip => l10n.availabilityPolicySkip,
  PolicyLine.share => l10n.availabilityPolicyShare,
};

class _AddSheet extends ConsumerStatefulWidget {
  const _AddSheet({required this.memberId});

  final String memberId;

  @override
  ConsumerState<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<_AddSheet> {
  final TextEditingController _reason = TextEditingController();
  String? _typeId;
  DateKey? _start;
  DateKey? _end;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final today = ref.read(familyDateKeysProvider).today();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: dateOfKey(today.addDays(-30)),
      lastDate: dateOfKey(today.addDays(AvailabilityLimits.maxDays)),
      initialDateRange: DateTimeRange(
        start: dateOfKey(_start ?? today),
        end: dateOfKey(_end ?? _start ?? today),
      ),
    );
    if (picked == null) return;
    setState(() {
      _start = DateKey(picked.start.year, picked.start.month, picked.start.day);
      _end = DateKey(picked.end.year, picked.end.month, picked.end.day);
    });
  }

  bool get _valid {
    final reason = _reason.text.trim();
    return _typeId != null &&
        _start != null &&
        _end != null &&
        reason.length >= AvailabilityLimits.minReason &&
        reason.length <= AvailabilityLimits.maxReason;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final reasons = ref.watch(absenceReasonsProvider);
    final english = Localizations.localeOf(context).languageCode == 'en';
    final policy = ref.watch(rotationPolicyProvider);
    final start = _start;
    final end = _end;
    var affected = 0;
    if (start != null && end != null) {
      for (final month in monthsOfRange(start, end)) {
        affected += affectedChoresCount(
          ref.watch(monthItemsProvider(month)).value?.items ?? const [],
          memberId: widget.memberId,
          start: start,
          end: end,
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.availabilityAdd,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.availabilityType,
              style: TextStyle(color: t.textSecondary),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final reason in reasons)
                  ChoiceChip(
                    key: Key('availability_type_${reason.id}'),
                    selected: _typeId == reason.id,
                    avatar: _typeId == reason.id
                        ? const Icon(Icons.check_rounded, size: 18)
                        : null,
                    label: Text(
                      english && reason.labelEn != null
                          ? reason.labelEn!
                          : reason.labelBn,
                    ),
                    onSelected: (_) => setState(() => _typeId = reason.id),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('availability_range'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range_rounded),
              label: Text(
                start == null || end == null
                    ? l10n.availabilityPickDates
                    : l10n.availabilityRangeLine(
                        formatters.fullDate(dateOfKey(start)),
                        formatters.fullDate(dateOfKey(end)),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('availability_reason'),
              controller: _reason,
              maxLength: AvailabilityLimits.maxReason,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.availabilityReasonHint,
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (start != null && end != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  l10n.availabilityAffected(formatters.number(affected)),
                  key: const Key('availability_affected'),
                  style: TextStyle(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                policyLineText(l10n, policyLineOf(policy)),
                key: const Key('availability_policy_line'),
                style: TextStyle(color: t.textSecondary, fontSize: 13),
              ),
            ),
            FilledButton.icon(
              key: const Key('availability_save'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _valid
                  ? () => Navigator.of(context).pop((
                      start: start!,
                      end: end!,
                      typeId: _typeId!,
                      reason: _reason.text.trim(),
                    ))
                  : null,
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.availabilitySave),
            ),
          ],
        ),
      ),
    );
  }
}
