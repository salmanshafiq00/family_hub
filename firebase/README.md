# firebase/

| File | Purpose |
| --- | --- |
| `firestore.rules` | Security rules (the backend half of every permission) |
| `firestore.indexes.json` | Composite indexes only (>= 2 fields). Checked by `node tools/check_indexes.mjs` |
| `rules_test/` | Emulator tests for the rules |

## Project

One Firebase project, `familyhub-app-ai`, serves both build flavors; `.firebaserc`
points the `default`, `dev` and `prod` aliases at it. The `dev` / `prod` split
that remains is only an Android flavor — a different app name and
`applicationId` suffix, so both installs can sit side by side on one phone.

**What that costs:** there is no second database to break. A test write from the
dev app is a real write, and `firebase deploy --only firestore:rules` changes the
rules the family is using immediately. Do rules experiments with the emulator
(`npx firebase emulators:exec`, above), and use the emulator or a family named
`QA …` for anything destructive.

```
npx firebase use dev          # or prod — both resolve to familyhub-app-ai
npx firebase deploy --only firestore:rules,firestore:indexes
```

**Deploy status, measured 2026-11-08 on `familyhub-app-ai`:** the indexes deployed successfully
(the CLI reported `(default)` database success). The rules did **not** publish — the CLI uploaded
the ruleset, then `POST …/v1/projects/familyhub-app-ai/releases` answered
`HTTP 409, Release projects/familyhub-app-ai/releases/cloud.firestore already exists`, on every
retry. That is upstream [firebase/firebase-tools#10819](https://github.com/firebase/firebase-tools/issues/10819);
the maintainers call it a backend problem with large rules files and there is no CLI workaround.
**Until it publishes, Firestore is in its console default: every client is denied** — confirmed with
an unauthenticated REST read, which returns `403 PERMISSION_DENIED` (`Missing or insufficient
permissions`). The app therefore cannot read or write real data yet.

Do it once from the console, which creates the release the CLI insists already exists: Firestore →
**Rules** → Edit rules → paste the whole contents of `firebase/firestore.rules` → **Publish**. Then
re-run the command above; the CLI path should work for later changes.

## Real Firebase configuration

**Status as of 2026-11-08: done for Android.** The `android` blocks of
`lib/core/firebase/firebase_options_*.dart` and the two `google-services.json` files carry the
real `familyhub-app-ai` values and all four files are `skip-worktree`, so the repo still shows
placeholders to git and nothing sensitive gets committed. The `ios`/`macos`/`web`/`windows` blocks
are still placeholders — the app is Android-only, and the startup guard checks only the current
platform.

Check the four files any time with `dart run tool/check_firebase_config.dart`. Run it after every
`git checkout`, `stash`, `reset`, `pull` or clone: it fails on placeholder keys or a
project/package mismatch and never prints a key value. CI does not run it (CI has placeholders on
purpose).

Re-doing it (fresh clone, or the project's keys are rotated):

```bash
git update-index --no-skip-worktree lib/core/firebase/firebase_options_dev.dart \
                                     lib/core/firebase/firebase_options_prod.dart \
                                     android/app/src/dev/google-services.json \
                                     android/app/src/prod/google-services.json
```

In the Firebase console for `familyhub-app-ai`:

- Authentication → Sign-in method → enable **Email/Password** (the only provider this app uses).
- Firestore Database → create in **Native mode**. The region is permanent — pick the
  one nearest Bangladesh that the console offers.
- Project settings → Your apps → both Android apps registered: `com.familyhub.family_hub.dev`
  and `com.familyhub.family_hub`, each with the debug SHA-1.

Then, verified against flutterfire_cli **1.4.1** on 2026-11-08:

```bash
npx firebase login                     # flutterfire reuses this session; no extra browser login
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure -y -p familyhub-app-ai \
  --platforms android -a com.familyhub.family_hub.dev --out=build/fh_tmp/firebase_options_dev.dart
dart pub global run flutterfire_cli:flutterfire configure -y -p familyhub-app-ai \
  --platforms android -a com.familyhub.family_hub --out=build/fh_tmp/firebase_options_prod.dart
```

- Run it from the repo root. `flutterfire` is **not** on PATH unless you add
  `%LOCALAPPDATA%\Pub\Cache\bin`; `dart pub global run flutterfire_cli:flutterfire …` needs no PATH
  edit.
- `-a` is `--android-package-name`; `--android-app-id` still parses but is deprecated.
- It asks for an `android-out` path even with `-y`, and it reads that answer from stdin: pipe it a
  path **relative to the project root** (`printf 'build/fh_tmp/google-services-dev.json\n' | …`).
  An absolute path is rejected and the prompt then dies with `RangeError`.
- Afterwards undo its side effects: it rewrites `firebase.json` (minified, plus a
  `flutter.platforms` block that points at the generated files) and, if you accept the default,
  writes `android/app/google-services.json`. `git checkout -- firebase.json`, delete that JSON, and
  delete `build/fh_tmp/`. The app does not read either file — it passes explicit `FirebaseOptions`.
- Transcribe the generated `apiKey` / `appId` / `messagingSenderId` into the matching `android`
  block of `lib/core/firebase/firebase_options_dev.dart` / `_prod.dart`. Keep the
  `DevFirebaseOptions` / `ProdFirebaseOptions` class names, the `static const String projectId`
  (the resolver and `test/core/firebase/firebase_options_test.dart` read it) and the other
  platform blocks untouched; do not use the CLI's `DefaultFirebaseOptions` shape directly.
- Re-apply the skip-worktree flags (the command above with `--skip-worktree`), then run
  `dart format .`, `flutter analyze`, `flutter test --exclude-tags golden` and
  `flutter build apk --debug --flavor dev -t lib/main_dev.dart`.
- Restrict the Android API key to the two package names + SHA-1s in Google Cloud Console →
  APIs & Services → Credentials. Android keys ship inside the APK; the restriction is the control.

## Verify the rules

The emulator needs JDK 21+. If `java -version` reports nothing, Android Studio
already ships a suitable JDK:

```
export JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"
export PATH="$JAVA_HOME/bin:$PATH"
npx firebase emulators:exec --only firestore --project demo-family-hub \
  "npm --prefix firebase/rules_test test"
```

After the local rules refactor, standalone emulator suites pass:
`chore_occurrences.test.mjs` (101, including the 400-document batch),
`chore_occurrence_parity.test.mjs` (6), and `chore_comments.test.mjs` (27).
The combined `npm test` run currently reports 673 pass and 33 fail; occurrence
creates pass standalone but fail when all test files are loaded, and unrelated
denied-case tests also unexpectedly succeed. Investigate test isolation and
rerun the complete suite before deploying. Production rules have not been
updated. See item 24 in `docs/phase4_polish_audit.md`.

`emulators:exec` refuses to start if something already holds port 8080 (`Could not start Firestore
Emulator, port taken`) — usually a `firebase emulators:start` left running for the app. Stop it, or
run the suite from a scratch config that moves Firestore elsewhere; the tests read
`FIRESTORE_EMULATOR_HOST`, so nothing needs to know the port. Create `scratch.firebase.json`
(gitignore it or delete it after) as a copy of `firebase.json` with `"port": 8090` for firestore and
no `auth`/`ui` blocks, then:

```
npx firebase emulators:exec --config scratch.firebase.json --only firestore \
  --project demo-family-hub "npm --prefix firebase/rules_test test"
```

Check the rules compile — and that they compile without warnings, since an unused helper is dead
code — with `npx firebase deploy --only firestore:rules --dry-run`. It performs no deploy.

## Marking an emulator user's e-mail verified

Every rule except the owner's own `users/{uid}` requires
`request.auth.token.email_verified == true`, and the Auth emulator sends no real
verification mail, so a signed-up account is stuck at `/verify-email` until you
flip the flag. This is the invocation that works (verified 2026-11-07): `POST`,
not `PATCH`, and the `Authorization: Bearer owner` header is what the emulator
accepts in place of a real key.

```
# 1. Sign up (or sign in) and read the localId out of the response.
curl -s -X POST \
  "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-sdk-key" \
  -H "Content-Type: application/json" \
  -d '{"email":"whoever@example.com","password":"Passw0rd2","returnSecureToken":true}'

# 2. Set emailVerified on that localId.
curl -s -X POST \
  "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:update?key=fake-sdk-key" \
  -H "Authorization: Bearer owner" -H "Content-Type: application/json" \
  -d '{"localId":"<localId from step 1>","emailVerified":true}'

# 3. Confirm, then reload the user in the app ("I have verified my e-mail").
curl -s -X POST \
  "http://127.0.0.1:9099/identitytoolkit.googleapis.com/v1/accounts:lookup?key=fake-sdk-key" \
  -H "Authorization: Bearer owner" -H "Content-Type: application/json" \
  -d '{"localId":["<localId>"]}'
```

The app listens on `userChanges()`, not `authStateChanges()`, so the reload after
step 2 is what moves it off `/verify-email`.
