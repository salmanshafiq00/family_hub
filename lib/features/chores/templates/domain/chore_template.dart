import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// The content of a chore template, WITHOUT its identity and bookkeeping.
///
/// The editor builds one of these, the validator checks it, and the use cases
/// turn it into a [ChoreTemplate] (create), merge it into an existing one
/// (update) or copy it (duplicate). Keeping the content apart from `id`,
/// `revision`, `sortOrder`, `builtIn` and `seedKey` is what makes it impossible
/// for an editor to change those by accident.
final class TemplateDraft {
  const TemplateDraft({
    required this.nameBn,
    required this.recurrence,
    required this.startDate,
    this.nameEn,
    this.groupId,
    this.slots = const <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey),
    ],
    this.assignee = AssigneeSpec.manual,
    this.instructions = '',
    this.subtasks = const <TemplateSubtask>[],
    this.estimatedMinutes,
    this.difficulty = Difficulty.normal,
    this.verification = VerificationMode.off,
    this.reminders = ReminderConfig.off,
    this.endDate,
    this.colorIndex,
    this.iconKey,
  });

  final String nameBn;
  final String? nameEn;

  /// A group id; an unknown one is tolerated (the catalogs fall back to
  /// "other").
  final String? groupId;

  final Recurrence recurrence;

  /// At least one slot; the first is always `main` (D-P3-3).
  final List<TemplateSlot> slots;

  final AssigneeSpec assignee;
  final String instructions;
  final List<TemplateSubtask> subtasks;
  final int? estimatedMinutes;
  final Difficulty difficulty;
  final VerificationMode verification;
  final ReminderConfig reminders;

  /// Inclusive active span. [startDate] is required; [endDate] may be null
  /// (runs forever).
  final DateKey startDate;
  final DateKey? endDate;

  final int? colorIndex;
  final String? iconKey;

  TemplateDraft copyWith({
    String? nameBn,
    String? nameEn,
    String? groupId,
    Recurrence? recurrence,
    List<TemplateSlot>? slots,
    AssigneeSpec? assignee,
    String? instructions,
    List<TemplateSubtask>? subtasks,
    int? estimatedMinutes,
    Difficulty? difficulty,
    VerificationMode? verification,
    ReminderConfig? reminders,
    DateKey? startDate,
    DateKey? endDate,
    int? colorIndex,
    String? iconKey,
    bool clearGroup = false,
    bool clearNameEn = false,
    bool clearEndDate = false,
    bool clearEstimatedMinutes = false,
    bool clearColorIndex = false,
    bool clearIconKey = false,
  }) => TemplateDraft(
    nameBn: nameBn ?? this.nameBn,
    nameEn: clearNameEn ? null : (nameEn ?? this.nameEn),
    groupId: clearGroup ? null : (groupId ?? this.groupId),
    recurrence: recurrence ?? this.recurrence,
    slots: slots ?? this.slots,
    assignee: assignee ?? this.assignee,
    instructions: instructions ?? this.instructions,
    subtasks: subtasks ?? this.subtasks,
    estimatedMinutes: clearEstimatedMinutes
        ? null
        : (estimatedMinutes ?? this.estimatedMinutes),
    difficulty: difficulty ?? this.difficulty,
    verification: verification ?? this.verification,
    reminders: reminders ?? this.reminders,
    startDate: startDate ?? this.startDate,
    endDate: clearEndDate ? null : (endDate ?? this.endDate),
    colorIndex: clearColorIndex ? null : (colorIndex ?? this.colorIndex),
    iconKey: clearIconKey ? null : (iconKey ?? this.iconKey),
  );

  @override
  bool operator ==(Object other) =>
      other is TemplateDraft &&
      other.nameBn == nameBn &&
      other.nameEn == nameEn &&
      other.groupId == groupId &&
      other.recurrence == recurrence &&
      _sameList(other.slots, slots) &&
      other.assignee == assignee &&
      other.instructions == instructions &&
      _sameList(other.subtasks, subtasks) &&
      other.estimatedMinutes == estimatedMinutes &&
      other.difficulty == difficulty &&
      other.verification == verification &&
      other.reminders == reminders &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.colorIndex == colorIndex &&
      other.iconKey == iconKey;

  @override
  int get hashCode => Object.hash(
    nameBn,
    nameEn,
    groupId,
    recurrence,
    Object.hashAll(slots),
    assignee,
    instructions,
    Object.hashAll(subtasks),
    estimatedMinutes,
    difficulty,
    verification,
    reminders,
    startDate,
    endDate,
    colorIndex,
    iconKey,
  );

  static bool _sameList<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => 'TemplateDraft($nameBn, ${recurrence.kind.id})';
}

