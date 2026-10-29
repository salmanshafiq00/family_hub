import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_event_mappers.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_mappers.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_parts.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-13: the occurrence and event maps round-trip, the dotted-key patch only
/// touches the keys it names, and the readers tolerate damaged documents.
void main() {
  final meta = BaseMapper.createMetadata(
    uid: 'alice',
    clock: FakeClock(DateTime.utc(2026, 10, 24, 9)),
  );
  final at = DateTime.utc(2026, 10, 24, 3, 30);

  group('occurrence round trip', () {
    test('a plain occurrence survives toMap -> fromDoc', () {
      final occurrence = anOccurrence();
      final map = OccurrenceMappers.toMap(occurrence, meta);
      expect(OccurrenceMappers.fromDoc(occurrence.id, map), occurrence);
    });

    test('a fully populated occurrence survives', () {
      final occurrence = anOccurrence(
        slotKey: 'noon',
        instructions: '# নিয়ম\n- **সাবধানে**',
        subtasks: <TemplateSubtask>[
          aSubtask(id: 'step_1', required: true),
          aSubtask(id: 'step_2', title: 'মুছা'),
        ],
        difficulty: Difficulty.hard,
        estimatedMinutes: 45,
        verification: VerificationMode.required,
        status: OccurrenceStatus.verified,
        coverForId: 'dave',
        assignmentSource: AssignmentSource.cover,
        needsCover: true,
        subtaskDone: <String, SubtaskDone>{
          'step_1': SubtaskDone(at: at, by: 'cara'),
          'step_2': SubtaskDone(at: at, by: 'dave'),
        },
        completedAt: at,
        completedBy: 'cara',
        verifiedAt: at,
        verifiedBy: 'bob',
        reopenCount: 2,
        exception: CompletionException(note: 'কিছু বাদ', by: 'bob', at: at),
        skipReason: SkipReason.absence,
        needsAttention: true,
        lastCommentAt: at,
      );
      final map = OccurrenceMappers.toMap(occurrence, meta);
      expect(OccurrenceMappers.fromDoc(occurrence.id, map), occurrence);
    });

    test('every key of the map is one the rules allow', () {
      final map = OccurrenceMappers.toMap(anOccurrence(), meta);
      expect(
        map.keys,
        containsAll(<String>[
          'templateId',
          'dateKey',
          'monthKey',
          'dueAt',
          'status',
          'subtaskDone',
          'reopenCount',
          'needsAttention',
          'schemaVersion',
        ]),
      );
      expect(map['dateKey'], '2026-10-24');
      expect(map['monthKey'], '2026-10');
      expect(map['status'], 'scheduled');
    });
  });

  group('tolerance', () {
    test('an unknown status reads as scheduled', () {
      final map = OccurrenceMappers.toMap(anOccurrence(), meta)
        ..['status'] = 'overdue';
      expect(
        OccurrenceMappers.fromDoc('tpl_1_20261024', map)?.status,
        OccurrenceStatus.scheduled,
      );
    });

    test('an unknown assignment source reads as manual', () {
      final map = OccurrenceMappers.toMap(anOccurrence(), meta)
        ..['assignmentSource'] = 'teleport';
      expect(
        OccurrenceMappers.fromDoc('tpl_1_20261024', map)?.assignmentSource,
        AssignmentSource.manual,
      );
    });

    test('a malformed tick is dropped, the others survive', () {
      final map = OccurrenceMappers.toMap(anOccurrence(), meta)
        ..['subtaskDone'] = <String, dynamic>{
          'ok': <String, dynamic>{'at': at, 'by': 'cara'},
          'bad': <String, dynamic>{'by': 'cara'},
        };
      final occurrence = OccurrenceMappers.fromDoc('tpl_1_20261024', map)!;
      expect(occurrence.subtaskDone.keys, <String>['ok']);
    });

    test('a document without a dateKey is unreadable, not a crash', () {
      final map = OccurrenceMappers.toMap(anOccurrence(), meta)
        ..remove('dateKey');
      expect(OccurrenceMappers.fromDoc('tpl_1_20261024', map), isNull);
      expect(OccurrenceMappers.fromDoc('x', null), isNull);
    });

    test('a missing dueAt falls back to the end of the family day', () {
      final map = OccurrenceMappers.toMap(anOccurrence(), meta)
        ..remove('dueAt');
      final occurrence = OccurrenceMappers.fromDoc('tpl_1_20261024', map)!;
      expect(occurrence.dueAt, DateTime.utc(2026, 10, 24, 23, 59, 59));
    });
  });

  group('patches', () {
    test('a dotted subtask patch carries only that key and the stamps', () {
      final patch = OccurrencePatch(
        occurrenceId: 'tpl_1_20261024',
        fields: <String, Object?>{
          'subtaskDone.step_1': SubtaskDone(at: at, by: 'cara'),
          'status': 'in_progress',
        },
        removedFields: const <String>{'completedAt'},
      );
      final map = OccurrenceMappers.patchMap(patch, actorId: 'cara', at: at);
      expect(map.keys, contains('subtaskDone.step_1'));
      expect(map['status'], 'in_progress');
      expect(map[BaseMapper.keyUpdatedBy], 'cara');
      expect(map['completedAt'], isNotNull);
    });

    test('the grid helpers round-trip one tick', () {
      final done = SubtaskDone(at: at, by: 'cara');
      expect(
        OccurrenceMappers.gridFromMap(OccurrenceMappers.gridMap(done)),
        done,
      );
      expect(OccurrenceMappers.gridFromMap('nope'), isNull);
    });

    test('a replan without an assignment change keeps the owner keys', () {
      final replan = OccurrenceReplan(
        occurrenceId: 'tpl_1_20261024',
        draft: anOccurrenceDraft(nameBn: 'নতুন নাম'),
        recomputeAssignment: false,
      );
      final map = OccurrenceMappers.replanMap(replan, actorId: 'bob', at: at);
      expect(map['nameBn'], 'নতুন নাম');
      expect(map.containsKey('assigneeId'), isFalse);
      expect(map.containsKey('plannedAssigneeId'), isFalse);
    });

    test('a replan with an assignment change writes the owner keys', () {
      final replan = OccurrenceReplan(
        occurrenceId: 'tpl_1_20261024',
        draft: anOccurrenceDraft(assigneeId: 'dave'),
      );
      final map = OccurrenceMappers.replanMap(replan, actorId: 'bob', at: at);
      expect(map['assigneeId'], 'dave');
      expect(map.containsKey('createdAt'), isFalse);
    });

    test('a restore clears the delete pair and keeps the creation stamps', () {
      final map = OccurrenceMappers.restoreMap(
        anOccurrence(deletedAt: at, deletedBy: 'bob'),
        actorId: 'bob',
        at: at,
      );
      expect(map.containsKey(BaseMapper.keyCreatedAt), isFalse);
      expect(map.containsKey(BaseMapper.keySchemaVersion), isFalse);
      expect(map[BaseMapper.keyDeletedAt], isNull);
      expect(map[BaseMapper.keyDeletedBy], isNull);
    });

    test('B-06: a restore writes ONLY the keys rule 12 allows', () {
      final map = OccurrenceMappers.restoreMap(
        anOccurrence(deletedAt: at, deletedBy: 'bob'),
        actorId: 'bob',
        at: at,
      );
      const allowed = <String>{
        'templateRev',
        'nameBn',
        'nameEn',
        'groupId',
        'instructions',
        'subtasks',
        'difficulty',
        'estimatedMinutes',
        'verification',
        'dueAt',
        'dueMinutes',
        'plannedAssigneeId',
        'assigneeId',
        'assignmentSource',
        'needsCover',
        'deletedAt',
        'deletedBy',
        'updatedAt',
        'updatedBy',
      };
      expect(map.keys.toSet().difference(allowed), isEmpty);
      expect(map.containsKey('status'), isFalse);
      expect(map.containsKey('subtaskDone'), isFalse);
    });
  });

  group('events', () {
    test('an event round-trips', () {
      final event = OccurrenceEvent(
        id: 'reopened_1',
        occurrenceId: 'tpl_1_20261024',
        type: OccurrenceEventType.reopened,
        actorId: 'bob',
        at: at,
        fromAssigneeId: 'cara',
        toAssigneeId: 'dave',
        reason: 'আবার করতে হবে',
        prevCompletedAt: at,
        requestId: 'swap_1',
      );
      final map = OccurrenceEventMappers.toMap(event, meta);
      // The READ honours the stored `createdAt` (the server time), so a map
      // written with another metadata clock keeps that instant, not `at`.
      expect(
        OccurrenceEventMappers.fromDoc(event.occurrenceId, event.id, map)?.id,
        event.id,
      );
      expect(
        OccurrenceEventMappers.fromDoc(
          event.occurrenceId,
          event.id,
          map,
        )?.reason,
        event.reason,
      );
      expect(
        OccurrenceEventMappers.fromDoc(
          event.occurrenceId,
          event.id,
          map,
        )?.redoSubtaskIds,
        event.redoSubtaskIds,
      );
      expect(map.keys, containsAll(<String>['type', 'actorId', 'reason']));
    });

    test('B-04: the steps a reopen cleared survive the round trip', () {
      final event = OccurrenceEvent(
        id: 'reopened_1',
        occurrenceId: 'tpl_1_20261024',
        type: OccurrenceEventType.reopened,
        actorId: 'bob',
        at: at,
        redoSubtaskIds: const <String>['step_1', 'step_2'],
      );
      final map = OccurrenceEventMappers.toMap(event, meta);
      final read = OccurrenceEventMappers.fromDoc(
        event.occurrenceId,
        event.id,
        map,
      );
      expect(read?.redoSubtaskIds, event.redoSubtaskIds);
    });

    test('an unknown event type is dropped', () {
      final map = OccurrenceEventMappers.toMap(
        OccurrenceEvent(
          id: 'x',
          occurrenceId: 'o',
          type: OccurrenceEventType.completed,
          actorId: 'cara',
          at: at,
        ),
        meta,
      )..['type'] = 'deleted';
      expect(OccurrenceEventMappers.fromDoc('o', 'x', map), isNull);
    });

    test('B-05: a patch records the unique event id as lastEventId', () {
      const event = NewEvent(
        occurrenceId: 'tpl_1_20261024',
        type: OccurrenceEventType.uncompleted,
      );
      final stamped = event.withId('evt_two');
      final patch = const OccurrencePatch(occurrenceId: 'tpl_1_20261024')
          .withField('lastEventId', stamped.id);

      expect(event.id, isEmpty);
      expect(stamped.id, 'evt_two');
      expect(patch.fields['lastEventId'], 'evt_two');
    });
  });

  test('a slot id keeps its date and slot', () {
    final occurrence = anOccurrence(
      id: 'tpl_1_20261024_noon',
      slotKey: 'noon',
      dateKey: DateKey(2026, 10, 24),
    );
    final map = OccurrenceMappers.toMap(occurrence, meta);
    expect(OccurrenceMappers.fromDoc(occurrence.id, map), occurrence);
  });
}
