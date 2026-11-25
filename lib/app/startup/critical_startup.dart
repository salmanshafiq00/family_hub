import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/startup/startup_step.dart';
import 'package:family_hub/core/firebase/firebase_bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two steps the app cannot run without. A failure is a [StartupFailure]
/// and is shown on the startup error screen.
Future<SharedPreferences> runCriticalStartup(Flavor flavor) async {
  final prefs = await runCriticalStep(
    'shared_preferences',
    SharedPreferences.getInstance,
    timeout: const Duration(seconds: 5),
  );
  await runCriticalStep(
    'firebase',
    () => initializeFirebase(flavor: flavor, prefs: prefs),
    timeout: const Duration(seconds: 20),
  );
  return prefs;
}
