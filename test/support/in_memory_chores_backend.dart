import 'dart:async';

import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/generation_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/occurrence_patch_apply.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';

/// In-memory `choreTemplates` for use-case tests (road map P3-07).
///
/// Later steps add their own collections here (duty groups in P3-10,
/// occurrences in P3-13, …) rather than starting a second backend, so a test
/// can exercise a flow across several repositories with one fixture.
class InMemoryChoresBackend implements TemplateRepository {
  /// `familyId -> templateId -> template`.
  final Map<String, Map<String, ChoreTemplate>> templates = {};

  /// `dutyGroups` lives in its own backend because its port has the same
  /// method names with different types (P3-09).
  final InMemoryDutyGroupBackend dutyGroups = InMemoryDutyGroupBackend();

  final List<AuditEvent> events = <AuditEvent>[];

  /// Set to make the next [save] fail (the failure is then cleared).
  AppFailure? nextSaveFailure;

  /// Set to make the next [get] / [list] fail.
  AppFailure? nextReadFailure;

  /// Number of applied writes.
  int writes = 0;

  final Map<String, StreamController<void>> _changes = {};

  StreamController<void> _controller(String familyId) =>
      _changes.putIfAbsent(familyId, () => StreamController<void>.broadcast());

  List<ChoreTemplate> _sorted(String familyId) {
    final all = templates[familyId]?.values.toList() ?? <ChoreTemplate>[];
    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }

  /// Notifies every listener of [familyId] (the repositories call this after a
  /// write; a test may call it to simulate a remote change).
  void notify(String familyId) => _controller(familyId).add(null);

  @override
  Stream<List<TemplateRecord>> watch(String familyId) async* {
    yield _records(familyId);
    await for (final _ in _controller(familyId).stream) {
      yield _records(familyId);
    }
  }

  List<TemplateRecord> _records(String familyId) => <TemplateRecord>[
    for (final template in _sorted(familyId))
      TemplateRecord(template: template),
  ];

  @override
  Future<Result<List<TemplateRecord>>> list(String familyId) async {
    final failure = nextReadFailure;
    if (failure != null) {
      nextReadFailure = null;
      return Failure<List<TemplateRecord>>(failure);
    }
    return Success<List<TemplateRecord>>(_records(familyId));
  }

  @override
  Future<Result<TemplateRecord?>> get(
    String familyId,
    String templateId,
  ) async {
    final failure = nextReadFailure;
    if (failure != null) {
      nextReadFailure = null;
      return Failure<TemplateRecord?>(failure);
    }
    final template = templates[familyId]?[templateId];
    return Success<TemplateRecord?>(
      template == null ? null : TemplateRecord(template: template),
    );
  }

  @override
  Future<Result<void>> save(
    String familyId,
    ChoreTemplate template,
    AuditEvent event,
  ) async {
    final failure = nextSaveFailure;
    if (failure != null) {
      nextSaveFailure = null;
      return Failure<void>(failure);
    }
    writes++;
    (templates[familyId] ??= <String, ChoreTemplate>{})[template.id] = template;
    events.add(event);
    notify(familyId);
    return const Success<void>(null);
  }
}

/// In-memory `dutyGroups` for use-case tests (road map P3-09).
///
/// It lives beside [InMemoryChoresBackend] instead of on it because both ports
/// declare `watch`/`list`/`get`/`save` with different element types; a test
/// still reaches it through `fixture.chores.dutyGroups`, so one fixture serves
/// the whole chores flow.
class InMemoryDutyGroupBackend implements DutyGroupRepository {
  /// `familyId -> groupId -> group`.
  final Map<String, Map<String, DutyGroup>> groups = {};

  final List<AuditEvent> events = <AuditEvent>[];

  /// Set to make the next [save] / [saveRotation] fail (then cleared).
  AppFailure? nextSaveFailure;

  /// Set to make the next [get] / [list] fail (then cleared).
  AppFailure? nextReadFailure;

  /// Number of applied everyday writes.
  int writes = 0;

  /// Number of applied integrity (rotation) writes.
  int rotationWrites = 0;

