import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/domain/template_saved.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/archive_template.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/create_template.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/duplicate_template.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/pause_template.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/resume_template.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/update_template.dart';

import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-07: the template use cases against the in-memory backend - the permission
/// matrix, the validation order, the revision bump, duplicate independence and
/// archive/pause/resume.
void main() {
  late ChoresFixture fixture;
  late CreateTemplate create;
  late UpdateTemplate update;
  late PauseTemplate pause;
  late ResumeTemplate resume;
  late ArchiveTemplate archive;
  late DuplicateTemplate duplicate;

  setUp(() {
    fixture = ChoresFixture();
    create = CreateTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    update = UpdateTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    pause = PauseTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    resume = ResumeTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    archive = ArchiveTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    duplicate = DuplicateTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
  });

  const familyId = ChoresFixture.familyId;

  Future<ChoreTemplate> seed({TemplateDraft? draft}) async {
    final result = await create(
      actorUid: 'alice',
      familyId: familyId,
      draft: draft ?? aTemplate(),
    );
    return result.valueOrNull!;
  }

  group('CreateTemplate', () {
    test(
      'a Household Manager creates revision 1 with sortOrder max + 1',
      () async {
        final first = await create(
          actorUid: 'bob',
          familyId: familyId,
          draft: aTemplate(),
        );
        final second = await create(
          actorUid: 'bob',
          familyId: familyId,
          draft: aTemplate(nameBn: 'ঝাড়ু দেওয়া'),
        );

        expect(first.isSuccess, isTrue);
        expect(first.valueOrNull!.revision, 1);
        expect(first.valueOrNull!.sortOrder, 0);
        expect(second.valueOrNull!.sortOrder, 1);
        expect(first.valueOrNull!.id, isNot(second.valueOrNull!.id));
      },
    );

    test('an admin creates', () async {
      final result = await create(
        actorUid: 'alice',
        familyId: familyId,
        draft: aTemplate(),
      );
      expect(result.isSuccess, isTrue);
    });

    test('a plain member is denied and nothing is written', () async {
      final result = await create(
        actorUid: 'cara',
        familyId: familyId,
        draft: aTemplate(),
      );
      expect(result.failureOrNull, const PermissionDenied());
      expect(fixture.chores.writes, 0);
    });

    test('a pending member is denied', () async {
      final result = await create(
        actorUid: 'erin',
        familyId: familyId,
        draft: aTemplate(),
      );
      expect(result.failureOrNull, const PermissionDenied());
    });

    test('writes exactly one audit entry with the name', () async {
      final template = await seed();
      final event = fixture.chores.events.single;
      expect(event.type, AuditEventType.choresTemplateCreated);
      expect(event.refId, template.id);
      expect(event.params['name'], 'বাসন ধোয়া');
      expect(event.actorId, 'alice');
    });

    test('validation runs before the write', () async {
      final result = await create(
        actorUid: 'alice',
        familyId: familyId,
        draft: aTemplate(nameBn: '   '),
      );
      expect(result.failureOrNull, const Validation('nameBn', 'required'));
      expect(fixture.chores.writes, 0);
    });

    test(
      'a starter-pack template gets tpl_<seedKey> and is built in',
      () async {
        final result = await create(
          actorUid: 'alice',
          familyId: familyId,
          draft: aTemplate(),
          seedKey: 'wash_dishes',
        );
        final template = result.valueOrNull!;
        expect(template.id, 'tpl_wash_dishes');
        expect(template.seedKey, 'wash_dishes');
        expect(template.builtIn, isTrue);
      },
    );

    test('applying the same seed key twice is a conflict', () async {
      await create(
        actorUid: 'alice',
        familyId: familyId,
        draft: aTemplate(),
        seedKey: 'wash_dishes',
      );
      final again = await create(
        actorUid: 'alice',
        familyId: familyId,
        draft: aTemplate(),
        seedKey: 'wash_dishes',
      );
      expect(again.failureOrNull, const Conflict(code: 'duplicate_id'));
    });

    test('a repository failure is passed through', () async {
      fixture.chores.nextSaveFailure = const Network();
      final result = await create(
        actorUid: 'alice',
        familyId: familyId,
        draft: aTemplate(),
      );
      expect(result.failureOrNull, const Network());
    });
  });

  group('UpdateTemplate', () {
    test('bumps revision by exactly one and keeps the identity', () async {
      final before = await seed();
      final result = await update(
        actorUid: 'bob',
        familyId: familyId,
        templateId: before.id,
        draft: before.draft.copyWith(nameBn: 'বাসন ও হাঁড়ি ধোয়া'),
      );

      final after = result.valueOrNull!.template;
      expect(after.revision, 2);
      expect(after.id, before.id);
      expect(after.sortOrder, before.sortOrder);
      expect(after.builtIn, before.builtIn);
      expect(after.draft.nameBn, 'বাসন ও হাঁড়ি ধোয়া');
      expect(
        fixture.chores.events.last.type,
        AuditEventType.choresTemplateUpdated,
      );
      expect(fixture.chores.events.last.params['rev'], '2');
    });

    test('returns the replan scope the caller asked for', () async {
      final before = await seed();
      final result = await update(
        actorUid: 'alice',
        familyId: familyId,
        templateId: before.id,
        draft: before.draft,
        replanScope: ReplanScope.includeUpcoming,
      );
      expect(result.valueOrNull!.replanScope, ReplanScope.includeUpcoming);
      // The default is futureOnly (D-P3-23).
      final second = await update(
        actorUid: 'alice',
        familyId: familyId,
        templateId: before.id,
        draft: before.draft,
      );
      expect(second.valueOrNull!.replanScope, ReplanScope.futureOnly);
    });

    test('an unknown template is NotFound', () async {
      final result = await update(
        actorUid: 'alice',
        familyId: familyId,
        templateId: 'missing',
        draft: aTemplate(),
      );
      expect(result.failureOrNull, const NotFound(entity: 'template'));
    });

    test('a plain member is denied', () async {
      final before = await seed();
      final result = await update(
        actorUid: 'cara',
        familyId: familyId,
        templateId: before.id,
        draft: before.draft,
      );
      expect(result.failureOrNull, const PermissionDenied());
    });

    test('an invalid draft never reaches the repository', () async {
      final before = await seed();
      final result = await update(
        actorUid: 'alice',
        familyId: familyId,
        templateId: before.id,
        draft: before.draft.copyWith(slots: const <TemplateSlot>[]),
      );
      expect(result.failureOrNull, const Validation('slots', 'no_dates'));
      expect(fixture.chores.writes, 1, reason: 'only the seed write');
    });
  });

  group('pause / resume / archive', () {
    test('pause sets active = false and keeps the template', () async {
      final template = await seed();
      final result = await pause(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      expect(result.valueOrNull!.active, isFalse);
      expect(result.valueOrNull!.isArchived, isFalse);
      // The P3-08 rules require +1 on every update, lifecycle included.
      expect(result.valueOrNull!.revision, template.revision + 1);
      expect(
        fixture.chores.events.last.type,
        AuditEventType.choresTemplatePaused,
      );
    });

    test('resume sets active = true again', () async {
      final template = await seed();
      final paused = await pause(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      final result = await resume(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      expect(result.valueOrNull!.active, isTrue);
      expect(result.valueOrNull!.revision, paused.valueOrNull!.revision + 1);
      expect(
        fixture.chores.events.last.type,
        AuditEventType.choresTemplateResumed,
      );
    });

    test('resuming an archived template is refused', () async {
      final template = await seed();
      await archive(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      final result = await resume(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      expect(result.failureOrNull, const Conflict(code: 'template_paused'));
    });

    test('archive sets active = false and archivedAt', () async {
      final template = await seed();
      final result = await archive(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      final archived = result.valueOrNull!;
      expect(archived.active, isFalse);
      expect(archived.archivedAt, fixture.clock.nowUtc());
      expect(archived.isGenerating, isFalse);
      expect(archived.revision, template.revision + 1);
    });

    test('archiving twice keeps the first archivedAt', () async {
      final template = await seed();
      final first = await archive(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      fixture.clock.advance(const Duration(days: 3));
      final second = await archive(
        actorUid: 'bob',
        familyId: familyId,
        templateId: template.id,
      );
      expect(second.valueOrNull!.archivedAt, first.valueOrNull!.archivedAt);
      expect(second.valueOrNull!.revision, first.valueOrNull!.revision + 1);
    });

    test('an archived template disappears from the active list', () async {
      final keep = await seed();
      final gone = await seed();
      await archive(actorUid: 'bob', familyId: familyId, templateId: gone.id);

      final listed = await fixture.chores.list(familyId);
      final active = listed.valueOrNull!
          .where((record) => record.template.isGenerating)
          .map((record) => record.template.id);
      expect(active, [keep.id]);
      expect(listed.valueOrNull, hasLength(2), reason: 'never deleted');
    });

    test('pause and archive need the manager permission', () async {
      final template = await seed();
      expect(
        (await pause(
          actorUid: 'cara',
          familyId: familyId,
          templateId: template.id,
        )).failureOrNull,
        const PermissionDenied(),
      );
      expect(
        (await archive(
          actorUid: 'cara',
          familyId: familyId,
          templateId: template.id,
        )).failureOrNull,
        const PermissionDenied(),
      );
    });
  });

  group('DuplicateTemplate', () {
    test('the copy is independent and not built in', () async {
      final source = await create(
        actorUid: 'alice',
        familyId: familyId,
        draft: aTemplate(subtasks: <TemplateSubtask>[aSubtask()]),
        seedKey: 'wash_dishes',
      );
      final copy = await duplicate(
        actorUid: 'bob',
        familyId: familyId,
        templateId: source.valueOrNull!.id,
        nameSuffix: ' (কপি)',
      );

      final created = copy.valueOrNull!;
      expect(created.id, isNot(source.valueOrNull!.id));
      expect(created.revision, 1);
      expect(created.builtIn, isFalse);
      expect(created.seedKey, isNull);
      expect(created.sortOrder, 1);
      expect(created.draft.nameBn, 'বাসন ধোয়া (কপি)');
      expect(created.draft.nameEn, 'Wash the dishes (কপি)');
      expect(created.draft.subtasks, source.valueOrNull!.draft.subtasks);
    });

    test('editing the copy leaves the original alone', () async {
      final source = await seed();
      final copy = (await duplicate(
        actorUid: 'alice',
        familyId: familyId,
        templateId: source.id,
        nameSuffix: ' (কপি)',
      )).valueOrNull!;

      await update(
        actorUid: 'alice',
        familyId: familyId,
        templateId: copy.id,
        draft: copy.draft.copyWith(nameBn: 'অন্য নাম'),
      );

      final original = await fixture.chores.get(familyId, source.id);
      expect(original.valueOrNull!.template.draft.nameBn, 'বাসন ধোয়া');
      expect(original.valueOrNull!.template.revision, 1);
    });

    test('a copy of a copy still gets a fresh id', () async {
      final source = await seed();
      final first = (await duplicate(
        actorUid: 'alice',
        familyId: familyId,
        templateId: source.id,
        nameSuffix: ' (কপি)',
      )).valueOrNull!;
      final second = (await duplicate(
        actorUid: 'alice',
        familyId: familyId,
        templateId: first.id,
        nameSuffix: ' (কপি)',
      )).valueOrNull!;
      expect(second.id, isNot(first.id));
      expect(second.sortOrder, 2);
    });

    test('the suffix is dropped rather than breaking the name limit', () async {
      final longName = 'ক' * TemplateLimits.maxNameLength;
      final source = await seed(
        draft: aTemplate(nameBn: longName, nameEn: null),
      );
      final copy = (await duplicate(
        actorUid: 'alice',
        familyId: familyId,
        templateId: source.id,
        nameSuffix: ' (কপি)',
      )).valueOrNull!;
      expect(copy.draft.nameBn.length, TemplateLimits.maxNameLength);
      expect(copy.draft.nameBn, endsWith(' (কপি)'));
    });

    test('a plain member cannot duplicate', () async {
      final source = await seed();
      final result = await duplicate(
        actorUid: 'cara',
        familyId: familyId,
        templateId: source.id,
        nameSuffix: ' (কপি)',
      );
      expect(result.failureOrNull, const PermissionDenied());
    });
  });

  group('the in-memory backend behaves like Firestore', () {
    test('watch emits the templates in sortOrder', () async {
      await seed(draft: aTemplate(nameBn: 'প্রথম'));
      await seed(draft: aTemplate(nameBn: 'দ্বিতীয়'));
      final list = await fixture.chores.watch(familyId).first;
      expect(list.map((record) => record.template.draft.nameBn), [
        'প্রথম',
        'দ্বিতীয়',
      ]);
    });

    test('a failing read is surfaced, not swallowed', () async {
      fixture.chores.nextReadFailure = const Network();
      final result = await fixture.chores.list(familyId);
      expect(result.failureOrNull, const Network());
    });
  });

  group('the draft is the only thing an editor may change', () {
    test('the id, revision and flags are not part of the draft', () {
      // Compile-time guarantee expressed as a runtime check: a draft has no
      // id/revision/builtIn/seedKey field, so an editor cannot set them.
      final draft = aTemplate();
      expect(draft.nameBn, isNotEmpty);
      expect(
        <String>[
          'id',
          'revision',
          'builtIn',
          'seedKey',
          'sortOrder',
          'active',
        ].where(draft.toString().contains),
        isEmpty,
      );
    });

    test('a template starts active and unarchived', () {
      final template = ChoreTemplate(
        id: 't1',
        draft: aTemplate(startDate: DateKey(2026, 10, 1)),
      );
      expect(template.active, isTrue);
      expect(template.isArchived, isFalse);
      expect(template.isGenerating, isTrue);
      expect(template.revision, 1);
      expect(template.builtIn, isFalse);
      expect(template.seedKey, isNull);
    });

    test('a recurrence is required and stored on the draft', () {
      final draft = aTemplate(
        recurrence: const WeekdaysRecurrence(weekdays: [6]),
      );
      expect(draft.recurrence, isA<WeekdaysRecurrence>());
    });
  });
}
