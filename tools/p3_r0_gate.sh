#!/usr/bin/env bash
# Wave R0 gate (docs/PHASE3_REVIEW_ROADMAP.md §3). Runs every check in order,
# keeps going after a failure, writes everything to docs/p3_r0_gate.log and
# prints a PASS/FAIL table you can paste into PROGRESS.md.
# Needs: Flutter on PATH, Node, Java (Firestore emulator).
set -u
cd "$(dirname "$0")/.."
LOG=docs/p3_r0_gate.log
: > "$LOG"
declare -a ROWS

run() {
  local name="$1"; shift
  echo "=== $name :: $*" | tee -a "$LOG"
  if "$@" >>"$LOG" 2>&1; then ROWS+=("| $name | PASS |"); else ROWS+=("| $name | **FAIL** (see $LOG) |"); fi
}

run "pub get"            flutter pub get
run "format"             dart format --set-exit-if-changed .
run "gen-l10n"           flutter gen-l10n
run "l10n no diff"       git diff --exit-code -- lib/core/localization/generated
run "analyze"            flutter analyze --fatal-infos
# R0-2 first: does the emulator even load firestore.rules? (B-11)
( cd firebase/rules_test && [ -d node_modules ] || npm ci ) >>"$LOG" 2>&1
run "rules suite"        npx firebase emulators:exec --only firestore --project demo-family-hub \
                           --config firebase.json "npm --prefix firebase/rules_test test"
run "unit tests"         flutter test --exclude-tags golden
run "R0-4 file size"     flutter test test/architecture/file_size_test.dart
run "R0-5 chores loads"  flutter test test/features/chores/chores_module_test.dart test/features/chores/chores_screens_test.dart
run "check_indexes"      node tools/check_indexes.mjs

echo
echo "| Command | Result |"; echo "| --- | --- |"
printf '%s\n' "${ROWS[@]}"
