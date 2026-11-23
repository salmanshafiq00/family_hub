import 'dart:async';

import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_repository.dart';
import 'package:family_hub/features/chores/starter_packs/domain/usecases/manage_starter_items.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// The family-editable starter list: customise, add, edit, delete, reset.
class _MemoryItems implements StarterItemRepository {
  final Map<String, ChoreTemplate> items = <String, ChoreTemplate>{};
  final List<AuditEvent> events = <AuditEvent>[];

  List<TemplateRecord> get _records {
    final sorted = items.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return <TemplateRecord>[
      for (final t in sorted) TemplateRecord(template: t),
    ];
  }

  @override
  Stream<List<TemplateRecord>> watch(String familyId) =>
      Stream<List<TemplateRecord>>.value(_records);

  @override
  Future<Result<List<TemplateRecord>>> list(String familyId) async =>
      Success<List<TemplateRecord>>(_records);

  @override
  Future<Result<void>> save(
    String familyId,
    ChoreTemplate item,
    AuditEvent event,
  ) async {
    items[item.id] = item;
    events.add(event);
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> delete(
    String familyId,
    String itemId,
    AuditEvent event,
  ) async {
    items.remove(itemId);
    events.add(event);
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> replaceAll(
    String familyId, {
    required List<ChoreTemplate> items,
    required List<String> removeIds,
    required AuditEvent event,
  }) async {
    removeIds.forEach(this.items.remove);
    for (final item in items) {
      this.items[item.id] = item;
    }
    events.add(event);
    return const Success<void>(null);
  }
}

void main() {
  late ChoresFixture fixture;
  late _MemoryItems repo;
  late ManageStarterItems manage;

  const familyId = ChoresFixture.familyId;

  setUp(() {
    fixture = ChoresFixture();
    repo = _MemoryItems();
    manage = ManageStarterItems(
      items: repo,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
  });

  Future<void> customise({String actor = 'bob'}) async {
    final result = await manage.customise(
      actorUid: actor,
      familyId: familyId,
      base: familyPdfPack,
    );
    expect(result.failureOrNull, isNull);
  }

  test('customise copies the built-in pack and only once', () async {
    await customise();
    expect(repo.items, hasLength(familyPdfPack.templates.length));

    final again = await manage.customise(
      actorUid: 'bob',
      familyId: familyId,
      base: familyPdfPack,
    );
    expect(again.failureOrNull, isA<Conflict>());
    expect(repo.items, hasLength(familyPdfPack.templates.length));
  });

  test('a plain member cannot change the list', () async {
    final result = await manage.customise(
      actorUid: 'cara',
      familyId: familyId,
      base: familyPdfPack,
    );
    expect(result.failureOrNull, isA<PermissionDenied>());
    expect(repo.items, isEmpty);
  });

  test('save adds a new line at the end', () async {
    await customise();
    final result = await manage.save(
      actorUid: 'alice',
      familyId: familyId,
      draft: aTemplate(nameBn: 'নতুন কাজ'),
    );
    final item = result.valueOrNull!;

    expect(repo.items[item.id], isNotNull);
    expect(item.seedKey, item.id);
    expect(item.sortOrder, familyPdfPack.templates.length);
    expect(item.draft.assignee, AssigneeSpec.manual);
  });

  test('save with an id edits that line and keeps its place', () async {
    await customise();
    final before = repo.items['dinner']!;
    final result = await manage.save(
      actorUid: 'bob',
      familyId: familyId,
      draft: before.draft.copyWith(nameBn: 'রাতের রান্না'),
      itemId: 'dinner',
    );

    expect(result.failureOrNull, isNull);
    expect(repo.items['dinner']!.draft.nameBn, 'রাতের রান্না');
    expect(repo.items['dinner']!.sortOrder, before.sortOrder);
    expect(repo.items, hasLength(familyPdfPack.templates.length));
  });

  test('an empty name is rejected before anything is written', () async {
    await customise();
    final result = await manage.save(
      actorUid: 'bob',
      familyId: familyId,
      draft: aTemplate(nameBn: ''),
    );
    expect(result.failureOrNull, isA<Validation>());
    expect(repo.items, hasLength(familyPdfPack.templates.length));
  });

  test('delete removes one line; an unknown id is NotFound', () async {
    await customise();
    final ok = await manage.delete(
      actorUid: 'bob',
      familyId: familyId,
      itemId: 'dinner',
    );
    expect(ok.failureOrNull, isNull);
    expect(repo.items.containsKey('dinner'), isFalse);

    final missing = await manage.delete(
      actorUid: 'bob',
      familyId: familyId,
      itemId: 'nope',
    );
    expect(missing.failureOrNull, isA<NotFound>());
  });

  test('reset empties the list so the built-in pack is used again', () async {
    await customise();
    final result = await manage.reset(actorUid: 'bob', familyId: familyId);

    expect(result.failureOrNull, isNull);
    expect(repo.items, isEmpty);
    expect(repo.events, isNotEmpty);
  });
}
