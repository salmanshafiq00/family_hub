# Wave R1 - notes (written without Flutter/Dart or the Firestore emulator)

Nothing here has been compiled or run. Run the gate (`tools/p3_r0_gate.sh` or the
commands in docs/PHASE3_REVIEW_ROADMAP.md Wave R0) and paste the table into PROGRESS.md.

## Done
| ID | What changed |
| --- | --- |
| B-11 | `firestore.rules`: the occurrence block used `before`/`after` that were never declared (compile error). Now `prev()`/`next()`/`occurrenceChanged()`. `.match()` capture removed (`occurrenceIdMatchesDate`). `todayKey` uses `request.time + duration.value(6,'h')` and `year()/month()/day()`. |
| B-05 | Unique event id per intent (`OccurrenceActionWriter`), patch carries `lastEventId`, rules require that event to be created in the same batch (`occurrenceEventNew`). `OccurrenceEventIds` removed. |
| B-06 | Rule 12 RESTORE; `restoreMap` writes only the replan keys + delete pair + stamps. |
| B-04 | `ReopenOccurrence` unticks the required steps (or `redoSubtaskIds`); rule 4 lets `subtaskDone` shrink. |
| B-01 | `ChoresGenerationHook` (wraps `AppShell`) starts `ensureOccurrencesOnOpenProvider` once per family; the provider now returns the failure to show (silent only for `Network`, skips when no uid, never throws). |
| B-02 | `PermissionPolicy.canVerifyOthers` + `canVerifyAnyProvider` drive the Verify tile and queue; the detail bar passes the template to `ref.can`. |
| B-03 | `verifiableOccurrences` (pure) is the queue filter. |

## Assumptions / open items
- Rules syntax I could not verify: `duration.value(6,'h')`, `timestamp + duration`, `year()/month()/day()`, functions declared inside a `match` block. If the emulator rejects one, send me the error.
- Existing rules tests were patched mechanically (`lastEventId` added next to each paired event); the 3 `reassigned_/swapped_` template-literal cases too. Re-run them.
- Rule 2 (uncomplete) allows `lastEventId` and then requires the `uncompleted` event; the use cases always write it.
- The reopen sheet still has no "which steps" checklist (default = all required steps), and the step list is not stored on the `reopened` event. Both need new ARB keys / an event key; left for a later wave.
- `Validation('redoSubtaskIds','pick_required_step')` has no localized text yet (shows the generic message).
- Existing router tests do not override the occurrence repositories: the hook then shows an "unknown failure" snackbar in those tests instead of crashing. If a router/onboarding test fails on it, add `occurrenceRepositoryProvider` / `generationMarkerRepositoryProvider` overrides.
- B-07..B-10, D-xx, M-xx, Q-xx, U-xx (other waves) are NOT touched.