/// A stored chore template (`choreTemplates/{id}`), road map 3.2.
///
/// Documents are never deleted: pause (active = false), resume, or archive
/// (active = false + [archivedAt]). Every write bumps [revision] by exactly one
/// (the P3-08 rules enforce it, lifecycle changes included); occurrences
/// snapshot [revision] so a later edit can tell which plan they came from.
final class ChoreTemplate {
  const ChoreTemplate({
    required this.id,
    required this.draft,
    this.revision = 1,
    this.active = true,
    this.archivedAt,
    this.sortOrder = 0,
    this.builtIn = false,
    this.seedKey,
  });

  final String id;
  final TemplateDraft draft;

  /// Starts at 1 and increases by one on every write (the P3-08 rule enforces
  /// it; lifecycle changes such as pause/archive bump it too).
  final int revision;

  /// False when paused or archived; paused templates generate no occurrences.
  final bool active;

  /// Set only by Archive.
  final DateTime? archivedAt;

  final int sortOrder;

  /// Seeded by a starter pack (P3-19); such a template is editable and can be
  /// switched off, never deleted.
  final bool builtIn;

  /// The starter-pack key (`tpl_<seedKey>` id); null for family-made templates.
  final String? seedKey;

  bool get isArchived => archivedAt != null;

  /// True when the template should generate new occurrences.
  bool get isGenerating => active && !isArchived;

  ChoreTemplate copyWith({
    TemplateDraft? draft,
    int? revision,
    bool? active,
    DateTime? archivedAt,
    int? sortOrder,
    bool? builtIn,
    String? seedKey,
    bool clearArchivedAt = false,
    bool clearSeedKey = false,
  }) => ChoreTemplate(
    id: id,
    draft: draft ?? this.draft,
    revision: revision ?? this.revision,
    active: active ?? this.active,
    archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    sortOrder: sortOrder ?? this.sortOrder,
    builtIn: builtIn ?? this.builtIn,
    seedKey: clearSeedKey ? null : (seedKey ?? this.seedKey),
  );

  /// A COPY with a new identity: a new id, `revision = 1`, not built-in and no
  /// seed key. The draft (and therefore the schedule) is unchanged.
  ChoreTemplate copyAsNew({
    required String newId,
    required TemplateDraft newDraft,
    required int sortOrder,
  }) => ChoreTemplate(
    id: newId,
    draft: newDraft,
    revision: 1,
    sortOrder: sortOrder,
  );

  @override
  bool operator ==(Object other) =>
      other is ChoreTemplate &&
      other.id == id &&
      other.draft == draft &&
      other.revision == revision &&
      other.active == active &&
      other.archivedAt == archivedAt &&
      other.sortOrder == sortOrder &&
      other.builtIn == builtIn &&
      other.seedKey == seedKey;

  @override
  int get hashCode => Object.hash(
    id,
    draft,
    revision,
    active,
    archivedAt,
    sortOrder,
    builtIn,
    seedKey,
  );

  @override
  String toString() =>
      'ChoreTemplate($id, rev $revision, active: $active, '
      '${draft.nameBn})';
}
