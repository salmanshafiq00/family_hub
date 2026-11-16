# Phase 4 polish audit (P4-23)

**Status:** every High finding is closed. The two Medium findings that stay open
are measurements, not guesses: Home's listener count and the unguarded stats
write. Neither is a Phase 4 gate, and both are handed to Phase 5 with the test
that pins it. This is the audit of the Phase 4 test harness, the screens touched
by Waves A–E and the changed files; it is not a line-by-line audit of every
screen in the app.

## Findings

| # | Category | Severity | Location | Issue | Status |
|---|---|---|---|---|---|
| 1 | Compile | High | `lib/features/chores/calendar/presentation/widgets/agenda_view.dart` | The agenda jump-to-today threshold was referenced but undefined, preventing compilation. | Fixed by defining the existing 240 dp threshold. Calendar view tests pass. |
| 2 | Test | Medium | `test/features/chores/calendar/presentation/calendar_polish_test.dart` | The reduced-motion test asserted that there were no transient callbacks, which was not a reliable assertion of the configured transition duration. | Fixed to assert the transition configuration. Test passes. |
| 3 | Test | Medium | `test/features/chores/calendar/presentation/calendar_views_test.dart` | The filter test left its modal route open while testing chip removal. | Fixed by dismissing the sheet through its Navigator. Test passes. |
| 4 | Offline | Medium | `test/features/chores/achievements/presentation/celebration_controller_test.dart` | A server-only celebration claim suppressed the celebration while offline, despite the existing offline expectation. | Fixed: a `Network` failure permits the local once-per-device fallback; online transactions remain the cross-session claim. This cannot guarantee deduplication across devices on an indeterminate network failure. Test passes. |
| 5 | Architecture | Medium | `lib/features/chores/achievements/presentation/celebration_controller.dart` | The controller exceeded the 300-line project limit. | Fixed by extracting repeated failure logging to `celebration_diagnostics.dart`; the file-size guard passes. |
| 6 | Read budget | Medium | `test/features/dashboard/perf/home_listener_census_test.dart` | No test proved the dashboard's listener ceiling or that tab changes add no listeners. | Measured, not assumed: 13 live sources, one subscription each; a rebuild adds none; a cold re-entry doubles none of the ten session-wide sources. The ceiling of seven in D-P4-14 is **not** met — open item 21 below. |
| 7 | Concurrency | Medium | `test/features/chores/achievements/concurrency/stats_sync_concurrency_test.dart`, `test/features/notifications/concurrency/two_phone_reminder_plan_test.dart` | No concurrent stats-sync test existed and nothing pinned two phones planning reminders; the only two-session test was the celebration claim. | Written and passing: two phones over one document converge, the second writes nothing, and a late phone adds a chore once (item 22 covers the stale read). The reminder half is 3 tests: both phones end on the same pending set, a re-plan cancels only its own alarms, and a sign-out clears only that device. The rules emulator now runs (item 23), so the remaining half of this row is the two-phone device check. |
| 8 | Harness scope | Low | `test/features/phase4/phase4_test_support.dart` | The shared state and semantics harness covers eight Phase 4 screens, not every screen or form touched by the whole application. | Eight-screen coverage passes; broader coverage remains open by design. |
| 9 | Evidence | Low | Device/UAT checklists | Reminder and push checklists contain procedures but no device records, screenshots, owner copy review, or family UAT results. | Not run; see [phase4_acceptance.md](./phase4_acceptance.md). |
| 10 | Evidence | Low | Goldens | Phase 4/Linux goldens were not generated or reviewed on this Windows machine. | Not run; generate and inspect on Linux. |
| 11 | Layout | High | `lib/features/chores/presentation/today_screen.dart` | The header, progress and helpers were a fixed `Column` above an `Expanded` list: at 2.0x text the top part alone was taller than the screen, so the list overflowed and the header controls could be pushed off. | Fixed — the whole screen is one `ListView` now, so every part scrolls. Two `today_screen_test` overflow cases pass. |
| 12 | Layout | High | `lib/features/chores/swaps/presentation/swap_status_banner.dart` | The answer/cancel button shared one `Row` with the message, leaving the text zero width at 2.0x or with a long Bangla label. | Fixed — the action sits under the message (still a 48 dp target). The banner tests in `swap_ui_test.dart` pass; the banner is not in the Phase 4 semantics harness, which is what row 8 still flags. |
| 13 | States | Medium | `lib/features/chores/swaps/presentation/swap_sheet.dart` | The sheet read `membersProvider` before it opened, so a family list that had not arrived yet was reported as "nobody is available". | Fixed — the sheet watches the list and shows the loading state instead of a wrong empty state, with a test that holds the list back and asserts no `swap_nobody`, no send button, one `LoadingView`. |
| 14 | Layout | Medium | `lib/features/chores/availability/presentation/availability_card.dart`, `lib/features/chores/rota/presentation/widgets/on_duty_strip.dart`, `lib/features/chores/starter_packs/presentation/widgets/starter_pack_pick_step.dart` | Fixed-width text in a `Row`: the availability status label overflowed its card by a pixel and the duty-strip count and starter-pack chip labels had no room at 2.0x Bangla. | Fixed with `Flexible` + maxLines/ellipsis; the labels truncate instead of pushing the row off. |
| 15 | A11y | Medium | `lib/features/chores/settings/presentation/chore_settings_screen_parts.dart`, `lib/features/chores/templates/presentation/widgets/editor_section_card.dart` | Section cards were a bare `DecoratedBox`, so a `Switch` or tile inside them painted no ink and the tap gave no visible feedback. | Fixed — wrapped in a transparent `Material`; the splash reaches the control. |
| 16 | Correctness | Low | `lib/features/chores/rota/presentation/rota_providers.dart` | Month bounds were built as `DateKey(year, month + 1, 1)`, which is invalid in December. | Fixed to `monthKey.startOfMonth` / `endOfMonth`; rota bounds tests pass. |
| 17 | Data | Medium | `lib/features/chores/occurrences/domain/occurrence_write_plan.dart` | `OccurrencePatch` compared its nested `fields` map by identity, so two patches carrying the same writes were unequal — the write plan could not recognise its own result. | Fixed — `sameValue`/`hashValue` in `lib/core/utils/value_equality.dart` compare maps and lists by content, with six unit tests. The extraction also returns the file to 289 lines, inside the 300-line guard. |
| 18 | Test | High | `test/support/in_memory_chores_backend.dart` | `watchRange` was an `async*` generator driven by `await for`; a generator parked on a broadcast stream does not run its `finally` when the consumer cancels, so the fake's live-listener counter never fell and every D-01 "released the month" assertion failed. | Fixed — an explicit `StreamController(onListen:, onCancel:)`, which is told the moment its last listener leaves. The assertions were kept, not loosened. |
| 19 | Test | Medium | `test/features/chores/swaps/domain/swap_use_cases_test.dart` | A swapped-back-after-starting case expected `concurrent_edit`; `AcceptSwap` checks ownership before start, so the code is `occurrence_started`. | Fixed the expectation against the documented check order in `accept_swap.dart:89` (ownership) before `:92` (start); the rule itself is unchanged. |
| 20 | Test | Medium | `test/features/chores/occurrences/presentation/occurrence_providers_test.dart` | The app-open hook tests asserted after one `pump()` and armed their failure after `listen`, so one passed vacuously and another read a run that had not finished. | Fixed — the failure is armed before the provider is read and the provider future is awaited. |
| 23 | Security rules | High | `firebase/firestore.rules` | The rules file **did not compile**. `firebase deploy --only firestore:rules` would have been refused, and the emulator's compiler said so with 15 diagnostics: six functions that nothing calls (which Firestore reports as errors, and which cascade into bogus "Invalid function name: exists/get" and "Invalid variable name: resource/request" errors inside them), a second looser `dateKeyOk` redefining the strict one, `todayKey(f)` reading an `f` that is not in scope there, and `d.dateKey.substring(0, 7)` which the rules language does not offer. The whole rules suite had therefore never run — every "enforced in firestore.rules" claim in Phase 2–4 was unverified, and 0 of 153 rules tests executed. | Fixed and measured 2026-11-07: dead helpers deleted (`canWriteOwnRecord`, `occurrenceSnapshotUnchanged`, `occurrenceLive`, loose `dateKeyOk`, `contributionPath`, `canViewAllContributions`, `isMember` — all verified to change no decision), `todayKey()` takes no argument, `substring` replaced by `d.dateKey.matches('^' + d.monthKey + '-[0-9]{2}$')`. Rules now compile and **138 of 153** rules tests pass. Item 24 is what the remaining 15 need. |
| 25 | Device smoke test | High | `lib/features/chores/achievements/presentation/celebration_orchestration.dart`, `test/support/app_test_side_effect_overrides.dart` | The dev app was installed on an AVD (API 37) pointed at the Auth + Firestore emulators and stopped on a red screen on first build: `ProviderException … Providers are not allowed to modify other providers during their initialization` — the signed-out branch of `celebrationOrchestrationProvider` called `celebrationControllerProvider.notifier.reset()` while `app.dart:56` was still building it. All 3275 widget tests passed because the shared test scope replaces every orchestration provider with `overrideWithValue(null)`, so none of their bodies ever executed under test. | Fixed: the notifier is captured during the build and the reset is deferred one microtask, the same shape `profile_setup_screen.dart:46` already uses. New `test/features/chores/achievements/presentation/celebration_orchestration_test.dart` reproduces the exception on the unfixed code and passes after; the suite is 3276. Re-installed on the same AVD, the app now renders the Bangla welcome screen. |

