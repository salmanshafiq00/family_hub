import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/family_date_keys.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/family/domain/family.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/member_role.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';

import '../../support/in_memory_backend.dart';
import '../../support/in_memory_chores_backend.dart';

import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_draft.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// Deterministic ids: `id_1`, `id_2`, …
class SeqIds {
  int _next = 0;

  String call() => 'id_${++_next}';
}

/// The chores test family of road map 3.11: admin `alice`, Household Manager
/// `bob`, members `cara` and `dave`, pending `erin`.  `dave` is the ordinary
/// member a "may not act on somebody else's chore" test uses (alice is an admin
/// and bob a Household Manager, so neither proves the plain-member rule).
///
/// The in-memory [InMemoryBackend] is the family port (it already implements
/// `FamilyRepository`); [FakeChoreSettingsRepository] is the settings port.
/// Later steps extend this file rather than starting a second fixture.
class ChoresFixture {
  ChoresFixture()
    : backend = InMemoryBackend(),
      clock = FakeClock(DateTime.utc(2026, 10, 24, 9)),
      ids = SeqIds() {
    _seedFamily();
  }

  static const String familyId = 'f1';

  final InMemoryBackend backend;
  final FakeClock clock;
  final SeqIds ids;
  final FakeChoreSettingsRepository settings = FakeChoreSettingsRepository();
  final InMemoryChoresBackend chores = InMemoryChoresBackend();
  final InMemoryOccurrenceBackend occurrences = InMemoryOccurrenceBackend();

  void _seedFamily() {
    backend.families[familyId] = const Family(
      id: familyId,
      name: 'Chores family',
    );
    backend.members[familyId] = <String, Member>{
      'alice': _member('alice', MemberRole.admin, MembershipStatus.active),
      'bob': _member('bob', MemberRole.moderator, MembershipStatus.active),
      'cara': _member('cara', MemberRole.member, MembershipStatus.active),
      'dave': _member('dave', MemberRole.member, MembershipStatus.active),
      'erin': _member('erin', MemberRole.member, MembershipStatus.pending),
    };
    backend.adminIds[familyId] = <String>['alice'];
    backend.permissionSettings[familyId] = PermissionSettings.defaults;
    for (final uid in <String>['alice', 'bob', 'cara', 'dave', 'erin']) {
      backend.userFamily[uid] = familyId;
    }
  }

  static Member _member(String uid, MemberRole role, MembershipStatus status) =>
      Member(
        uid: uid,
        role: role,
        status: status,
        fullName: 'Person $uid',
        relationship: 'other',
      );

  /// The family port the use cases ask for permissions through.
  FamilyRepository get families => backend;

  /// The family zone for the generator and the due times.
  FamilyDateKeys get dateKeys => FamilyDateKeys(clock: clock);

  /// The seeded roster as the rotation resolver sees it (Alice, Bob, Cara,
  /// Dave and the pending Erin).
  List<Member> get roster =>
      backend.members[familyId]?.values.toList() ?? const <Member>[];
}

/// A valid draft: daily "wash the dishes", manual assignment, one main slot.
/// Tests override only what they are about.
TemplateDraft aTemplate({
  String nameBn = 'বাসন ধোয়া',
  String? nameEn = 'Wash the dishes',
  String? groupId = 'kitchen',
  Recurrence? recurrence,
  List<TemplateSlot>? slots,
  AssigneeSpec? assignee,
  String instructions = '',
  List<TemplateSubtask>? subtasks,
  int? estimatedMinutes,
  Difficulty difficulty = Difficulty.normal,
  VerificationMode verification = VerificationMode.off,
  ReminderConfig? reminders,
  DateKey? startDate,
  DateKey? endDate,
  int? colorIndex,
  String? iconKey,
}) => TemplateDraft(
  nameBn: nameBn,
  nameEn: nameEn,
  groupId: groupId,
  recurrence: recurrence ?? const DailyRecurrence(),
  slots: slots ?? <TemplateSlot>[aSlot()],
  assignee: assignee ?? AssigneeSpec.manual,
  instructions: instructions,
  subtasks: subtasks ?? const <TemplateSubtask>[],
  estimatedMinutes: estimatedMinutes,
  difficulty: difficulty,
  verification: verification,
  reminders: reminders ?? ReminderConfig.off,
  startDate: startDate ?? DateKey(2026, 10, 1),
  endDate: endDate,
  colorIndex: colorIndex,
  iconKey: iconKey,
);

