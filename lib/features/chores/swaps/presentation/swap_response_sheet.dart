import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/date_of_key.dart';
import 'package:family_hub/features/chores/presentation/member_names.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_request.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/reason_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The recipient's answer to a swap or cover request (P3-27): who asks, for
/// which chore and day, their reason, then Accept or Decline (an optional reason
/// for a decline).
///
/// Accept and decline are INTEGRITY writes: offline they fail with a clear
/// "needs internet" message instead of queueing, so two phones can never both
/// win. Returns null when the person backed out, otherwise the use case result
/// (the failure is already shown).
extension SwapResponseSheets on WidgetRef {
  Future<Result<Object?>?> respondToSwapWithSheet(
    BuildContext context,
    SwapRequest request,
  ) async {
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    final occurrence = (await read(
      occurrenceRepositoryProvider,
    ).get(familyId, request.occurrenceId)).valueOrNull;
    if (!context.mounted) return null;
    final members = read(membersProvider).value ?? const [];
    final l10n = context.l10n;
    final formatters = read(appFormattersProvider);
    final line = request.kind == SwapKind.cover
        ? l10n.inboxCoverRequest(
            memberNameOf(
              members,
              request.fromMemberId,
              fallback: l10n.inboxSomeone,
            ),
            occurrence?.nameBn ?? '',
            formatters.fullDate(dateOfKey(request.occurrenceDateKey)),
          )
        : l10n.inboxSwapRequest(
            memberNameOf(
              members,
              request.fromMemberId,
              fallback: l10n.inboxSomeone,
            ),
            occurrence?.nameBn ?? '',
            formatters.fullDate(dateOfKey(request.occurrenceDateKey)),
          );

    final accept = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) =>
          _ResponseSheet(line: line, reason: request.reason),
    );
    if (accept == null || !context.mounted) return null;
    String? declineReason;
    if (!accept) {
      declineReason = await showReasonSheet(
        context,
        title: l10n.swapDeclineReasonTitle,
        required: false,
      );
      if (declineReason == null || !context.mounted) return null;
    }

    final Result<Object?> result = accept
        ? await read(acceptSwapProvider)(
            familyId: familyId,
            actorUid: uid,
            requestId: request.id,
          )
        : await read(declineSwapProvider)(
            familyId: familyId,
            actorUid: uid,
            requestId: request.id,
            reason: declineReason!.isEmpty ? null : declineReason,
          );
    final failure = result.failureOrNull;
    if (failure != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure is Network
                ? l10n.swapNeedsInternet
                : l10n.choresFailureMessage(failure),
          ),
        ),
      );
    }
    return result;
  }
}

class _ResponseSheet extends StatelessWidget {
  const _ResponseSheet({required this.line, required this.reason});

  final String line;
  final String reason;

  /// Only the first press counts: a quick second tap while the sheet is closing
  /// must not pop one screen too many.
  static void _answer(BuildContext context, bool accept) {
    if (ModalRoute.of(context)?.isCurrent ?? true) {
      Navigator.of(context).pop(accept);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.swapResponseTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(line, style: TextStyle(color: t.textPrimary, fontSize: 15)),
          const SizedBox(height: 8),
          Text(
            l10n.swapReasonLabel(reason),
            style: TextStyle(color: t.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('swap_accept'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => _answer(context, true),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.swapAccept),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const Key('swap_decline'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => _answer(context, false),
            icon: const Icon(Icons.close_rounded),
            label: Text(l10n.swapDecline),
          ),
        ],
      ),
    );
  }
}
