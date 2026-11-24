import 'dart:async';

import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/tx_runner.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/chores/starter_packs/data/firestore_starter_item_repository.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_mapping.dart';
import 'package:flutter_test/flutter_test.dart';

/// Counts commits and how many starter items each one added, and can make one
/// commit fail (a rules denial) without writing anything.
class _SpyTxRunner implements TxRunner {
  _SpyTxRunner(this.inner, this.familyId);

  final FakeTxRunner inner;
  final String familyId;
  int calls = 0;
  int? failOnCall;
  final List<int> itemsAddedPerCall = <int>[];

  int get _itemCount {
    final prefix = '${FirestorePaths.starterPackItems(familyId)}/';
    return inner.store.keys.where((k) => k.startsWith(prefix)).length;
  }

  @override
  Future<void> runBatch(
    FutureOr<void> Function(BatchContext batch) action,
  ) async {
    calls++;
    if (calls == failOnCall) inner.failNextBatchWith = StateError('denied');
    final before = _itemCount;
    await inner.runBatch(action);
    itemsAddedPerCall.add(_itemCount - before);
  }

  @override
  Future<T> runTransaction<T>(
    FutureOr<T> Function(TransactionContext tx) action, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) => inner.runTransaction<T>(
    action,
    timeout: timeout,
    maxAttempts: maxAttempts,
  );
}

void main() {
  const familyId = 'fam1';
  final event = AuditEvent(
    id: 'evt1',
    type: AuditEventType.choresSettingsUpdated,
    actorId: 'u1',
    refType: AuditRefType.choreSettings,
    refId: familyId,
    at: DateTime.utc(2026, 11, 24),
    params: const <String, String>{'name': 'starter_list'},
  );
  final items = [
    for (var i = 0; i < familyPdfPack.templates.length; i++)
      familyPdfPack.templates[i].toItem(sortOrder: i),
  ];

  late FakeTxRunner fake;
  late _SpyTxRunner spy;
  late FirestoreStarterItemRepository repo;

  setUp(() {
    fake = FakeTxRunner();
    spy = _SpyTxRunner(fake, familyId);
    repo = FirestoreStarterItemRepository(tx: spy, clock: const SystemClock());
  });

  test('customise writes every item in small commits, audit last', () async {
    final result = await repo.replaceAll(
      familyId,
      items: items,
      removeIds: const <String>[],
      event: event,
    );

    expect(result.failureOrNull, isNull);
    expect(spy.itemsAddedPerCall.reduce((a, b) => a + b), items.length);
    expect(
      spy.itemsAddedPerCall.every((n) => n <= kStarterWriteChunk),
      isTrue,
      reason: 'one request must stay under the rules expression budget',
    );
    expect(spy.calls, greaterThan(1));
    expect(
      fake.store.containsKey(FirestorePaths.activityDoc(familyId, 'evt1')),
      isTrue,
    );
  });

  test('a refused commit leaves no half list and no audit entry', () async {
    spy.failOnCall = 3;

    final result = await repo.replaceAll(
      familyId,
      items: items,
      removeIds: const <String>[],
      event: event,
    );

    expect(result.failureOrNull, isNotNull);
    expect(spy._itemCount, 0);
    expect(
      fake.store.containsKey(FirestorePaths.activityDoc(familyId, 'evt1')),
      isFalse,
    );
  });

  test('reset removes the items and logs once', () async {
    await repo.replaceAll(
      familyId,
      items: items,
      removeIds: const <String>[],
      event: event,
    );
    final result = await repo.replaceAll(
      familyId,
      items: const [],
      removeIds: [for (final i in items) i.id],
      event: event,
    );

    expect(result.failureOrNull, isNull);
    expect(spy._itemCount, 0);
  });
}
