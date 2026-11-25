import 'package:family_hub/app/startup/startup_step.dart';
import 'package:flutter/widgets.dart';

/// Runs AFTER the first frame is on screen. Injected callbacks keep it testable.
Future<void> initOptionalPlatformServices({
  required Future<void> Function() notifications,
  required Future<void> Function() push,
  Future<void> Function()? afterFirstFrame,
  Duration timeout = const Duration(seconds: 15),
}) async {
  await (afterFirstFrame ?? () => WidgetsBinding.instance.endOfFrame)();
  await runOptionalStep('local_notifications', notifications, timeout: timeout);
  await runOptionalStep('push_messaging', push, timeout: timeout);
}
