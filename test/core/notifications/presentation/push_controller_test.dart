import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/notifications/domain/device_token.dart';
import 'package:family_hub/core/notifications/domain/push_message.dart';
import 'package:family_hub/core/notifications/domain/usecases/register_device_token.dart';
import 'package:family_hub/core/notifications/domain/usecases/remove_device_token.dart';
import 'package:family_hub/core/notifications/presentation/push_controller.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_push_service.dart';

final class _MemoryDeviceTokenRepository implements DeviceTokenRepository {
  final List<DeviceTokenRegistration> registrations =
      <DeviceTokenRegistration>[];
  final List<String> registeredIds = <String>[];
  final List<String> removedIds = <String>[];
  AppFailure? removeFailure;

  @override
  Future<Result<void>> register({
    required String uid,
    required String deviceId,
    required DeviceTokenRegistration registration,
  }) async {
    registrations.add(registration);
    registeredIds.add(deviceId);
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> remove({
    required String uid,
    required String deviceId,
  }) async {
    removedIds.add(deviceId);
    final failure = removeFailure;
    if (failure != null) return Failure<void>(failure);
    return const Success<void>(null);
  }
}

final class _MemoryInstallationStore implements DeviceInstallationStore {
  DeviceInstallation? installation;
  int createCalls = 0;

  @override
  Future<DeviceInstallation?> read() async => installation;

  @override
  Future<DeviceInstallation> getOrCreate({
    required String Function() newId,
    required DateTime nowUtc,
  }) async {
    createCalls++;
    return installation ??= DeviceInstallation(id: newId(), createdAt: nowUtc);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakePushService service;
  late _MemoryDeviceTokenRepository repository;
  late _MemoryInstallationStore installationStore;
  late FakeClock clock;
  late PushController controller;

  setUp(() {
    service = FakePushService();
    repository = _MemoryDeviceTokenRepository();
    installationStore = _MemoryInstallationStore();
    clock = FakeClock(DateTime.utc(2026, 11, 6, 10));
    controller = PushController(
      messaging: service,
      registerDeviceToken: RegisterDeviceToken(repository),
      removeDeviceToken: RemoveDeviceToken(repository),
      installationStore: installationStore,
      newId: () => 'stable-install-id',
      clock: clock,
      flavor: Flavor.dev,
      appVersion: '0.1.0',
    );
  });

  tearDown(() async {
    await controller.dispose();
    await service.close();
  });

  test('registers once on sign-in without requesting permission', () async {
    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');

    expect(repository.registrations, hasLength(1));
    expect(installationStore.createCalls, 1);
    expect(service.permissionRequests, 0);
    expect(controller.diagnostics.tokenRegistered, isTrue);
    expect(controller.diagnostics.tokenPrefix, 'token-');
  });

  test('asks once when notifications are not granted', () async {
    service.notificationsAllowed = false;

    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
    await controller.onResumed();

    expect(service.permissionRequests, 1);
    expect(controller.diagnostics.notificationsGranted, isTrue);
    expect(repository.registrations, hasLength(1));
  });

  test('does not ask again after a denied permission', () async {
    service
      ..notificationsAllowed = false
      ..permissionRequestResult = false;

    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
    await controller.onResumed();

    expect(service.permissionRequests, 1);
    expect(controller.diagnostics.notificationsGranted, isFalse);
  });

  test('refreshes the saved token when FCM changes it', () async {
    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
    service.tokenRefreshes.add('refreshed-token-123');
    await Future<void>.delayed(Duration.zero);

    expect(repository.registrations, hasLength(2));
    expect(controller.diagnostics.tokenPrefix, 'refres');
  });

  test('language changes update the registration language', () async {
    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
    await controller.onLanguageChanged('en');

    expect(repository.registrations, hasLength(2));
    expect(repository.registrations.last.languageCode, 'en');
    expect(repository.registeredIds, <String>[
      'stable-install-id',
      'stable-install-id',
    ]);
    expect(
      repository.registrations.last.createdAt,
      repository.registrations.first.createdAt,
    );
  });

  test('resume registration is limited to once per UTC day', () async {
    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
    await controller.onResumed();
    expect(service.getTokenCalls, 1);

    clock.advance(const Duration(days: 1));
    await controller.onResumed();
    expect(service.getTokenCalls, 2);
    expect(repository.registrations, hasLength(2));
  });

  test(
    'explicit permission requests update capability and token state',
    () async {
      await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
      service.permissionRequestResult = false;

      final granted = await controller.requestPermission();

      expect(granted, isFalse);
      expect(service.permissionRequests, 1);
      expect(controller.diagnostics.notificationsGranted, isFalse);
    },
  );

  test(
    'foreground messages update diagnostics without logging payloads',
    () async {
      await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
      service.foregroundMessages.add(
        PushMessage(
          title: 'Update',
          body: 'A generic update',
          data: const <String, String>{'inboxId': 'inbox-1'},
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        controller.diagnostics.lastReceivedMessage,
        DateTime.utc(2026, 11, 6, 10),
      );
    },
  );

  test(
    'sign-out removes this device record and deletes the FCM token',
    () async {
      await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');

      final result = await controller.unregisterForSignOut();

      expect(result.isSuccess, isTrue);
      expect(repository.removedIds, <String>['stable-install-id']);
      expect(service.tokenDeletes, 1);
      expect(controller.diagnostics.tokenRegistered, isFalse);
    },
  );

  test('leaving the active session also removes the device token', () async {
    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');

    await controller.onSessionEnded();

    expect(repository.removedIds, <String>['stable-install-id']);
    expect(service.tokenDeletes, 1);
    expect(controller.diagnostics.tokenRegistered, isFalse);
  });

  test('retries failed session cleanup before a later sign-out', () async {
    await controller.onSessionActive(uid: 'member-1', languageCode: 'bn');
    repository.removeFailure = const Network();

    await controller.onSessionEnded();

    expect(controller.diagnostics.lastError, 'Network');
    expect(service.tokenDeletes, 1);

    repository.removeFailure = null;
    final result = await controller.unregisterForSignOut();

    expect(result.isSuccess, isTrue);
    expect(repository.removedIds, <String>[
      'stable-install-id',
      'stable-install-id',
    ]);
    expect(service.tokenDeletes, 2);
  });
}
