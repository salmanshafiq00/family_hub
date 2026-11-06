import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/permissions/permission_settings.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/member_role.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:family_hub/features/notifications/domain/usecases/update_notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/usecases/update_notification_delivery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final clock = FakeClock(DateTime.utc(2026, 11, 6));

  test('delivery policy update checks permission before validation', () async {
    final repository = _DeliveryRepository();
    final useCase = UpdateNotificationDelivery(
      families: _Families(MemberRole.member),
      repository: repository,
      clock: clock,
      newId: () => 'event',
    );

    final result = await useCase.call(
      actorUid: 'member',
      familyId: 'family',
      settings: NotificationDeliverySettings(
        modes: const <String, DeliveryMode>{'unknown': DeliveryMode.push},
      ),
    );

    expect(result.failureOrNull, isA<PermissionDenied>());
    expect(repository.saved, isNull);
  });

  test('admin delivery update rejects unknown type before writing', () async {
    final repository = _DeliveryRepository();
    final useCase = UpdateNotificationDelivery(
      families: _Families(MemberRole.admin),
      repository: repository,
      clock: clock,
      newId: () => 'event',
    );

    final result = await useCase.call(
      actorUid: 'admin',
      familyId: 'family',
      settings: NotificationDeliverySettings(
        modes: const <String, DeliveryMode>{'unknown': DeliveryMode.normal},
      ),
    );

    expect(
      result.failureOrNull,
      const Validation('modes', 'unknown_notification_type'),
    );
    expect(repository.saved, isNull);
  });

  test('a Household Manager may save valid family reminder defaults', () async {
    final repository = _DefaultsRepository();
    final useCase = UpdateNotificationDefaults(
      families: _Families(MemberRole.moderator),
      repository: repository,
      clock: clock,
      newId: () => 'event',
    );
    final settings = NotificationDefaults(chores: false);

    final result = await useCase.call(
      actorUid: 'manager',
      familyId: 'family',
      settings: settings,
    );

    expect(result.isSuccess, isTrue);
    expect(repository.saved, settings);
    expect(repository.event?.type, 'family.notification_defaults_updated');
  });
}

final class _Families implements FamilyRepository {
  _Families(this.role);

  final MemberRole role;

  @override
  Future<Result<Member?>> getMember(String familyId, String uid) async =>
      Success<Member?>(
        Member(
          uid: uid,
          role: role,
          status: MembershipStatus.active,
          fullName: uid,
          relationship: 'other',
        ),
      );

  @override
  Future<Result<PermissionSettings>> getPermissionSettings(
    String familyId,
  ) async => const Success<PermissionSettings>(PermissionSettings.defaults);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _DeliveryRepository implements NotificationDeliveryRepository {
  NotificationDeliverySettings? saved;

  @override
  Stream<NotificationDeliverySettings> watch(String familyId) =>
      Stream.value(NotificationDeliverySettings.defaults());

  @override
  Future<Result<void>> save(
    String familyId,
    NotificationDeliverySettings settings,
    event,
  ) async {
    saved = settings;
    return const Success<void>(null);
  }
}

final class _DefaultsRepository implements NotificationDefaultsRepository {
  NotificationDefaults? saved;
  dynamic event;

  @override
  Stream<NotificationDefaults> watch(String familyId) =>
      Stream.value(NotificationDefaults.defaults);

  @override
  Future<Result<void>> save(
    String familyId,
    NotificationDefaults settings,
    event,
  ) async {
    saved = settings;
    this.event = event;
    return const Success<void>(null);
  }
}
