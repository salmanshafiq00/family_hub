import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_request.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_providers.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_response_sheet.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:family_hub/features/notifications/domain/virtual_inbox.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

extension InboxOpenAction on WidgetRef {
  Future<void> openInboxItem(BuildContext context, InboxItem item) async {
    final familyId = read(currentFamilyIdProvider);
    final uid = read(currentUidProvider);
    if (item.isUnread) {
      if (item.id.startsWith('v:')) {
        final saved = await read(markVirtualInboxReadProvider)(<String>[
          item.id,
        ]);
        if (!saved && context.mounted) {
          _showOnce(context, context.l10n.errorUnknown);
        }
      } else if (familyId != null && uid != null) {
        final result = await read(markInboxReadProvider)(
          familyId: familyId,
          actorUid: uid,
          ids: <String>[item.id],
        );
        if (result.failureOrNull != null && context.mounted) {
          _showOnce(context, context.l10n.errorUnknown);
        }
      }
    }
    if (!context.mounted) return;

    // Replace the stack so opening a target cannot duplicate the shell route.
    switch (item.type) {
      case VirtualInboxType.budgetAlert:
        context.go(AppRoutes.bazarBudget);
        return;
      case VirtualInboxType.pendingJoinRequests:
        context.go(AppRoutes.familyMembers);
        return;
      case VirtualInboxType.pendingContributionRequests:
        context.go(AppRoutes.bazarFundPending);
        return;
      case VirtualInboxType.contributionDue:
        context.go(AppRoutes.bazarFund);
        return;
      case VirtualInboxType.awaitingVerification:
        context.go(AppRoutes.choresVerify);
        return;
    }
    if (item.type == InboxType.choreAssigned &&
        item.params['kind'] == 'summary') {
      context.go(AppRoutes.chores);
      return;
    }
    switch (item.refType) {
      case AuditRefType.swapRequest:
        // Load THIS request by id (a server read, cache only when offline).
        // The old way waited for the first snapshot of the pending list, which
        // on a cold start from a phone notification is often the local cache
        // without the new request, so a real, open request looked "closed".
        if (familyId == null) return;
        final loaded = await read(swapRepositoryProvider)
            .get(familyId, item.refId);
        if (!context.mounted) return;
        final failure = loaded.failureOrNull;
        if (failure != null) {
          final message = failure is Network
              ? context.l10n.errorNetwork
              : context.l10n.choresFailureMessage(failure);
          _showOnce(context, message);
          return;
        }
        final request = loaded.valueOrNull;
        if (request != null &&
            request.status == SwapStatus.pending &&
            request.toMemberId == uid) {
          await respondToSwapWithSheet(context, request);
          return;
        }
        if (item.type == InboxType.swapRequest) {
          _showOnce(context, context.l10n.choresFailure_swap_not_pending);
        }
      case AuditRefType.availability:
        if (context.mounted) context.go(AppRoutes.choresAvailability);
      case AuditRefType.occurrence:
        if (context.mounted) {
          context.go(AppRoutes.choresOccurrence(item.refId));
        }
      case AuditRefType.member:
        if (item.type == InboxType.memberApproved) {
          context.go(AppRoutes.home);
        }
        return;
    }
  }
}

/// One message at a time: a new one replaces the one on screen, so several
/// quick taps never queue a row of identical snackbars.
void _showOnce(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