## Open items handed to Phase 5

| # | Category | Severity | Location | Issue | Status |
|---|---|---|---|---|---|
| 21 | Read budget | Medium | `test/features/dashboard/perf/home_listener_census_test.dart`, `docs/phase4_read_budget.md` | Home keeps 13 live data listeners where D-P4-14 planned seven: budget, categories, fund transactions, contribution plans, availability and member stats each read their own source. Flat in family size, but above the plan. | Open. The test pins the ceiling at 13, so a new listener fails rather than passing silently. |
| 22 | Concurrency | Medium | `lib/features/chores/achievements/data/firestore_member_stats_repository.dart` (`save`) | The write is a blind batch `set`, so a phone that syncs from a read taken before the other phone wrote replaces its document — the second phone's finalised month is gone. Pinned by the third test in `stats_sync_concurrency_test.dart`. | Open. Needs a guarded (compare-and-set / transaction) write in Phase 5. |
| 24 | Security rules | High | `firebase/firestore.rules` (`occurrenceOk` and the `choreOccurrences` / `comments` match blocks) | The local rules route occurrence updates through one transition dispatcher, validate fresh creates without repeating the full lifecycle checks, and validate only changed snapshot fields on replan/restore. Standalone emulator runs pass: `chore_occurrences.test.mjs` (101), `chore_occurrence_parity.test.mjs` (6), and `chore_comments.test.mjs` (27), including the 400-document batch. The complete `npm test` run is still not green (673 passed, 33 failed); occurrence creates pass standalone but fail when all test files are loaded together, and unrelated denied-case tests also unexpectedly succeed. | Partial — the three chore suites have standalone evidence, but the complete rules test run still needs reliable isolation and a green result. Production rules have not been updated. Do not deploy yet. |

