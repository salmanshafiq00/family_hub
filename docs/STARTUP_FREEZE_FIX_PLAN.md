# Family Hub — Fix Plan: app freezes on the launch logo (startup hardening) + review of the bulk-assign commit

**Written:** 2026-11-25 against `android.zip` (the tree that contains `docs/FIX_PLAN_STARTER_NOTIFY_AGENDA.md`).
**Symptom:** `flutter run --flavor dev -t lib/main_dev.dart` on a physical phone installs and launches, but only the logo is shown and nothing else, forever.
**Purpose:** written so any AI coding tool can implement it without design thinking. Same house style as `FIX_PLAN_STARTER_NOTIFY_AGENDA.md`: root cause, exact edits, tests, manual check, done-when.

**How to use:** do **STARTUP-0 yourself first** (10 minutes, no code). Then one item = one branch = one commit. Paste into the AI tool:
> Read CLAUDE.md and this plan. Implement item STARTUP-n exactly as written. List the files you will touch first. Do not touch anything else. End with: files changed, how to verify, assumptions.

**Before every commit (CLAUDE.md gates):** `dart format .` · `flutter gen-l10n` (no diff after) · `flutter analyze` (zero issues) · `flutter test --exclude-tags golden`. Architecture tests apply: files ≤ 300 lines, no `Colors.*`, no raw `Color(0x`, no hard-coded UI strings (ARB only, Bangla in `app_bn.arb` and English in `app_en.arb`), no `TODO(step-`.

**Order:** STARTUP-0 → STARTUP-1 → STARTUP-2 → STARTUP-3.

---

## What I checked, and what I could not

| Checked (by reading the files in the zip) | Not possible for me |
| --- | --- |
| `android/` (manifest, Gradle, `MainActivity`, resources, `google-services.json`), `lib/app/bootstrap.dart`, `main_dev.dart`, `app.dart`, `push_hook.dart`, `firebase_bootstrap.dart`, both notification services, `firebase_options_*.dart`, `firebase/README.md`, the Firestore rules for `notificationInbox`, every file named in FIX-3, the ARB + generated l10n files, the `bootstrap_overrides_test` logic (re-run by script: nothing missing). | Run Flutter, the app, or the tests (no SDK here). Read the git history (the zip has no `.git`), so "the last commit" is judged by comparing the code with FIX-3 in `FIX_PLAN_STARTER_NOTIFY_AGENDA.md`. See your real `firebase_options_*.dart` values: the zip copy holds placeholders (see root cause 1). |

**Verdict in one paragraph.** The bulk-assign commit (FIX-3) is implemented correctly and is **not** what freezes the app: it adds no code that runs before the first frame, and all provider wiring is present. The freeze is a startup-design problem: `bootstrap()` waits for three platform calls before it ever calls `runApp()`, with no timeout and no visible error. If any of them throws or never answers, Flutter never draws a frame and Android keeps showing the launch icon (the "logo"). The most likely trigger is the Firebase configuration check (root cause 1), and several other steps can cause the same silent freeze (root cause 2).

---

## Root cause (verified in code)

**Why it is "only the logo".** The app has no in-app logo (the only declared assets are fonts, `pubspec.yaml` line 49-63). The logo you see is Android's launch splash (adaptive icon). It stays until Flutter draws its first frame. The first frame needs `runApp()`.

`lib/app/bootstrap.dart` runs these awaits **before** `runApp()` (line numbers of the current file):

| Line | Call | What can go wrong |
| --- | --- | --- |
| 125 | `SharedPreferences.getInstance()` | very unlikely |
| 134 | `reminderScheduler.initialize(...)` | `ensureTimeZonesInitialized()` and `notificationChannels()` run **outside** the `try` in `local_notifications_scheduler.dart` line 39-40; the plugin call has no timeout. Your first log shows `FlutterLocalNotificationsPlugin.initialize` hitting `NullPointerException: Context.getResources() on a null object` right after the activity was created twice (two `callActivityOnCreate`) and the first engine was detached. |
| 140 | `initializeFirebase(...)` | throws `FirebaseNotConfiguredException` when the options hold placeholders (root cause 1); `CacheWipe.clearPersistence()` and the Firestore `settings` assignment can throw after an activity restart; no timeout. |
| 143 | `pushMessagingService.initialize(...)` | `firebase_messaging` calls on a phone without Google Play services can fail or never complete. Your log contains Huawei/EMUI markers (`HwPhoneWindow`, `HiTouch`). |

