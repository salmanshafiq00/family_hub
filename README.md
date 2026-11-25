# Family Hub

Bangla-first household app: bazar / family finance + family chores.
Flutter, Riverpod, Firebase (Spark plan). Architecture rules: `CLAUDE.md`.
Docs: `docs/` for the Bazar and Chores contracts, runbooks and ADRs (`docs/decisions/`).

## Prerequisites
| Tool | Version |
| --- | --- |
| Flutter / Dart | Flutter 3.47.7 (Dart 3.13.x) - the version CI uses (`FLUTTER_VERSION` in `.github/workflows/ci.yml`) |
| JDK for Android builds | 17 |
| JDK for the Firestore emulator | 21 or newer |
| Node (rules tests, index check) | 24 |
| Firebase CLI | `npm i -g firebase-tools` |

## Commands
| Task | Command |
| --- | --- |
| Install packages | `flutter pub get` |
| Run dev | `flutter run --flavor dev -t lib/main_dev.dart` |
| Run dev against emulators | `flutter run --flavor dev -t lib/main_dev.dart --dart-define=USE_EMULATOR=true` |
| Run prod | `flutter run --flavor prod -t lib/main_prod.dart` |
| Unit + widget tests (no goldens) | `flutter test --exclude-tags golden` |
| Format / analyze | `dart format .` and `flutter analyze` |
| Rules tests | `npm ci --prefix firebase/rules_test && npm run test:emulator --prefix firebase/rules_test` |
| Index file check | `node tools/check_indexes.mjs` |
| Build APK (dev) | `flutter build apk --flavor dev -t lib/main_dev.dart` |
| Build APK (prod, release) | `flutter build apk --release --flavor prod -t lib/main_prod.dart` (needs `android/key.properties`, see `docs/RELEASE.md`) |

There is no code generation step: models are hand-written immutable classes and
localizations are checked in (`flutter gen-l10n` regenerates them after an ARB change).

## Launcher icons
Each flavor has its own launcher icon: teal for prod, orange for dev. The generated
resources live in `android/app/src/prod/res/` and `android/app/src/dev/res/`
(`mipmap-*` PNGs, `mipmap-anydpi-v26/ic_launcher.xml`, `drawable-*` foreground, and
`values/colors.xml` with the adaptive background); `main/res` carries no launcher icon.

```bash
# Regenerate after changing an image in assets/icon/ (reads both flavor configs)
flutter pub get
dart run flutter_launcher_icons
```

The tool picks the flavor from the config file name
(`flutter_launcher_icons-prod.yaml`, `flutter_launcher_icons-dev.yaml`). The images in
`assets/icon/` are icon sources only and are not listed under `flutter: assets:`.
Launchers cache icons, so uninstall the app before checking a new one.

```bash
# Run each flavor
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart
```

## Golden (image) tests
Goldens are **only** generated on Linux, by the `Update goldens` GitHub workflow
(Actions -> Update goldens -> Run workflow). Download the `linux-goldens` artifact, unzip it
at the repo root and commit the PNGs. Never commit goldens rendered on Windows or macOS.
Locally, skip them: `flutter test --exclude-tags golden`.

## Firebase
One Firebase project, `familyhub-app-ai`, backs both build flavors (aliases in `.firebaserc`).
Wiring (`flutterfire configure`, `google-services.json`, deploying rules and indexes) is in
`firebase/README.md`; it is already done for Android on the owner's machine. The real
`android/app/src/{dev,prod}/google-services.json` and the `android` blocks of
`lib/core/firebase/firebase_options_{dev,prod}.dart` are marked `skip-worktree` and must never be
committed — their project number, app ids and API key must not be copied into any tracked file.
A run with placeholder keys against real Firebase fails at startup
(`FirebaseNotConfiguredException`); `--dart-define=USE_EMULATOR=true` still works everywhere.

### Emulators
Auth (9099), Firestore (8080), UI (4000):
```bash
firebase emulators:start --only auth,firestore
flutter run --flavor dev -t lib/main_dev.dart --dart-define=USE_EMULATOR=true
```
On an Android emulator the app connects to `10.0.2.2`, elsewhere to `127.0.0.1`.
The Emulator UI is at http://localhost:4000. `firebase emulators:start` needs a
JDK 21+; Android Studio ships one — see `firebase/README.md` for the `JAVA_HOME`
lines and for the curl that marks an emulator user's e-mail address verified
(every rule except the owner's own profile requires it).

Without a terminal attached to `flutter run`, the same check works headlessly:

```bash
flutter build apk --debug --flavor dev -t lib/main_dev.dart --dart-define=USE_EMULATOR=true
"$ANDROID_SDK_ROOT/platform-tools/adb" install -r -g build/app/outputs/flutter-apk/app-dev-debug.apk
"$ANDROID_SDK_ROOT/platform-tools/adb" shell am start -n \
  "com.familyhub.family_hub.dev/com.familyhub.family_hub.MainActivity"
```

The activity class stays in the `com.familyhub.family_hub` package; only the
applicationId carries the `.dev` suffix.

## Chores (Phase 3)

Chore templates with slots and recurrence, rotating duty groups, a generated chore calendar (Agenda / Month / Week) with projected future chores, Today, subtasks with verification, comments, absences, swaps and covers, an inbox, a workload board and Home dashboard cards (Today, Overdue, Awaiting verification, This week).

## Dashboard, notifications and engagement (Phase 4)

Home renders real data through role-based card policy and a per-user layout;
local reminders are planned on the phone with a Push/Normal choice per type that
stays effectively Normal while the family is on Spark (no sender); stats, levels,
badges and the once-a-day celebration are private by default, with an opt-in
points-free level card. What Phase 5 may build on is in
`docs/phase5_contract.md`. The Firestore rules suite needs a JDK 21+ on PATH;
Android Studio ships one, so on Windows
`export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"` and
`export PATH="$JAVA_HOME/bin:$PATH"` before running it; `firebase/README.md`
carries the current suite status.
