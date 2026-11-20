import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/availability/data/availability_mappers.dart';
import 'package:family_hub/features/chores/presentation/chores_inbox_port.dart';
import 'package:family_hub/features/chores/swaps/data/swap_mappers.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_request.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/notifications/data/inbox_mappers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:family_hub/features/notifications/domain/inbox_writer.dart';
import 'package:family_hub/features/notifications/domain/usecases/archive_inbox_item.dart';
import 'package:family_hub/features/notifications/domain/usecases/clear_all_inbox_items.dart';
import 'package:family_hub/features/notifications/domain/usecases/mark_all_read.dart';
import 'package:family_hub/features/notifications/domain/usecases/mark_inbox_read.dart';
import 'package:family_hub/features/notifications/domain/virtual_inbox.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/rules_source.dart';
import '../chores_test_helpers.dart';

/// P3-26: the inbox use cases, the real port and the mappers vs the rules.
void main() {
  const familyId = ChoresFixture.familyId;
  late ChoresFixture fixture;
  late MarkInboxRead markRead;
  late ArchiveInboxItem archive;

  InboxItem row(String id, String to) => InboxItem(
    id: id,
    toMemberId: to,
    type: InboxType.swapRequest,
    refType: 'swapRequest',
    refId: 'r1',
    createdAt: DateTime.utc(2026, 10, 24),
  );

  setUp(() {
    fixture = ChoresFixture();
    fixture.inboxRows.items['i1'] = row('i1', 'cara');
    fixture.inboxRows.items['i2'] = row('i2', 'dave');
    markRead = MarkInboxRead(
      inbox: fixture.inboxRows,
      families: fixture.families,
      clock: fixture.clock,
    );
    archive = ArchiveInboxItem(
      inbox: fixture.inboxRows,
      families: fixture.families,
      clock: fixture.clock,
    );
  });

  test('the owner marks a row read, once', () async {
    final first = await markRead(
      familyId: familyId,
      actorUid: 'cara',
      ids: ['i1'],
    );
    expect(first.valueOrNull, 1);
    expect(fixture.inboxRows.items['i1']!.readAt, fixture.clock.nowUtc());
    final again = await markRead(
      familyId: familyId,
      actorUid: 'cara',
      ids: ['i1'],
    );
    expect(again.valueOrNull, 0, reason: 'already read: nothing written');
  });

  test('mark all read changes stored rows and ignores virtual rows', () async {
    final markAll = MarkAllRead(markRead);
    final result = await markAll(
      familyId: familyId,
      actorUid: 'cara',
      items: <InboxItem>[
        fixture.inboxRows.items['i1']!,
        InboxItem(
          id: 'v:budget:2026-10',
          toMemberId: 'cara',
          type: VirtualInboxType.budgetAlert,
          refType: 'budget',
          refId: '2026-10',
          createdAt: fixture.clock.nowUtc(),
        ),
      ],
    );

    expect(result.valueOrNull, 1);
    expect(fixture.inboxRows.items['i1']!.readAt, fixture.clock.nowUtc());
  });

  test('nobody touches somebody else’s row', () async {
    final result = await markRead(
      familyId: familyId,
      actorUid: 'cara',
      ids: ['i2'],
    );
    expect(result.failureOrNull, isA<PermissionDenied>());
    final denied = await archive(
      familyId: familyId,
      actorUid: 'cara',
      itemId: 'i2',
    );
    expect(denied.failureOrNull, isA<PermissionDenied>());
    final pending = await markRead(
      familyId: familyId,
      actorUid: 'erin',
      ids: ['i1'],
    );
    expect(pending.failureOrNull, isA<PermissionDenied>());
  });

  test('archiving hides the row but keeps it', () async {
    final result = await archive(
      familyId: familyId,
      actorUid: 'cara',
      itemId: 'i1',
    );
    expect(result.failureOrNull, isNull);
    expect(fixture.inboxRows.items['i1']!.isArchived, isTrue);
    final missing = await archive(
      familyId: familyId,
      actorUid: 'cara',
      itemId: 'nope',
    );
    expect(missing.failureOrNull, isA<NotFound>());
  });

  test('clear all archives stored rows of actor and ignores virtual rows', () async {
    final clearAll = ClearAllInboxItems(
      inbox: fixture.inboxRows,
      families: fixture.families,
      clock: fixture.clock,
    );
    final result = await clearAll(
      familyId: familyId,
      actorUid: 'cara',
      items: <InboxItem>[
        fixture.inboxRows.items['i1']!,
        fixture.inboxRows.items['i2']!,
        InboxItem(
          id: 'v:budget:2026-10',
          toMemberId: 'cara',
          type: VirtualInboxType.budgetAlert,
          refType: 'budget',
          refId: '2026-10',
          createdAt: fixture.clock.nowUtc(),
        ),
      ],
    );

    expect(result.valueOrNull, 1);
    expect(fixture.inboxRows.items['i1']!.isArchived, isTrue);
    expect(fixture.inboxRows.items['i2']!.isArchived, isFalse);
  });

  test('the writer enforces the closed type list and six parameters', () {
    expect(rulesList('inboxTypes'), InboxType.all.toSet());
    NewInboxItem? ok() => InboxWriter.create(
      toMemberId: 'cara',
      type: InboxType.needsCover,
      refType: 'availability',
      refId: 'a1',
    ).valueOrNull;
    expect(ok(), isNotNull);
    expect(
      InboxWriter.create(
        toMemberId: 'cara',
        type: 'spam',
        refType: 'x',
        refId: 'a1',
      ).failureOrNull,
      isA<Validation>(),
    );
    expect(
      InboxWriter.create(
        toMemberId: 'cara',
        type: InboxType.needsCover,
        refType: 'x',
        refId: 'a1',
        params: {for (var i = 0; i < 7; i++) 'k$i': 'v'},
      ).failureOrNull,
      isA<Validation>(),
    );
  });

  test('every row the real port builds is a valid inbox shape', () {
    const port = ChoresInboxPort();
    final rows = <NewInboxItem?>[
      port.swapRequested(
        requestId: 'r',
        toMemberId: 'a',
        choreName: 'n',
        dateKey: 'd',
        fromMemberId: 'b',
        cover: true,
      ),
      port.swapResult(
        requestId: 'r',
        toMemberId: 'a',
        choreName: 'n',
        dateKey: 'd',
        outcome: 'accepted',
        byMemberId: 'b',
      ),
      port.needsCover(
        availabilityId: 'a',
        toMemberId: 'a',
        absentMemberId: 'b',
        count: 2,
        from: 'x',
        to: 'y',
      ),
      port.absenceDecision(
        availabilityId: 'a',
        toMemberId: 'a',
        status: 'active',
        byMemberId: 'b',
      ),
      port.choreReopened(
        occurrenceId: 'o',
        toMemberId: 'a',
        choreName: 'n',
        dateKey: 'd',
        actorId: 'b',
      ),
      port.commentAttention(
        occurrenceId: 'o',
        toMemberId: 'a',
        choreName: 'n',
        dateKey: 'd',
        authorId: 'b',
      ),
    ];
    for (final item in rows) {
      expect(InboxType.all, contains(item!.type));
      expect(item.params.length, lessThanOrEqualTo(InboxWriter.maxParams));
    }
  });

  test('mapper keys match the rules key lists', () {
    final swap = SwapMappers.toMap(
      NewSwap(
        id: 's',
        occurrenceId: 'o',
        occurrenceDateKey: DateKey(2026, 10, 24),
        kind: SwapKind.swap,
        fromMemberId: 'a',
        toMemberId: 'b',
        reason: 'abc',
        expiresAt: DateTime.utc(2026, 10, 24, 15),
      ),
      actorId: 'a',
      at: DateTime.utc(2026, 10, 24),
    );
    expect(swap.keys.toSet(), rulesList('swapKeys'));
    final change = SwapMappers.changeMap(
      const SwapChange(requestId: 's', status: SwapStatus.accepted),
      actorId: 'b',
      at: DateTime.utc(2026, 10, 24),
    );
    expect(rulesList('swapKeys').containsAll(change.keys), isTrue);
    expect(
      rulesList('inboxKeys').containsAll(
        InboxMappers.readMap(actorId: 'a', at: DateTime.utc(2026)).keys,
      ),
      isTrue,
    );
    expect(
      rulesList('inboxKeys').containsAll(
        InboxMappers.archiveMap(actorId: 'a', at: DateTime.utc(2026)).keys,
      ),
      isTrue,
    );
    expect(rulesList('availabilityKeys').isNotEmpty, isTrue);
    expect(AvailabilityMappers.fromDoc('x', null), isNull);
  });
}
