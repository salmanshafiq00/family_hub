import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/achievements/domain/default_engagement_settings.dart';
import 'package:family_hub/features/chores/achievements/domain/member_stats.dart';
import 'package:family_hub/features/chores/achievements/domain/member_stats_repository.dart';
import 'package:family_hub/features/chores/achievements/domain/public_stats.dart';
import 'package:family_hub/features/chores/achievements/domain/public_stats_repository.dart';
import 'package:family_hub/features/chores/achievements/domain/usecases/sync_member_stats.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/member_role.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/in_memory_backend.dart';
import '../domain/engagement_test_support.dart';

/// P4-25 item 3: one member, two phones.
///
/// Nothing in the app holds a lock while it syncs stats, so the two paths have
/// to converge on the stored document. They do: a second phone that reads what
/// the first wrote recomputes the same numbers and writes nothing, and a phone
/// that arrives with one more chore adds exactly one, because the month is
/// rebuilt from the occurrences instead of added to. What is still open is the
/// interleaving in the last test, where a phone writes from a read taken before
/// the other one wrote; this test documents that interleaving.
void main() {
  const familyId = 'family';
  const memberId = 'member';
  final today = DateKey(2026, 11, 5);
  final settings = defaultEngagementSettings(
    startedOn: DateKey(2026, 10, 1),
    graceMinutes: 30,
  );
  final items = <ChoreOccurrence>[engagementOccurrence(day: today)];

  late _SharedStore store;
  late _SharedPublic publicStats;

  setUp(() {
    store = _SharedStore();
    publicStats = _SharedPublic(store);
  });

  /// A phone. [octoberRows] is what its October read returns, which is how a
  /// stale or partial month cache is simulated.
  SyncMemberStats phone({MemberStatsRepository? stats, int octoberRows = 2}) =>
      SyncMemberStats(
        families: _family(),
        stats: stats ?? store,
        publicStats: publicStats,
        previousMonthItemsLoader: (familyId, month) async =>
            Success<List<ChoreOccurrence>>(
              month == MonthKey(2026, 10)
                  ? <ChoreOccurrence>[
                      for (var day = 12; day < 12 + octoberRows; day++)
                        engagementOccurrence(
                          id: 'oct$day',
                          day: DateKey(2026, 10, day),
                        ),
                    ]
                  : const <ChoreOccurrence>[],
            ),
      );

  Future<Result<MemberStats?>> sync(
    SyncMemberStats target, {
    required List<ChoreOccurrence> currentMonthItems,
  }) => target.call(
    familyId: familyId,
    memberId: memberId,
    today: today,
    settings: settings,
    currentMonthItems: currentMonthItems,
  );

  test('the second phone converges and writes nothing', () async {
    final first = await sync(phone(), currentMonthItems: items);
    expect(first.failureOrNull, isNull);
    final writesAfterFirst = store.writes;

    final second = await sync(phone(), currentMonthItems: items);
    expect(second.failureOrNull, isNull);
    expect(second.valueOrNull, first.valueOrNull);
    expect(
      store.writes,
      writesAfterFirst,
      reason: 'a phone with nothing new leaves the document alone',
    );
    expect(store.current?.monthly['2026-10']?.isFinal, isTrue);
  });

  test('a late phone adds the new chore once, never twice', () async {
    await sync(phone(), currentMonthItems: items);

    final late = await sync(
      phone(),
      currentMonthItems: <ChoreOccurrence>[
        ...items,
        engagementOccurrence(id: 'nov4', day: DateKey(2026, 11, 4)),
      ],
    );

    expect(late.failureOrNull, isNull);
    expect(late.valueOrNull?.monthly['2026-11']?.done, 2);
    expect(late.valueOrNull?.completedTotal, 4);
    expect(store.current?.completedTotal, 4);
  });

  test('the phone that writes last wins, even from a stale read', () async {
    final staleRead = store.current;
    await sync(phone(), currentMonthItems: items);
    final afterFirstPhone = store.current!;
    expect(afterFirstPhone.completedTotal, 3);

    final late = await sync(
      phone(stats: _StaleReader(store, staleRead), octoberRows: 1),
      currentMonthItems: items,
    );

    expect(late.failureOrNull, isNull);
    expect(store.current, late.valueOrNull);
    // Not the behaviour we want: the stale phone re-added only what it could
    // see, so the document lost the October chore the first phone finalised.
    // Phase 5 owes this write a guard.
    expect(store.current?.completedTotal, 2);
  });
}

