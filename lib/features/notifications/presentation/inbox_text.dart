import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/presentation/date_of_key.dart';
import 'package:family_hub/features/chores/presentation/member_names.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:family_hub/features/notifications/domain/virtual_inbox.dart';

/// The sentence of one inbox row (P3-27), built from the row's few parameters.
///
/// Names are looked up from uids at display time, so a renamed member reads
/// right in old rows, and a removed member falls back to a neutral word. A row
/// of an unknown type (a newer app version wrote it) reads as a generic line
/// instead of breaking the list.
String inboxTextOf(
  AppLocalizations l10n,
  AppFormatters formatters,
  InboxItem item,
  List<Member> members,
) {
  String who(String key) =>
      memberNameOf(members, item.params[key], fallback: l10n.inboxSomeone);
  final chore = item.params['name'] ?? '';
  final raw = item.params['date'];
  final parsed = raw == null ? null : DateKey.parse(raw).valueOrNull;
  final date = parsed == null
      ? (raw ?? '')
      : formatters.fullDate(dateOfKey(parsed));

  switch (item.type) {
    case VirtualInboxType.budgetAlert:
      return l10n.inboxBudgetAlert(
        formatters.number(int.tryParse(item.params['percent'] ?? '') ?? 0),
      );
    case VirtualInboxType.pendingJoinRequests:
      return l10n.inboxPendingJoinRequests(
        formatters.number(int.tryParse(item.params['count'] ?? '') ?? 0),
      );
    case VirtualInboxType.pendingContributionRequests:
      return l10n.inboxPendingContributionRequests(
        formatters.number(int.tryParse(item.params['count'] ?? '') ?? 0),
      );
    case VirtualInboxType.contributionDue:
      return l10n.inboxContributionDue;
    case VirtualInboxType.awaitingVerification:
      return l10n.inboxAwaitingVerification(
        formatters.number(int.tryParse(item.params['count'] ?? '') ?? 0),
      );
    case InboxType.swapRequest:
      return item.params['kind'] == 'cover'
          ? l10n.inboxCoverRequest(who('from'), chore, date)
          : l10n.inboxSwapRequest(who('from'), chore, date);
    case InboxType.swapResult:
      return switch (item.params['outcome']) {
        'accepted' => l10n.inboxSwapAccepted(who('by'), chore, date),
        'declined' => l10n.inboxSwapDeclined(who('by'), chore, date),
        'cancelled' => l10n.inboxSwapCancelled(who('by'), chore, date),
        'expired' => l10n.inboxSwapExpired(chore, date),
        'reassigned' => l10n.inboxReassigned(who('by'), chore, date),
        _ => l10n.inboxUnknown,
      };
    case InboxType.choreAssigned:
      if (item.params['kind'] == 'summary') {
        return l10n.inboxChoresAssignedSummary(
          who('by'),
          formatters.number(int.tryParse(item.params['count'] ?? '') ?? 0),
          _day(formatters, item.params['from']),
          _day(formatters, item.params['to']),
        );
      }
      return l10n.inboxReassigned(who('by'), chore, date);
    case InboxType.memberApproved:
      return l10n.inboxMemberApproved;
    case InboxType.needsCover:
      return l10n.inboxNeedsCover(
        who('member'),
        formatters.number(int.tryParse(item.params['count'] ?? '') ?? 0),
        _day(formatters, item.params['from']),
        _day(formatters, item.params['to']),
      );
    case InboxType.absenceDecision:
      return item.params['status'] == 'active'
          ? l10n.inboxAbsenceApproved(who('by'))
          : l10n.inboxAbsenceRejected(who('by'));
    case InboxType.choreReopened:
      return l10n.inboxChoreReopened(who('by'), chore, date);
    case InboxType.commentAttention:
      return l10n.inboxCommentAttention(who('by'), chore, date);
    case InboxType.verificationNeeded:
      return l10n.inboxVerificationNeeded(who('by'), chore, date);
    default:
      return l10n.inboxUnknown;
  }
}

String _day(AppFormatters formatters, String? raw) {
  final key = raw == null ? null : DateKey.parse(raw).valueOrNull;
  return key == null ? (raw ?? '') : formatters.fullDate(dateOfKey(key));
}
