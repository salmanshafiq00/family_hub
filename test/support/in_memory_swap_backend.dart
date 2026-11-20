import 'dart:async';

import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_repository.dart';
import 'package:family_hub/features/chores/availability/domain/availability_write_plan.dart';
import 'package:family_hub/features/chores/availability/domain/member_availability.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_repository.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_request.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_write_plan.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_repository.dart';

import 'in_memory_chores_backend.dart';

/// The shared state of the P3-26 fakes: swap requests, absences and the inbox
/// rows and audit entries the plans wrote.
class SwapWorld {
  SwapWorld(this.occurrences);

  final InMemoryOccurrenceBackend occurrences;
  final Map<String, SwapRequest> swapRequests = <String, SwapRequest>{};
  final Map<String, MemberAvailability> absences =
      <String, MemberAvailability>{};
  final List<NewInboxItem> inbox = <NewInboxItem>[];
  final List<NewAudit> audits = <NewAudit>[];

  /// Set to make the next write fail (then cleared).
  AppFailure? nextStageFailure;

  AppFailure? takeFailure() {
    final failure = nextStageFailure;
    nextStageFailure = null;
    return failure;
  }

  SwapRequest toRequest(NewSwap swap, String actorId) => SwapRequest(
    id: swap.id,
    occurrenceId: swap.occurrenceId,
    occurrenceDateKey: swap.occurrenceDateKey,
    kind: swap.kind,
    fromMemberId: swap.fromMemberId,
    toMemberId: swap.toMemberId,
    reason: swap.reason,
    status: SwapStatus.pending,
    expiresAt: swap.expiresAt,
    requestedBy: actorId,
    availabilityId: swap.availabilityId,
  );

  Future<Result<void>> stageOccurrencePart(
    String familyId,
    OccurrenceWritePlan plan,
  ) async {
    final staged = await occurrences.stage(familyId, plan);
    final failure = staged.failureOrNull;
    if (failure != null) return Failure<void>(failure);
    inbox.addAll(plan.inbox);
    audits.addAll(plan.audits);
    return const Success<void>(null);
  }
}

/// In-memory [SwapRepository]. Like Firestore, a status change of a request
/// that is no longer pending is refused (the rules deny it).
class InMemorySwapBackend implements SwapRepository {
  InMemorySwapBackend(this.world);

  final SwapWorld world;
  final List<SwapWritePlan> plans = <SwapWritePlan>[];

  List<SwapRequest> _pending() => <SwapRequest>[
    for (final r in world.swapRequests.values)
      if (r.isPending) r,
  ];

  @override
  Stream<List<SwapRequest>> watchPending(String familyId) =>
      Stream<List<SwapRequest>>.value(_pending());

  @override
  Future<Result<SwapRequest?>> get(String familyId, String requestId) async =>
      Success<SwapRequest?>(world.swapRequests[requestId]);

  @override
  Future<Result<List<SwapRequest>>> listPendingForOccurrence(
    String familyId,
    String occurrenceId,
  ) async => Success<List<SwapRequest>>(<SwapRequest>[
    for (final r in _pending())
      if (r.occurrenceId == occurrenceId) r,
  ]);

  @override
  Future<Result<List<SwapRequest>>> listPending(String familyId) async =>
      Success<List<SwapRequest>>(_pending());

  @override
  Future<Result<List<SwapRequest>>> listExpired(
    String familyId,
    DateTime now,
  ) async => Success<List<SwapRequest>>(<SwapRequest>[
    for (final r in _pending())
      if (r.isExpiredAt(now)) r,
  ]);

  @override
  Future<Result<void>> stage(
    String familyId,
    SwapWritePlan plan, {
    required bool integrity,
  }) async {
    final failure = world.takeFailure();
    if (failure != null) return Failure<void>(failure);
    for (final change in plan.changes) {
      final current = world.swapRequests[change.requestId];
      if (current == null || !current.isPending) {
        return const Failure<void>(PermissionDenied());
      }
    }
    final staged = await world.stageOccurrencePart(familyId, plan.occurrence);
    final stagedFailure = staged.failureOrNull;
    if (stagedFailure != null) return Failure<void>(stagedFailure);
    for (final swap in plan.creates) {
      world.swapRequests[swap.id] = world.toRequest(swap, plan.actorId);
    }
    for (final change in plan.changes) {
      world.swapRequests[change.requestId] = world
          .swapRequests[change.requestId]!
          .withStatus(
            change.status,
            by: plan.actorId,
            at: plan.at,
            responseReason: change.responseReason,
          );
    }
    plans.add(plan);
    return const Success<void>(null);
  }
}

