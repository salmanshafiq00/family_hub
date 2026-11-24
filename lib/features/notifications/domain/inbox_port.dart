import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// The inbox types a chore action may send (`notificationInbox.type`).
///
/// They are module-neutral strings (D-P3-19): the inbox document lives in
/// `features/notifications/`, and P3-26 supplies its rules and screen.
abstract final class InboxType {
  static const String swapRequest = 'swap_request';
  static const String swapResult = 'swap_result';
  static const String needsCover = 'needs_cover';
  static const String choreReopened = 'chore_reopened';
  static const String commentAttention = 'comment_attention';
  static const String verificationNeeded = 'verification_needed';
  static const String absenceDecision = 'absence_decision';
  static const String choreAssigned = 'chore_assigned';
  static const String memberApproved = 'member_approved';

  /// Stored inbox types, mirrored by `inboxTypes()` in Firestore rules.
  static const List<String> all = <String>[
    swapRequest,
    swapResult,
    needsCover,
    choreReopened,
    commentAttention,
    verificationNeeded,
    absenceDecision,
    choreAssigned,
    memberApproved,
  ];
}

/// What a chore action may ask the inbox to deliver (P3-14).
///
/// The chore domain must not import the notifications FEATURE, so it depends on
/// this port. The no-op implementation is the default until P3-26 wires the real
/// writer, and every implementation merely BUILDS a [NewInboxItem]: the write
/// happens inside the same [OccurrenceWritePlan] batch as the change (road map
/// 3.4), never as a second call.
abstract interface class InboxPort {
  /// "Somebody reopened your chore" — to the assignee.
  NewInboxItem? choreReopened({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String actorId,
  });

  /// "Your chore is completed and waiting for a check" — to the checker.
  NewInboxItem? verificationNeeded({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String completedBy,
  });

  /// "A chore of yours was moved to somebody else" — to the new assignee.
  NewInboxItem? choreReassigned({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String byMemberId,
  });

  /// "Somebody flagged your chore as incorrect or incomplete" — to the
  /// assignee (P3-25).
  NewInboxItem? commentAttention({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String authorId,
  });

  /// "Somebody asks you to take a chore" (swap) or "please cover" (policy B) —
  /// to the recipient (P3-26).
  NewInboxItem? swapRequested({
    required String requestId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String fromMemberId,
    required bool cover,
  });

  /// "Your request was accepted / declined / cancelled / expired" — to the
  /// requester (or, for a cancel, to the recipient).
  NewInboxItem? swapResult({
    required String requestId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String outcome,
    required String byMemberId,
  });

  /// "[count] chores need a cover" — to the absent member and to the managers.
  NewInboxItem? needsCover({
    required String availabilityId,
    required String toMemberId,
    required String absentMemberId,
    required int count,
    required String from,
    required String to,
  });

  /// "Your absence was approved / rejected" — to the member.
  NewInboxItem? absenceDecision({
    required String availabilityId,
    required String toMemberId,
    required String status,
    required String byMemberId,
  });

  /// ONE row for a bulk move ("N chores from A to B were given to you").
  NewInboxItem? choresAssignedSummary({
    required String batchId,
    required String toMemberId,
    required String byMemberId,
    required int count,
    required String from,
    required String to,
  });
}

/// The port used before P3-26: it builds nothing, so a test can tell "no inbox
/// yet" from "the writer forgot".
final class NoopInboxPort implements InboxPort {
  const NoopInboxPort();

  @override
  NewInboxItem? choreReopened({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String actorId,
  }) => null;

  @override
  NewInboxItem? verificationNeeded({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String completedBy,
  }) => null;

  @override
  NewInboxItem? choreReassigned({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String byMemberId,
  }) => null;

  @override
  NewInboxItem? commentAttention({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String authorId,
  }) => null;
  @override
  NewInboxItem? swapRequested({
    required String requestId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String fromMemberId,
    required bool cover,
  }) => null;

  @override
  NewInboxItem? swapResult({
    required String requestId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String outcome,
    required String byMemberId,
  }) => null;

  @override
  NewInboxItem? needsCover({
    required String availabilityId,
    required String toMemberId,
    required String absentMemberId,
    required int count,
    required String from,
    required String to,
  }) => null;

  @override
  NewInboxItem? absenceDecision({
    required String availabilityId,
    required String toMemberId,
    required String status,
    required String byMemberId,
  }) => null;

  @override
  NewInboxItem? choresAssignedSummary({
    required String batchId,
    required String toMemberId,
    required String byMemberId,
    required int count,
    required String from,
    required String to,
  }) => null;
}

/// The shared shape of a chore inbox row (P3-26 copies this into its writer).
NewInboxItem choreInboxItem({
  required String type,
  required String toMemberId,
  required String occurrenceId,
  required Map<String, String> params,
}) => NewInboxItem(
  toMemberId: toMemberId,
  type: type,
  refType: AuditRefType.occurrence,
  refId: occurrenceId,
  params: params,
);