  final Map<String, StreamController<void>> _changes = {};

  StreamController<void> _controller(String familyId) =>
      _changes.putIfAbsent(familyId, () => StreamController<void>.broadcast());

  List<DutyGroup> _sorted(String familyId) {
    final all = groups[familyId]?.values.toList() ?? <DutyGroup>[];
    all.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return all;
  }

  /// Notifies every listener of [familyId].
  void notify(String familyId) => _controller(familyId).add(null);

  @override
  Stream<List<DutyGroup>> watch(String familyId) async* {
    yield _sorted(familyId);
    await for (final _ in _controller(familyId).stream) {
      yield _sorted(familyId);
    }
  }

  @override
  Future<Result<List<DutyGroup>>> list(String familyId) async {
    final failure = nextReadFailure;
    if (failure != null) {
      nextReadFailure = null;
      return Failure<List<DutyGroup>>(failure);
    }
    return Success<List<DutyGroup>>(_sorted(familyId));
  }

  @override
  Future<Result<DutyGroup?>> get(String familyId, String groupId) async {
    final failure = nextReadFailure;
    if (failure != null) {
      nextReadFailure = null;
      return Failure<DutyGroup?>(failure);
    }
    return Success<DutyGroup?>(groups[familyId]?[groupId]);
  }

  @override
  Future<Result<void>> save(
    String familyId,
    DutyGroup group,
    AuditEvent event,
  ) => _write(familyId, group, event, rotation: false);

  @override
  Future<Result<void>> saveRotation(
    String familyId,
    DutyGroup group,
    AuditEvent event,
  ) => _write(familyId, group, event, rotation: true);

  Future<Result<void>> _write(
    String familyId,
    DutyGroup group,
    AuditEvent event, {
    required bool rotation,
  }) async {
    final failure = nextSaveFailure;
    if (failure != null) {
      nextSaveFailure = null;
      return Failure<void>(failure);
    }
    if (rotation) {
      rotationWrites++;
    } else {
      writes++;
    }
    (groups[familyId] ??= <String, DutyGroup>{})[group.id] = group;
    events.add(event);
    notify(familyId);
    return const Success<void>(null);
  }
}

