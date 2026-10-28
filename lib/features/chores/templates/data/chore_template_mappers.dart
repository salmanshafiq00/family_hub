import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/templates/data/rotation_mappers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';

/// Pure functions between [ChoreTemplate] and `choreTemplates/{id}`.
///
/// The map is the single source of truth for the closed `templateKeys()` list
/// and the contract fixture. `toMap` writes the WHOLE document (identity and
/// content), so the P3-08 rule can check `revision` and `seedKey` immutability
/// against the previous version.
///
/// `fromMap` is TOLERANT: a template whose `recurrence.kind` this build does
/// not know (a newer app version wrote it) is still shown - as an INVALID
/// SCHEDULE - instead of crashing the list. [TemplateRecord.invalidSchedule]
/// tells the UI to say so. An out-of-range `colorIndex` falls back to the
/// template's group colour (null).
abstract final class ChoreTemplateMappers {
  static Map<String, dynamic> toMap(
    ChoreTemplate template,
    BaseDocumentMetadata meta,
  ) {
    final d = template.draft;
    return <String, dynamic>{
      'nameBn': d.nameBn,
      'nameEn': d.nameEn,
      'groupId': d.groupId,
      'recurrence': d.recurrence.toMap(),
      'slots': <Map<String, Object?>>[for (final slot in d.slots) slot.toMap()],
      'assignee': d.assignee.toMap(),
      'instructions': d.instructions,
      'subtasks': <Map<String, Object?>>[
        for (final subtask in d.subtasks) subtask.toMap(),
      ],
      'estimatedMinutes': d.estimatedMinutes,
      'difficulty': d.difficulty.id,
      'verification': d.verification.id,
      'reminders': d.reminders.toMap(),
      'startDate': d.startDate.toString(),
      'endDate': d.endDate?.toString(),
      'active': template.active,
      'archivedAt': template.archivedAt == null
          ? null
          : BaseMapper.dateTimeToTimestamp(template.archivedAt!),
      'colorIndex': d.colorIndex,
      'iconKey': d.iconKey,
      'sortOrder': template.sortOrder,
      'revision': template.revision,
      'builtIn': template.builtIn,
      'seedKey': template.seedKey,
      ...BaseMapper.metadataToMap(meta),
    };
  }

  /// Reads one document. `null` when the document does not exist.
  ///
  /// A document that cannot be turned into a usable draft is NOT dropped: it
  /// comes back as a [TemplateRecord] with [TemplateRecord.invalidSchedule]
  /// set, so the list can show "invalid schedule" and the manager can fix or
  /// archive it.
  static TemplateRecord? fromDoc(String id, Map<String, dynamic>? map) {
    if (map == null) return null;
    final read = fromMap(id, map);
    return read;
  }

  /// Convenience alias used by the repository and the tests.
  static TemplateRecord fromMap(String id, Map<String, dynamic> map) {
    final revision = _int(map['revision']);
    final startDate = _date(map['startDate']) ?? DateKey(2000, 1, 1);
    final recurrenceResult = Recurrence.fromMap(map['recurrence']);
    final recurrence = recurrenceResult.valueOrNull;
    final slots = _slots(map['slots']);

    final draft = TemplateDraft(
      nameBn: _string(map['nameBn'], TemplateLimits.maxNameLength),
      nameEn: _nullableString(map['nameEn'], TemplateLimits.maxNameLength),
      groupId: _nullableString(map['groupId'], 24),
      // A recurrence this build cannot read becomes "once, long ago": it can
      // never fire, and `invalidSchedule` tells the UI why.
      recurrence: recurrence ?? OnceRecurrence(DateKey(2000, 1, 1)),
      slots: slots,
      assignee: _assignee(map['assignee']),
      instructions: _string(map['instructions'], 4000),
      subtasks: _subtasks(map['subtasks']),
      estimatedMinutes: _intOrNull(map['estimatedMinutes']),
      difficulty: Difficulty.fromId(map['difficulty']),
      verification: VerificationMode.fromId(map['verification']),
      reminders: _reminders(map['reminders']),
      startDate: startDate,
      endDate: _date(map['endDate']),
      colorIndex: _colorIndex(map['colorIndex']),
      iconKey: _nullableString(map['iconKey'], 24),
    );

    final template = ChoreTemplate(
      id: id,
      draft: draft,
      revision: revision < 1 ? 1 : revision,
      active: map['active'] is bool ? map['active'] as bool : true,
      archivedAt: _timestamp(map['archivedAt']),
      sortOrder: _int(map['sortOrder']),
      builtIn: map['builtIn'] is bool ? map['builtIn'] as bool : false,
      seedKey: _nullableString(map['seedKey'], 64),
    );

    return TemplateRecord(
      template: template,
      invalidSchedule: recurrenceResult.isFailure,
    );
  }

  // ── Primitives ──────────────────────────────────────────────────────────────

