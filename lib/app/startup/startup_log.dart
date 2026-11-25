import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

final Stopwatch _sinceStart = Stopwatch()..start();

/// Startup breadcrumb. `debugPrint` shows in the `flutter run` terminal;
/// `developer.log` often does not, so we use both.
void startupLog(String message, {Object? error, StackTrace? stack}) {
  debugPrint(
    '[startup +${_sinceStart.elapsedMilliseconds}ms] $message'
    '${error == null ? '' : ' -> $error'}',
  );
  if (stack != null) debugPrint(stack.toString());
  developer.log(
    message,
    name: 'family_hub.startup',
    error: error,
    stackTrace: stack,
    level: error == null ? 800 : 1000,
  );
}

/// Replaces the hooks that used to live in bootstrap.dart (`_logError`,
/// FlutterError.onError, PlatformDispatcher.onError).
void installGlobalErrorHooks() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    startupLog(
      'Uncaught Flutter error',
      error: details.exception,
      stack: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    startupLog('Uncaught platform error', error: error, stack: stack);
    return true;
  };
}