/// In-memory [AvailabilityRepository].
class InMemoryAvailabilityBackend implements AvailabilityRepository {
  InMemoryAvailabilityBackend(this.world);

  final SwapWorld world;
  final List<AvailabilityWritePlan> plans = <AvailabilityWritePlan>[];

  @override
  Stream<List<MemberAvailability>> watchLive(String familyId, DateKey since) =>
      Stream<List<MemberAvailability>>.value(<MemberAvailability>[
        for (final a in world.absences.values)
          if (a.isLive && !a.endDate.isBefore(since)) a,
      ]);

  @override
  Future<Result<MemberAvailability?>> get(String familyId, String id) async =>
      Success<MemberAvailability?>(world.absences[id]);

  @override
  Future<Result<List<MemberAvailability>>> listLiveFor(
    String familyId,
    String memberId,
  ) async => Success<List<MemberAvailability>>(<MemberAvailability>[
    for (final a in world.absences.values)
      if (a.memberId == memberId && a.isLive) a,
  ]);

  @override
  Future<Result<List<MemberAvailability>>> listActive(
    String familyId,
    DateKey since,
  ) async => Success<List<MemberAvailability>>(<MemberAvailability>[
    for (final a in world.absences.values)
      if (a.isActive && !a.endDate.isBefore(since)) a,
  ]);

  @override
  Future<Result<void>> stage(
    String familyId,
    AvailabilityWritePlan plan, {
    required bool integrity,
  }) async {
    final failure = world.takeFailure();
    if (failure != null) return Failure<void>(failure);
    final staged = await world.stageOccurrencePart(familyId, plan.occurrence);
    final stagedFailure = staged.failureOrNull;
    if (stagedFailure != null) return Failure<void>(stagedFailure);
    for (final record in plan.creates) {
      world.absences[record.id] = MemberAvailability(
        id: record.id,
        memberId: record.memberId,
        startDate: record.startDate,
        endDate: record.endDate,
        typeId: record.typeId,
        reason: record.reason,
        status: record.status,
        createdBy: plan.actorId,
      );
    }
    for (final change in plan.changes) {
      final current = world.absences[change.availabilityId];
      if (current == null) continue;
      world.absences[change.availabilityId] = current.withStatus(
        change.status,
        by: plan.actorId,
        at: plan.at,
      );
    }
    for (final swap in plan.swaps) {
      world.swapRequests[swap.id] = world.toRequest(swap, plan.actorId);
    }
    plans.add(plan);
    return const Success<void>(null);
  }
}

/// In-memory [InboxRepository] with seeded rows.
class InMemoryInboxBackend implements InboxRepository {
  final Map<String, InboxItem> items = <String, InboxItem>{};

  @override
  Stream<List<InboxItem>> watchMine(String familyId, String memberId) =>
      Stream<List<InboxItem>>.value(<InboxItem>[
        for (final i in items.values)
          if (i.toMemberId == memberId) i,
      ]);

  @override
  Future<Result<InboxItem?>> get(String familyId, String itemId) async =>
      Success<InboxItem?>(items[itemId]);

  @override
  Future<Result<void>> markRead(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  }) async {
    for (final id in ids) {
      final item = items[id];
      if (item != null) items[id] = item.copyWith(readAt: at);
    }
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> archive(
    String familyId, {
    required String actorId,
    required String id,
    required DateTime at,
  }) async {
    final item = items[id];
    if (item != null) items[id] = item.copyWith(archivedAt: at);
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> archiveAll(
    String familyId, {
    required String actorId,
    required List<String> ids,
    required DateTime at,
  }) async {
    for (final id in ids) {
      final item = items[id];
      if (item != null) items[id] = item.copyWith(archivedAt: at);
    }
    return const Success<void>(null);
  }
}
