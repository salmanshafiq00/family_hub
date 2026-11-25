import 'dart:async';

import 'package:family_hub/app/startup/startup_log.dart';

/// A critical step failed or timed out: the app shows StartupErrorApp.
final class StartupFailure implements Exception {
  const StartupFailure(this.step, this.cause, this.stackTrace);

  final String step;
  final Object cause;
  final StackTrace stackTrace;

  @override
  String toString() => 'Startup step "$step" failed: $cause';
}

/// Runs a prerequisite. Never waits longer than [timeout]. Failure -> [StartupFailure].
Future<T> runCriticalStep<T>(
  String step,
  Future<T> Function() body, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  startupLog('$step: start');
  try {
    final value = await body().timeout(timeout);
    startupLog('$step: ok');
    return value;
  } on Object catch (error, stack) {
    startupLog('$step: FAILED', error: error, stack: stack);
    throw StartupFailure(step, error, stack);
  }
}

/// Runs a feature that must never stop the app. Never waits longer than [timeout]. Failure is only logged.
Future<void> runOptionalStep(
  String step,
  Future<void> Function() body, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  startupLog('$step: start');
  try {
    await body().timeout(timeout);
    startupLog('$step: ok');
  } on Object catch (error, stack) {
    startupLog('$step: FAILED (app continues)', error: error, stack: stack);
  }
}
