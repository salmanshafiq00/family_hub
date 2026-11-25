import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/startup/startup_log.dart';
import 'package:family_hub/core/firebase/cache_wipe.dart';
import 'package:family_hub/core/firebase/firebase_options_resolver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes Firebase, Firestore persistence, and emulator routing.
///
/// [prefs] (H9): when the "wipe on next start" flag is raised, the on-disk
/// Firestore cache is cleared here, BEFORE anything reads or writes Firestore.
Future<void> initializeFirebase({
  required Flavor flavor,
  bool? useEmulator,
  SharedPreferences? prefs,
}) async {
  final shouldEmulate =
      useEmulator ??
      const bool.fromEnvironment('USE_EMULATOR', defaultValue: false);

  if (Firebase.apps.isEmpty) {
    final options = firebaseOptionsForFlavor(flavor);
    assertFirebaseConfigured(flavor, options, useEmulator: shouldEmulate);
    await Firebase.initializeApp(options: options);
  }

  // Configure Firestore offline persistence (enabled by default on mobile platforms,
  // explicit settings ensure persistence is active). After an activity restart in the
  // same process the native Firestore can already be started, so this must not block
  // startup.
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } on Object catch (error, stack) {
    startupLog('firestore settings not applied', error: error, stack: stack);
  }

  if (shouldEmulate) {
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';

    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
  }

  if (prefs != null) {
    // A failed wipe is logged and the flag stays raised, so it is retried next
    // start. Startup must not fail because the cache is busy.
    try {
      await CacheWipe.wipeIfRequested(
        prefs,
        FirebaseFirestore.instance.clearPersistence,
      );
    } on Object catch (error, stack) {
      startupLog(
        'firestore cache wipe not completed',
        error: error,
        stack: stack,
      );
    }
  }
}
