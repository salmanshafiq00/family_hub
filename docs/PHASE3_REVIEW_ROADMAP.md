# Family Hub — Phase 3 Review Roadmap (P3-01 … P3-15)

**Reviewed:** `family_hub_p3_lean_20261029-0019.zip` (HEAD `6bd2187`) against `docs/PHASE3_CHORES_ROADMAP.md`, `CLAUDE.md` and `PROGRESS.md`.
**Purpose:** a fix-it plan you can work through one wave at a time, in the same style as the Phase 3 roadmap (one wave = one branch = one prompt = one commit).

---

## 0. How this review was done — and what it is NOT

| Item | Status |
| --- | --- |
| Method | **Static reading only.** No Flutter/Dart SDK and no Firestore emulator were available, so I could not run `dart format`, `flutter analyze`, `flutter test`, `gen-l10n`, or the rules suite. Nothing below is a test result. |
| Confidence tags | **[CONFIRMED]** = I read the code/rules and the defect follows directly. **[LIKELY]** = strong reason to believe, but a tool (emulator/analyzer) must confirm. **[DESIGN]** = the roadmap itself is the cause, not your implementation. |
| Depth | **Deep:** P3-09 – P3-15 (rotation engine, occurrence domain, generator/Ensure/Regenerate, occurrence data layer + rules, completion use cases, Today / Detail / Verify screens). **Light:** P3-01 – P3-08 (progress notes + targeted greps: file sizes, raw colours, `DateTime.now`, TODOs, seed ids). I did **not** read every file in P3-04 (widgets), P3-08/P3-10 mappers and rules, or the test suites line by line. |
| `PROGRESS.md` | Stops at **P3-08**. P3-09 … P3-15 have **no gate record** (format/analyze/test/rules results). Treat them as unverified until Wave R0 is done. |

---

## 1. Verdict in one page

**What is good (keep it):**
- Clean layering held up: pure `domain/`, write *plans* (`OccurrenceWritePlan`) staged by one `OccurrenceWriteStager`, use cases returning `Result`, no `Colors.*`, no `DateTime.now()` in lib, no TODOs left.
- The pure engines (recurrence, rotation, `effectiveStatus`, `SubtaskSync`, generator) are well-factored, snapshot-based and mostly table-tested; dotted-key patches for subtask ticks are the right merge strategy.
- Contract tests that push real mapper output through the rules key sets are an excellent idea.

