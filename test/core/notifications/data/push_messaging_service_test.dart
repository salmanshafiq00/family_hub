import 'dart:async';

import 'package:family_hub/core/notifications/data/push_messaging_service.dart';
import 'package:family_hub/core/notifications/domain/notification_tap_router.dart';
import 'package:family_hub/core/notifications/domain/push_message.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeMessagingDriver implements FirebaseMessagingDriver {
  final StreamController<String> tokenRefreshes =
      StreamController<String>.broadcast();
  final StreamController<PushMessage> foreground =
      StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> opened =
      StreamController<PushMessage>.broadcast();

  PushMessage? initialMessage;
  bool notificationsAllowed = false;
  bool permissionResult = false;
  int backgroundRegistrations = 0;
  int permissionRequests = 0;
  int tokenReads = 0;
  int tokenDeletes = 0;
  String? token = 'registration-token';

  @override
  Future<void> registerBackgroundHandler() async {
    backgroundRegistrations++;
  }

  @override
  Future<bool> notificationsGranted() async => notificationsAllowed;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionResult;
  }

  @override
  Future<String?> getToken() async {
    tokenReads++;
    return token;
  }

  @override
  Stream<String> get onTokenRefresh => tokenRefreshes.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => foreground.stream;

  @override
  Stream<PushMessage> get onOpenedApp => opened.stream;

  @override
  Future<PushMessage?> getInitialMessage() async => initialMessage;

  @override
  Future<void> deleteToken() async {
    tokenDeletes++;
    token = null;
  }

  Future<void> close() async {
    await tokenRefreshes.close();
    await foreground.close();
    await opened.close();
  }
}

void main() {
  late _FakeMessagingDriver driver;
  late FirebasePushMessagingService service;

  setUp(() {
    driver = _FakeMessagingDriver();
    service = FirebasePushMessagingService(driver: driver);
  });

  tearDown(() async {
    await service.dispose();
    await driver.close();
  });

  test(
    'registers the background handler and routes initial and warm taps',
    () async {
      final routes = <String>[];
      final tapRouter = NotificationTapRouter();
      driver.initialMessage = PushMessage(
        data: const <String, String>{'route': '/chores/today'},
      );

      await service.initialize(tapRouter);
      tapRouter.attach(
        navigate: routes.add,
        choresEnabled: true,
        bazarEnabled: true,
      );
      driver.opened.add(
        PushMessage(data: const <String, String>{'route': '/bazar/fund'}),
      );
      await Future<void>.delayed(Duration.zero);

      expect(driver.backgroundRegistrations, 1);
      expect(routes, <String>['/chores/today', '/bazar/fund']);
      expect(driver.permissionRequests, 0);
    },
  );

  test('push inbox id opens its actionable inbox row', () async {
    final routes = <String>[];
    final tapRouter = NotificationTapRouter();
    driver.initialMessage = PushMessage(
      data: const <String, String>{'inboxId': 'inbox-1', 'route': '/inbox'},
    );

    await service.initialize(tapRouter);
    tapRouter.attach(
      navigate: routes.add,
      choresEnabled: true,
      bazarEnabled: true,
    );

    expect(routes, <String>['/inbox/inbox-1']);
  });

  test('forwards FCM permission, token and foreground APIs', () async {
    await service.initialize(NotificationTapRouter());
    driver.notificationsAllowed = true;
    driver.permissionResult = true;

    expect(await service.notificationsGranted(), isTrue);
    expect(await service.requestPermission(), isTrue);
    expect(await service.getToken(), 'registration-token');

    final message = PushMessage(
      title: 'Update',
      body: 'A generic update',
      data: const <String, String>{'inboxId': 'inbox-1'},
    );
    final received = expectLater(service.onForegroundMessage, emits(message));
    driver.foreground.add(message);
    await received;

    await service.deleteToken();
    expect(driver.permissionRequests, 1);
    expect(driver.tokenReads, 1);
    expect(driver.tokenDeletes, 1);
  });
}
