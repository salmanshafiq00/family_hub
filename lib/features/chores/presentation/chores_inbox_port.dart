import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';

/// The real [InboxPort] (P3-26): it BUILDS the inbox rows a chore action adds
/// to its own batch. Replaces [NoopInboxPort] in `bootstrap.dart`.
///
/// Nothing here writes: the plan stages the row with an id the plan builder
/// stamps, so a retry rewrites the same document. Parameters are the few
/// strings the inbox text needs (names are resolved by the screen from uids).
class ChoresInboxPort implements InboxPort {
  const ChoresInboxPort();

  NewInboxItem _occurrence(
    String type,
    String to,
    String occurrenceId,
    Map<String, String> params,
  ) => choreInboxItem(
    type: type,
    toMemberId: to,
    occurrenceId: occurrenceId,
    params: params,
  );

  @override
  NewInboxItem? choreReopened({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String actorId,
  }) => _occurrence(InboxType.choreReopened, toMemberId, occurrenceId, {
    'name': choreName,
    'date': dateKey,
    'by': actorId,
  });

  @override
  NewInboxItem? verificationNeeded({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String completedBy,
  }) => _occurrence(InboxType.verificationNeeded, toMemberId, occurrenceId, {
    'name': choreName,
    'date': dateKey,
    'by': completedBy,
  });

  @override
  NewInboxItem? choreReassigned({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String byMemberId,
  }) => _occurrence(InboxType.choreAssigned, toMemberId, occurrenceId, {
    'name': choreName,
    'date': dateKey,
    'by': byMemberId,
  });

  @override
  NewInboxItem? commentAttention({
    required String occurrenceId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String authorId,
  }) => _occurrence(InboxType.commentAttention, toMemberId, occurrenceId, {
    'name': choreName,
    'date': dateKey,
    'by': authorId,
  });

  @override
  NewInboxItem? swapRequested({
    required String requestId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String fromMemberId,
    required bool cover,
  }) => NewInboxItem(
    toMemberId: toMemberId,
    type: InboxType.swapRequest,
    refType: AuditRefType.swapRequest,
    refId: requestId,
    params: <String, String>{
      'name': choreName,
      'date': dateKey,
      'from': fromMemberId,
      'kind': cover ? 'cover' : 'swap',
    },
  );

  @override
  NewInboxItem? swapResult({
    required String requestId,
    required String toMemberId,
    required String choreName,
    required String dateKey,
    required String outcome,
    required String byMemberId,
  }) => NewInboxItem(
    toMemberId: toMemberId,
    type: InboxType.swapResult,
    refType: AuditRefType.swapRequest,
    refId: requestId,
    params: <String, String>{
      'name': choreName,
      'date': dateKey,
      'outcome': outcome,
      'by': byMemberId,
    },
  );

  @override
  NewInboxItem? needsCover({
    required String availabilityId,
    required String toMemberId,
    required String absentMemberId,
    required int count,
    required String from,
    required String to,
  }) => NewInboxItem(
    toMemberId: toMemberId,
    type: InboxType.needsCover,
    refType: AuditRefType.availability,
    refId: availabilityId,
    params: <String, String>{
      'member': absentMemberId,
      'count': '$count',
      'from': from,
      'to': to,
    },
  );

  @override
  NewInboxItem? absenceDecision({
    required String availabilityId,
    required String toMemberId,
    required String status,
    required String byMemberId,
  }) => NewInboxItem(
    toMemberId: toMemberId,
    type: InboxType.absenceDecision,
    refType: AuditRefType.availability,
    refId: availabilityId,
    params: <String, String>{'status': status, 'by': byMemberId},
  );

  @override
  NewInboxItem? choresAssignedSummary({
    required String batchId,
    required String toMemberId,
    required String byMemberId,
    required int count,
    required String from,
    required String to,
  }) => NewInboxItem(
    toMemberId: toMemberId,
    type: InboxType.choreAssigned,
    // Any 1-40 character refType is accepted by the rules; the row is about
    // the bulk move, not one chore.
    refType: AuditRefType.choreSettings,
    refId: batchId,
    params: <String, String>{
      'kind': 'summary',
      'count': '$count',
      'from': from,
      'to': to,
      'by': byMemberId,
    },
  );
}
