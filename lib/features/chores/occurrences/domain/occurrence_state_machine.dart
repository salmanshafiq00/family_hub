import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// The actions of Appendix C (the occurrence state machine).
enum OccurrenceAction {
  tickSubtask('tick_subtask'),
  untickSubtask('untick_subtask'),
  checkParent('check_parent'),
  uncheckParent('uncheck_parent'),
  verify('verify'),
  reopen('reopen'),
  recordException('record_exception'),
  skip('skip'),
  unskip('unskip'),
  reassign('reassign'),
  acceptSwap('accept_swap'),
  softDelete('soft_delete'),
  replan('replan');

  const OccurrenceAction(this.id);

  final String id;
}

/// Everything the state machine may know about the actor.
///
/// It is a VALUE, not a member document: the use case resolves the role and the
/// permission switches once, and the pure table below never reads Firestore.
/// Contextual preconditions that are NOT in this value (the template requires
/// verification, the family switch is on, a reason was typed, a swap request is
/// still pending) stay in the use case; the P3-13 rules mirror both.
final class OccurrenceActor {
  const OccurrenceActor({
    required this.uid,
    this.isManager = false,
    this.isAssignee = false,
    this.canCompleteForOthers = false,
    this.canComment = true,
    this.isCompleter = false,
    this.hasAcceptedSwap = false,
  });

  final String uid;

  /// Admin or Household Manager (`manageChoreOccurrences`).
  final bool isManager;

  /// The occurrence's current assignee.
  final bool isAssignee;

  /// `settings/permissions.membersCanCompleteForOthers` is on.
  final bool canCompleteForOthers;

  /// `commentOnChore` (every active member by default).
  final bool canComment;

  /// The member who completed it (never allowed to verify their own work).
  final bool isCompleter;

  /// The recipient of an ACCEPTED swap/cover request for this occurrence.
  final bool hasAcceptedSwap;

  bool get mayTick => isAssignee || isManager || canCompleteForOthers;

  @override
  bool operator ==(Object other) =>
      other is OccurrenceActor &&
      other.uid == uid &&
      other.isManager == isManager &&
      other.isAssignee == isAssignee &&
      other.canCompleteForOthers == canCompleteForOthers &&
      other.canComment == canComment &&
      other.isCompleter == isCompleter &&
      other.hasAcceptedSwap == hasAcceptedSwap;

  @override
  int get hashCode => Object.hash(
    uid,
    isManager,
    isAssignee,
    canCompleteForOthers,
    canComment,
    isCompleter,
    hasAcceptedSwap,
  );

  @override
  String toString() => 'OccurrenceActor($uid, manager: $isManager)';
}

/// Appendix C as a pure table: may [actor] apply [action] to an occurrence
/// whose EFFECTIVE status is [from]?
///
/// `overdue` is a display status derived from the clock, so it is treated as
/// `in_progress` here. This function answers the status + actor question only;
/// the use case (and P3-13's rules) additionally check the reason length, the
/// verification switch, the assignee's availability and the request state.
abstract final class OccurrenceStateMachine {
  static bool can(
    ChoreStatus from,
    OccurrenceAction action,
    OccurrenceActor actor,
  ) {
    final status = from == ChoreStatus.overdue ? ChoreStatus.inProgress : from;
    final open =
        status == ChoreStatus.scheduled || status == ChoreStatus.inProgress;

    return switch (action) {
      OccurrenceAction.tickSubtask =>
        (open || status == ChoreStatus.completed) && actor.mayTick,
      OccurrenceAction.untickSubtask =>
        (status == ChoreStatus.inProgress || status == ChoreStatus.completed) &&
            actor.mayTick,
      OccurrenceAction.checkParent => open && actor.mayTick,
      OccurrenceAction.uncheckParent =>
        status == ChoreStatus.completed && actor.mayTick,
      OccurrenceAction.verify =>
        status == ChoreStatus.completed && !actor.isCompleter,
      OccurrenceAction.reopen =>
        (status == ChoreStatus.completed && actor.canComment) ||
            (status == ChoreStatus.verified && actor.isManager),
      OccurrenceAction.recordException => open && actor.isManager,
      OccurrenceAction.skip => open && actor.isManager,
      OccurrenceAction.unskip =>
        status == ChoreStatus.skipped && actor.isManager,
      OccurrenceAction.reassign => open && actor.isManager,
      OccurrenceAction.acceptSwap => open && actor.hasAcceptedSwap,
      OccurrenceAction.softDelete =>
        status == ChoreStatus.scheduled && actor.isManager,
      OccurrenceAction.replan =>
        status == ChoreStatus.scheduled && actor.isManager,
    };
  }
}