| 26 | Test harness | Medium | `test/support/app_test_side_effect_overrides.dart` | Seven app-level side-effect providers (`preferenceSync`, `dashboardPreferenceSync`, `reminderOrchestration`, `pushOrchestration`, `foregroundNotificationBridge`, `statsSyncOrchestration`, `celebrationOrchestration`) are overridden with `overrideWithValue(null)` in every widget test, so their bodies never execute under test. Finding 25 is a crash this hid. | Open. Phase 5 should give each hook its own focused test that runs the real body against fakes, the way `celebration_orchestration_test.dart` now does, and keep the null override only for screen tests that do not care about it. |

## Automated coverage run for this review

- Celebration controller: 7 tests passed, including online race simulation and
  offline local fallback.
- Stats actions and sync: 7 tests passed.
- Stats sync from two phones: 3 tests passed.
- Two phones planning reminders: 3 tests passed.
- Home listener census: 5 tests passed.
- `value_equality`: 6 tests passed.
- Phase 4 screen state matrix: 180 tests passed.
- Phase 4 accessibility audit: 19 tests passed.
- Dashboard grid, tablet shell, achievements responsive layout, and occurrence
  detail responsive layout: 18 tests passed.
- Calendar polish and calendar views: 32 tests passed.
- Architecture file-size guard: 1 test passed.
- Swap UI (banner answers, sheet waits for the family list): 6 tests passed.
- Firestore rules emulator: standalone chore suites pass after the local
  refactor (`chore_occurrences` 101, parity 6, comments 27). The complete
  `npm test` run reports 673 passed and 33 failed. Since occurrence creates
  pass in isolation but fail when all files are loaded, investigate cross-file
  test setup before treating the combined result as rules evidence. Production
  rules are not updated.
- Whole suite: 3276 passed, 0 failed, 0 skipped (`flutter test --exclude-tags
  golden`, 2026-11-07). `flutter analyze` reports no issues, `dart format .` is
  clean and `node tools/check_indexes.mjs` passes.
- Device smoke test (Android emulator, API 37, dev flavor with
  `USE_EMULATOR=true` against the Auth + Firestore emulators): the app reaches
  the Bangla welcome screen and the sign-up form renders and validates. The
  first build of this run crashed on a red screen — finding 25. Sign-up, family
  creation and the two-phone flows were not completed on the emulator; they
  still need a real account pair, which is the UAT sheet.

These are focused automated checks, not evidence for device behavior, Firestore
read counts, a production rules deploy, or family acceptance. See
[phase4_read_budget.md](./phase4_read_budget.md) and
[phase4_acceptance.md](./phase4_acceptance.md) for the open gates.
