import 'package:family_hub/features/chores/occurrences/domain/occurrence_state_machine.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// P3-11 / Appendix C: the allowed transitions as a table.
///
/// Each action is checked against EVERY status (6 x 13 cases), then the actor
/// dimension is checked on its own.
void main() {
  const statuses = <ChoreStatus>[
    ChoreStatus.scheduled,
    ChoreStatus.inProgress,
    ChoreStatus.completed,
    ChoreStatus.verified,
    ChoreStatus.skipped,
    ChoreStatus.overdue,
  ];

  const assignee = OccurrenceActor(uid: 'cara', isAssignee: true);
  const manager = OccurrenceActor(uid: 'bob', isManager: true);
  const swapRecipient = OccurrenceActor(uid: 'dave', hasAcceptedSwap: true);

  // The actor that is allowed the action in the table test.
  final cases = <OccurrenceAction, (Set<ChoreStatus>, OccurrenceActor)>{
    OccurrenceAction.tickSubtask: (
      {ChoreStatus.scheduled, ChoreStatus.inProgress, ChoreStatus.completed},
      assignee,
    ),
    OccurrenceAction.untickSubtask: (
      {ChoreStatus.inProgress, ChoreStatus.completed},
      assignee,
    ),
    OccurrenceAction.checkParent: (
      {ChoreStatus.scheduled, ChoreStatus.inProgress},
      assignee,
    ),
    OccurrenceAction.uncheckParent: ({ChoreStatus.completed}, assignee),
    OccurrenceAction.verify: ({ChoreStatus.completed}, manager),
    OccurrenceAction.reopen: (
      {ChoreStatus.completed, ChoreStatus.verified},
      manager,
    ),
    OccurrenceAction.recordException: (
      {ChoreStatus.scheduled, ChoreStatus.inProgress},
      manager,
    ),
    OccurrenceAction.skip: (
      {ChoreStatus.scheduled, ChoreStatus.inProgress},
      manager,
    ),
    OccurrenceAction.unskip: ({ChoreStatus.skipped}, manager),
    OccurrenceAction.reassign: (
      {ChoreStatus.scheduled, ChoreStatus.inProgress},
      manager,
    ),
    OccurrenceAction.acceptSwap: (
      {ChoreStatus.scheduled, ChoreStatus.inProgress},
      swapRecipient,
    ),
    OccurrenceAction.softDelete: ({ChoreStatus.scheduled}, manager),
    OccurrenceAction.replan: ({ChoreStatus.scheduled}, manager),
  };

  test('every action x every status matches Appendix C', () {
    expect(cases.length, OccurrenceAction.values.length);
    for (final action in OccurrenceAction.values) {
      final (allowed, actor) = cases[action]!;
      for (final status in statuses) {
        // `overdue` is `in_progress` with a late clock.
        final effective = status == ChoreStatus.overdue
            ? ChoreStatus.inProgress
            : status;
        expect(
          OccurrenceStateMachine.can(status, action, actor),
          allowed.contains(effective),
          reason: '${action.id} from ${status.id}',
        );
      }
    }
  });

  test('who may tick', () {
    const plain = OccurrenceActor(uid: 'cara');
    const helper = OccurrenceActor(uid: 'dave', canCompleteForOthers: true);

    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.scheduled,
        OccurrenceAction.tickSubtask,
        assignee,
      ),
      isTrue,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.scheduled,
        OccurrenceAction.tickSubtask,
        manager,
      ),
      isTrue,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.scheduled,
        OccurrenceAction.tickSubtask,
        helper,
      ),
      isTrue,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.scheduled,
        OccurrenceAction.tickSubtask,
        plain,
      ),
      isFalse,
    );
  });

  test('nobody verifies their own work', () {
    const completer = OccurrenceActor(uid: 'cara', isCompleter: true);
    const managerCompleter = OccurrenceActor(
      uid: 'bob',
      isManager: true,
      isCompleter: true,
    );
    const other = OccurrenceActor(uid: 'dave');

    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.completed,
        OccurrenceAction.verify,
        completer,
      ),
      isFalse,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.completed,
        OccurrenceAction.verify,
        managerCompleter,
      ),
      isFalse,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.completed,
        OccurrenceAction.verify,
        other,
      ),
      isTrue,
    );
  });

  test('reopen: commenter from completed, manager from verified', () {
    const commenter = OccurrenceActor(uid: 'dave');
    const muted = OccurrenceActor(uid: 'dave', canComment: false);

    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.completed,
        OccurrenceAction.reopen,
        commenter,
      ),
      isTrue,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.completed,
        OccurrenceAction.reopen,
        muted,
      ),
      isFalse,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.verified,
        OccurrenceAction.reopen,
        manager,
      ),
      isTrue,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.verified,
        OccurrenceAction.reopen,
        commenter,
      ),
      isFalse,
    );
  });

  test('a swap is only accepted by the recipient of the request', () {
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.scheduled,
        OccurrenceAction.acceptSwap,
        swapRecipient,
      ),
      isTrue,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.scheduled,
        OccurrenceAction.acceptSwap,
        assignee,
      ),
      isFalse,
    );
  });

  test('manager-only actions reject a member', () {
    const plain = OccurrenceActor(uid: 'cara', isAssignee: true);
    final from = <OccurrenceAction, ChoreStatus>{
      OccurrenceAction.recordException: ChoreStatus.scheduled,
      OccurrenceAction.skip: ChoreStatus.scheduled,
      OccurrenceAction.unskip: ChoreStatus.skipped,
      OccurrenceAction.reassign: ChoreStatus.scheduled,
      OccurrenceAction.softDelete: ChoreStatus.scheduled,
      OccurrenceAction.replan: ChoreStatus.scheduled,
    };
    for (final entry in from.entries) {
      expect(
        OccurrenceStateMachine.can(entry.value, entry.key, plain),
        isFalse,
        reason: entry.key.id,
      );
      expect(
        OccurrenceStateMachine.can(entry.value, entry.key, manager),
        isTrue,
        reason: entry.key.id,
      );
    }
  });

  test('overdue is in_progress: it can be ticked but not unchecked', () {
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.overdue,
        OccurrenceAction.checkParent,
        assignee,
      ),
      isTrue,
    );
    expect(
      OccurrenceStateMachine.can(
        ChoreStatus.overdue,
        OccurrenceAction.uncheckParent,
        assignee,
      ),
      isFalse,
    );
  });
}
