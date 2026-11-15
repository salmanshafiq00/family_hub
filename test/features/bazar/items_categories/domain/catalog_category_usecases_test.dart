import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bazar_test_helpers.dart';

String _repeat(String value, int count) =>
    List<String>.filled(count, value).join();

void _expectFailure(Result<Object?> result, AppFailure failure) {
  expect(result.failureOrNull, failure);
}

void main() {
  group('AddCategory', () {
    test('creates a category with the next sort order and an event', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_existing', sortOrder: 4);

      final result = await f.addCategory(
        actorUid: 'alice',
        familyId: BazarFixture.familyId,
        nameBn: '  নতুন ক্যাটাগরি  ',
        nameEn: '  New category  ',
        colorIndex: 3,
      );

      final created = result.valueOrNull!;
      expect(created.nameBn, 'নতুন ক্যাটাগরি');
      expect(created.nameEn, 'New category');
      expect(created.colorIndex, 3);
      expect(created.sortOrder, 5);
      expect(created.active, isTrue);
      expect(created.builtIn, isFalse);
      expect(created.seedKey, isNull);
      expect(f.backend.categories[BazarFixture.familyId]![created.id], created);

      final event = f.backend.events.single;
      expect(event.type, AuditEventType.bazarCategoryCreated);
      expect(event.refType, AuditRefType.category);
      expect(event.refId, created.id);
      expect(event.actorId, 'alice');
      expect(event.params, <String, String>{'name': 'নতুন ক্যাটাগরি'});
    });

    test('the first category gets sortOrder 0', () async {
      final f = BazarFixture();
      final result = await f.addCategory(
        actorUid: 'alice',
        familyId: BazarFixture.familyId,
        nameBn: 'খাবার',
        colorIndex: 0,
      );
      expect(result.valueOrNull!.sortOrder, 0);
    });

    test('a plain member is denied', () async {
      final f = BazarFixture();
      _expectFailure(
        await f.addCategory(
          actorUid: 'cara',
          familyId: BazarFixture.familyId,
          nameBn: 'খাবার',
          colorIndex: 0,
        ),
        const PermissionDenied(),
      );
      expect(f.backend.writes, 0);
    });

    test('a pending member is denied', () async {
      final f = BazarFixture();
      _expectFailure(
        await f.addCategory(
          actorUid: 'dave',
          familyId: BazarFixture.familyId,
          nameBn: 'খাবার',
          colorIndex: 0,
        ),
        const PermissionDenied(),
      );
    });

    test('a moderator needs the family finance switch', () async {
      final f = BazarFixture();
      f.backend.permissionSettings[BazarFixture.familyId] =
          const PermissionSettings(moderatorManagesFinance: false);
      _expectFailure(
        await f.addCategory(
          actorUid: 'bob',
          familyId: BazarFixture.familyId,
          nameBn: 'খাবার',
          colorIndex: 0,
        ),
        const PermissionDenied(),
      );

      f.backend.permissionSettings[BazarFixture.familyId] =
          PermissionSettings.defaults;
      expect(
        (await f.addCategory(
          actorUid: 'bob',
          familyId: BazarFixture.familyId,
          nameBn: 'খাবার',
          colorIndex: 0,
        )).isSuccess,
        isTrue,
      );
    });

    test('validates the name, colour, emoji and image', () async {
      final f = BazarFixture();
      Future<Result<Object?>> add({
        String nameBn = 'খাবার',
        String? nameEn,
        int colorIndex = 0,
        String? emoji,
        String? imageData,
      }) => f.addCategory(
        actorUid: 'alice',
        familyId: BazarFixture.familyId,
        nameBn: nameBn,
        nameEn: nameEn,
        colorIndex: colorIndex,
        emoji: emoji,
        imageData: imageData,
      );

      _expectFailure(
        await add(nameBn: '   '),
        const Validation('nameBn', 'required'),
      );
      _expectFailure(
        await add(nameBn: _repeat('a', 61)),
        const Validation('nameBn', 'too_long'),
      );
      _expectFailure(
        await add(nameEn: _repeat('a', 61)),
        const Validation('nameEn', 'too_long'),
      );
      _expectFailure(
        await add(colorIndex: 24),
        const Validation('colorIndex', 'invalid'),
      );
      _expectFailure(
        await add(colorIndex: -1),
        const Validation('colorIndex', 'invalid'),
      );
      _expectFailure(
        await add(emoji: _repeat('🍚', 9)),
        const Validation('emoji', 'too_long'),
      );
      _expectFailure(
        await add(imageData: _repeat('a', 24001)),
        const Validation('imageData', 'too_long'),
      );
      expect(f.backend.writes, 0);
    });
  });

  group('UpdateCategory', () {
    test('renames and recolours while keeping seed fields', () async {
      final f = BazarFixture();
      f.putCategory(
        id: 'cat_food',
        nameBn: 'খাবার',
        nameEn: 'Food',
        colorIndex: 1,
        sortOrder: 2,
        builtIn: true,
        seedKey: 'food',
      );

      final result = await f.updateCategory(
        actorUid: 'alice',
        familyId: BazarFixture.familyId,
        categoryId: 'cat_food',
        nameBn: ' খাদ্য ',
        nameEn: ' Groceries ',
        colorIndex: 7,
        emoji: '🍚',
      );

      final updated = result.valueOrNull!;
      expect(updated.id, 'cat_food');
      expect(updated.nameBn, 'খাদ্য');
      expect(updated.nameEn, 'Groceries');
      expect(updated.colorIndex, 7);
      expect(updated.emoji, '🍚');
      expect(updated.sortOrder, 2);
      expect(updated.active, isTrue);
      expect(updated.builtIn, isTrue);
      expect(updated.seedKey, 'food');
      expect(f.backend.events.single.type, AuditEventType.bazarCategoryUpdated);
    });

    test('an unknown category is not found', () async {
      final f = BazarFixture();
      _expectFailure(
        await f.updateCategory(
          actorUid: 'alice',
          familyId: BazarFixture.familyId,
          categoryId: 'missing',
          nameBn: 'খাদ্য',
          colorIndex: 0,
        ),
        const NotFound(entity: 'category'),
      );
    });

    test('a plain member is denied', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_food');
      _expectFailure(
        await f.updateCategory(
          actorUid: 'cara',
          familyId: BazarFixture.familyId,
          categoryId: 'cat_food',
          nameBn: 'খাদ্য',
          colorIndex: 0,
        ),
        const PermissionDenied(),
      );
    });

    test('a pending member is denied', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_food');
      _expectFailure(
        await f.updateCategory(
          actorUid: 'dave',
          familyId: BazarFixture.familyId,
          categoryId: 'cat_food',
          nameBn: 'খাদ্য',
          colorIndex: 0,
        ),
        const PermissionDenied(),
      );
    });

    test('validates the colour', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_food');
      _expectFailure(
        await f.updateCategory(
          actorUid: 'alice',
          familyId: BazarFixture.familyId,
          categoryId: 'cat_food',
          nameBn: 'খাদ্য',
          colorIndex: 24,
        ),
        const Validation('colorIndex', 'invalid'),
      );
    });
  });

  group('DeactivateCategory', () {
    test('sets active=false and writes one event', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_food', builtIn: true, seedKey: 'food');

      final result = await f.deactivateCategory(
        actorUid: 'bob',
        familyId: BazarFixture.familyId,
        categoryId: 'cat_food',
      );

      final updated = result.valueOrNull!;
      expect(updated.active, isFalse);
      expect(updated.builtIn, isTrue);
      expect(updated.seedKey, 'food');
      final event = f.backend.events.single;
      expect(event.type, AuditEventType.bazarCategoryDeactivated);
      expect(event.refType, AuditRefType.category);
      expect(event.params, <String, String>{'name': 'খাবার'});
    });

    test('deactivating twice is a no-op', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_food');
      await f.deactivateCategory(
        actorUid: 'alice',
        familyId: BazarFixture.familyId,
        categoryId: 'cat_food',
      );
      final before = f.backend.events.length;

      final second = await f.deactivateCategory(
        actorUid: 'alice',
        familyId: BazarFixture.familyId,
        categoryId: 'cat_food',
      );

      expect(second.valueOrNull!.active, isFalse);
      expect(f.backend.events.length, before);
    });

    test('an unknown category is not found', () async {
      final f = BazarFixture();
      _expectFailure(
        await f.deactivateCategory(
          actorUid: 'alice',
          familyId: BazarFixture.familyId,
          categoryId: 'missing',
        ),
        const NotFound(entity: 'category'),
      );
    });

    test('a plain member is denied', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_food');
      _expectFailure(
        await f.deactivateCategory(
          actorUid: 'cara',
          familyId: BazarFixture.familyId,
          categoryId: 'cat_food',
        ),
        const PermissionDenied(),
      );
    });

    test('a pending member is denied', () async {
      final f = BazarFixture();
      f.putCategory(id: 'cat_food');
      _expectFailure(
        await f.deactivateCategory(
          actorUid: 'dave',
          familyId: BazarFixture.familyId,
          categoryId: 'cat_food',
        ),
        const PermissionDenied(),
      );
    });
  });
}