/// In-memory `choreOccurrences` + `settings/choreGeneration` (road map P3-12).
///
/// It applies the whole [OccurrenceWritePlan] the use cases build, so a test
/// can exercise generation, regeneration and replanning without Firestore.
/// [beforeStage] lets a test inject another device's writes between the id read
/// and the batch, which is exactly the race the use cases retry once.
class InMemoryOccurrenceBackend
    implements OccurrenceRepository, GenerationMarkerRepository {
  /// `familyId -> occurrenceId -> occurrence`.
  final Map<String, Map<String, ChoreOccurrence>> occurrences = {};

  /// `familyId -> through` (the generation marker).
  final Map<String, DateKey> markers = {};

  /// Every plan that reached [stage] / [stageIntegrity].
  final List<OccurrenceWritePlan> plans = <OccurrenceWritePlan>[];

  /// Every audit entry carried by those plans.
  final List<NewAudit> audits = <NewAudit>[];

  /// Runs before a batch is applied (a test may write a competing document or
  /// set [nextStageFailure] to simulate the server).
  void Function(String familyId, OccurrenceWritePlan plan)? beforeStage;

  /// Set to make the next batch fail (the failure is then cleared).
  AppFailure? nextStageFailure;

  /// Set to make the next marker write fail.
  AppFailure? nextMarkerFailure;

  /// When true, the next [idsInRange] pretends the range is empty (a device
  /// that read before the other one wrote).
  bool hideExistingIdsOnce = false;

  /// When true, a create on an id that already exists fails the way the RULES
  /// do (`permission-denied`), not with `already_exists`: Firestore evaluates a
  /// create on an existing document as an update, and no update rule accepts a
  /// fresh document. B-07 depends on that difference.
  bool createsDeniedAsPermission = false;

  int stageAttempts = 0;
  int conflicts = 0;
  int writes = 0;
  int integrityWrites = 0;
  int markerWrites = 0;

  final Map<String, StreamController<void>> _changes = {};

  StreamController<void> _controller(String familyId) =>
      _changes.putIfAbsent(familyId, () => StreamController<void>.broadcast());

  Map<String, ChoreOccurrence> _docs(String familyId) =>
      occurrences.putIfAbsent(familyId, () => <String, ChoreOccurrence>{});

  void notify(String familyId) => _controller(familyId).add(null);

  List<ChoreOccurrence> _inRange(String familyId, DateKey from, DateKey to) {
    final docs = <ChoreOccurrence>[
      for (final occurrence in _docs(familyId).values)
        if (!occurrence.dateKey.isBefore(from) &&
            !occurrence.dateKey.isAfter(to))
          occurrence,
    ];
    docs.sort((a, b) {
      final byDate = a.dateKey.compareTo(b.dateKey);
      return byDate != 0
          ? byDate
          : (a.slotKey ?? '').compareTo(b.slotKey ?? '');
    });
    return docs;
  }

  @override
  Stream<List<ChoreOccurrence>> watchRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) async* {
    yield _inRange(familyId, from, to);
    await for (final _ in _controller(familyId).stream) {
      yield _inRange(familyId, from, to);
    }
  }

  @override
  Stream<ChoreOccurrence?> watchOne(
    String familyId,
    String occurrenceId,
  ) async* {
    ChoreOccurrence? live() {
      final found = _docs(familyId)[occurrenceId];
      return found == null || found.isDeleted ? null : found;
    }

    yield live();
    await for (final _ in _controller(familyId).stream) {
      yield live();
    }
  }

  @override
  Future<Result<ChoreOccurrence?>> get(
    String familyId,
    String occurrenceId,
  ) async {
    final found = _docs(familyId)[occurrenceId];
    return Success<ChoreOccurrence?>(
      found == null || found.isDeleted ? null : found,
    );
  }

  @override
  Future<Result<List<String>>> idsInRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) async {
    if (hideExistingIdsOnce) {
      hideExistingIdsOnce = false;
      return const Success<List<String>>(<String>[]);
    }
    return Success<List<String>>(<String>[
      for (final occurrence in _inRange(familyId, from, to)) occurrence.id,
    ]);
  }

  @override
  Future<Result<List<ChoreOccurrence>>> listRange(
    String familyId, {
    required DateKey from,
    required DateKey to,
  }) async => Success<List<ChoreOccurrence>>(_inRange(familyId, from, to));

  @override
  Future<Result<List<ChoreOccurrence>>> listByTemplate(
    String familyId,
    String templateId, {
    required DateKey from,
  }) async {
    final docs = <ChoreOccurrence>[
      for (final occurrence in _docs(familyId).values)
        if (occurrence.templateId == templateId &&
            !occurrence.dateKey.isBefore(from))
          occurrence,
    ];
    docs.sort((a, b) => a.dateKey.compareTo(b.dateKey));
    return Success<List<ChoreOccurrence>>(docs);
  }

  @override
  Future<Result<void>> stage(String familyId, OccurrenceWritePlan plan) =>
      _apply(familyId, plan, integrity: false);

  @override
  Future<Result<void>> stageIntegrity(
    String familyId,
    OccurrenceWritePlan plan,
  ) => _apply(familyId, plan, integrity: true);

  Future<Result<void>> _apply(
    String familyId,
    OccurrenceWritePlan plan, {
    required bool integrity,
  }) async {
    stageAttempts++;
    beforeStage?.call(familyId, plan);
    final failure = nextStageFailure;
    if (failure != null) {
      nextStageFailure = null;
      return Failure<void>(failure);
    }

    final docs = _docs(familyId);
    for (final draft in plan.creates) {
      if (docs.containsKey(draft.id)) {
        conflicts++;
        return createsDeniedAsPermission
            ? const Failure<void>(PermissionDenied())
            : const Failure<void>(Conflict(code: 'already_exists'));
      }
    }
    for (final draft in plan.creates) {
      docs[draft.id] = draft.toOccurrence();
    }
    for (final draft in plan.restores) {
      docs[draft.id] = draft.toOccurrence();
    }
    for (final replan in plan.replans) {
      final current = docs[replan.occurrenceId];
      if (current != null) {
        docs[replan.occurrenceId] = _replan(current, replan);
      }
    }
    for (final patch in plan.patches) {
      final current = docs[patch.occurrenceId];
      if (current != null) {
        docs[patch.occurrenceId] = _patch(current, patch);
      }
    }

    for (final event in plan.events) {
      events.add(
        OccurrenceEvent(
          id: event.id,
          occurrenceId: event.occurrenceId,
          type: event.type,
          actorId: plan.actorId,
          at: plan.at,
          fromAssigneeId: event.fromAssigneeId,
          toAssigneeId: event.toAssigneeId,
          reason: event.reason,
          prevCompletedAt: event.prevCompletedAt,
          requestId: event.requestId,
        ),
      );
    }

    plans.add(plan);
    audits.addAll(plan.audits);
    if (integrity) {
      integrityWrites++;
    } else {
      writes++;
    }
    notify(familyId);
    return const Success<void>(null);
  }

  ChoreOccurrence _replan(ChoreOccurrence current, OccurrenceReplan replan) {
    final draft = replan.draft.occurrence;
    var next = current.copyWith(
      templateRev: draft.templateRev,
      dueAt: draft.dueAt,
      dueMinutes: draft.dueMinutes,
      nameBn: draft.nameBn,
      nameEn: draft.nameEn,
      groupId: draft.groupId,
      instructions: draft.instructions,
      subtasks: draft.subtasks,
      difficulty: draft.difficulty,
      estimatedMinutes: draft.estimatedMinutes,
      verification: draft.verification,
    );
    if (replan.recomputeAssignment) {
      next = next.copyWith(
        plannedAssigneeId: draft.plannedAssigneeId,
        assigneeId: draft.assigneeId,
        assignmentSource: draft.assignmentSource,
        needsCover: draft.needsCover,
      );
    }
    return next;
  }

  /// Applies a dotted-key patch exactly like the stored document (P3-14):
  /// only the named keys change, so two patches never overwrite each other.
  ChoreOccurrence _patch(ChoreOccurrence current, OccurrencePatch patch) =>
      applyOccurrencePatch(current, patch);

  @override
  Stream<DateKey?> watchThrough(String familyId) async* {
    yield markers[familyId];
    await for (final _ in _controller(familyId).stream) {
      yield markers[familyId];
    }
  }

  @override
  Stream<List<OccurrenceEvent>> watchEvents(
    String familyId,
    String occurrenceId,
  ) async* {
    yield eventsIn(occurrenceId);
    await for (final _ in _controller(familyId).stream) {
      yield eventsIn(occurrenceId);
    }
  }

  @override
  Stream<List<ChoreOccurrence>> watchVerifyQueue(String familyId) async* {
    List<ChoreOccurrence> queue() => <ChoreOccurrence>[
      for (final occurrence in _docs(familyId).values)
        if (!occurrence.isDeleted &&
            occurrence.status == OccurrenceStatus.completed)
          occurrence,
    ]..sort((a, b) => b.dateKey.compareTo(a.dateKey));

    yield queue();
    await for (final _ in _controller(familyId).stream) {
      yield queue();
    }
  }

  /// Every plan-applied event, for the timeline tests of later steps.
  final List<OccurrenceEvent> events = <OccurrenceEvent>[];

  List<OccurrenceEvent> eventsIn(String occurrenceId) => <OccurrenceEvent>[
    for (final event in events)
      if (event.occurrenceId == occurrenceId) event,
  ];

  @override
  Future<Result<DateKey?>> readThrough(String familyId) async =>
      Success<DateKey?>(markers[familyId]);

  @override
  Future<Result<void>> writeThrough(
    String familyId,
    DateKey through, {
    required String actorId,
  }) async {
    final failure = nextMarkerFailure;
    if (failure != null) {
      nextMarkerFailure = null;
      return Failure<void>(failure);
    }
    markers[familyId] = through;
    markerWrites++;
    return const Success<void>(null);
  }
}
