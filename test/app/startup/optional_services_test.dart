import 'dart:async';

import 'package:family_hub/app/startup/optional_services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('never-completing callbacks do not stop the app', () async {
    var afterFirstFrame = false;

    await initOptionalPlatformServices(
      notifications: () => Completer<void>().future,
      push: () => Completer<void>().future,
      afterFirstFrame: () async {
        afterFirstFrame = true;
      },
      timeout: const Duration(milliseconds: 50),
    );

    expect(afterFirstFrame, isTrue);
  });

  test('one throwing callback does not stop the other', () async {
    var pushRan = false;

    await initOptionalPlatformServices(
      notifications: () => Future<void>.error(StateError('notifications')),
      push: () async {
        pushRan = true;
      },
      afterFirstFrame: () async {},
      timeout: const Duration(milliseconds: 50),
    );

    expect(pushRan, isTrue);
  });
}