Any exception inside this chain is caught by `runZonedGuarded` and passed to `_logError`, which only calls `developer.log`. `developer.log` normally does **not** appear in the `flutter run` terminal (it shows in DevTools → Logging or the IDE debug console). `debugPrint` does. That is why your terminal shows no error: the failure is real but silent.

### Root cause 1 (most likely): placeholder Firebase configuration
- `lib/core/firebase/firebase_options_dev.dart` in the zip: `appId: '1:100000000001:android:devplaceholder00001'`.
- `android/app/src/dev/google-services.json` in the zip: `project_number 100000000001`, `project_id familyhub-dev`, placeholder key. The README says the real project is `familyhub-app-ai`.
- `lib/core/firebase/firebase_bootstrap.dart` line 25 calls `assertFirebaseConfigured`, which **throws** on placeholders unless `USE_EMULATOR=true`.
- `firebase/README.md` ("Real Firebase configuration") says the real values live **only in your working tree** and the four files are marked `skip-worktree` so git shows placeholders. In the zip all four files have the same timestamp (2026-11-24 06:44) as every other file, which is what a checkout, clone, stash or reset produces. If a git operation (yours or an AI tool's) rewrote them, your real keys are gone and the app now throws at startup. If the zip was only a clean export and your local files still hold real keys, root cause 1 does not apply and STARTUP-0 will show that.

### Root cause 2 (always true, even with correct keys): no startup step is bounded
Optional services (local notification setup, push setup, cache wipe) are allowed to block or kill startup. A phone without Google Play services, a restarted activity, or a stale "wipe cache" flag (`wipeFirestoreCacheOnNextStart` is only cleared after a **successful** wipe, so one failure repeats on every start) all produce the same frozen logo.

---

## Decisions I made (change them if you disagree)

| # | Decision | Why |
| --- | --- | --- |
| A | Only **Firebase init** (and SharedPreferences) are *critical* at startup. A failure shows an error screen with the step name, the message and a Retry button. | The app cannot work without them, but you must be able to read why. |
| B | Local-notification setup and push setup move to **after the first frame**, each with a 15 s timeout, failures only logged. | They are features, not prerequisites. The reminder scheduler's public methods will *wait* for its setup instead of throwing. |
| C | A failed Firestore cache wipe or a failed Firestore `settings` assignment does **not** block startup; it is logged and the wipe flag stays raised, so the wipe is retried next start. | Keeps the app usable. Trade-off: after a failed wipe a different person signing in on the same phone could briefly see the previous cache. If you prefer fail-closed, make the wipe a critical step instead. |
| D | The error screen shows Bangla **and** English together and needs no providers. | It must work when nothing else has started. |
| E | All logging on the startup path uses `debugPrint` (plus `developer.log`). | `developer.log` is invisible in the terminal. |

---

## STARTUP-0 — Find out what is really failing (you do this, no code, 10 minutes)

Run in the repo root (Windows PowerShell). Write the result next to each line.

1. **Are the Firebase files real?**
   ```powershell
   Select-String -Path lib\core\firebase\firebase_options_dev.dart -Pattern 'placeholder'
   Get-Content android\app\src\dev\google-services.json | Select-String 'project_id|package_name|project_number'
   git ls-files -v | Select-String '^S'
   ```
   | Result | Meaning | Action |
   | --- | --- | --- |
   | The first command prints lines containing `devplaceholder`, or `project_id` is `familyhub-dev` | The real keys are gone from your working tree. **This is the freeze.** | Re-apply them with the README section "Real Firebase configuration" (`flutterfire configure` commands are there, transcribe `apiKey`/`appId`/`messagingSenderId` into the `android` block of both options files, copy the two `google-services.json`), then run `git update-index --skip-worktree` on the four files again. The dev `google-services.json` must show package `com.familyhub.family_hub.dev` and project `familyhub-app-ai`. |
   | No `placeholder` anywhere, `git ls-files -v` lists the four files with `S` | Config is fine. | Continue with 2-4; STARTUP-1 is still needed. |
   | No `placeholder`, but the four files are **not** listed with `S` | Real keys are in the working tree but not protected from `git checkout`/`stash`. | Run `git update-index --skip-worktree lib/core/firebase/firebase_options_dev.dart lib/core/firebase/firebase_options_prod.dart android/app/src/dev/google-services.json android/app/src/prod/google-services.json`. |

2. **Clear stale app state** (removes a stuck cache-wipe flag and old prefs):
   ```powershell
   adb shell pm clear com.familyhub.family_hub.dev
   flutter run --flavor dev -t lib/main_dev.dart
   ```
3. **Does the phone have Google Play services?**
   ```powershell
   adb shell pm list packages | Select-String 'gms'
   ```
   No output = no GMS. Push (FCM) cannot work on that phone, so push must never block startup (STARTUP-1 does this). Keep the push tests for a phone with GMS.
4. **See the hidden error right now** (before any code change): in VS Code run the app with F5 and read **Debug Console**, or open DevTools → **Logging** and look for `Uncaught error` from `family_hub`. Copy that exact text; it is the answer. If you can paste it to me, the diagnosis is certain.

**Done when:** you know which row of the table applies. If row 1 applied and the app starts after re-applying the keys, the freeze is cured for you, but do STARTUP-1 anyway so it can never be silent again.

---

## STARTUP-1 — Make startup unable to hang or die silently

### New files (all under `lib/app/startup/`, each well below 300 lines)

**1. `startup_log.dart`**
```dart
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

final Stopwatch _sinceStart = Stopwatch()..start();

/// Startup breadcrumb. `debugPrint` shows in the `flutter run` terminal;
/// `developer.log` often does not, so we use both.
void startupLog(String message, {Object? error, StackTrace? stack}) {
  debugPrint('[startup +${_sinceStart.elapsedMilliseconds}ms] $message'
      '${error == null ? '' : ' -> $error'}');
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
    startupLog('Uncaught Flutter error', error: details.exception, stack: details.stack);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    startupLog('Uncaught platform error', error: error, stack: stack);
    return true;
  };
}
```
(`PlatformDispatcher` comes from `dart:ui`; import it, or keep the existing `package:flutter/widgets.dart` import which re-exports it as bootstrap.dart does today.)

**2. `startup_step.dart`**
```dart
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
```

**3. `critical_startup.dart`**
```dart
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
```

**4. `optional_services.dart`**
```dart
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
```

**5. `startup_error_app.dart`** — a `StatelessWidget` `StartupErrorApp({required StartupFailure failure, required VoidCallback onRetry})` returning its own `MaterialApp` (no Riverpod, no router, no theme registry):
- `theme: ThemeData(useMaterial3: true)` and `darkTheme: ThemeData.dark(useMaterial3: true)`, `themeMode: ThemeMode.system`. Colors only through `Theme.of(context).colorScheme` (no `Colors.*`, no `Color(0x`).
- `localizationsDelegates: AppLocalizations.localizationsDelegates`, `supportedLocales: AppLocalizations.supportedLocales`.
- Texts from `lookupAppLocalizations(const Locale('bn'))` **and** `lookupAppLocalizations(const Locale('en'))` (Bangla line first, English line under it).
- Layout: `Scaffold` → `SafeArea` → `SingleChildScrollView` (must scroll at text scale 2.0) → icon `Icons.error_outline_rounded` (size 48, `colorScheme.error`), title, body, a step label, the failure text in a `SelectableText`, the Firebase hint **only if** `failure.cause is FirebaseNotConfiguredException` (import from `core/firebase/firebase_options_resolver.dart`), and a `FilledButton` Retry with `minimumSize: Size(48, 48)`.

### New ARB keys (both files, then `flutter gen-l10n`)
| Key | bn | en |
| --- | --- | --- |
| `startupFailedTitle` | `অ্যাপ চালু হতে পারেনি` | `The app could not start` |
| `startupFailedBody` | `শুরুর একটি ধাপ ব্যর্থ হয়েছে। নিচের বিবরণ ডেভেলপারকে দেখান।` | `A startup step failed. Show the details below to the developer.` |
| `startupStepLabel` (placeholder `step`: String) | `ধাপ: {step}` | `Step: {step}` |
| `startupFirebaseHint` | `Firebase-এর কী এখনো আসল নয়। firebase/README.md-এর "Real Firebase configuration" অংশ দেখুন।` | `The Firebase keys are still placeholders. See firebase/README.md → "Real Firebase configuration".` |

Reuse the existing `actionRetry` key for the button. Do not add a Retry key.

### Edit `lib/app/bootstrap.dart` (currently 294 lines, hard cap 300)
1. **Delete** `_logError` (lines 89-97) and the two handler blocks (lines 113-120); call `installGlobalErrorHooks();` right after `WidgetsFlutterBinding.ensureInitialized();`. Pass `startupLog('Uncaught error', error: e, stack: s)` as the `runZonedGuarded` error callback (line 293).
2. **Replace lines 122-143** (prefs load, scheduler init, Firebase init, push init) with:
   ```dart
   final SharedPreferences prefs;
   try {
     prefs = await runCriticalStartup(flavor);
   } on StartupFailure catch (failure) {
     runApp(StartupErrorApp(
       failure: failure,
       onRetry: () => unawaited(bootstrap(flavor)),
     ));
     return;
   }

   final notificationTapRouter = NotificationTapRouter();
   final reminderScheduler = LocalNotificationsScheduler(
     preferences: prefs,
     tapRouter: notificationTapRouter,
     applicationId: flavor.applicationId,
   );
   final languageCode = prefs.getString('language_code') == 'en' ? 'en' : 'bn';
   final pushMessagingService = FirebasePushMessagingService();
   ```
   (the constructors do no I/O; Firebase is already initialized, as before).
3. **After** the `runApp(...)` call (still inside the zone) add:
   ```dart
   unawaited(initOptionalPlatformServices(
     notifications: () => reminderScheduler.initialize(
       localizations: lookupAppLocalizations(Locale(languageCode)),
     ),
     push: () => pushMessagingService.initialize(notificationTapRouter),
   ));
   ```
4. Keep the whole `overrides:` list **inside bootstrap.dart** (`test/app/bootstrap_overrides_test.dart` reads that file as text). Remove imports that became unused. Confirm `wc -l lib/app/bootstrap.dart` ≤ 300.

### Edit `lib/core/notifications/data/local_notifications_scheduler.dart` (261 lines now)
1. Add field `final Completer<void> _ready = Completer<void>();` (import `dart:async`).
2. `initialize(...)`: move `ensureTimeZonesInitialized();` and `_channels = notificationChannels(localizations);` **inside** the `try`, and add `finally { if (!_ready.isCompleted) _ready.complete(); }`. The `catch` stays (records the error).
3. Replace `void _ensureInitialized()` (line 201-207) with:
   ```dart
   Future<void> _ensureInitialized() async {
     // Setup now runs after the first frame; callers wait for it instead of failing.
     await _ready.future.timeout(const Duration(seconds: 20), onTimeout: () {});
     if (!_initialized) {
       throw StateError(_lastError ?? 'The local notification adapter is not initialized.');
     }
   }
   ```
4. Add `await` to every call site: `pending`, `schedule`, `showNow`, `cancel`, `cancelAll`, `permissions`, `requestNotifications`, `requestExactAlarms`, and inside the `try` of `diagnostics`.
5. Do not change the public `ReminderScheduler` interface. All callers already catch errors (`reminder_sync_controller.dart` lines 59-142, `reminder_providers.dart` line 86).

### Edit `lib/core/firebase/firebase_bootstrap.dart`
1. Wrap the `FirebaseFirestore.instance.settings = ...` assignment (line 31-33) in `try { ... } on Object catch (e, s) { startupLog('firestore settings not applied', error: e, stack: s); }`. After an activity restart in the same process the native Firestore can already be started and the assignment throws.
2. Wrap the `CacheWipe.wipeIfRequested(...)` block (line 44-49) the same way. The flag stays raised on failure, so the wipe is retried next start (Decision C).
3. Do **not** wrap `Firebase.initializeApp`, `assertFirebaseConfigured` or the emulator calls: their failures must reach the error screen.

### Edit `lib/core/notifications/data/push_messaging_service.dart`
No code change needed: `initialize` (line 43-60) is now bounded by `runOptionalStep`. Keep `_initialized = true` last, as it is.

### Tests
`test/app/startup/startup_step_test.dart` (use short real timeouts, e.g. 50 ms, and a never-completing `Completer`):
- `runCriticalStep` success returns the value.
- body throws → `StartupFailure` with the right `step`.
- body never completes → `StartupFailure` whose `cause` is `TimeoutException`.
- `runOptionalStep` with a throwing body and with a never-completing body returns normally (no exception).

`test/app/startup/optional_services_test.dart`: both callbacks never complete, `timeout: 50ms`, `afterFirstFrame: () async {}` → the returned future completes. One callback throws → the other still runs.

`test/app/startup/startup_error_app_test.dart` (widget): shows step name and error text in Bangla and English; shows the Firebase hint for `FirebaseNotConfiguredException(Flavor.dev)` and not for `StateError`; Retry calls `onRetry`; no overflow at 360 dp wide with `textScaler` 2.0 (scrollable); button ≥ 48 dp.

`test/core/notifications/local_notifications_scheduler_test.dart` (extend, or create with a fake `LocalNotificationsDriver`): a call to `pending()` made **before** `initialize` completes waits and then succeeds; if the driver throws in `initialize`, `pending()` throws `StateError` with the recorded message; `ensureTimeZonesInitialized` failure is recorded (not thrown) by `initialize`.

Existing tests that must keep passing: `bootstrap_overrides_test`, `file_size_test`, `no_hardcoded_options_test`, `notification_plugin_boundary_test`, `layer_boundaries_test`.

### Manual check (real phone)
1. Normal run: the terminal prints `[startup +…ms] shared_preferences: ok`, `firebase: ok`, the UI appears within about 2 s, then `local_notifications: ok` and `push_messaging: ok` (or `FAILED (app continues)` on a phone without GMS, with the app fully usable).
2. Simulate placeholders: temporarily put `placeholder` into the `android` `appId` of `firebase_options_dev.dart` → the error screen appears at once with the Firebase hint. Revert.
3. Simulate a hang: temporarily make the push callback `await Completer<void>().future;` → the app opens normally; after 15 s the terminal shows `push_messaging: FAILED … TimeoutException`. Revert.
4. `adb shell pm clear com.familyhub.family_hub.dev`, cold start; start in airplane mode; kill and relaunch twice.

**Done when:** every row above behaves as written, all gates are green, and there is no code path before `runApp()` that waits without a timeout or swallows its error.

---

## STARTUP-2 — A check that catches lost Firebase keys in 2 seconds

**Why:** the real keys are deliberately hidden from git, so nothing tells you when they are lost. CI must **not** run this (CI has placeholders on purpose); it is a local command.

**New file `tool/check_firebase_config.dart`** (pure Dart, no Flutter imports, exit code 1 on any FAIL):
1. For `dev` and `prod`, read `lib/core/firebase/firebase_options_<flavor>.dart`. Take the text from `static const FirebaseOptions android` to the next `);`. Extract `apiKey`, `appId`; extract `static const String projectId`. FAIL if `apiKey` or `appId` contains `placeholder`.
2. Read `android/app/src/<flavor>/google-services.json`. FAIL if: `project_info.project_id` ≠ `projectId`; `client[0].client_info.android_client_info.package_name` ≠ `com.familyhub.family_hub.dev` (dev) / `com.familyhub.family_hub` (prod); `client[0].client_info.mobilesdk_app_id` ≠ the options `appId`; `client[0].api_key[0].current_key` contains `placeholder`.
3. Run `git ls-files -v` through `Process.run`; WARN (not FAIL) for each of the four files whose line does not start with `S ` ("not protected by skip-worktree").
4. Print one line per check: `PASS dev options`, `FAIL dev google-services: project_id familyhub-dev != familyhub-app-ai`. Never print the key values.

**Docs:** add to `firebase/README.md` under "Real Firebase configuration": "Check any time: `dart run tool/check_firebase_config.dart`. Run it after every `git checkout`, `stash`, `reset`, `pull` or clone."

**Test:** `test/tool/check_firebase_config_test.dart` — extract the checks into a pure function taking file contents (put it in `tool/check_firebase_config_lib.dart`) and test PASS/FAIL cases with strings. The test must not read your real files.

**Done when:** it prints FAIL on the zip's placeholder files and PASS on your real configuration.

---

## STARTUP-3 — Review of the bulk-assign commit (FIX-3) and follow-ups

### What is correct (verified)
- `AutoShareAbsentChores` calls `reassign(..., notify: false)` for each move, groups moves per recipient, writes **one** summary row per recipient with id `ib_as_<firstChoreId>` (idempotent), skips the actor, and returns the unchanged `moved` count.
- `InboxPort.choresAssignedSummary` exists in the interface, in `NoopInboxPort` (returns `null`) and in `ChoresInboxPort` (type `chore_assigned`, `params.kind = summary`, 5 params).
- Firestore rules accept it without a change: `chore_assigned` is in `inboxTypes()`, `refType` 1-40 chars, `refId` up to 200 chars (`ib_as_` + a chore id fits), `params` ≤ 6.
- `autoShareAbsentChoresProvider` passes `inbox` and `clock`; `inboxPortProvider` is overridden in bootstrap.
- `inbox_text.dart` renders the summary; `inbox_open_action.dart` routes a summary to `AppRoutes.chores`, and the new check sits before the `refType` switch.
- All five new ARB keys exist in both languages and in the generated l10n files.
- `test/.../auto_share_absent_chores_test.dart` covers: one summary for several chores, a second run moves nothing, two recipients, a chore moved to the actor.

### Gaps and small fixes
1. **Missing tests from the FIX-3 plan** (only the use-case test exists). Add:
   - `inbox_text` test: a summary row renders the sentence in bn (Bangla digits) and en.
   - `openInboxItem` test: a summary row navigates to `/chores`; a normal `chore_assigned` row still opens its occurrence.
   - Foreground-bridge test: one new summary row ⇒ exactly one `showNow`.
   - Run `verify_reopen_skip_reassign_test.dart` (single reassign still notifies: `'chore_assigned -> dave'`).
2. **"Best effort" is only half true.** In `auto_share_absent_chores.dart` line 199-204 the result of `occurrences.stageIntegrity(...)` is ignored, but an exception would still escape and turn a successful move into an error. Wrap the call: `try { await occurrences.stageIntegrity(...); } on Object { /* best effort: the moves already happened */ }`. Add a test with a repository whose `stageIntegrity` throws: `call` still returns `Success(moved)`.
3. **English wording (optional polish).** `"{count} chore(s)"` reads oddly. If you want proper plurals: add an `int count` placeholder next to the formatted text, e.g. en `"{name} assigned you {count, plural, =1{1 chore} other{{countText} chores}} from {from} to {to}"`, and pass both `count` and `formatters.number(count)`. Skip if short on time.

**Done when:** the three missing tests exist and pass, the throwing-repository test passes, gates are green.

---

## Optional observations (no action needed unless they bite)

- **Activity restarted once at startup** (two `callActivityOnCreate` in your first log, same process). The manifest's `configChanges` list equals Flutter's default template, so this is a device/ROM behavior. STARTUP-1 makes the app indifferent to it. If it still happens after STARTUP-1, capture `adb logcat -b events | Select-String wm_relaunch` right after launching: it names the cause.
- **Gradle/Kotlin warnings** in your log (restricted native access, plugins applying KGP: `firebase_auth`, `firebase_core`) are warnings only. Do not change `android.builtInKotlin` / `android.newDsl` in `gradle.properties` as part of this fix.
- **Sharing the project for review:** the zip included `.gradle` caches (70 MB), `android/key.properties` and `android/local.properties`. Next time send only `lib/`, `test/`, `docs/`, `pubspec.yaml`, `pubspec.lock`, `android/app/src`, `android/*.kts`, `android/gradle.properties`, plus the output of `git show --stat HEAD` and `git diff HEAD~1` so a review can see the real commit. Never send `key.properties`, `*.jks` or real `google-services.json`.

## Final acceptance (all must be true)
- With real Firebase keys: cold start shows the app UI in about 2 s; terminal shows the startup breadcrumbs.
- With placeholder keys: the error screen appears, in Bangla and English, with the Firebase hint and a Retry button. Never a frozen logo.
- With push or notification setup hanging: the app still opens; the failure is only a log line.
- `dart run tool/check_firebase_config.dart` reports PASS on your machine.
- All gates green: `dart format .`, `flutter gen-l10n` (no diff), `flutter analyze`, `flutter test --exclude-tags golden`.