/// The main slot: due at 09:00 by default.
TemplateSlot aSlot({
  String key = TemplateLimits.mainSlotKey,
  String? labelBn,
  String? labelEn,
  int? dueMinutes = 540,
}) => TemplateSlot(
  key: key,
  labelBn: labelBn,
  labelEn: labelEn,
  dueMinutes: dueMinutes,
);

/// A subtask with a stable id.
TemplateSubtask aSubtask({
  String id = 'step_1',
  String title = 'প্লেট ধোয়া',
  bool required = false,
  String? hint,
}) => TemplateSubtask(id: id, title: title, required: required, hint: hint);

/// A stored rotation version, Saturday week start unless stated (F.2).
RotationVersion aVersion({
  List<String> members = const <String>['alice', 'cara', 'dave'],
  DateKey? from,
  DateKey? anchorDate,
  int anchorIndex = 0,
  CycleUnit cycleUnit = CycleUnit.week,
  int weekStartDay = DateTime.saturday,
}) => RotationVersion(
  from: from ?? DateKey(2026, 9, 1),
  members: members,
  anchorDate: anchorDate ?? DateKey(2026, 10, 3),
  anchorIndex: anchorIndex,
  cycleUnit: cycleUnit,
  weekStartDay: weekStartDay,
);

/// A one-version rotation: the common setup of the rotation tests.
Rotation aRotation({
  List<String> members = const <String>['alice', 'cara', 'dave'],
  DateKey? from,
  DateKey? anchorDate,
  int anchorIndex = 0,
  CycleUnit cycleUnit = CycleUnit.week,
  int weekStartDay = DateTime.saturday,
}) => Rotation(
  versions: <RotationVersion>[
    aVersion(
      members: members,
      from: from,
      anchorDate: anchorDate,
      anchorIndex: anchorIndex,
      cycleUnit: cycleUnit,
      weekStartDay: weekStartDay,
    ),
  ],
);

/// A duty group whose rotation is [rotation].
DutyGroup aDutyGroup({
  String id = 'group_1',
  String nameBn = 'দৈনিক রান্নাঘর ডিউটি',
  String? nameEn = 'Daily kitchen duty',
  int? colorIndex = 1,
  Rotation? rotation,
  bool active = true,
  int sortOrder = 0,
}) => DutyGroup(
  id: id,
  nameBn: nameBn,
  nameEn: nameEn,
  colorIndex: colorIndex,
  rotation: rotation ?? aRotation(),
  active: active,
  sortOrder: sortOrder,
);

/// A stored occurrence: daily "wash the dishes", assigned to `cara`, 09:00
/// Dhaka (03:00 UTC) on 2026-10-24. Tests override only what they are about.
ChoreOccurrence anOccurrence({
  String id = 'tpl_1_20261024',
  String templateId = 'tpl_1',
  int templateRev = 1,
  String? slotKey,
  DateKey? dateKey,
  DateTime? dueAt,
  int? dueMinutes = 540,
  String nameBn = 'বাসন ধোয়া',
  String? nameEn = 'Wash the dishes',
  String? groupId = 'kitchen',
  String instructions = '',
  List<TemplateSubtask>? subtasks,
  Difficulty difficulty = Difficulty.normal,
  int? estimatedMinutes,
  VerificationMode verification = VerificationMode.off,
  OccurrenceStatus status = OccurrenceStatus.scheduled,
  String? plannedAssigneeId = 'cara',
  String? assigneeId = 'cara',
  String? coverForId,
  AssignmentSource assignmentSource = AssignmentSource.manual,
  bool needsCover = false,
  Map<String, SubtaskDone>? subtaskDone,
  DateTime? completedAt,
  String? completedBy,
  DateTime? verifiedAt,
  String? verifiedBy,
  int reopenCount = 0,
  CompletionException? exception,
  SkipReason? skipReason,
  bool needsAttention = false,
  DateTime? lastCommentAt,
  DateTime? deletedAt,
  String? deletedBy,
}) {
  final day = dateKey ?? DateKey(2026, 10, 24);
  return ChoreOccurrence(
    id: id,
    templateId: templateId,
    templateRev: templateRev,
    slotKey: slotKey,
    dateKey: day,
    monthKey: day.monthKey,
    dueAt: dueAt ?? DateTime.utc(day.year, day.month, day.day, 3),
    dueMinutes: dueMinutes,
    nameBn: nameBn,
    nameEn: nameEn,
    groupId: groupId,
    instructions: instructions,
    subtasks: subtasks ?? const <TemplateSubtask>[],
    difficulty: difficulty,
    estimatedMinutes: estimatedMinutes,
    verification: verification,
    status: status,
    plannedAssigneeId: plannedAssigneeId,
    assigneeId: assigneeId,
    coverForId: coverForId,
    assignmentSource: assignmentSource,
    needsCover: needsCover,
    subtaskDone: subtaskDone ?? const <String, SubtaskDone>{},
    completedAt: completedAt,
    completedBy: completedBy,
    verifiedAt: verifiedAt,
    verifiedBy: verifiedBy,
    reopenCount: reopenCount,
    exception: exception,
    skipReason: skipReason,
    needsAttention: needsAttention,
    lastCommentAt: lastCommentAt,
    deletedAt: deletedAt,
    deletedBy: deletedBy,
  );
}

