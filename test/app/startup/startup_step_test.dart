import 'dart:async';

import 'package:family_hub/app/startup/startup_step.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('runCriticalStep', () {
    test('returns the value of a successful body', () async {
      final value = await runCriticalStep(
        'ok-step',
        () async => 42,
        timeout: const Duration(milliseconds: 50),
      );

      expect(value, 42);
    });

    test(
      'wraps a throwing body in StartupFailure with the step name',
      () async {
        final failure = await _criticalFailure(
          () => Future<int>.error(StateError('boom')),
        );

        expect(failure.step, 'critical-step');
        expect(failure.cause, isA<StateError>());
        expect(failure.cause.toString(), contains('boom'));
      },
    );

    test('a body that never completes fails with a TimeoutException', () async {
      final failure = await _criticalFailure(() => Completer<int>().future);

      expect(failure.step, 'critical-step');
      expect(failure.cause, isA<TimeoutException>());
    });
  });

  group('runOptionalStep', () {
    test('a throwing body returns normally', () async {
      await expectLater(
        runOptionalStep(
          'optional-step',
          () => Future<void>.error(StateError('boom')),
          timeout: const Duration(milliseconds: 50),
        ),
        completes,
      );
    });

    test('a body that never completes returns normally', () async {
      await expectLater(
        runOptionalStep(
          'optional-step',
          () => Completer<void>().future,
          timeout: const Duration(milliseconds: 50),
        ),
        completes,
      );
    });
  });
}

Future<StartupFailure> _criticalFailure(Future<int> Function() body) async {
  try {
    await runCriticalStep(
      'critical-step',
      body,
      timeout: const Duration(milliseconds: 50),
    );
  } on StartupFailure catch (failure) {
    return failure;
  }
  fail('expected a StartupFailure');
}