InMemoryBackend _family() =>
    InMemoryBackend()
      ..members['family'] = <String, Member>{
        'member': const Member(
          uid: 'member',
          role: MemberRole.member,
          status: MembershipStatus.active,
          fullName: 'Member',
          relationship: 'other',
        ),
      };

/// One stored document, seen by both phones, counting every write.
final class _SharedStore implements MemberStatsRepository {
  MemberStats? current;
  PublicStats? publicCard;
  int writes = 0;

  @override
  Stream<MemberStats?> watch(
    String familyId,
    String memberId, {
    required DateKey defaultStartedOn,
  }) => Stream<MemberStats?>.value(current);

  @override
  Future<Result<MemberStats?>> get(
    String familyId,
    String memberId, {
    required DateKey defaultStartedOn,
  }) async => Success<MemberStats?>(current);

  @override
  Future<Result<void>> save(
    String familyId,
    String memberId,
    MemberStats stats, {
    required PublicStats? publicStats,
  }) async {
    writes++;
    current = stats;
    publicCard = publicStats;
    return const Success<void>(null);
  }

  @override
  Future<Result<bool>> claimCelebration(
    String familyId,
    String memberId, {
    required DateKey dateKey,
    required DateKey defaultStartedOn,
  }) async {
    final previous = current ?? MemberStats.empty(startedOn: defaultStartedOn);
    final celebrated = previous.lastCelebratedDateKey;
    if (celebrated != null && !dateKey.isAfter(celebrated)) {
      return const Success<bool>(false);
    }
    writes++;
    current = previous.copyWith(lastCelebratedDateKey: dateKey);
    return const Success<bool>(true);
  }
}

/// The second phone's repository: every read comes from the snapshot it took
/// when it opened, while writes still land on the shared document - a blind
/// `set`, exactly like the Firestore one.
final class _StaleReader implements MemberStatsRepository {
  _StaleReader(this._store, this._snapshot);

  final _SharedStore _store;
  final MemberStats? _snapshot;

  @override
  Stream<MemberStats?> watch(
    String familyId,
    String memberId, {
    required DateKey defaultStartedOn,
  }) => _store.watch(familyId, memberId, defaultStartedOn: defaultStartedOn);

  @override
  Future<Result<MemberStats?>> get(
    String familyId,
    String memberId, {
    required DateKey defaultStartedOn,
  }) async => Success<MemberStats?>(_snapshot);

  @override
  Future<Result<void>> save(
    String familyId,
    String memberId,
    MemberStats stats, {
    required PublicStats? publicStats,
  }) => _store.save(familyId, memberId, stats, publicStats: publicStats);

  @override
  Future<Result<bool>> claimCelebration(
    String familyId,
    String memberId, {
    required DateKey dateKey,
    required DateKey defaultStartedOn,
  }) => _store.claimCelebration(
    familyId,
    memberId,
    dateKey: dateKey,
    defaultStartedOn: defaultStartedOn,
  );
}

final class _SharedPublic implements PublicStatsRepository {
  _SharedPublic(this._store);

  final _SharedStore _store;

  @override
  Stream<PublicStats?> watch(String familyId, String memberId) =>
      Stream<PublicStats?>.value(_store.publicCard);

  @override
  Stream<Map<String, PublicStats>> watchFamily(String familyId) =>
      Stream<Map<String, PublicStats>>.value(const <String, PublicStats>{});

  @override
  Future<Result<PublicStats?>> get(String familyId, String memberId) async =>
      Success<PublicStats?>(_store.publicCard);
}