/// A member with a stable shape, for the disabled/absent cases.
Member aMember({
  String uid = 'cara',
  MemberRole role = MemberRole.member,
  MembershipStatus status = MembershipStatus.active,
  String fullName = 'Person cara',
  String relationship = 'other',
}) => Member(
  uid: uid,
  role: role,
  status: status,
  fullName: fullName,
  relationship: relationship,
);

/// A projected occurrence (a generator draft) with the same defaults as
/// [anOccurrence], so a test can compare the projected and stored views.
OccurrenceDraft anOccurrenceDraft({
  String id = 'tpl_1_20261024',
  String templateId = 'tpl_1',
  int templateRev = 1,
  String? slotKey,
  DateKey? dateKey,
  DateTime? dueAt,
  int? dueMinutes = 540,
  String nameBn = 'বাসন ধোয়া',
  String? nameEn = 'Wash the dishes',
  String? groupId = 'kitchen',
  String instructions = '',
  List<TemplateSubtask>? subtasks,
  Difficulty difficulty = Difficulty.normal,
  int? estimatedMinutes,
  VerificationMode verification = VerificationMode.off,
  String? plannedAssigneeId = 'cara',
  String? assigneeId = 'cara',
  AssignmentSource assignmentSource = AssignmentSource.manual,
  bool needsCover = false,
}) => OccurrenceDraft(
  anOccurrence(
    id: id,
    templateId: templateId,
    templateRev: templateRev,
    slotKey: slotKey,
    dateKey: dateKey,
    dueAt: dueAt,
    dueMinutes: dueMinutes,
    nameBn: nameBn,
    nameEn: nameEn,
    groupId: groupId,
    instructions: instructions,
    subtasks: subtasks,
    difficulty: difficulty,
    estimatedMinutes: estimatedMinutes,
    verification: verification,
    plannedAssigneeId: plannedAssigneeId,
    assigneeId: assigneeId,
    assignmentSource: assignmentSource,
    needsCover: needsCover,
  ),
);

/// In-memory [ChoreSettingsRepository] for use-case tests.
class FakeChoreSettingsRepository implements ChoreSettingsRepository {
  FakeChoreSettingsRepository({
    this.settings = ChoreSettings.defaults,
    this.policy = AbsencePolicy.askCover,
  });

  ChoreSettings settings;
  AbsencePolicy policy;
  int saves = 0;
  int policySaves = 0;
  AppFailure? nextFailure;
  final List<AuditEvent> events = <AuditEvent>[];

  @override
  Stream<ChoreSettings> watch(String familyId) => Stream.value(settings);

  @override
  Future<Result<ChoreSettings>> get(String familyId) async =>
      Success<ChoreSettings>(settings);

  @override
  Future<Result<void>> save(
    String familyId,
    ChoreSettings value,
    AuditEvent event,
  ) async {
    saves++;
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      return Failure<void>(failure);
    }
    settings = value;
    events.add(event);
    return const Success<void>(null);
  }

  @override
  Stream<AbsencePolicy> watchAbsencePolicy(String familyId) =>
      Stream.value(policy);

  @override
  Future<Result<AbsencePolicy>> getAbsencePolicy(String familyId) async =>
      Success<AbsencePolicy>(policy);

  @override
  Future<Result<void>> saveAbsencePolicy(
    String familyId,
    AbsencePolicy value,
    AuditEvent event,
  ) async {
    policySaves++;
    final failure = nextFailure;
    if (failure != null) {
      nextFailure = null;
      return Failure<void>(failure);
    }
    policy = value;
    events.add(event);
    return const Success<void>(null);
  }
}