**What blocks the first slice (the roadmap's "tick steps → verify → template edit" milestone cannot work today):**

| # | Blocker | One line |
| --- | --- | --- |
| B-01 | Occurrences are never generated | `ensureOccurrencesOnOpenProvider` has no caller outside tests. |
| B-02 | Verification is unreachable in the UI | `ref.can(Permission.verifyChore, …)` is called without the template, so it is always `false`. |
| B-04 | "Reopen" does nothing visible on a chore with steps | `effectiveStatus` counts ticks; reopen leaves them. **[DESIGN]** |
| B-05 | Second untick / second skip / reassign ping-pong fails | Deterministic event ids collide; events are create-only. **[DESIGN]** |
| B-06 | Resuming a template cannot restore deleted days | No rule allows updating a soft-deleted occurrence. |
| B-11 | The rules file may not compile | Uses `.match()`, `timestamp.date(timestamp.value(…))`, `.year`, `.toString()`. **[LIKELY]** |

**Scorecard**

| Step | Verdict | Main concern |
| --- | --- | --- |
| P3-01 skeleton | OK | Manage-hub gate hides the Verify tile for everyone (B-02). |
| P3-02 helpers | OK (not deeply read) | — |
| P3-03 vocabulary | OK | — |
| P3-04 widgets | OK | `flutter_slidable` and `animations` are in `pubspec` but imported nowhere (Today uses `Dismissible`). |
| P3-05 recurrence | OK | — |
| P3-06 settings | OK | Rules suite never run. |
| P3-07 template domain | OK | — |
| P3-08 template data | OK | Rules suite never run. |
| P3-09 rotation | Engine good; builder/data not deeply read | Verify F.2 #9 (`occurrence` unit) in a run. |
| P3-10 duty-group data | Not deeply read | Run rules + contract tests. |
| P3-11 occurrence domain | **Needs fixes** | Reopen derivation (B-04); duplicated completion logic. |
| P3-12 generator | **Needs fixes** | Race retry never fires (B-07); projected draft built wrongly (B-08). |
| P3-13 data + rules | **Needs fixes** | Pagination (B-09), restore (B-06), rules syntax (B-11), rule gaps (M-xx). |
| P3-14 use cases | **Needs fixes** | Event ids (B-05), audit/inbox ids (B-10), permission/assignee mismatch. |
| P3-15 screens | **Needs fixes** | Verify unreachable (B-02/B-03), self-heal never runs, 309-line file, missing error states. |

---

## 2. How to work through this file

1. Do **Wave R0 first**. Everything else assumes you can run the tools.
2. One wave = one branch (`fix/p3-r1-…`) = one commit. Do not mix waves.
3. Each finding has an ID, a severity (**Blocker / High / Medium / Low**), where it is, why it matters, the fix, and the test that proves it.
4. After every wave run the commit checklist from roadmap §3.11 (`dart format .`, `flutter analyze`, `flutter test --exclude-tags golden`, rules suite, `node tools/check_indexes.mjs`) and record the result in `PROGRESS.md`.
5. Do **not** start P3-16 until the exit criteria in §9 are met.

---

## 3. Wave R0 — Make the base verifiable (do this first)

| ID | Sev | Task |
| --- | --- | --- |
| R0-1 | Blocker | Run the full gate on your machine: `dart format --set-exit-if-changed .`, `flutter pub get`, `flutter gen-l10n` (no diff), `flutter analyze` (zero issues, infos included), `flutter test --exclude-tags golden`, the rules suite, `node tools/check_indexes.mjs`. Paste the output into `PROGRESS.md`. Fix **only** red items in a commit `P3-00: repair base`. |
| R0-2 | Blocker | Run the rules suite **before** anything else in this file. `PROGRESS.md` says it was never run for P3-06 and P3-08, and there is no record for P3-10/P3-13. If the emulator refuses to load `firestore.rules`, that is B-11. |
| R0-3 | High | `PROGRESS.md` has no entries for P3-09 … P3-15. Add them with real gate output. CLAUDE.md "Working method" requires it. |
| R0-4 | Medium | `lib/features/chores/presentation/occurrence_detail_screen.dart` is **309 lines**; `file_size_test` caps at 300 and it is not on the allow-list → that test fails. Split it (see U-02). |
| R0-5 | Medium | `P3-08` noted that `chores_module_test.dart` / `chores_screens_test.dart` could not load because Phase 2 Bazar code did not compile. Confirm those two files now load and pass. |
| R0-6 | Low | `today_screen.dart`: `if (mounted)` followed by a statement on the next line without braces is likely to trip `curly_braces_in_flow_control_structures` and keep CI red. |

**Prompt for R0**
```text
Read CLAUDE.md. Run the gate in docs/PHASE3_REVIEW_ROADMAP.md Wave R0 in order and fix ONLY what is red, in a commit "P3-00: repair base". Then add P3-09..P3-15 sections to PROGRESS.md with the real command output. Do not change behaviour.
```

---

## 4. Wave R1 — Make the first slice work (blockers)

### B-01 · Blocker · Occurrences are never generated **[CONFIRMED]**
- **Where:** `occurrences/presentation/occurrence_providers.dart` (`ensureOccurrencesOnOpenProvider`). A search of `lib/` finds **no reader** of it; only `occurrence_providers_test.dart` uses it. Roadmap P3-13 requires `bootstrap.dart` to start it once per family per app start.
- **Effect:** the marker never advances, so Today is empty forever unless something else calls `RegenerateRange` (which the template editor, P3-16, does not exist yet).
- **Also in that provider:** it swallows **every** failure (`return null`), contradicting CLAUDE rule 9 ("no silent catches") and the roadmap ("swallow `Network` silently, report the rest"). And `actorUid: ref.read(currentUidProvider) ?? ''` runs the use case with an empty uid.
- **Fix:** start it from one place that already knows "signed in + active member + family id" (the shell widget or an app-level `ref.listen`), once per family per process. Skip when `uid == null`. Map `Network` → silent retry next open; every other `AppFailure` → the global error banner/snackbar.
- **Test:** widget/provider test that building the shell with an active member calls `EnsureOccurrences` exactly once; a `PermissionDenied` result surfaces a message; offline does not.

### B-02 · Blocker · Verify is unreachable in the UI **[CONFIRMED]**
- **Where:**
  - `presentation/widgets/occurrence_actions_bar.dart:73` — `ref.can(Permission.verifyChore, ownerId: completedBy)`
  - `presentation/verify_queue_screen.dart:35` — `ref.can(Permission.verifyChore, ownerId: '__someone__')`
  - `chores_entries.dart:65` + the hub's `ref.can(entry.requires!)` — the Verify tile
- **Why:** `PermissionPolicy` returns `false` for `verifyChore` unless `template?.verificationEnabled == true`. None of these calls pass a template. So the Verify button, the queue screen's list, and the hub tile are all permanently hidden. Roadmap §E.2 step 4 ("a second member verifies") cannot pass.
- **Fix:**
  - Detail bar: `ref.can(Permission.verifyChore, ownerId: completedBy, template: permissionTemplateFor(item.verification))`.
  - Queue screen: replace the `'__someone__'` sentinel with a purpose-built provider (e.g. `canVerifyAnyProvider`) that asks the policy "may this actor verify others' chores at all?".
  - Hub tile: use that same provider via a `bool` gate instead of `requires: Permission.verifyChore`.
- **Decide (see M-05):** rules let **any active member** verify; `PermissionPolicy` allows **managers only**. Pick one and make UI, use case and rules agree.
- **Test:** member A completes a `verification: required` chore → manager B sees *Verify* and the queue row; A does not; with the family switch off nobody sees it.

### B-03 · High · Verify queue lists chores that need no verification **[CONFIRMED]**
- **Where:** `occurrences/presentation/today_providers.dart` → `verifyItemsProvider`. The doc comment says it drops chores "that do not need a check", the code only checks `completedBy != uid`. It also filters on the **stored** `occurrence.status` (CLAUDE rule 36 says use the effective status).
- **Fix:** keep only `verification == required`, `effectiveStatus == completed`, `completedBy != uid`, `verifiedAt == null`. Move the filter into a pure function and unit-test it.

### B-04 · Blocker · "Reopen" does not work for chores with steps **[DESIGN + CONFIRMED]**
- **Where:** roadmap P3-11 defines `completed` as "every required step is ticked"; `reopen_occurrence.dart` only clears `completedAt/By` and bumps `reopenCount`. The ticks stay, so `effectiveStatus` still says **completed**, and `RepairStatus` would even write `completed` back. Chores without steps are fine; every fridge-cleaning style chore (the ones with verification) is not.
- **Fix (recommended):** reopening a chore that has steps must say **which steps to redo** (default: all required). The same patch unticks them (`removedFields: subtaskDone.<id>`), and the `reopened` event stores the list (add `redoSubtaskIds` to the event or to `params`). Update rule 4's `affectedKeys` to allow `subtaskDone`. Extend `showReasonSheet` (or a small `ReopenSheet`) with a checklist.
- **Alternative:** add `reopenedAt` to the document and make `effectiveStatus` ignore ticks older than it. This is more invasive (key set, rules, contract fixtures).
- **Test:** complete 3/3 steps → reopen → `effectiveStatus == inProgress`, it stays that way after `RepairStatus`, `reopenCount == 1`, event holds `prevCompletedAt`.
- **Docs:** amend roadmap P3-11/Appendix C so the spec matches.

### B-05 · Blocker · Event ids collide; the second occurrence of a transition fails **[DESIGN + CONFIRMED]**
- **Where:** `occurrence_event.dart` → `OccurrenceEventIds.transition(type, reopenCount)` and `.assignment(type, assigneeId)`; the rules pair events with `getAfter(...'<type>_' + reopenCount)`; events are **create-only**.
- **Failing sequences (each rejects the whole batch, including the patch):**
  1. complete → untick → complete → untick (no reopen in between): second `uncompleted_0` already exists.
  2. skip → unskip → skip: second `skipped_0` exists.
  3. reassign A→B, B→A, A→B: second `reassigned_B` exists. Same for `swapped_` / `covered_`.
- **Fix:** give every event a unique id **generated once per user intent** (CLAUDE rule 15 / roadmap §3.4 already say this) and let the rules find it through the occurrence document: add a field `lastEventId` to the patch; rule: `existsAfter(event(after.lastEventId))` and `getAfter(...).type == '<expected>'`. Remove the `reopenCount`/assignee suffix scheme.
- **Test:** the three sequences above against the InMemory backend **and** the rules suite (new cases in `chore_occurrences.test.mjs`).

### B-06 · Blocker · `RegenerateRange` restore path is denied by the rules **[CONFIRMED]**
- **Where:** `OccurrenceWriteStager` stages `restores` with `batch.update(restoreMap(...))`. Every update rule in `firestore.rules` starts with `before.get('deletedAt', null) == null`; **no rule** updates a soft-deleted document (rule 11 only *sets* `deletedAt`). `restoreMap` also rewrites ~25 fields, not just the snapshot keys.
- **Effect:** resuming a paused template, or re-adding a date that was removed, fails the whole chunk. Roadmap F.3 #10 ("resume regenerates") cannot pass. There is no rules test for it either.
- **Fix:** add rule **12 · RESTORE** (manager; `before.deletedAt != null`; `after.deletedAt == null`; `before.status == 'scheduled'`; `affectedKeys().hasOnly(replanKeys + ['deletedAt','deletedBy','updatedAt','updatedBy'])`) and shrink `restoreMap` to exactly those keys. Add allowed + denied rules tests and a contract fixture.

### B-11 · Blocker (verify first) · Rules may not compile **[LIKELY]**
- **Where:** `firebase/firestore.rules`
  - `occurrenceDateKey(id)` (≈ line 433): `id.match('…')[0][1]` — I do not believe Firestore rules has a `String.match()` that returns capture groups (only `matches()` → bool).
  - `todayKey(f)` (≈ line 566): `timestamp.date(timestamp.value(…))`, `date.year`, `.toString()`. `timestamp.date()` builds a timestamp from year/month/day; year/month/day are **methods**; the same file uses `string(x)` elsewhere, not `.toString()`.
- **Why it matters:** a rules compile error blocks **the entire ruleset** (every collection in the project), not just chores.
- **Fix:**
  - Compare the id to the body without capturing: `id.matches('.*_' + d.dateKey.replace('-', '').replace('-', '') + '(_[a-z0-9]{1,12})?$')`, and check `templateId`/`slotKey` from the body (see M-03).
  - Compute "today" with documented APIs only (`request.time` methods, `timestamp.value(ms, 'ms')`). Confirm in the emulator.
  - The hard-coded `+21600000` (UTC+6) ignores the family timezone setting; record it in an ADR or pass the day from a field the client writes and bound it (`abs(clientDay − serverDay) ≤ 1`).
- **Test:** the emulator must load the file and the existing 400-create test must pass.

**Prompt for R1**
```text
Read CLAUDE.md and docs/PHASE3_REVIEW_ROADMAP.md Wave R1. Implement B-01, B-02, B-03, B-04, B-05, B-06 and B-11 one commit each, test-first. For B-05 and B-06 extend firebase/rules_test/chore_occurrences.test.mjs and the contract fixtures in the same commit. Update docs/PHASE3_CHORES_ROADMAP.md Appendix C where the spec changes. End with: files changed, how to verify, assumptions.
```

---

## 5. Wave R2 — Data integrity and generation safety

### B-07 · High · The generation race never retries **[CONFIRMED]**
- **Where:** `ensure_occurrences.dart` → `_writeChunk` retries only `if (failure is Conflict)`. `core/firebase/firestore_guard.dart` maps `permission-denied` to `PermissionDenied`, and `already-exists`/`aborted` to `Conflict`. A *create on an id that now exists* is evaluated by the rules as an **update** and denied → `permission-denied` → no retry, the run aborts, the marker is not advanced, and (because of B-01's swallow) nobody sees it.
- **Fix:** treat `PermissionDenied` **and** `Conflict` after a chunk failure as "re-read ids, drop what exists, retry once". Keep the second-failure → `Conflict('concurrent_edit')`.
- **Test:** InMemory backend that pre-creates half a chunk between the read and the write; expect success on retry. Roadmap F.3 #6.

### B-08 · High (latent until P3-21) · Projected draft is built without duty groups, policy or availability **[CONFIRMED]**
- **Where:** `usecases/occurrence_action.dart` → `_draftFor` calls `OccurrenceGenerator.drafts(dutyGroups: const [], …)` with default policy/availability.
- **Effect:** for any template that rotates through a **duty group**, the draft has `plannedAssigneeId == null`. The first action on a projected day then (a) fails the permission check for the real assignee and (b) **creates a document with no assignee** (the rules accept it: D-P3-7). It also differs from what the calendar projection will show (C-9).
- **Also:** in `loadOccurrenceContext` the `if (needsCover || assigneeId == null)` branch and the final `return` are **identical**; the comment promises "needs a cover first" but nothing enforces it. Delete the dead branch or implement the rule.
- **Fix:** load duty groups, absence policy and availability index the same way `EnsureOccurrences` does (or accept the draft from the projection provider). One shared helper `draftsFor(range, …)`.
- **Test:** duty-group template, projected day, plain member completes → created doc `assigneeId == planned`.

### B-09 · High · Paging skips documents that share a `dateKey` **[CONFIRMED]**
- **Where:** `firestore_occurrence_repository.dart` → `_readAll`: orders only by `dateKey` and resumes with `startAfter([lastDateKey])`. If a page ends in the middle of a day, the rest of that day is skipped. The first page uses `limit(kMaxOccurrencesPerMonth + 1)` (901) while the loop uses `kOccurrencePageSize` (400) as its stop condition, so the two limits disagree.
- **Used by:** `idsInRange` (EnsureOccurrences), `listRange`, `listByTemplate` (RegenerateRange/Replan; a 3-slot chore has three docs per `dateKey`).
- **Effect:** missed ids → the generator tries to create documents that exist → denied (B-07); regenerate may fail to remove/replan some days.
- **Fix:** add `orderBy(FieldPath.documentId)` as a second sort and resume with `startAfterDocument(lastSnapshot)`; use one page size.
- **Test:** fake 1,000 documents with 3 per day, page size 400 → all ids returned exactly once.

### B-10 · Medium · "Deterministic" audit/inbox ids are not deterministic **[CONFIRMED]**
- **Where:** `occurrence_write_stager.dart` → `_key(Object)` uses `value.hashCode`. `NewAudit` and `NewInboxItem` do not override `==/hashCode`, so the hash is an **identity hash**: different per instance and per run. The comment ("a retry writes the same row, never a second") is false; a retry duplicates audit and inbox rows, and a 32-bit hash can collide inside one batch.
- **Fix:** give `NewAudit`/`NewInboxItem` an `id` generated once per intent (same `IdGenerator` as events) and stage with it.
- **Test:** build the same intent twice with the same ids → one document.

### D-01 · Medium · Month listener is never disposed **[CONFIRMED]**
- **Where:** `monthOccurrencesProvider` is `isAutoDispose: false` for **every** month. Roadmap §3.5 / D-P3-8 want keep-alive for the current month only. Browsing months leaves live listeners (reads + battery) forever; CLAUDE rule 11 says cancel on dispose.
- **Fix:** keep-alive only for the current month (`ref.keepAlive()` conditionally), auto-dispose the rest.

### D-02 · Low · Marker write after a lost race
- `writeThrough` always writes `target`; if another device already advanced further the rules deny a decrease and the whole run reports failure after having done the work. Compare with the live marker first and skip.

### D-03 · Low · Client clocks decide ordering
- Events and `createdAt` use the phone's clock (`plan.at`); the timeline is ordered by `createdAt`. Use `FieldValue.serverTimestamp()` for `createdAt` where rules allow, keep `at` as the client time.

**Prompt for R2**
```text
Implement B-07, B-08, B-09, B-10, D-01 from docs/PHASE3_REVIEW_ROADMAP.md, test-first, one commit each. Add the failing test before the fix. Keep domain/ free of Firestore types. Run the rules suite and record results in PROGRESS.md.
```

---

## 6. Wave R3 — Rules parity with the roadmap (P3-13 "state machine")

The use cases are stricter than the rules in several places. Rules are the last line of defence (CLAUDE rule 12).

| ID | Sev | Gap | Fix |
| --- | --- | --- | --- |
| M-01 | Medium | Rule 2 (complete) does not require "all required steps ticked **or** an exception", although the roadmap and its own comment say so. | Snapshot a `requiredCount` at create (add to `occurrenceKeys()`, mapper, contract fixture) and require `after.subtaskDone.size() >= after.requiredCount \|\| after.exception is map`. |
| M-02 | Medium | Rule 1 requires `after.completedBy == uid` even for a tick that does not complete; partial ticks only pass through rule 2. A tick on an already-completed chore by someone else is denied by both. | Merge rules 1 and 2 into one tick/complete/uncomplete rule with clear branches; add the missing cases to the tests. |
| M-03 | Medium | Create rule checks the id *pattern* but not that `templateId`, `slotKey`, `dateKey` equal the id's components (roadmap P3-13 requires it). | Compare `id == templateId + '_' + yyyyMMdd (+ '_' + slotKey)`. |
| M-04 | Medium | Soft-delete (rule 11) only checks "future"; the roadmap says "manager, **status scheduled, no ticks**". | Add `before.status == 'scheduled'` and `before.subtaskDone.size() == 0`. |
| M-05 | Medium | **Verify:** rules = any active member ≠ completer; `PermissionPolicy` = managers only; roadmap Appendix C = "active member ≠ completer". | Owner decision (add to Appendix G). Then align policy, `OccurrenceStateMachine.can(verify)`, UI and rules. |
| M-06 | Medium | `mayTick` in rules uses `before.assigneeId == uid` only. The use case (`OccurrenceContext.build`) treats `assigneeId ?? plannedAssigneeId` as the assignee, and `CompleteOccurrence` uses `assigneeId` only. Three different definitions of "assignee". | One definition everywhere: an unassigned chore is "somebody else's" (roadmap §3.3). Remove the `?? plannedAssigneeId` fallback. |
| M-07 | Low | `todayKey` is fixed to UTC+6 (ignores `settings/general.timezone`). | See B-11. |
| M-08 | Low | No rules tests for: restore, second `uncompleted`/`skipped`, reassign ping-pong, tick-after-complete by another user, soft-delete of a started doc. | Add them with the fixes above. |
| M-09 | Low | `CompleteOccurrence`/`ToggleParent` and rule 2 allow completing without ticks on a chore whose steps are all optional by ticking them all; fine, but document it in Appendix C. | Doc only. |

---

## 7. Wave R4 — Domain and use-case quality

| ID | Sev | Finding | Fix |
| --- | --- | --- | --- |
| Q-01 | Medium | The "open required step" check and the "tick all optional steps" logic exist **three times**: `SubtaskSync.toggleParent`, `ToggleParent`, `CompleteOccurrence`. | One `SubtaskSync.completionPatch(...)`; the use cases only add permission, event and audit. |
| Q-02 | Medium | Each tap does ~5 reads (`getMember`, `getPermissionSettings`, occurrence `get`, then `requirePermission` loads member + settings **again**). "Everyday writes must queue offline" (rule 26). | Build the actor from already-streamed providers, or pass the loaded `Member`/`PermissionSettings` into `requirePermission`. Verify cache-first behaviour offline. |
| Q-03 | Medium | `RepairStatus` can fight reopen (B-04) and runs for any member. | Fixed by B-04; add a test that repair never changes `effectiveStatus`. |
| Q-04 | Low | `ChoreItem._withOverdue` rebuilds the item field by field; the next added field will be silently dropped. | Add `ChoreItem.copyWith` and use it. |
| Q-05 | Low | `stateFailure()` falls back to `not_assigned_to_you` for any unknown denial. | Return a specific code per action, or `PermissionDenied`. |
| Q-06 | Low | `OccurrenceActionWriter.planFor` builds `<NewAudit>[?audit?.build(...)]` (null-aware element with a chained `?.`). Hard to read. | Use an explicit `if`. |
| Q-07 | Low | `RotationEngine._occurrenceDistance`: off-by-one risk when the anchor does not fire. | Confirm with F.2 #9 in a real run; add a case where the anchor is not a firing day. |
| Q-08 | Low | `kGenerationChunk` (named in the roadmap and ADR 0011) is `GenerationLimits.chunkWrites = 400`. The proof (400-create emulator test) has never been run. | Run it; if rejected, lower the constant and write the proven value into ADR 0011. |

---

## 8. Wave R5 — P3-15 screens

| ID | Sev | Where | Finding | Fix |
| --- | --- | --- | --- | --- |
| U-01 | High | `occurrence_detail_screen.dart` `_repairOnce` | Self-heal sets `_repaired = true` **before** the document has loaded (`document == null` on first frame), so it never repairs on a cold open. | Run it from `ref.listen(occurrenceProvider(id))` the first time a non-null document arrives. |
| U-02 | Medium | same file (309 lines) | Over the 300-line rule; and `ref.read(currentFamilyIdProvider)!` / `currentUidProvider)!` repeated ~10 times (a crash if the session ends mid-tap). | Extract a `_Session` helper and `occurrence_detail_actions.dart` (`_reopen/_reassign/_skip/_exception`). |
| U-03 | High | `occurrenceItemProvider` | Returns `null` when there is no stored document, so a projected item opens as "not found". Roadmap P3-15 requires projected items to open read-only. | Fall back to the projected draft once P3-21 exists; until then hide navigation to projected rows. |
| U-04 | Medium | `today_screen.dart` | No error state: `month.hasError` is ignored and shows the **empty** state. | `ErrorView(onRetry: invalidate)`. |
| U-05 | Medium | `today_screen.dart` | The header progress ignores the Mine/Family toggle, and the roadmap's `ProgressRing` is missing (plain text). | Compute progress from `scoped`; use `ProgressRing`. |
| U-06 | Medium | `today_screen.dart` | When everything is done, `pending.isEmpty` shows the "no chores today" copy. | Separate "all done" copy. |
| U-07 | Low | `today_screen.dart` | Default scope is hard-coded `mine`; `settings.defaultScope` is ignored. | Initialise from `choreSettingsProvider`. |
| U-08 | Low | `today_screen.dart` | `Dismissible` instead of `Slidable` (roadmap D-P3-15); `flutter_slidable` and `animations` are unused dependencies. Swiping a tile in "Done" completes again and shows "completed". | Use `Slidable` (or remove the packages until P3-22); disable swipe on completed rows. |
| U-09 | Medium | `verify_queue_screen.dart` | No error state, no pull-to-refresh; `__someone__` sentinel (see B-02). | Fix with B-02. |
| U-10 | Low | `occurrence_actions_bar.dart` | Up to 9 buttons in a `Wrap` at the bottom; at text scale 2.0 in Bangla it can cover most of the screen. | Primary action + overflow menu for manager actions. |
| U-11 | Low | list rows | Swipe-to-complete has no semantic custom action. | Add `Semantics(customSemanticsActions: …)`. |
| U-12 | Low | `chore_icons.dart` | Contains the seed group ids (`'kitchen'`, …). The roadmap allows this file as the one literal map, but the future `no_hardcoded_options_test` must exempt it. | Exempt explicitly. |

---

## 9. Wave R6 — Process, tests, docs

| ID | Sev | Task |
| --- | --- | --- |
| P-01 | High | Create `test/architecture/no_hardcoded_options_test.dart` (roadmap §3.7, CLAUDE rule 34). It does not exist. Import the seed ids from `default_chore_settings.dart`; exempt `chore_icons.dart` and the starter-pack data. |
| P-02 | Medium | Add the **end-to-end first-slice widget test** from roadmap §E.2 with the in-memory backend: generate → Today shows rows → tick steps → completed → second member verifies → first cannot → template edit "future only". It would have caught B-01, B-02, B-04. |
| P-03 | Medium | Add an **InMemory-vs-rules parity** test: run the same transition table against `InMemoryChoresBackend` and the emulator (roadmap P3-13 asked for it). It would have caught B-05/B-06 and M-02/M-06. |
| P-04 | Medium | Update `docs/PHASE3_CHORES_ROADMAP.md` for the **design corrections** (reopen semantics, unique event ids, verify actor, restore rule) so Appendix C matches the code. |
| P-05 | Low | Add a line to `docs/ROADMAP.md` Step 20 ("re-cut as P3-xx") — still listed as undone in `PROGRESS.md`. |
| P-06 | Low | Mark in ADR 0012 that reopen now unticks steps (after B-04). |

---

## 10. Exit criteria before starting P3-16

- [ ] Wave R0 gate is green and recorded for P3-09 … P3-15 in `PROGRESS.md`.
- [ ] Rules suite green, including the new cases for B-05, B-06, M-01 … M-04 and the 400-create batch.
- [ ] On an emulator with two accounts: create a template (manually or via a test seed) → open the app → occurrences appear → tick steps → completed → the second member verifies → reopen returns to in-progress → untick/complete/untick twice works → resume a paused template restores days.
- [ ] `no_hardcoded_options_test`, `file_size_test`, `layer_boundaries_test` green.
- [ ] No finding marked Blocker or High in this file remains open.

---

## 11. Quick finding index

| ID | Sev | Short title |
| --- | --- | --- |
| B-01 | Blocker | Generation never starts |
| B-02 | Blocker | Verify unreachable (missing template in `ref.can`) |
| B-03 | High | Verify queue lists chores needing no verification |
| B-04 | Blocker | Reopen is invisible on chores with steps |
| B-05 | Blocker | Event ids collide on repeat transitions |
| B-06 | Blocker | Restore of soft-deleted occurrences denied |
| B-07 | High | Generation race retry never fires |
| B-08 | High | Projected draft built without groups/policy/availability |
| B-09 | High | Paging skips docs sharing a `dateKey` |
| B-10 | Medium | Audit/inbox ids are identity hashes |
| B-11 | Blocker | Rules likely do not compile |
| D-01 … D-03 | Medium–Low | Listener lifetime, marker race, client clocks |
| M-01 … M-09 | Medium–Low | Rules vs roadmap gaps |
| Q-01 … Q-08 | Medium–Low | Domain/use-case quality |
| U-01 … U-12 | High–Low | Screen defects |
| P-01 … P-06 | High–Low | Process, tests, docs |
| R0-1 … R0-6 | Blocker–Low | Verify the base |

---

## 12. What I did not review (so you know the gaps)

- Line-by-line reading of: `RotationBuilder`, `ChangeRotation`, `ReplanOccurrences`, `ChoreItem`, `occurrence_mappers.toMap/fromDoc`, duty-group mappers/rules, template mappers/rules, shared widgets (P3-04), the gallery, ARB files, and the test suites.
- Whether the existing tests pass. They were not run.
- Anything outside P3-01 … P3-15 (calendar, comments, swaps, availability, inbox, rota board are not in the zip).
- The Phase 2 Bazar folders (the zip is a "lean" export without them).