  static List<TemplateSlot> _slots(Object? raw) {
    final rows = _rows(raw);
    final slots = <TemplateSlot>[];
    final keys = <String>{};
    for (final row in rows) {
      if (slots.length == TemplateLimits.maxSlots) break;
      final key = _nullableString(row['key'], 12);
      if (key == null || !keys.add(key)) continue;
      slots.add(
        TemplateSlot(
          key: key,
          labelBn: _nullableString(row['labelBn'], 30),
          labelEn: _nullableString(row['labelEn'], 30),
          dueMinutes: _intIn(row['dueMinutes'], 0, 1439),
        ),
      );
    }
    if (slots.isEmpty) {
      return const <TemplateSlot>[
        TemplateSlot(key: TemplateLimits.mainSlotKey),
      ];
    }
    // The first slot is always `main` (D-P3-3): a document that lost it is
    // repaired on read rather than rejected.
    if (!slots.first.isMain) {
      slots.insert(0, const TemplateSlot(key: TemplateLimits.mainSlotKey));
    }
    return slots;
  }

  static List<TemplateSubtask> _subtasks(Object? raw) {
    final rows = _rows(raw);
    final subtasks = <TemplateSubtask>[];
    final ids = <String>{};
    for (final row in rows) {
      if (subtasks.length == TemplateLimits.maxSubtasks) break;
      final id = _nullableString(row['id'], 16);
      final title = _string(row['title'], 120);
      // The same id pattern the validator enforces: `subtaskDone` on an
      // occurrence is keyed by it, so an unreadable id is unusable.
      if (id == null ||
          title.isEmpty ||
          !_subtaskId.hasMatch(id) ||
          !ids.add(id)) {
        continue;
      }
      subtasks.add(
        TemplateSubtask(
          id: id,
          title: title,
          required: row['required'] is bool ? row['required'] as bool : false,
          hint: _nullableString(row['hint'], 200),
        ),
      );
    }
    return subtasks;
  }

  static AssigneeSpec _assignee(Object? raw) {
    if (raw is! Map) return AssigneeSpec.manual;
    final map = raw.cast<String, Object?>();
    final strategy = AssigneeStrategy.fromId(map['strategy']);
    return AssigneeSpec(
      strategy: strategy,
      fixedMemberId: _nullableString(map['fixedMemberId'], 64),
      dutyGroupId: _nullableString(map['dutyGroupId'], 24),
      rotation: strategy == AssigneeStrategy.rotation
          ? RotationMappers.fromMap(map['rotation'])
          : null,
    );
  }

  static ReminderConfig _reminders(Object? raw) {
    if (raw is! Map) return ReminderConfig.off;
    final offsets = raw['offsetsMinutes'];
    return ReminderConfig(
      enabled: raw['enabled'] is bool ? raw['enabled'] as bool : false,
      atDue: raw['atDue'] is bool ? raw['atDue'] as bool : true,
      offsetsMinutes: <int>[
        if (offsets is List)
          for (final offset in offsets)
            if (offset is int && offset >= 1 && offset <= 1440) offset,
      ].take(TemplateLimits.maxReminderOffsets).toList(),
      overdueEnabled: raw['overdueEnabled'] is bool
          ? raw['overdueEnabled'] as bool
          : false,
      overdueAfterMinutes: _intIn(raw['overdueAfterMinutes'], 1, 1440) ?? 60,
    );
  }

  /// An out-of-range colour is dropped, so the group colour applies.
  static int? _colorIndex(Object? value) =>
      _intIn(value, 0, TemplateLimits.paletteLength - 1);

  static List<Map<String, Object?>> _rows(Object? raw) {
    if (raw is! List) return const <Map<String, Object?>>[];
    return <Map<String, Object?>>[
      for (final item in raw)
        if (item is Map) item.cast<String, Object?>(),
    ];
  }

  static int _int(Object? value) => value is num ? value.toInt() : 0;

  /// `[a-z0-9_]{1,16}`, as the validator and the rules require.
  static final RegExp _subtaskId = RegExp(r'^[a-z0-9_]{1,16}$');

  static int? _intOrNull(Object? value) => value is num ? value.toInt() : null;

  static int? _intIn(Object? value, int min, int max) {
    final asInt = _intOrNull(value);
    if (asInt == null || asInt < min || asInt > max) return null;
    return asInt;
  }

  static String _string(Object? value, int max) {
    if (value is! String) return '';
    return value.length > max ? value.substring(0, max) : value;
  }

  static String? _nullableString(Object? value, int max) {
    if (value is! String || value.isEmpty) return null;
    return value.length > max ? value.substring(0, max) : value;
  }

  static DateKey? _date(Object? value) {
    if (value is! String) return null;
    return DateKey.parse(value).valueOrNull;
  }

  static DateTime? _timestamp(Object? value) =>
      value == null ? null : BaseMapper.timestampToDateTime(value);
}
