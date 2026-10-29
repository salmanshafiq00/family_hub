# Family Hub — Phase 3 Detailed Implementation Roadmap (Family Chores)

**Version:** 1.0 · written 2026-10-25 against the codebase in `android.zip` (Phase 1 + hardening H1–H12 + Phase 2 through P2-16 are in the tree).
**Purpose:** a build plan an AI coding tool can follow with almost no design thinking. Every step lists the exact files, names, signatures, data shapes, how the piece plugs into the rest of the app, what it depends on, and when it is done. Same format as `PHASE2_BAZAR_ROADMAP.md`.
**Scope:** `ROADMAP.md` Steps 20–26 (templates, rotation, generator, task detail, comments, availability/swaps, calendar), re-cut into smaller steps, aligned with the code that exists now, and extended with the two things the owner asked for on 2026-10-25: **(1) everything configurable is data, not hard-coded**, and **(2) a calendar that is modern, beautiful, dynamic and feature-rich**. `ROADMAP.md` stays the product source of truth; this file is the engineering source of truth for Phase 3.
**Not in Phase 3 (Phase 4):** local reminder scheduling, achievement badges/Hub Level, the celebration animation, the dashboard restyle. Phase 3 stores the data they need (reminder config on templates, completion events with timestamps) and writes `docs/chores_phase4_contract.md` so Phase 4 can start without reading Phase 3 code.

---

## 0. How to use this file

1. Work in the order of **§4 (execution plan)**. A step may start only when everything in its **Depends on** line is merged and CI is green.
2. One step = one branch = one prompt = one commit: `P3-07: Template data layer`. Never start a step on a red CI (CLAUDE.md "Never start the next step with a red CI").
3. Paste into the AI tool: *"Read CLAUDE.md and `docs/PHASE3_CHORES_ROADMAP.md` §1–§3, then implement step P3-xx exactly as written. List the files you will create before coding. End with: files changed, how to verify, assumptions."* (full template: Appendix E).
4. Each step card has the same fields as Phase 2: **Type** (`INDEPENDENT` / `DEPENDENT` / `PARALLEL-SAFE`), **Depends on**, **Parallel with**, **Unblocks**, **Files** (`NEW` / `EDIT` / `DELETE`), **Contents**, **Interacts with**, **Rules / tests**, **Done when**.
5. **[VERIFY]** = depends on current Firebase / package behaviour; check the official docs or the emulator, not memory. **[OWNER]** = a decision only the family owner can make; a default is given so work is never blocked.
6. **Owner requests already binding (2026-10-25):** (a) no option list is hard-coded: chore groups, due-time presets, absence reasons, calendar defaults, week start, generation horizon, house rules are **data in `settings/chores`** edited in the app (D-P3-4); (b) the chore calendar is the hero screen: Month / Week / Agenda + a family Rota board, filters, heat mode, projected future months, Bangla-first, light + dark (Appendix B is its spec); (c) free, maintained packages may be used where they clearly beat hand-written code (§2 D-P3-15, Appendix D).
7. **Carried over from Phase 1/2 and still binding:** Household Manager = the `moderator` role (display label only); Admin stays the super power; members see every member's contributions (irrelevant here); week start is a setting; Bangla default; two themes; Spark plan only; no Cloud Functions.

---

## 1. What the audit of the current code found (and what it changes in the plan)

I read the code Phase 3 builds on. These facts are *why* the plan looks the way it does.

### 1.1 What already exists and must be reused (do not rebuild)

| Capability | Where | How Phase 3 uses it |
| --- | --- | --- |
| Folder skeleton for chores: `chores/{templates, duty_groups, occurrences, calendar, swaps, availability, comments, achievements}` each with `data/ domain/ presentation/` (empty, `.gitkeep`); `ChoresModule` + `ChoresPlaceholderScreen` | `lib/features/chores/` | Fill the folders; replace the placeholder (P3-01). `achievements/` stays empty until Phase 4. |
| `FirestorePaths` already has `choreTemplates`, `dutyGroups`, `choreOccurrences`, `occurrenceEvents`, `occurrenceComments`, `memberAvailability`, `swapRequests`, `notificationInbox` | `core/firebase/firestore_paths.dart` | Add only what is missing (P3-03). |
| Rules: the generic deny-only block already names `choreTemplates, dutyGroups, choreOccurrences, memberAvailability, swapRequests, notificationInbox, memberStats` | `firebase/firestore.rules` bottom | Each Phase 3 step carves its collection out of that block with its own `match` (same method as Phase 2). |
| Indexes already seeded for `choreOccurrences`: `(dateKey, status)`, `(assigneeId, dateKey)`, `(monthKey, status)` | `firebase/firestore.indexes.json` | Keep; add the ones in §3.8. |
| Permissions: `manageChoreTemplates`, `reassignChore`, `requestSwap(own)`, `completeOwnChore(own)`, `commentOnChore`, `verifyChore(other, needs family switch + template switch)`; `PermissionSettings.choreVerificationEnabled`; `settings/permissions` | `core/permissions/` | Reuse; **five** new rows and one new family switch are added in P3-03 (§3.3). |
| Status tokens: `statusScheduled / InProgress / Completed / Verified / Overdue` each with `Container` and `On` colours, in both themes; `chart[0..9]`, `placeholderPalette[0..11]`; `StatusChip` + `WidgetStatus` (icon + label + colour) | `app/theme/app_tokens.dart`, `shared/widgets/status_chip.dart` | Every chore status uses these. `skipped` is the only new visual state (P3-15). |
| `DateKey`, `MonthKey`, `DateKeyRange`, `FamilyDateKeys`, `familyDateKeysProvider`, `resolveRange`, `startOfWeek`, `daysIn`, `monthsIn`, `Clock/FakeClock`, `IdGenerator` | `core/utils/` | The ONLY source of "today", day math and ids. `instantOf(DateKey, minutes)` is the one missing inverse (P3-02). |
| `AppFormatters`: Bangla/English `monthName`, `weekdayName`, `weekdayShort`, `monthLabel(MonthKey)`, `fullDate`, digit switch | `core/localization/app_formatters.dart` | All calendar labels. No new date formatting code in widgets. |
| `Result<T>` + sealed `AppFailure`, `TxRunner` (`runBatch`, `runTransaction`), `FakeTxRunner`, `guardWrite(commit, {probe})`, `AuditWriter`, `AuditEvent`, `BaseMapper`, `ServerTime` | `core/` | Same write patterns as Phase 2 §3.4. |
| `PermissionPolicy.can`, `requirePermission`, `ref.can`, `PermissionGate`, `currentActorProvider`; architecture test banning role checks in UI | `core/permissions`, `features/family` | Same as Phase 2. |
| `membersProvider` (all members), `Member.displayName`, `AppAvatar`, `PersonPicker` | `features/family`, `shared/widgets` | Assignee chips/avatars/pickers. |
| `FamilyModule` registry (`routes`, `dashboardCards`, `reports`, `requiredPermission`) and the nested-route pattern of `BazarModule` | `lib/modules/`, `features/bazar/bazar_module.dart` | Chores routes are nested under `AppRoutes.chores` **inside `ChoresModule.routes`**. |
| `bazar_entries.dart` tile-list pattern + `BazarHomeScreen` | `features/bazar/` | Same pattern → `chores_entries.dart` (P3-01). |
| `BazarSettings` + `settings/bazar` + `bazarSettingsProvider` (defaults when the document is absent) | `features/bazar/settings/` | **The template for `ChoreSettings` / `settings/chores`** (P3-05): absent document ⇒ defaults, no backfill needed. |
| Shared widgets (23): `MonthSwitcher`, `PersonPicker`, `ChoiceWrap`, `ProgressRing`, `ProgressBarStatus`, `StatusChip`, `AppCard`, `EmptyState`, `ErrorView`, `LoadingView`, `SectionHeader`, `DaySectionHeader`, `BusyButton`, `SyncBanner`, `PermissionGate`, `CategoryBadge`, `AppAvatar`… | `lib/shared/widgets/` | Reuse. New reusable widgets go in the same folder **and** in a new `lib/app/gallery/gallery_sections_p3.dart` (goldens + overflow test automatically). |
| Gallery + screen-state harness + overflow tests at text scale 2.0 | `app/gallery/`, `test/support/screen_states.dart` | Every Phase 3 screen is added to the harness (P3-30). |
| Architecture tests: `layer_boundaries` (import graph), `file_size` (300 lines), `no_unbounded_queries`, `no_role_checks_in_ui`, `no_step_todos`, `no_hard_coded_strings`, `no_raw_color`, `no_floating_point` | `test/architecture/`, `test/core/` | Phase 3 code must pass them: files ≤ 300 lines, `.limit()` on every collection read, no `Colors.*`, no `TODO(step-`. |
| `InMemoryBackend` / `InMemoryBazarBackend` pattern for use-case tests | `test/support/` | New `InMemoryChoresBackend` (P3-07, extended later). |

### 1.2 Gaps and traps found (each one is handled by a step)

| # | Finding | Consequence if ignored | Handled in |
| --- | --- | --- | --- |
| C-1 | CLAUDE.md rule 4 says occurrence id = `{templateId}_{yyyyMMdd}`. The family's own list has chores done **৩ বেলা** (three times a day: sweeping, filling the water filter). One id per template per day cannot represent them. | Either three look-alike templates or lost occurrences. | D-P3-3: templates have **slots**; id = `{templateId}_{yyyyMMdd}` for the `main` slot and `{templateId}_{yyyyMMdd}_{slotKey}` for others. CLAUDE.md rule 4 is amended in P3-01. |
| C-2 | `kMaxListenerDocs = 500`. A family with 15 daily templates has ≈ 450 occurrences a month, 20 templates ≈ 600. A month listener would silently cut data. | Missing days in the calendar. | P3-13 adds the dedicated `kMaxOccurrencesPerMonth = 900`; P3-21 adds the `truncated` flag and banner; P3-30 measures the read budget. |
| C-3 | `settings/rotationPolicy.absencePolicy` is written at family creation but **no use case edits it** and the rules only accept it as part of the generic settings union. | The absence policy chosen by the owner (A/B/C) can never be changed. | P3-06: `UpdateRotationPolicy` use case + rule. |
| C-4 | Rules for `settings/{s}`: write = `isAdmin(f)` (+ `bazar` for finance managers). A Household Manager cannot write `settings/chores`. | Managers cannot edit chore settings. | P3-06: `s == 'chores'` allowed for `isManager(f)`; `settings/choreGeneration` allowed for any active member (monotonic). |
| C-5 | Rules `eventTypes()` / `refTypes()` are closed lists (Phase 2 G-3). | Every chore write is denied until the new audit types exist. | P3-03 adds them in Dart **and** rules + mirror test. |
| C-6 | `Permission` has no row for: completing for someone else, own availability, managing others' availability, managing occurrences (skip/exception/force-reopen/hide comment), moderating comments; `PermissionSettings` has no `membersCanCompleteForOthers`. | Those actions would abuse `reassignChore` / `manageChoreTemplates`. | P3-03 (§3.3), matrix regenerated. |
| C-7 | `WidgetStatus` has five values; the stored status set needs `skipped` (absence policy C / manager skip) and the UI needs "awaiting verification", "needs cover", "needs attention" flags. | Skipped tasks shown as overdue or scheduled; flags squeezed into colour. | P3-04 adds `WidgetStatus.skipped` (neutral tokens), `StatusGlyph` and a generic `FlagChip`. |
| C-8 | `FamilyDateKeys` converts instant → date but not date + time-of-day → instant. `dueAt` needs it. | Local-time math scattered in use cases. | P3-02 `instantOf(DateKey, int minutesOfDay)` + tests around Dhaka midnight. |
| C-9 | A projected future month (no documents yet) and a materialized month must look identical and never disagree. | Calendar shows tasks that the generator later creates differently. | D-P3-6: ONE pure `OccurrenceGenerator`; the calendar's projected items are its drafts; materialized wins by id. |
| C-10 | `FirestoreTxRunner.runTransaction` cannot run offline (Phase 2 G-8). Swap accept/decline and cover assignment are integrity writes. | An offline accept would silently queue and conflict. | §3.4: integrity chore writes = transaction/batch **with probe** (server required); everyday completion = batch **without probe** (queues offline). |
| C-11 | Rules access-call limit (10 per request, 20 per batch). Generating 400 occurrences in one batch with per-document `get()` is rejected (Phase 2 G-9). | Generator fails on first run. | P3-13 mandatory emulator test with a 400-create batch; creation rule uses **one** membership lookup and no template/rotation lookup (D-P3-7); chunk fallback ≤ 100. **[VERIFY]** whether repeated `get()` of one document counts once. |
| C-12 | The calendar needs "my chores" and "all family" for the same month. Two queries double reads. | Reads budget blown. | D-P3-8: ONE month listener (all family), scope filter in memory. |
| C-13 | Subtask ticks by two phones at once (A ticks step 1, B ticks step 2 offline) leave a stored `status` that no single device computed. | Task stuck "in progress" with every box ticked. | D-P3-9: the stored status is a *cache*; the UI always uses the pure `effectiveStatus(...)`; the detail screen self-heals (idempotent). |
| C-14 | The family's PDF text is garbled (font encoding). I decoded it as far as I could (Appendix A) but several lines are uncertain. | Wrong seed wording. | P3-19 (starter-pack wizard) shows a confidence badge per line; nothing below "High" confidence is ticked by default, and Appendix G asks you to confirm the doubtful lines. |
| C-15 | `ROADMAP.md` sections 5/6/18 (chore business rules, rotation test cases) are not in the repo (PROGRESS.md says so). | The AI cannot read them. | The rules are restated here: §3.2 (data), Appendix C (status machine), Appendix F (rotation test cases). |
| C-16 | `PROGRESS.md`: Phase 2 steps P2-11…P2-16 were "written, not run". The base for Phase 3 may not compile. | Phase 3 starts on an unverified base. | P3-01 gate (same as P2-01). |
| C-17 | A member who leaves or is disabled stays in rotation snapshots. | Occurrences assigned to a person who cannot act. | D-P3-12: generator marks such days `assigneeId = null, needsCover = true`; duty-group screen warns. |
| C-18 | Week start: Bazar stores `weekStartDay` in `settings/bazar`; rotation by week and the calendar need one too. A later change must not silently shift rotation. | Rotation boundaries move when someone edits a setting. | `settings/chores.weekStartDay` (own value, default Saturday); every rotation **version snapshots its own** `weekStartDay`. |

---

## 2. Decisions (defaults are used unless you change them)

| # | Decision | Default in this roadmap |
| --- | --- | --- |
| D-P3-1 | Phase boundary | Phase 3 = templates, rotation, occurrences, completion, verification, comments, availability, swaps/covers, inbox, calendar, rota board. **Reminders, badges, Hub Level, celebration, dashboard restyle = Phase 4** (data hooks only). |
| D-P3-2 | Field naming | Same as Phase 2: explicit units (`dueMinutes`, `estimatedMinutes`, `throughEpochDay`), dates as `dateKey`/`monthKey` strings + UTC timestamps. |
| D-P3-3 | **Slots** (C-1) | A template has 1–6 `slots` `{key, labelBn?, labelEn?, dueMinutes?}`. The first slot key is always `main`. Occurrence id: `{templateId}_{yyyyMMdd}` for `main`, `{templateId}_{yyyyMMdd}_{slotKey}` for the others (slot keys: lowercase `[a-z0-9]{1,12}`). CLAUDE.md rule 4 is amended accordingly. |
| D-P3-4 | **No hard-coded option lists** | Chore groups, due-time presets, absence reasons, default calendar view/scope, week start, generation horizon, projected-months-ahead, overdue grace, swap expiry buffer, swaps on/off, absence approval, workload visibility and house rules live in `settings/chores` (absent document ⇒ `ChoreSettings.defaults`; no backfill, no seeder). Closed *domain* sets stay in code because the state machine depends on them: statuses, difficulty, assignee strategy, recurrence kinds, verification mode, cycle units. Widgets render lists they are given; a test fails if a widget file contains a literal option list (§3.7). |
| D-P3-5 | Occurrence per template per day | One document per (template, date, slot), deterministic id, never random. Soft-delete only (`deletedAt`) for obsolete unstarted future occurrences. |
| D-P3-6 | **Projected occurrences** (C-9) | The calendar and Today show materialized occurrences plus **projected** ones (drafts from the same pure generator) for dates that have no document yet, up to `projectedMonthsAhead` (default 3). Projected items are read-only, dashed, labelled "planned"; the first write on one (complete, comment, swap) **materializes it in the same batch**. Materialized always wins by id. |
| D-P3-7 | Who may create occurrences | **Any active member** (a plain member must be able to complete today's chore even if no manager opened the app). Rules check shape, id pattern, `status == 'scheduled'`, `createdBy == uid`; they cannot verify rotation correctness (Spark has no trusted server) — recorded in ADR 0011 as an accepted limit. |
| D-P3-8 | One listener per month | One live listener per visible month (all family occurrences, by `dateKey` range), keepAlive for the current month. "My chores / Family" is an in-memory filter. Outside-month days in the grid are dimmed and carry no markers (no extra reads). |
| D-P3-9 | Stored vs effective status (C-13) | Stored: `scheduled \| in_progress \| completed \| verified \| skipped`. Overdue is **derived** (`isOverdue(occurrence, now, grace)`), never stored. `effectiveStatus` is a pure function of `subtaskDone`, `completedAt`, `verifiedAt`, `skipReason`; all reads use it; a mismatch is repaired by an idempotent write when the detail screen opens. |
| D-P3-10 | Generation | A marker `settings/choreGeneration {throughEpochDay}` (any active member may only advance it, ≤ +120 days). App open: read the marker (cached) → generate only `(through, today + horizon]` → advance. Two devices racing write identical deterministic documents. Template/rotation edits call `RegenerateRange` on the manager's device. Default horizon **30 days** (setting 14–90). |
| D-P3-11 | Rotation | Calendar-based, never "who completed last" (spec). `planned(date) = M[(anchorIndex + cycles(anchorDate, date)) mod n]`, negative cycles handled, versions effective from a date, each version snapshots `weekStartDay`. Cycle units: `day, week, month, occurrence`. Duty group = one owner per cycle for all its templates; a template may also rotate alone. |
| D-P3-12 | Inactive member in rotation (C-17) | Occurrence created with `assigneeId = null`, `needsCover = true`, shown "needs an assignee" to managers. Never silently skip to the next person (that would shift the rota). |
| D-P3-13 | Absence policy | Default **A: ask for cover** (CLAUDE.md). B: auto-cover — the app picks a replacement and sends them a cover request they may decline (nothing is reassigned silently). C: skip (manager marks "skipped (absence)"). Stored in `settings/rotationPolicy.absencePolicy` (`ask_cover \| auto_cover \| skip`). Approved absence is neutral for later scoring. |
| D-P3-14 | Who completes | Default: the assignee, or a manager. `settings/permissions.membersCanCompleteForOthers` (default **false**) lets any active member complete someone else's chore ("done by"); `completedBy` is always the real actor. [OWNER] |
| D-P3-15 | Packages | **Add two**: `animations` (view transitions) and `flutter_slidable` (swipe actions). **Do not add**: `table_calendar`, `calendar_view`, `kalender`, `rrule`, `syncfusion_*`, a markdown package, `scrollable_positioned_list`. Reasons and verified facts: Appendix D. Phase 4 adds `flutter_local_notifications`, `confetti`/`lottie`. |
| D-P3-16 | Calendar | Custom month grid / week strip / agenda built from small widgets over a **pure `CalendarMonthModel`** (testable, token-themed, Bangla digits, any week start). `table_calendar` is the documented fallback only if the custom month grid fails the Appendix B acceptance checks. |
| D-P3-17 | Reasons | Reassign, swap, decline (optional), reopen, skip, exception and absence all require a **reason** (3–300 chars) except decline. Stored on the event. Reasons are free text; the absence *type* comes from the configurable list. |
| D-P3-18 | Comments | Never deleted by members. A manager may **hide** (flag + note, audited). `needsAttention` comment highlights the task for the assignee and offers "Reopen with this reason". Attachments: field **not** in the rules key set until the Storage decision is made (§2 D-P2-13 still holds). |
| D-P3-19 | Inbox | `notificationInbox` is general (module-neutral types) and lives in `features/notifications/`; Chores writes to it. Spark limit shown in help text: a recipient learns of a request when the app opens. |
| D-P3-20 | Workload / fairness view | Visible to managers by default; `settings/chores.workloadVisibleToMembers` (default **false**) opens it to everyone. No ranking, no "winner"; wording is "this month's share". |
| D-P3-21 | Per-user calendar preferences | View, scope, filters, density, marker style are **local** (`SharedPreferences`, `CalendarPrefs`), initial values from `settings/chores`. Not synced across devices in Phase 3. |
| D-P3-22 | Starter chores | Not seeded at family creation (they are this family's content). A **starter-pack wizard** (P3-19) offers packs defined as pure data; the first pack is the family's PDF (Appendix A). Every seeded template is editable and can be switched off. |
| D-P3-23 | Template edits | `UpdateTemplate` always bumps `revision`; the user chooses **future occurrences only** (default) or **also upcoming unstarted** (Replan). Started/completed occurrences are never touched. |
| D-P3-24 | Grid minimum width | Month grid cells must be ≥ 48 dp wide (accessibility). Below ≈ 336 dp screen width the Month view falls back to the Week view automatically (documented in Appendix B). |

---

## 3. Shared blueprint (every step refers to this section)

### 3.1 Folder layout to create

Names follow CLAUDE.md (snake_case files, `FooRepository` / `FirestoreFooRepository` / `FooMappers` / `FooController` / `FooScreen`, one use case per file). New sub-features `settings`, `rota` (and `features/notifications/` for the inbox) are added to the CLAUDE.md folder list in P3-01.

```text
lib/features/chores/
├── chores_module.dart                  EDIT  (routes, dashboardCards, settingsEntry)
├── chores_entries.dart                 NEW   list of "Manage" hub tiles (each step appends one)
├── presentation/
│   ├── chores_home_screen.dart         NEW   the calendar screen (replaces chores_placeholder_screen.dart, delete it)
│   ├── chores_manage_screen.dart       NEW   hub of chores_entries
│   ├── chores_providers.dart           NEW   cross-feature providers (see §3.5)
│   ├── chores_failure_messages.dart    NEW   extension on AppLocalizations: choresFailureMessage(AppFailure)
│   ├── chore_icons.dart                NEW   iconKey → IconData (the ONLY literal map allowed; ~40 icons + fallback)
│   └── widgets/                        NEW   chores-only widgets
├── settings/{domain,data,presentation}/        ChoreSettings (+ catalogs), rotation policy
├── templates/{domain,data,presentation}/       templates/domain/recurrence/ = the recurrence engine
├── duty_groups/{domain,data,presentation}/     rotation engine + duty groups
├── occurrences/{domain,data,presentation}/     entity, status machine, generator, completion use cases
├── comments/{domain,data,presentation}/
├── availability/{domain,data,presentation}/
├── swaps/{domain,data,presentation}/
├── calendar/{domain,presentation}/             CalendarMonthModel & friends (NO data layer: it reads occurrences)
├── rota/{domain,presentation}/                 workload / fairness board
└── achievements/                               stays empty until Phase 4
lib/features/notifications/{domain,data,presentation}/   the inbox (module-neutral)
lib/app/gallery/gallery_sections_p3.dart        NEW
test/features/chores/<same tree>/               mirrors lib/
test/support/in_memory_chores_backend.dart      NEW (P3-07, extended in later steps)
```

Cross-sub-feature imports: a `domain/` may import another chores sub-feature's `domain/` (never `data/` or `presentation/`). `presentation/` may import any chores `domain/` and shared/core, never `data/`. `features/notifications/domain` must not import any chores code (chores imports it).

### 3.2 Collections and document shapes

All documents also carry the `BaseMapper` fields `createdAt, createdBy, updatedAt, updatedBy, schemaVersion` (+ `deletedAt, deletedBy` where soft-deletable). "Key set" = the exact `hasOnly` list in the rules (one `*Keys()` function each, mirrored in `test/contract/rules_key_sets_test.dart`). Lists/maps are size-bounded in the rules (rules cannot iterate); the app tolerates ill-formed items like `relationships.items`.

**Shared value shapes**

```text
recurrence: { kind: 'once'|'daily'|'every_n_days'|'weekdays'|'every_n_weeks'|'days_of_month'|'nth_weekday'|'last_day',
              date?:'yyyy-MM-dd' (once), n?:int 2..60, anchor?:'yyyy-MM-dd' (every_n_*), weekStart?:1..7 (every_n_weeks only: snapshot, so a later week-start setting change cannot shift the pattern),
              weekdays?:[1..7] ≤7, days?:[1..31] ≤31, nth?:1..4|-1, weekday?:1..7,
              monthEnd?:'clamp'|'skip' (days_of_month; default clamp) }
slot:       { key:'main'|[a-z0-9]{1,12}, labelBn?:≤30, labelEn?:≤30, dueMinutes?:0..1439 }     // list ≤ 6, first key 'main'
subtask:    { id:[a-z0-9_]{1,16}, title:1..120, required:bool, hint?:≤200 }                      // list ≤ 30
rotation:   { versions:[ { from:'yyyy-MM-dd', members:[uid]≤12, anchorDate:'yyyy-MM-dd', anchorIndex:int≥0,
                           cycleUnit:'day'|'week'|'month'|'occurrence', weekStartDay:1..7 } ] }  // versions ≤ 20
reminders:  { enabled:bool, atDue:bool, offsetsMinutes:[int 1..1440]≤5, overdueEnabled:bool, overdueAfterMinutes:int 1..1440 }  // STORED in Phase 3, consumed in Phase 4
```

| Collection (under `families/{f}/…`) | Doc id | Fields (besides base) | Soft-delete | Notes |
| --- | --- | --- | --- | --- |
| `settings/chores` | doc | `weekStartDay` 1–7 (6), `defaultCalendarView` `agenda\|month\|week`, `defaultScope` `mine\|all`, `generationHorizonDays` 14–90 (30), `showProjected` bool, `projectedMonthsAhead` 0–12 (3), `overdueGraceMinutes` 0–240 (0), `swapsEnabled` bool, `swapExpiryBufferMinutes` 0–1440 (120), `absenceNeedsApproval` bool (false), `workloadVisibleToMembers` bool (false), `houseRules` ≤ 2000 chars (mini-markdown), `dueTimePresets` list ≤ 8 `{id, labelBn, labelEn?, minutes}`, `groups` list ≤ 30 `{id, nameBn, nameEn?, colorIndex 0–11, iconKey, sortOrder, active, builtIn}`, `absenceReasons` list ≤ 12 `{id, labelBn, labelEn?, active, builtIn}` | no | Absent ⇒ `ChoreSettings.defaults` (D-P3-4). Default catalogs: Appendix A.3. Extends `settingsKeys()`/`settingsOk` (new keys only; `weekStartDay` already exists). |
| `settings/choreGeneration` | doc | `throughEpochDay` int ≥ 0 | no | Marker (D-P3-10). Any active member may update **only** when the new value is greater and ≤ old + 120. Create allowed once. |
| `settings/rotationPolicy` | doc (exists) | `absencePolicy` `ask_cover\|auto_cover\|skip` | no | New use case `UpdateRotationPolicy` (C-3). |
| `settings/permissions` | doc (exists) | + `membersCanCompleteForOthers` bool (false) | no | Admin write (existing rule); key added to `settingsKeys()`, `PermissionSettings`, mapper. |
| `choreTemplates` | `tpl_<seedKey>` or random | `nameBn` 1–80, `nameEn?` ≤80, `groupId` (≤30, tolerant), `recurrence`, `slots`, `assignee` = `{strategy:'rotation'\|'fixed'\|'manual', fixedMemberId?, dutyGroupId?, rotation?}` (`rotation?` = the template's OWN rotation when `dutyGroupId` is absent), `instructions` ≤ 4000, `subtasks`, `estimatedMinutes?` 1–600, `difficulty` `easy\|normal\|hard`, `verification` `off\|required`, `reminders`, `startDate`, `endDate?`, `active`, `colorIndex?` 0–11, `iconKey?` ≤ 24, `sortOrder` int, `revision` int ≥ 1, `builtIn`, `seedKey?` | via `active=false` + `archivedAt` | Deactivate/archive, never delete. `revision` bumps on every content edit. |
| `dutyGroups` | random | `nameBn`, `nameEn?`, `colorIndex?`, `rotation`, `active`, `sortOrder` | via `active=false` | **The templates of a group are found by `template.assignee.dutyGroupId`** (single source of truth; the group stores no template list). |
| `choreOccurrences` | `{templateId}_{yyyyMMdd}` or `{templateId}_{yyyyMMdd}_{slotKey}` | `templateId`, `templateRev`, `slotKey`, `dateKey`, `monthKey`, `dueAt` (UTC ts; end of day when the slot has no time), `dueMinutes?`, **snapshots**: `nameBn`, `nameEn?`, `groupId`, `instructions`, `subtasks`, `difficulty`, `estimatedMinutes?`, `verification`; **state**: `status` `scheduled\|in_progress\|completed\|verified\|skipped`, `plannedAssigneeId?`, `assigneeId?` (null = unassigned), `coverForId?`, `assignmentSource` `rotation\|fixed\|manual\|cover\|swap\|reassign`, `needsCover` bool, `subtaskDone` map `subtaskId → {at: ts, by: uid}` (≤ 30 keys), `completedAt?`, `completedBy?`, `verifiedAt?`, `verifiedBy?`, `reopenCount` int, `exception?` `{note, by, at}`, `skipReason?` `absence\|manager`, `needsAttention` bool, `lastCommentAt?` | `deletedAt/By` (managers; obsolete unstarted future ones only) | **Snapshots never change** after creation except through Replan on unstarted documents. `subtaskDone` is a **map** so two phones can tick different boxes without overwriting each other (dotted-path `update`). |
| `choreOccurrences/{id}/events` | random | `type` (see below), `actorId`, `at` (client ts), `fromAssigneeId?`, `toAssigneeId?`, `reason?` ≤ 300, `prevCompletedAt?`, `requestId?` | never (append-only) | **Lifecycle only**: `covered, swapped, reassigned, completed, uncompleted, verified, reopened, exception, skipped, unskipped`. Subtask ticks and the initial rotation assignment write **no** event (the document itself shows them). Types are a closed list in the rules. |
| `choreOccurrences/{id}/comments` | random | `authorId`, `text` 1–1000, `needsAttention` bool, `resolvedAt?`, `resolvedBy?`, `hidden` bool, `hiddenBy?`, `hiddenNote?` ≤ 200 | `hidden` flag (never deleted) | Attachment fields are **not** in the key set (D-P3-18). |
| `memberAvailability` | random | `memberId`, `startDateKey`, `endDateKey`, `typeId` (id in `absenceReasons`, tolerant), `reason` 3–200, `status` `pending\|active\|rejected\|cancelled`, `decidedBy?`, `decidedAt?` | via `status` | A member creates own (`active`, or `pending` when `absenceNeedsApproval`); a manager creates for anyone. Max 366 days per record. |
| `swapRequests` | random | `occurrenceId`, `occurrenceDateKey`, `kind` `swap\|cover`, `fromMemberId`, `toMemberId`, `reason` 3–300, `status` `pending\|accepted\|declined\|expired\|cancelled`, `expiresAt` ts, `respondedAt?`, `respondedBy?`, `responseReason?` ≤ 300, `availabilityId?`, `requestedBy` uid | via `status` | Accept/decline happen only inside a batch that also updates the occurrence (see rules in P3-26). |
| `notificationInbox` | random | `toMemberId`, `type` (`swap_request, swap_result, needs_cover, chore_reopened, comment_attention, verification_needed, absence_decision`), `refType`, `refId`, `params` (≤ 6 string keys), `readAt?`, `archivedAt?` | via `archivedAt` | Owner reads/updates only `readAt`; any active member creates for another member (shape-checked). |

### 3.3 Permissions → use cases (single source: `PermissionPolicy`)

**New `Permission` rows (P3-03)** — all `PermissionModule.chores`:

| New permission | Admin | Household Manager | Member | Used for |
| --- | --- | --- | --- | --- |
| `completeChoreForOthers` | yes | yes | only when `settings/permissions.membersCanCompleteForOthers` | completing a chore assigned to somebody else |
| `recordOwnAvailability` | own | own | own | my own absence (`ownerId` = memberId) |
| `manageAvailability` | yes | yes | no | absence of anybody, approve/reject |
| `manageChoreOccurrences` | yes | yes | no | skip/unskip, completion exception, reopen a **verified** task |
| `moderateChoreComments` | yes | yes | no | hide / unhide a comment |

| Use case | Permission checked first (`requirePermission`) | Notes |
| --- | --- | --- |
| `UpdateChoreSettings`, `UpdateRotationPolicy`, `CreateTemplate`, `UpdateTemplate`, `PauseTemplate`, `ResumeTemplate`, `ArchiveTemplate`, `DuplicateTemplate`, `ApplyStarterPack`, `CreateDutyGroup`, `UpdateDutyGroup`, `ChangeRotation` (add/remove member), `RegenerateRange`, `ReplanOccurrences` | `manageChoreTemplates` | Household Manager and Admin. |
| `EnsureOccurrences` (materialize/advance marker) | `requireActiveMember` (add to `permission_access.dart` if missing: loads the member, denies anyone not active) | Any active member (D-P3-7). |
| `ToggleSubtask`, `ToggleParent`, `CompleteOccurrence` | `completeOwnChore(ownerId: assigneeId)` when actor == assignee, else `completeChoreForOthers` | An unassigned occurrence: `completeChoreForOthers`. |
| `VerifyOccurrence` | `verifyChore(ownerId: completedBy, template: snapshot.verification)` | Never the person who completed it. |
| `ReopenOccurrence` | `commentOnChore` for `completed`; `manageChoreOccurrences` for `verified` | Reason required (D-P3-17). |
| `RecordCompletionException`, `SkipOccurrence`, `UnskipOccurrence` | `manageChoreOccurrences` | Note/reason required. |
| `ReassignOccurrence`, `AssignOccurrence` (manual, unassigned) | `reassignChore` | Reason required; event + audit in the same batch. |
| `AddComment`, `MarkNeedsAttention`, `ResolveComment` | `commentOnChore` | |
| `HideComment`, `UnhideComment` | `moderateChoreComments` | Note required. |
| `AddAvailability` / `CancelAvailability` | `recordOwnAvailability` (`ownerId == memberId`) or `manageAvailability` | |
| `DecideAvailability` | `manageAvailability` | Only when `absenceNeedsApproval`. |
| `RequestSwap` | `requestSwap(ownerId: occurrence.assigneeId)` | Needs `settings.swapsEnabled`. |
| `AcceptSwap`, `DeclineSwap` | actor must be `toMemberId` (`requireActiveMember` + equality; no permission row) | A manager may `CancelSwap`. |
| `CancelSwap` | requester, or `reassignChore` | |
| `ExpireSwaps` | `requireActiveMember` | Runs on app open. |
| `MarkInboxRead` | owner only | |
| Reading templates, occurrences, comments, events, groups, settings | any active member (`canReadFamilyData`) | Everybody sees every chore (spec: personal and family views). |
| Reading the workload board | `manageChoreTemplates` **or** `settings.workloadVisibleToMembers` | D-P3-20. |

### 3.4 Write patterns (same two patterns as Phase 2 §3.4)

```text
EVERYDAY (batch, guardWrite WITHOUT probe → queues offline, global SyncBanner shows it):
  CreateTemplate/UpdateTemplate/Pause/Resume/Archive/Duplicate (the template doc only), duty-group edits,
  ToggleSubtask, ToggleParent, CompleteOccurrence, VerifyOccurrence, ReopenOccurrence, RecordCompletionException,
  Skip/Unskip, AddComment, ResolveComment, HideComment, AddAvailability (own), RequestSwap, MarkInboxRead,
  materializing a projected occurrence together with the action that touched it.
INTEGRITY (guardWrite WITH probe → server required, fails fast with Network):
  UpdateChoreSettings, UpdateRotationPolicy, ApplyStarterPack, ChangeRotation, RegenerateRange, ReplanOccurrences,
  EnsureOccurrences (generation), ReassignOccurrence, AcceptSwap, DeclineSwap, CancelSwap, ExpireSwaps,
  absence-policy application (cover requests / auto-cover), DecideAvailability.
```
* A use case builds a **pure write plan** (plain Dart objects); the repository stages it with its mappers. `domain/` never sees `TxRunner`.
* Generate ids **once per user intent** (the controller creates `eventId`, `requestId`, `commentId`, `availabilityId` when the sheet opens; a retry reuses them).
* **Bulk chunks:** ≤ 400 writes per batch (`kMaxBatchWrites` is 500; leave room for audit). Generation, regenerate and replan return progress and are **resumable** (deterministic ids make a repeat harmless).
* Every write calls `AuditWriter.write` in the same batch with an `AuditEvent` of §3.9. Subtask ticks and generation chunks write no per-document event.
* An assignee change on a document that is not `scheduled` + `rotation/fixed`, **always** carries an `events` document in the same batch (rules pair it with `getAfter`).

### 3.5 Provider graph — how every screen stays in sync

One Firestore listener per data set; everything else is a pure derived `Provider`. Keyed on `currentFamilyIdProvider`.

```text
currentFamilyIdProvider ─┬─ choreSettingsProvider (Stream; ChoreSettings.defaults when absent) ─► choreGroupsProvider, dueTimePresetsProvider, absenceReasonsProvider
                         ├─ templatesProvider (Stream ≤ kMaxChoreTemplates = 200)         ─► templateIndexProvider (id → template)
                         ├─ dutyGroupsProvider (Stream ≤ 50)
                         ├─ membersProvider (existing) ─► activeMembersProvider
                         ├─ availabilityProvider (Stream: active/pending, endDateKey ≥ today − 7, ≤ 200) ─► availabilityIndexProvider
                         ├─ generationMarkerProvider (Stream doc) ─► ensureOccurrencesOnOpen (side effect, once per app start per family)
                         ├─ monthOccurrencesProvider(MonthKey) (Stream, ≤ kMaxOccurrencesPerMonth; keepAlive for the current month; auto-dispose others)
                         │     ├─► projectedItemsProvider(MonthKey)  = OccurrenceGenerator.drafts(...) for dates with no document, beyond-today, within projectedMonthsAhead
                         │     └─► monthItemsProvider(MonthKey)      = merge(materialized, projected) → List<ChoreItem> (effectiveStatus, overdue via nowTickProvider)
                         │             ├─► calendarMonthModelProvider(MonthKey) → CalendarMonthModel (scope + filters applied)
                         │             ├─► agendaModelProvider, weekModelProvider
                         │             ├─► todayItemsProvider (mine) ─► todayProgressProvider      ─► (Phase 4 dashboard)
                         │             ├─► overdueItemsProvider
                         │             └─► workloadProvider(MonthKey) → WorkloadSummary
                         ├─ occurrenceProvider(id) (Stream doc; falls back to the projected draft) ─► occurrenceEventsProvider(id), commentsProvider(id)
                         ├─ verifyQueueProvider (Stream: status == completed && verification == required, ≤ 50)
                         ├─ pendingSwapsProvider (to me / from me / all for managers, ≤ 50) ─► swapCountsProvider
                         └─ inboxProvider (Stream, mine, ≤ 50) ─► unreadInboxCountProvider
nowTickProvider  (Stream every 60 s, autoDispose; watched ONLY by screens that show "overdue")
calendarPrefsProvider (Notifier, local) ─► calendarViewProvider, calendarScopeProvider, calendarFiltersProvider, selectedDayProvider, focusedMonthProvider
```
Interaction rules:
1. A screen never calls a repository; it calls a use-case provider through `newActionProvider()` and lets the listeners push the result back. Offline, the local cache makes the change appear immediately and `SyncBanner` shows "waiting to sync".
2. **"Mine / Family" and every filter are in-memory** over `monthItemsProvider` (D-P3-8). No filter ever starts another listener.
3. `focusedMonthProvider` re-targets the Month, Week and Agenda views together; each view keeps its own scroll position.
4. Derived numbers (progress, overdue, workload, day summary) are computed by **pure classes** (`SubtaskSync`, `effectiveStatus`, `CalendarMonthModel`, `WorkloadCalculator`), so Today, the calendar, the dashboard (Phase 4) and reports can never disagree.
5. Time never enters a widget: widgets get `dateKey`s and labels from providers; `now` only through `clockProvider` / `nowTickProvider`.

### 3.6 Stable failure codes (map each in `choresFailureMessage`, bn + en)

`Validation(field, code)`: `required`, `too_long`, `invalid_time`, `invalid_recurrence`, `no_dates`, `invalid_range`, `invalid_date`, `too_many_subtasks`, `too_many_slots`, `duplicate_slot`, `too_many_items`, `duplicate_id`, `reason_required`, `reason_too_short`, `member_required`, `invalid_rotation`, `too_few_members`, `invalid_horizon`, `invalid_week_start`, `invalid_minutes`.
`Conflict(code)`: `not_assigned_to_you`, `already_completed`, `not_completed`, `required_subtasks_open`, `self_verification`, `verification_not_required`, `already_verified`, `verified_requires_manager`, `occurrence_started`, `already_skipped`, `not_skipped`, `swap_not_pending`, `swap_expired`, `swaps_disabled`, `cover_not_needed`, `availability_overlap`, `member_unavailable`, `template_paused`, `rotation_member_inactive`, `range_too_large`, `starter_pack_applied`, `occurrence_deleted`, `concurrent_edit`, `last_group_in_use` (deactivating a group that templates still use is allowed but warns), `not_a_recipient`.
`NotFound(entity)`: `template`, `dutyGroup`, `occurrence`, `swapRequest`, `availability`, `comment`, `inboxItem`, `member`.

### 3.7 UI conventions for every Phase 3 screen

* Tokens only (`context.tokens`); status = `statusScheduled/InProgress/Completed/Verified/Overdue` (+ neutral for `skipped`); member colours = `placeholderPalette[stableIndex(uid)]` with `AppAvatar.foregroundFor`; group colours = `placeholderPalette[group.colorIndex]`; charts/heat = `tokens.chart`, never hex.
* Every stream-backed screen: `LoadingView` → data / `EmptyState` (friendly, with an action for managers) / `ErrorView(onRetry)`; offline = the global banner. Status is **icon + label + colour** (shape differs per status in calendar markers, Appendix B).
* **No literal option lists in widgets (D-P3-4).** Groups, presets, reasons, views come from providers. `test/architecture/no_hardcoded_options_test.dart` fails if any file under `lib/features/chores/**/presentation` or `lib/shared/widgets` contains one of the seed ids of Appendix A.3 (`'kitchen'`, `'sick'`, `'morning'`, …); only `default_chore_settings.dart` and the starter-pack data may.
* All dates through `AppFormatters` / providers; all numbers through the digit switch; text must survive scale 2.0 in Bangla; touch targets ≥ 48 dp (D-P3-24 for the grid).
* Strings: ARB keys in `app_bn.arb` (template) **and** `app_en.arb` + the three generated files; prefixes `chore*`, `template*`, `recurrence*`, `rotation*`, `dutyGroup*`, `occurrence*`, `calendar*`, `rota*`, `swap*`, `availability*`, `inbox*`, `starterPack*`, `choreSettings*`.
* Permission-dependent controls: `PermissionGate(allowed: ref.can(...), mode: disable|hide, deniedMessage: …)`. Screens that save use a file-private `newActionProvider()` + `BusyButton` + `choresFailureMessage`.
* Reasons (D-P3-17) are collected with one shared `ReasonSheet` (P3-04) so every flow validates 3–300 characters identically.
* File ≤ 300 lines: split into `widgets/` early; calendar widgets are small by design.

### 3.8 Indexes to add (each ≥ 2 fields; `tools/check_indexes.mjs` enforces it)

`choreOccurrences (status ASC, dateKey DESC)` (verify queue) · `choreOccurrences (templateId ASC, dateKey ASC)` (regenerate / replan one template) · `swapRequests (toMemberId ASC, status ASC)` · `swapRequests (fromMemberId ASC, status ASC)` · `swapRequests (status ASC, expiresAt ASC)` (expiry sweep) · `swapRequests (occurrenceId ASC, status ASC)` · `notificationInbox (toMemberId ASC, createdAt DESC)` · `memberAvailability (memberId ASC, endDateKey DESC)` · `memberAvailability (status ASC, endDateKey DESC)`. Existing `choreOccurrences (assigneeId, dateKey)` and `(dateKey, status)` stay. The month window query is a single-field range on `dateKey` (automatic index).

### 3.9 Audit event vocabulary (added in P3-03; mirror in `AuditEventType` AND rules `eventTypes()`)

| `type` | `refType` | `params` keys | Written by |
| --- | --- | --- | --- |
| `chores.settings_updated` | `choreSettings` | — | UpdateChoreSettings |
| `chores.rotation_policy_updated` | `choreSettings` | `policy` | UpdateRotationPolicy |
| `chores.template_created` / `_updated` / `_paused` / `_resumed` / `_archived` / `_duplicated` | `choreTemplate` | `name` (+ `rev`) | template use cases |
| `chores.starter_pack_applied` | `choreSettings` | `pack`, `templates`, `groups` | ApplyStarterPack |
| `chores.duty_group_created` / `_updated` | `dutyGroup` | `name` | duty-group use cases |
| `chores.rotation_changed` | `dutyGroup` | `name`, `change` (`add\|remove\|reorder`), `from` | ChangeRotation |
| `chores.occurrences_generated` | `choreSettings` | `from`, `to`, `count` | EnsureOccurrences / RegenerateRange (one per chunk) |
| `chores.occurrences_replanned` | `choreTemplate` | `name`, `from`, `count` | ReplanOccurrences |
| `chores.occurrence_completed` / `_uncompleted` / `_verified` / `_reopened` / `_exception` / `_skipped` / `_unskipped` / `_reassigned` | `occurrence` | `name`, `date`, `member` (+ `reason` where required) | completion use cases |
| `chores.comment_added` / `_hidden` | `comment` | `name`, `date` | comment use cases |
| `chores.availability_added` / `_cancelled` / `_decided` | `availability` | `member`, `from`, `to` (+ `status`) | availability use cases |
| `chores.swap_requested` / `_accepted` / `_declined` / `_cancelled` / `_expired` | `swapRequest` | `name`, `date`, `from`, `to` | swap use cases |
| `chores.cover_assigned` | `occurrence` | `name`, `date`, `from`, `to` | auto-cover (policy B) |

New `refTypes`: `choreSettings, choreTemplate, dutyGroup, occurrence, comment, availability, swapRequest`. Member params hold **uids**; `activityText` resolves names. Dates are `dateKey` strings.

### 3.10 Routes (all inside `ChoresModule.routes`, nested under `AppRoutes.chores = '/chores'`; the inbox is a top-level route above the shell)

| Constant in `AppRoutes` | Path | Screen | Step |
| --- | --- | --- | --- |
| `chores` (exists) | `/chores` | `ChoresHomeScreen` (the calendar) | P3-01 skeleton → P3-22 |
| `choresToday` | `/chores/today` | `TodayScreen` | P3-15 |
| `choresOccurrencePattern` / `choresOccurrence(id)` | `/chores/occurrence/:id` | `OccurrenceDetailScreen` | P3-15 |
| `choresVerify` | `/chores/verify` | `VerifyQueueScreen` | P3-15 |
| `choresManage` | `/chores/manage` | `ChoresManageScreen` | P3-01 skeleton → P3-29 |
| `choresTemplates` | `/chores/templates` | `TemplateListScreen` | P3-16 |
| `choresTemplateNew` | `/chores/templates/new` | `TemplateEditorScreen` | P3-16 (declare **before** `:id`) |
| `choresTemplateEditPattern` / `choresTemplateEdit(id)` | `/chores/templates/:id` | `TemplateEditorScreen(editingId:)` | P3-16 |
| `choresSettings` | `/chores/settings` | `ChoreSettingsScreen` | P3-17 |
| `choresDutyGroups` | `/chores/duty-groups` | `DutyGroupListScreen` | P3-18 |
| `choresDutyGroupPattern` / `choresDutyGroup(id)` | `/chores/duty-groups/:id` | `DutyGroupEditorScreen` | P3-18 |
| `choresStarterPack` | `/chores/starter-pack` | `StarterPackWizardScreen` | P3-19 |
| `choresAvailability` | `/chores/availability` | `AvailabilityScreen` | P3-27 |
| `choresRota` | `/chores/rota` | `RotaBoardScreen` | P3-28 |
| `inbox` | `/inbox` | `InboxScreen` | P3-27 (top-level; add to the router's signed-in-and-active set) |

The router's disabled-module redirect already uses `module.basePath` prefix matching, so every `/chores/...` route disappears when the family switches Chores off. `/inbox` stays reachable (it is module-neutral) but shows only items whose module is on.

### 3.11 Test pattern for every step (same as Phase 2 §3.8)

| Layer | Test file | Uses |
| --- | --- | --- |
| Pure domain / engines | `test/features/chores/<sub>/domain/*_test.dart` | `FakeClock(DateTime.utc(2026,10,24,9))`, table-driven; the rotation/recurrence cases of Appendix F |
| Use cases | `…/domain/usecases/*_test.dart` | `InMemoryChoresBackend` + `ChoresFixture` (family `f1`: admin `alice`, household manager `bob`, members `cara`, `dave`; pending `erin`) in `test/features/chores/chores_test_helpers.dart` |
| Mappers / repositories | `…/data/*_test.dart` | `FakeTxRunner` store assertions; round-trip `toMap → fromMap`; tolerance for missing/unknown values |
| Rules | `firebase/rules_test/<collection>.test.mjs` | copy `templates/collection.test.mjs.tmpl`; actors `ALICE` admin, `BOB` household manager, `CARA` member, `DAVE` pending, `ERIN` other family; one allowed + one denied per rule |
| Contract | `test/contract/rules_fixtures_test.dart` + `contract.test.mjs` + `fixtures/*.json` | real mapper payloads accepted by the real rules |
| Widgets | `test/features/chores/<sub>/presentation/*_test.dart` | provider overrides; bn + en; light + dark; text scale 2.0 |
| Goldens | tag `golden`, **Linux CI only** | calendar, task detail, editor |

Before every commit: `dart format .`, `flutter analyze` (zero issues, infos included), `flutter test --exclude-tags golden`, the rules suite, `node tools/check_indexes.mjs`.

---

## 4. Execution plan

### 4.1 Dependency table (read this before anything else)

| Step | Title | Type | Depends on | Can run in parallel with |
| --- | --- | --- | --- | --- |
| P3-01 | Preflight gate, Chores skeleton, seams | INDEPENDENT (gate) | Phase 2 up to P2-16 present | — |
| P3-02 | Pure helpers: time of day, `instantOf`, month matrix, mini-markdown | INDEPENDENT | — (after P3-01 for a green base) | P3-03, P3-04 |
| P3-03 | Phase 3 vocabulary: audit, paths, permissions, settings keys, ARB base | DEPENDENT | P3-01 | P3-02, P3-04 |
| P3-04 | Shared widgets + gallery (+ `skipped` status) | INDEPENDENT | P3-01 | everything in Waves A–C |
| P3-05 | Recurrence engine (pure) | DEPENDENT | P3-02 | P3-06, P3-09 |
| P3-06 | Chore settings & catalogs (domain + data + rules + providers) | DEPENDENT | P3-03 | P3-05, P3-09 |
| P3-07 | Template domain, use cases, in-memory backend | DEPENDENT | P3-05, P3-06 | P3-09 |
| P3-08 | Template data layer, rules, indexes, providers | DEPENDENT | P3-07 | P3-09, P3-11 |
| P3-09 | Rotation engine + duty-group domain (pure) | DEPENDENT | P3-02, P3-03, P3-05 | P3-06…P3-08 |
| P3-10 | Duty groups data, rules, providers | DEPENDENT | P3-08, P3-09 | P3-11 |
| P3-11 | Occurrence domain: entity, status machine, `SubtaskSync` | DEPENDENT | P3-02, P3-05, P3-07 | P3-08…P3-10 |
| P3-12 | Generator, projection, Ensure / Regenerate / Replan | DEPENDENT | P3-07, P3-09, P3-11 | P3-08, P3-10 |
| P3-13 | Occurrence data layer, rules (state machine), indexes, providers | DEPENDENT | P3-08, P3-10, P3-12 | — |
| P3-14 | Completion use cases | DEPENDENT | P3-11, P3-13 | P3-04 |
| P3-15 | Task detail, Today, Verify queue | DEPENDENT | P3-14, P3-04 | P3-16, P3-17 |
| P3-16 | Template list + editor + recurrence picker | DEPENDENT | P3-08, P3-05, P3-04 | P3-15, P3-17 |
| P3-17 | Chore settings screen + module settings hub | DEPENDENT | P3-06, P3-04 | P3-15, P3-16, P3-18 |
| P3-18 | Duty group screens (+ rota preview, own-rotation editor) | DEPENDENT | P3-10, P3-04, P3-16 | P3-15, P3-17 |
| P3-19 | Starter pack: data, use case, wizard | DEPENDENT | P3-08, P3-10, P3-16, P3-18 | P3-20 |
| P3-20 | Calendar domain (pure) | DEPENDENT | P3-11, P3-12, P3-02, P3-06 | P3-15…P3-19 |
| P3-21 | Calendar providers + local prefs | DEPENDENT | P3-20, P3-13 | P3-15…P3-19 |
| P3-22 | Month view | DEPENDENT | P3-21, P3-04, P3-15 | P3-28 |
| P3-23 | Day panel, Agenda, Week | DEPENDENT | P3-22, P3-15 | P3-28 |
| P3-24 | Calendar polish: heat, hatch, motion, accessibility, tablet, goldens | DEPENDENT | P3-22, P3-23 | P3-25, P3-26 |
| P3-25 | Comments | DEPENDENT | P3-13, P3-15 | P3-24, P3-26 |
| P3-26 | Availability, swaps, covers, inbox: domain + data + rules | DEPENDENT | P3-13, P3-09 | P3-24, P3-25 |
| P3-27 | Availability, swap, cover, inbox screens | DEPENDENT | P3-26, P3-04, P3-15 | P3-28 |
| P3-28 | Rota board & workload | DEPENDENT | P3-21, P3-04 | P3-23…P3-27 |
| P3-29 | Chores home, manage hub, dashboard cards, activity text, Phase 4 contract | DEPENDENT | P3-15, P3-17, P3-23, P3-27 | — |
| P3-30 | Hardening, performance, acceptance, sign-off | DEPENDENT | all | — |

### 4.2 Recommended order (single developer / single AI)

`P3-01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17 → 18 → 19 → 20 → 21 → 22 → 23 → 24 → 25 → 26 → 27 → 28 → 29 → 30`

**Why this order:** the numbers are the order. The first working slice lands at **P3-19**: pick the starter pack, choose who is in the rotation, see *today's* chores, complete one in two taps. The hero calendar (Wave E, P3-20…P3-24) comes next because it depends only on occurrences — comments, swaps and covers (Wave F) plug into it afterwards through providers the calendar already reads (empty until then, never a crash).

### 4.3 Parallel lanes (if you run several agents; each lane touches different folders)

| Lane | Steps in order | Folders touched |
| --- | --- | --- |
| **A — Pure engines** (critical path) | P3-02 → 05 → 09 → 11 → 12 → 14 | `core/utils`, `templates/domain/recurrence`, `duty_groups/domain`, `occurrences/domain` |
| **B — Data & rules** | (after 03) 06 → 07 → 08 → 10 → 13 | `settings/`, `templates/`, `duty_groups/`, `occurrences/data`, `firestore.rules` |
| **C — UI kit** | P3-04, then screens | `shared/widgets`, `app/gallery` |
| **D — First slice screens** | 15, 16, 17, 18, 19 | `*/presentation` |
| **E — Calendar** | 20 → 21 → 22 → 23 → 24; 28 | `calendar/`, `rota/` |
| **F — Collaboration** | 25, 26 → 27 | `comments/`, `availability/`, `swaps/`, `features/notifications/` |

Conflict hot-spots when lanes merge (append, never reorder): `firestore.rules`, `firestore.indexes.json`, `firestore_paths.dart`, `app_bn.arb` / `app_en.arb` (+ regenerate l10n), `app_routes.dart`, `chores_entries.dart`, `gallery_sections_p3.dart`, `bootstrap.dart` provider overrides, `test/contract/rules_fixtures_test.dart`, `audit_event_type.dart`, `permission.dart`, `settingsKeys()`. Merge one lane at a time; re-run `flutter gen-l10n`.

---

## 5. Step cards

Conventions used in every card: paths are relative to the Flutter project root; `NEW` = create, `EDIT` = change an existing file, `DELETE` = remove. "Hot-spot files" (§4.3) are only ever appended to. Every step ends with the commit checklist of §3.11. Names such as `ChoreItem`, `OccurrenceGenerator`, `ChoreSettings` are fixed here so later steps can rely on them.

---

### Wave A — Foundations (P3-01 … P3-04)

#### P3-01 — Preflight gate, Chores skeleton, seams

- **Type:** INDEPENDENT (gate). **Depends on:** Phase 2 steps up to P2-16 present in the tree. **Parallel with:** nothing. **Unblocks:** everything.
- **Why:** `PROGRESS.md` says P2-11…P2-16 were written without running (C-16). Phase 3 must not start on an unverified base, and it needs a few repository rules amended before any code exists (C-1).
- **Files:**
  - EDIT `PROGRESS.md` (gate result table), `CLAUDE.md` (see below), `ROADMAP.md` (one line at Step 20: "re-cut as P3-xx, see `docs/PHASE3_CHORES_ROADMAP.md`").
  - NEW `docs/PHASE3_CHORES_ROADMAP.md` (this file), `docs/adr/0009-chore-slots-and-occurrence-ids.md`, `0010-projected-occurrences-and-generation-marker.md`, `0011-occurrence-creation-by-any-member.md`, `0012-stored-vs-effective-status.md`, `0013-custom-calendar-instead-of-package.md`.
  - NEW `lib/features/chores/chores_entries.dart`, `presentation/chores_home_screen.dart`, `presentation/chores_manage_screen.dart`.
  - EDIT `lib/features/chores/chores_module.dart` (routes nested under `AppRoutes.chores`: `''` → `ChoresHomeScreen`, `manage` → `ChoresManageScreen`), `lib/app/router/app_routes.dart` (`choresManage`).
  - DELETE `presentation/chores_placeholder_screen.dart` (and its test if any; move the test to the new screen).
  - NEW `lib/features/notifications/{domain,data,presentation}/.gitkeep`.
- **Contents:**
  1. **Gate** (run in this order, paste the output into `PROGRESS.md` under "P3-01 gate"): `dart format --set-exit-if-changed .` → `flutter pub get` → `flutter gen-l10n` (must give no diff) → `flutter analyze` → `flutter test --exclude-tags golden` → rules suite (CLAUDE.md "Rules extension") → `node tools/check_indexes.mjs`. If anything is red, fix **only that** in a separate commit `P3-00: repair base` before continuing. Nothing else in Phase 3 starts on red.
  2. **CLAUDE.md edits.** Rule 4 becomes: *"Occurrence ids are deterministic: `{templateId}_{yyyyMMdd}` for the `main` slot, `{templateId}_{yyyyMMdd}_{slotKey}` for other slots. Never `add()`."* Add folder entries for `chores/settings`, `chores/rota`, `features/notifications`. Add rules 34–44:
     - 34 No literal option list (group, preset, reason, view) in chores presentation code; lists come from `settings/chores` providers (D-P3-4).
     - 35 Dates, assignees and statuses are derived only by the pure engines `RecurrenceEngine`, `RotationEngine`, `OccurrenceGenerator`, `effectiveStatus`, `SubtaskSync`, `CalendarMonthModel`; widgets never compute them.
     - 36 The stored `status` is a cache. UI reads `ChoreItem.status` (effective), never `occurrence.status` directly.
     - 37 One Firestore listener per visible month; scope and filters are in-memory; no per-day queries.
     - 38 Occurrence documents are written with deterministic ids only.
     - 39 Occurrence snapshots (`nameBn`, `subtasks`, …) never change except by `ReplanOccurrences` on unstarted documents.
     - 40 Reassign, swap, reopen, skip, exception, absence need a reason (3–300 chars) collected by `ReasonSheet`.
     - 41 Rotation follows the calendar, never "who completed last"; every rotation version snapshots its `weekStartDay`.
     - 42 Comments are never deleted; managers may hide with a note.
     - 43 Calendar targets ≥ 48 dp; status = glyph + label + colour; honour reduced motion.
     - 44 Only the packages in Appendix D may be added in Phase 3; another needs an ADR.
  3. **ADR files** (one page each: context, decision, consequences) restating D-P3-3, D-P3-6/10, D-P3-7, D-P3-9, D-P3-16.
  4. **Skeleton screens.** `ChoresHomeScreen`: `Scaffold`, app bar "চোর/Chores" (existing l10n key), body = `EmptyState` "calendar arrives in P3-22" is **not** allowed (no step text in UI); use the real empty state wording "কোনো কাজ নেই / No chores yet" with a manager-only button "Manage" → `AppRoutes.choresManage`. `ChoresManageScreen`: tile list built from `choresEntries(ref)` (same shape as `bazarEntries`): a record `ChoresEntry({id, titleKey, subtitleKey, icon, route, requiredPermission, badgeProvider?})`; the list starts empty and every later step appends one entry.
  5. Keep the `ChoresModule` registry contract unchanged (`requiredPermission`, `dashboardCards` empty, `reports` empty).
- **Interacts with:** `FamilyModule` registry and the router's disabled-module redirect (prefix `/chores`); `BazarModule` is the pattern to copy.
- **Rules / tests:** `chores_module_test.dart` (routes exist, `manage` route reachable by a manager, hidden when module off); architecture tests still green (no `TODO(step-`).
- **Done when:** gate green and recorded; app starts; Chores tab shows the skeleton; CLAUDE.md contains rules 34–44; five ADR files exist.

#### P3-02 — Pure helpers: time of day, `instantOf`, month matrix, mini-markdown

- **Type:** INDEPENDENT. **Depends on:** P3-01 (green base). **Parallel with:** P3-03, P3-04. **Unblocks:** P3-05, P3-09, P3-11, P3-20.
- **Files:**
  - EDIT `lib/core/utils/family_date_keys.dart` (+ tests): `DateTime instantOf(DateKey key, int minutesOfDay)` (UTC instant of that wall-clock time in the household timezone), `DateTime endOfDay(DateKey key)` (= `instantOf(key, 1439)` with seconds 59), `int minutesOfDay(DateTime instant)`.
  - EDIT `lib/core/utils/date_key.dart` **only if missing**: `DateKey.addDays(int)`, `DateKey.isoWeekday` (1 = Monday … 7 = Sunday), `MonthKey.addMonths(int)`, `DateKey.compareTo`, `DateKey.epochDay` / `DateKey.fromEpochDay`.
  - NEW `lib/core/utils/month_matrix.dart`: `MonthMatrix.build(MonthKey month, int weekStartDay) → List<List<DateKey>>` (always full weeks; 4–6 rows; leading/trailing days are the neighbouring months'), `MonthMatrix.weekdayOrder(int weekStartDay) → List<int>` (e.g. start 6 ⇒ `[6,7,1,2,3,4,5]`), `weekOf(DateKey, weekStartDay) → DateKeyRange`.
  - NEW `lib/core/utils/mini_markdown.dart`: pure parser `MiniMarkdown.parse(String) → List<MdBlock>`; blocks: `MdParagraph(spans)`, `MdBullet(spans)`, `MdNumbered(n, spans)`, `MdHeading(spans)`; spans `MdText(text, bold)`. Supported syntax only: `**bold**`, lines starting `- ` or `• `, lines starting `1. `, lines starting `# `. Everything else is plain text. No HTML, no links (no injection surface).
  - EDIT `lib/core/localization/app_formatters.dart`: `timeOfDay(int minutes)` ("সকাল ৯:০০" / "9:00 AM"; day-part words সকাল/দুপুর/বিকাল/সন্ধ্যা/রাত in Bangla), `dayPartKey(int minutes)` → enum `DayPart {earlyMorning, morning, noon, afternoon, evening, night}` (pure; labels come from ARB), `durationLabel(int minutes)` ("৪৫ মি." / "1 h 30 m").
  - NEW tests: `family_date_keys_instant_test.dart` (Dhaka midnight, 23:59, 00:00 next day, leap day 2028-02-29), `month_matrix_test.dart` (every week-start 1–7 × months Feb 2026, Oct 2026, Feb 2028; 5- and 6-row months; first cell weekday correct), `mini_markdown_test.dart` (nesting, unclosed `**`, Bangla text, empty lines, 4000-char input in < 5 ms).
- **Contents:** these are the only helpers Phase 3 adds to `core/`. They contain no Flutter imports (except `AppFormatters` which already does) and no `DateTime.now()`.
- **Interacts with:** `Clock`/`FakeClock` (callers pass `now`), `AppFormatters` digit switch, `familyDateKeysProvider` (timezone).
- **Rules / tests:** property test: `dateKeyOf(instantOf(k, m)) == k` for every minute in a sample month; `MonthMatrix` rows × 7 cells, no duplicates, contiguous.
- **Done when:** tests green; `flutter analyze` clean; no widget code touched.

#### P3-03 — Phase 3 vocabulary: audit types, paths, permissions, settings keys, limits, ARB base

- **Type:** DEPENDENT. **Depends on:** P3-01. **Parallel with:** P3-02, P3-04. **Unblocks:** P3-06, P3-09.
- **Files (all EDIT unless NEW):**
  - `lib/core/audit/audit_event_type.dart`: every type in §3.9 (const strings), grouped under a `chores` section; `AuditRefType` additions.
  - `firebase/firestore.rules`: `eventTypes()` and `refTypes()` get the same values; `settingsKeys()` gets `membersCanCompleteForOthers` (the other new settings keys come in P3-06).
  - `test/contract/audit_vocabulary_mirror_test.dart` (existing mirror test is extended: Dart constants == rules lists, parsed from the `.rules` file).
  - `lib/core/firebase/firestore_paths.dart`: add `choreGeneration` (settings doc), `choreSettings` (settings doc), `occurrenceEvents(id)`, `occurrenceComments(id)` if not yet there, `inbox` helpers; add `AppRoutes` constants of §3.10 (declared, screens come later) — **but** do not register routes whose screen does not exist.
  - `lib/core/permissions/permission.dart`, `permission_policy.dart`, `permission_access.dart`: the five rows of §3.3 + `requireActiveMember(ref/actor)`; `PermissionSettings.membersCanCompleteForOthers` (default `false`) + mapper + `settingsOk` key.
  - `docs/permission_matrix.md` regenerated from the policy (the generator test already exists; update its expected file).
  - `lib/core/firebase/query_limits.dart`: `kMaxChoreTemplates = 200`, `kMaxDutyGroups = 50`, `kMaxOccurrencesPerMonth = 900`, `kMaxAvailabilityDocs = 200`, `kMaxSwapDocs = 50`, `kMaxInboxDocs = 50`, `kMaxVerifyQueue = 50`, `kMaxCommentsPerOccurrence = 200`, `kMaxEventsPerOccurrence = 100`.
  - `lib/core/localization/app_bn.arb`, `app_en.arb` and the three generated files: base keys for the module name, the five new permission labels, the audit activity strings (stub text that P3-29 finalises), the status words for `skipped`, `flags` (needs cover, awaiting verification, needs attention, planned), the failure codes of §3.6 (`choresFailure_*`).
- **Contents:** nothing here has behaviour; it is the vocabulary every later step compiles against. Keys follow the prefixes in §3.7. Bangla text first, English second, both written together.
- **Interacts with:** the rules mirror test is what stops a later step from writing an audit type the rules reject (C-5).
- **Rules / tests:** `permission_policy_test.dart` rows for all five new permissions × admin / manager / member / pending / disabled; `rules_key_sets_test.dart` unchanged but green; ARB parity test (every key in both languages).
- **Done when:** analyzer clean; matrix doc diff shows exactly five new rows; `flutter gen-l10n` produces no diff after the manual edit.

#### P3-04 — Shared widgets and gallery (+ `skipped` status, status glyphs)

- **Type:** INDEPENDENT. **Depends on:** P3-01. **Parallel with:** everything in Waves A–C. **Unblocks:** P3-15…P3-18, P3-22…P3-28.
- **Files:**
  - EDIT `pubspec.yaml`: `animations` and `flutter_slidable` (Appendix D; **[VERIFY]** the resolved versions with `flutter pub add`, keep caret ranges, commit `pubspec.lock`).
  - EDIT `lib/shared/widgets/status_chip.dart`: `WidgetStatus.skipped` (tokens `statusSkipped` / `statusSkippedContainer` / `On` added to `AppTokens` for both themes; neutral grey-blue, contrast ≥ 4.5:1 checked by the existing contrast test).
  - NEW in `lib/shared/widgets/`: `status_glyph.dart` (shape per status, drawn with `CustomPainter`: scheduled = hollow ring, in progress = half-filled ring, completed = filled circle + check, verified = filled circle + double check on a ring, overdue = rounded triangle with `!`, skipped = ring with a dash; sizes 10/14/18; always paired with a label somewhere on the screen), `flag_chip.dart` (small pill: icon + label + tone; used for "needs cover", "awaiting verification", "needs attention", "planned", "swap pending"), `reason_sheet.dart` (`showReasonSheet(context, {title, hint, minLength = 3, maxLength = 300, required = true}) → Future<String?>`; validates identically everywhere; Bangla error text), `minutes_field.dart` (wraps `showTimePicker`, shows `AppFormatters.timeOfDay`, returns minutes), `weekday_chips.dart` (multi-select 1–7 in the order of a given `weekStartDay`, labels from `AppFormatters.weekdayShort`), `color_swatch_picker.dart` (indices 0–11 of `placeholderPalette`, selected state with check + semantics label), `avatar_stack.dart` (overlapping `AppAvatar`s, "+N"), `step_progress.dart` (animated "3/5" with ring, reduced-motion aware), `mini_markdown_view.dart` (renders `MdBlock`s with theme text styles; selectable), `catalog_editor.dart` (generic reorderable list editor for `{id, labelBn, labelEn?, active}` rows with add/edit sheet; used three times in P3-17), `segmented_choice.dart` only if `ChoiceWrap` cannot do single-select segmented (check first).
  - NEW `lib/app/gallery/gallery_sections_p3.dart` and an edit of the gallery index: one section per new widget in both themes, both languages, scale 1.0 and 2.0.
  - NEW tests next to each widget; goldens only in the gallery (tag `golden`).
- **Contents:** all widgets take data and callbacks only, never providers (they live in `shared/`). Colours only from `context.tokens`. Every interactive widget has `Semantics` labels and ≥ 48 dp targets.
- **Interacts with:** `no_raw_color`, `no_hard_coded_strings`, overflow test at scale 2.0 (the gallery harness picks the new sections up automatically).
- **Rules / tests:** widget tests for `ReasonSheet` (2 chars rejected, 3 accepted, 301 rejected, cancel returns null), `WeekdayChips` (start day 6 order), `StatusGlyph` semantics, `CatalogEditor` (reorder, add, deactivate, built-in cannot be removed).
- **Done when:** gallery renders all new widgets without overflow in bn/en, light/dark, scale 2.0; `statusSkipped` contrast test passes.

---

### Wave B — Engines and data (P3-05 … P3-10)

#### P3-05 — Recurrence engine (pure)

- **Type:** DEPENDENT. **Depends on:** P3-02. **Parallel with:** P3-06, P3-09. **Unblocks:** P3-07, P3-09, P3-11, P3-12.
- **Files:** NEW `lib/features/chores/templates/domain/recurrence/`:
  - `recurrence.dart`: `sealed class Recurrence` with `OnceRecurrence(date)`, `DailyRecurrence`, `EveryNDaysRecurrence(n, anchor)`, `WeekdaysRecurrence(weekdays)`, `EveryNWeeksRecurrence(n, anchor, weekdays, weekStart)`, `DaysOfMonthRecurrence(days, monthEnd)`, `NthWeekdayRecurrence(nth, weekday)`, `LastDayRecurrence`; `RecurrenceKind` enum with the string ids of §3.2.
  - `recurrence_engine.dart`: `RecurrenceEngine.occursOn(Recurrence r, DateKey day, {DateKey? startDate, DateKey? endDate})`; `datesIn(Recurrence r, DateKeyRange range, {startDate, endDate}) → List<DateKey>` (ascending, bounded by the template's active span); `nextAfter(r, DateKey, limit: 400 days) → DateKey?`; `countBetween(r, from, to)` (used by the `occurrence` rotation unit).
  - `recurrence_validator.dart`: returns `List<Validation>` with the stable codes `invalid_recurrence`, `no_dates`, `invalid_range`, `invalid_date` (e.g. 31st with `skip` mode never fires in some months → warning, not error; empty weekday set → `no_dates`).
  - `recurrence_describe.dart`: `RecurrenceSummary` value object (`kind`, `n`, `weekdays`, `days`, `nth`) — **no strings**; the presentation layer turns it into a sentence via ARB (so Bangla grammar lives in ARB, not code).
- **Contents:** semantics, all in household local dates (never UTC):
  - `days_of_month` with `monthEnd = clamp`: day 31 fires on the last day of shorter months; with `skip`: not at all that month. Feb 29 follows the same rule.
  - `nth_weekday`: `nth` 1–4 or −1 (last). `last_day`: last calendar day.
  - `every_n_days`: `(epochDay(day) − epochDay(anchor)) mod n == 0`, defined for days before the anchor too.
  - `every_n_weeks`: week index = `floor((epochDay(day) − epochDay(weekStartOf(anchor))) / 7)`; fires when `index mod n == 0` and the weekday is in the set. `weekStart` comes from the recurrence itself.
  - `once`: only that date. `startDate`/`endDate` clip every kind.
- **Interacts with:** the editor (P3-16) for live preview, the generator (P3-12), the rotation `occurrence` unit (P3-09).
- **Rules / tests:** the table in Appendix F.1 (≥ 40 cases) as a data-driven test; a fuzz test comparing `datesIn` with 365 individual `occursOn` calls for every kind.
- **Done when:** all cases green; no `DateTime` use except through `DateKey`.

#### P3-06 — Chore settings and catalogs (domain + data + rules + providers)

- **Type:** DEPENDENT. **Depends on:** P3-03. **Parallel with:** P3-05, P3-09. **Unblocks:** P3-07, P3-17, P3-20.
- **Files:** NEW under `lib/features/chores/settings/`:
  - `domain/chore_settings.dart` (`ChoreSettings` + `ChoreGroup`, `DueTimePreset`, `AbsenceReason`, enums `CalendarViewKind {agenda, month, week}`, `CalendarScopeKind {mine, all}`), `domain/default_chore_settings.dart` (the **only** place with seed ids — Appendix A.3), `domain/chore_catalogs.dart` (`ChoreCatalogs`: `groupOf(id)` tolerant fallback "other", `presetOf(id)`, `reasonOf(id)`, active-only getters, sorted by `sortOrder`), `domain/usecases/update_chore_settings.dart`, `update_rotation_policy.dart`, `domain/chore_settings_repository.dart`, `domain/chore_settings_validator.dart`.
  - `data/chore_settings_mappers.dart`, `data/firestore_chore_settings_repository.dart`.
  - `presentation/chore_settings_providers.dart`: `choreSettingsProvider`, `choreGroupsProvider`, `dueTimePresetsProvider`, `absenceReasonsProvider`, `rotationPolicyProvider`, `choreCatalogsProvider`, `updateChoreSettingsProvider`.
  - EDIT `firebase/firestore.rules`: extend `settingsKeys()` with the new keys; add `choreSettingsOk(d)` (type and range checks of §3.2, list sizes, each list item shape via helper functions for the first and last item only — rules cannot loop; the app tolerates malformed middle items); `settings/chores` write allowed for `isManager(f)` **and** admin; `settings/choreGeneration` create-once / monotonic update by any active member (`new > old && new <= old + 120`); `settings/rotationPolicy.absencePolicy` update validated (`ask_cover|auto_cover|skip`) by manager/admin.
  - NEW `firebase/rules_test/chore_settings.test.mjs` and fixtures.
- **Contents:**
  - `ChoreSettings.defaults` as in §3.2; absent document ⇒ defaults; **no seeder, no backfill**. A saved document stores the whole object (so a later release can add defaults without overwriting the family's choices: unknown/missing keys fall back to defaults per field in the mapper).
  - Validation: ids unique within a list, ≤ list limits, `builtIn` items may be renamed/deactivated but not removed, at least one active group and one active absence reason, `weekStartDay` 1–7, `generationHorizonDays` 14–90, `projectedMonthsAhead` 0–12, `overdueGraceMinutes` 0–240, `swapExpiryBufferMinutes` 0–1440, `houseRules` ≤ 2000.
  - `UpdateChoreSettings` is an INTEGRITY write (probe) with audit `chores.settings_updated`. `UpdateRotationPolicy` writes `settings/rotationPolicy` with audit `chores.rotation_policy_updated` (closes C-3).
  - `membersCanCompleteForOthers` stays in `settings/permissions` (admin only, existing rule); this step only adds the toggle to the existing permission-settings use case if it does not already take the whole object.
- **Interacts with:** every later screen reads catalogs through providers; `bazar_settings` is the code template (copy its test layout).
- **Rules / tests:** use-case tests (validation table), mapper tolerance tests (missing list, unknown `calendarView`), rules tests: admin ✔, manager ✔ (`chores`), member ✘, pending ✘, other family ✘; generation marker: member +1 ✔, decrease ✘, +121 ✘, create when absent ✔.
- **Done when:** a manager can change settings via a test-only call; defaults appear when the document is absent; rules suite green.

#### P3-07 — Template domain, use cases, in-memory backend

- **Type:** DEPENDENT. **Depends on:** P3-05, P3-06. **Parallel with:** P3-09. **Unblocks:** P3-08, P3-11, P3-12.
- **Files:** NEW under `lib/features/chores/templates/domain/`: `chore_template.dart` (`ChoreTemplate`, `TemplateSlot`, `TemplateSubtask`, `AssigneeSpec` + `AssigneeStrategy {rotation, fixed, manual}`, `Difficulty {easy, normal, hard}`, `VerificationMode {off, required}`, `ReminderConfig`), `template_validator.dart`, `template_repository.dart` (interface), and `usecases/`: `create_template.dart`, `update_template.dart` (`ReplanScope {futureOnly, includeUpcoming}`), `pause_template.dart`, `resume_template.dart`, `archive_template.dart`, `duplicate_template.dart`.
  NEW `test/support/in_memory_chores_backend.dart` (templates, settings, members, and the slots other steps will fill) and `test/features/chores/chores_test_helpers.dart` (`ChoresFixture`, builders `aTemplate()`, `aSlot()`).
- **Contents:**
  - Validator (stable codes of §3.6): name 1–80, ≤ 6 slots, first slot `main`, unique slot keys `[a-z0-9]{1,12}`, ≤ 30 subtasks with unique ids and 1–120 char titles, `instructions` ≤ 4000, recurrence valid, `fixed` needs a member, `rotation` needs a duty group **or** an own rotation with ≥ 2 members, `endDate ≥ startDate`, `estimatedMinutes` 1–600.
  - `CreateTemplate` assigns a random id (or `tpl_<seedKey>` for starter packs), `revision = 1`, `sortOrder = max + 1`. `UpdateTemplate` bumps `revision`, returns `TemplateSaved(template, replanScope)`; the **caller** (editor controller, P3-16) then runs `RegenerateRange` / `ReplanOccurrences` from P3-12 — the use case itself never touches occurrences (keeps domain steps independent).
  - Pause/Resume flip `active`; Archive sets `active = false` and `archivedAt`; Duplicate copies with a new id, name suffix from ARB ("(কপি)"), `builtIn = false`, `seedKey = null`.
  - Audit per §3.9. All are EVERYDAY writes (batch, no probe).
- **Interacts with:** catalogs (group must exist or fall back), duty groups (checked only for id format here; existence is checked in P3-10 via the repository).
- **Rules / tests:** use-case tests with the in-memory backend: permission matrix (admin ✔, manager ✔, member ✘), each validation code, revision bump, duplicate independence, archive hides from active list.
- **Done when:** use-case tests green against the in-memory backend; zero Firestore imports in `domain/`.

#### P3-08 — Template data layer, rules, indexes, providers

- **Type:** DEPENDENT. **Depends on:** P3-07. **Parallel with:** P3-09, P3-11. **Unblocks:** P3-10, P3-13, P3-16.
- **Files:** NEW `templates/data/chore_template_mappers.dart`, `firestore_chore_template_repository.dart`; NEW `templates/presentation/template_providers.dart` (`templatesProvider` Stream ≤ `kMaxChoreTemplates`, `templateIndexProvider`, `templateProvider(id)`, `activeTemplatesProvider`, `createTemplateProvider`…); EDIT `firebase/firestore.rules` (carve `choreTemplates` out of the deny block; `templateKeys()`, `templateOk(d)`; create/update manager-or-admin; **no delete**; `revision` must increase by exactly 1 on content edits; `seedKey` immutable); NEW `firebase/rules_test/chore_templates.test.mjs`; EDIT `test/contract/rules_fixtures_test.dart` + `fixtures/choreTemplates.json`; EDIT `firebase/firestore.indexes.json` only if a query needs it (the list query is `orderBy sortOrder` on a family-scoped collection → automatic).
- **Contents:** mappers tolerate unknown `recurrence.kind` (template shown as "invalid schedule", never crashes) and out-of-range `colorIndex`. `templatesProvider` caps at the constant and exposes `truncated`. Template documents carry no occurrence data.
- **Interacts with:** `bootstrap.dart` provider overrides for the real repositories (append).
- **Rules / tests:** one allowed and one denied case per rule; contract test proves the real mapper payload passes `templateOk`; round-trip tests; a 30-subtask, 6-slot, 4000-char maximum payload passes; 31 subtasks fails.
- **Done when:** a manager creates a template through the repository against the emulator; a member cannot; rules suite green.

#### P3-09 — Rotation engine and duty-group domain (pure)

- **Type:** DEPENDENT. **Depends on:** P3-02, P3-03, P3-05. **Parallel with:** P3-06…P3-08. **Unblocks:** P3-10, P3-12, P3-18, P3-26.
- **Files:** NEW under `lib/features/chores/duty_groups/domain/`: `rotation.dart` (`Rotation`, `RotationVersion`, `CycleUnit`), `rotation_engine.dart`, `rotation_builder.dart`, `duty_group.dart`, `duty_group_repository.dart`, `absence_resolver.dart`, `cover_picker.dart`, `usecases/create_duty_group.dart`, `update_duty_group.dart`, `change_rotation.dart`.
- **Contents:**
  - `RotationEngine.planned(Rotation r, DateKey day, {int? occurrenceIndex}) → String? memberId`: pick the version with the greatest `from ≤ day` (none ⇒ `null`); `cycles = cyclesBetween(version.anchorDate, day, unit, version.weekStartDay)` using floor semantics so days before the anchor give negative cycles; `index = (anchorIndex + cycles) mod n` with a **mathematical** modulo. Units: `day` (epoch-day difference), `week` (difference of week-start dates), `month` (difference of month keys), `occurrence` (number of recurrence dates between anchor and day, via `RecurrenceEngine.countBetween`; needs the template's recurrence, passed in).
  - `RotationBuilder` creates the next version without shifting anyone's turn (Appendix F.2): **add** member → appended at the end, effective at the next cycle boundary ≥ requested date, `anchorIndex` = index of whoever the old version planned at that boundary; **remove** member → removed from the list, if they were planned at the boundary the next person in the old order takes it, everyone else keeps their relative order; **reorder** → explicit new order with a chosen "starts with" member at the boundary. `versions` ≤ 20: when full, the oldest version is dropped only if its `from` is older than 400 days, otherwise validation fails with `too_many_items`.
  - `AbsenceResolver.resolve({planned, day, availabilityIndex, policy, members}) → AssignmentDecision {assignee, needsCover, suggestedCover?}`: policy A ⇒ keep the planned person and `needsCover = true` **only if** that person is unavailable that day (derived, not stored — see P3-11); B ⇒ same plus `suggestedCover` from `CoverPicker`; C ⇒ keep the planned person, no flag (the manager skips). An inactive/disabled planned member ⇒ `assignee = null`, `needsCover = true` (D-P3-12). Rotation never "moves on".
  - `CoverPicker.pick({candidates, day, windowLoad, unavailable}) → memberId?`: active, not unavailable on that day, fewest weighted assigned items in the window, ties broken by the order in the rotation members list (deterministic, no randomness).
  - Duty-group use cases: `CreateDutyGroup` (≥ 2 members, ≤ 12), `UpdateDutyGroup` (name, colour, sort, active), `ChangeRotation(add|remove|reorder, effectiveFrom)` using the builder; audit `chores.duty_group_*` / `chores.rotation_changed`; EVERYDAY for create/update, INTEGRITY for `ChangeRotation`.
- **Interacts with:** the generator (P3-12) is the only runtime caller of `RotationEngine`; the rota preview (P3-18) and the rota board (P3-28) call it too, so every screen agrees.
- **Rules / tests:** Appendix F.2 (≥ 30 cases: negative cycles, month length, Saturday/Sunday week starts, version switches mid-cycle, adding/removing members, the `occurrence` unit across a skipped Friday, inactive member, all members unavailable).
- **Done when:** F.2 table green; a property test proves that after `ChangeRotation(add)`, every date **before** the effective boundary has the same planned member as before.

#### P3-10 — Duty groups data layer, rules, providers

- **Type:** DEPENDENT. **Depends on:** P3-08, P3-09. **Parallel with:** P3-11. **Unblocks:** P3-13, P3-18, P3-19.
- **Files:** NEW `duty_groups/data/duty_group_mappers.dart`, `firestore_duty_group_repository.dart`, `duty_groups/presentation/duty_group_providers.dart` (`dutyGroupsProvider` ≤ 50, `dutyGroupProvider(id)`, `groupTemplatesProvider(id)` = templates whose `assignee.dutyGroupId == id`, `groupOnDutyProvider` = who is planned today); EDIT rules (`dutyGroups` carve-out: `dutyGroupKeys()`, `rotationOk(r)` checking `versions` size ≤ 20 and first/last version shape, members ≤ 12, manager/admin write, no delete); NEW rules test + fixture + contract entry.
- **Contents:** the group stores no template list (single source of truth = the template's `dutyGroupId`). Deactivating a group is allowed even if templates use it; the use case returns a `Conflict('last_group_in_use')` **warning** the screen can confirm.
- **Interacts with:** `membersProvider` for "inactive member in rotation" warnings; the generator.
- **Rules / tests:** as P3-08, plus a rotation with 20 versions passes and 21 fails.
- **Done when:** duty group CRUD works against the emulator; providers tested with overrides.

---

### Wave C — Occurrences (P3-11 … P3-14)

#### P3-11 — Occurrence domain: entity, status machine, `SubtaskSync`

- **Type:** DEPENDENT. **Depends on:** P3-02, P3-05, P3-07. **Parallel with:** P3-08…P3-10. **Unblocks:** P3-12, P3-14, P3-20.
- **Files:** NEW under `lib/features/chores/occurrences/domain/`: `chore_occurrence.dart` (fields of §3.2, `SubtaskDone {at, by}`), `occurrence_status.dart` (stored enum + `ChoreStatus` display enum incl. `overdue`), `occurrence_id.dart` (`OccurrenceId.of(templateId, dateKey, slotKey)` and `parse`), `effective_status.dart` (`effectiveStatus(...)`, `isOverdue(...)`), `subtask_sync.dart`, `chore_item.dart` (`ChoreItem` = one view-model for materialized **or** projected: `id, isProjected, occurrence snapshot fields, status (ChoreStatus), flags (EnumSet<ChoreFlag>), assignee, plannedAssignee, progress (done, total), dueAt`), `occurrence_repository.dart` (interface; streams + `stage(plan)`), `occurrence_write_plan.dart` (plain data: `OccurrencePatch`, `NewEvent`, `NewInboxItem`, `NewAudit`).
- **Contents:**
  - `effectiveStatus(occ)` (a pure function of the document; priority order): (1) `skipReason != null || status == skipped` ⇒ `skipped`; (2) `verifiedAt != null` (and the task counts as completed) ⇒ `verified`; (3) the **required set** = subtasks with `required == true` (if none are required, all subtasks); a task *with* subtasks is `completed` when every member of the required set has a tick in `subtaskDone`; a task *without* subtasks is `completed` when `completedAt != null`; a task completed through an `exception` counts as completed when `completedAt != null` and `exception != null`; (4) otherwise `in_progress` when at least one tick exists; (5) otherwise `scheduled`. A stale `completedAt` on a task whose required ticks were removed is ignored (and repaired). `isOverdue(occ, now, graceMinutes)` = effective status is `scheduled|in_progress` and `now > dueAt + grace`. **Overdue is derived and never stored.**
  - `SubtaskSync` (all pure, each returns an `OccurrencePatch` that touches only the dotted keys it needs): `toggleSubtask(occ, id, actor, now)` ticks/unticks one box; when this tick makes the required set complete it also sets `status = completed`, `completedAt = now`, `completedBy = actor`; when an untick makes a completed task incomplete it sets `status = in_progress`, clears `completedAt/By` and the caller adds an `uncompleted` event carrying `prevCompletedAt` (spec: preserve history). `toggleParent(occ, actor, now)`: **checking** the parent ticks every unticked subtask (by `actor`) and completes; **unchecking** the parent is "undo completion": it unticks **all** subtasks, clears `completedAt/By`, status `scheduled`, event `uncompleted`. A task without subtasks: the parent box is the only control. Completing with open required subtasks is refused with `Conflict('required_subtasks_open')` unless `exception` exists (`RecordCompletionException` first). Two phones that tick different boxes merge, because each patch touches only its own `subtaskDone.<id>` key and the status is recomputed from the merged map (D-P3-9).
  - `ChoreItem.fromOccurrence` / `fromDraft`; flags: `awaitingVerification` (completed, verification required, no verifiedAt), `needsCover` (stored flag **or** assignee unavailable on that day — takes the `AvailabilityIndex` as an argument, empty until P3-26), `needsAttention`, `isProjected`, `isCover` (`coverForId != null`), `hasPendingSwap`.
  - Appendix C is the source for the allowed transitions; `OccurrenceStateMachine.can(from, action, actor)` is a pure function tested as a table.
- **Interacts with:** generator (drafts become `ChoreItem(isProjected: true)`), every screen, rules (the transition table is mirrored in P3-13).
- **Rules / tests:** Appendix C table test (every action × every state), `SubtaskSync` tests including two simulated phones applying patches in different orders ⇒ same final map; `effectiveStatus` property: any subset of ticks yields a status consistent with the tick count.
- **Done when:** table tests green; no import of Flutter, Firestore or Riverpod in `occurrences/domain`.

#### P3-12 — Generator, projection, Ensure / Regenerate / Replan

- **Type:** DEPENDENT. **Depends on:** P3-07, P3-09, P3-11. **Parallel with:** P3-08, P3-10. **Unblocks:** P3-13, P3-14, P3-20.
- **Files:** NEW under `occurrences/domain/`: `occurrence_generator.dart`, `occurrence_draft.dart`, `generation_plan.dart`, `usecases/ensure_occurrences.dart`, `regenerate_range.dart`, `replan_occurrences.dart`, `materialize_draft.dart`.
- **Contents:**
  - `OccurrenceGenerator.drafts({templates, dutyGroups, availabilityIndex, policy, members, range, settings}) → List<OccurrenceDraft>`. For each **active** template, each date from `RecurrenceEngine.datesIn(range, startDate, endDate)`, each slot: id by `OccurrenceId.of`; snapshots copied from the template (`templateRev = revision`); `dueMinutes` = slot's else null (⇒ `dueAt = endOfDay`); assignee by strategy — `fixed` ⇒ that member, `manual` ⇒ `null` + `assignmentSource = manual` + `needsCover = false` (shown as "unassigned"), `rotation` ⇒ `RotationEngine.planned` of the duty group (or the template's own rotation), then `AbsenceResolver`. **Same function** serves persisted generation and calendar projection (C-9).
  - `EnsureOccurrences(today)`: read the marker `through` (default = today − 1); `target = today + settings.generationHorizonDays`; if `through ≥ target` ⇒ no-op. Otherwise: (1) one range query by `dateKey` for `(through, target]` returns the ids that already exist (≤ `kMaxOccurrencesPerMonth` per chunk of dates); (2) drafts whose id exists are dropped (a `set` on an existing id would be evaluated by the rules as an *update* and rejected); (3) the remaining drafts are written in chunks ≤ `kGenerationChunk` (400 until the P3-13 emulator test proves otherwise), each chunk with one audit `chores.occurrences_generated`; (4) if a chunk is rejected because another device created some ids meanwhile, re-run steps 1–2 for that chunk and retry **once**; a second failure ends the run with `Conflict('concurrent_edit')` and the next app open continues; (5) the marker is advanced **after the last chunk**. The run is resumable and safe to repeat.
  - `RegenerateRange(templateId?, from, to)`: for the template(s) affected, creates missing occurrences, **soft-deletes** (`deletedAt`) unstarted future occurrences that no longer match the recurrence (never touches started/completed/verified/skipped/ones with comments or exceptions), and leaves matching ones alone.
  - `ReplanOccurrences(templateId, from)`: for unstarted future occurrences, refresh snapshots (name, subtasks, instructions, difficulty, verification, `templateRev`) and recompute `dueAt` / planned assignee **only when assignmentSource is `rotation|fixed`** (manual/cover/swap/reassign are preserved).
  - `MaterializeDraft(draft, actorId)`: plan of one create used together with a first action on a projected item (complete, comment, swap) in one batch.
  - Generation is an INTEGRITY write (probe); `MaterializeDraft` is EVERYDAY.
- **Interacts with:** calendar providers (P3-21), editor save flow (P3-16), duty-group rotation change (P3-18), `onAppOpen` hook (P3-13).
- **Rules / tests:** Appendix F.3: recurrence × rotation × absence integration table (≥ 25 cases); idempotence (running twice yields the same plan the second time = empty); two devices racing (both generate the same range) produce identical documents; a 400-draft plan is chunked into ≤ 400 writes; `RegenerateRange` never deletes a completed document; Replan keeps a swapped assignee.
- **Done when:** all tests green; plan size and chunking proven; no Firestore import.

#### P3-13 — Occurrence data layer, rules (state machine), indexes, providers

- **Type:** DEPENDENT. **Depends on:** P3-08, P3-10, P3-12. **Parallel with:** nothing. **Unblocks:** P3-14, P3-21, P3-25, P3-26.
- **Files:** NEW `occurrences/data/occurrence_mappers.dart`, `firestore_occurrence_repository.dart`, `occurrence_event_mappers.dart`; NEW `occurrences/presentation/occurrence_providers.dart` (`monthOccurrencesProvider(MonthKey)`, `occurrenceProvider(id)`, `occurrenceEventsProvider(id)`, `verifyQueueProvider`, `generationMarkerProvider`, `ensureOccurrencesOnOpenProvider`); EDIT `firebase/firestore.rules` (carve `choreOccurrences` and its `events` subcollection out of the deny block); NEW `firebase/rules_test/chore_occurrences.test.mjs` + fixtures + contract entry; EDIT `firebase/firestore.indexes.json` (§3.8: `status+dateKey DESC`, `templateId+dateKey`); EDIT `query_limits.dart` use; EDIT `bootstrap.dart` (override + start `ensureOccurrencesOnOpenProvider` once per family per app start); EDIT `test/support/in_memory_chores_backend.dart`.
- **Contents — rules (the state machine, one `match` function per transition, each using `affectedKeys().hasOnly([...])`):**
  - **create**: active member; id matches `^[A-Za-z0-9_]+_\d{8}(_[a-z0-9]{1,12})?$` and equals the components in the body; `status == 'scheduled'`; `createdBy == uid`; closed key set; list/map bounds; `reopenCount == 0`; no completion fields; **one** membership lookup only (D-P3-7, C-11).
  - **tick** (`subtaskDone.*`, `status`, `completedAt`, `completedBy`, `updatedAt/By`): actor is the assignee, or a manager, or `membersCanCompleteForOthers` (one `get` of `settings/permissions`); each new tick has `by == uid`; `completedBy`, when set, equals `uid`.
  - **complete / uncomplete**: sets/clears `completedAt/By` with `completedBy == uid`, status transitions per Appendix C; completing requires either all required subtasks ticked or an `exception` present.
  - **verify**: `verifiedBy == uid`, `!= completedBy`, snapshot `verification == 'required'`, family switch (`choreVerificationEnabled`) via `get`; sets `verifiedAt`, status `verified`; event `verified` in the same batch (`getAfter`).
  - **reopen**: from `completed` by any active member who may comment; from `verified` by a manager; `reopenCount + 1`, clears verification, event `reopened` with reason (`getAfter`), `prevCompletedAt` stored on the event.
  - **reassign / cover / swap**: `assigneeId` changes only with an event of type `reassigned|covered|swapped` created in the same batch; allowed for managers (reassign) or when a `swapRequests/{requestId}` is `accepted` after the batch (`getAfter`) with `toMemberId == new assignee` (P3-26 supplies the request rules; until then only the manager path exists).
  - **exception / skip / unskip**: manager only, event + reason; skip sets `status = 'skipped'`, `skipReason`.
  - **needsAttention / lastCommentAt**: any active member may set `needsAttention = true` and `lastCommentAt`; only the assignee or a manager may set it back to `false` (comments step, P3-25).
  - **soft delete** (`deletedAt`): manager only, and only when status `scheduled`, `dateKey > today`.
  - **replan**: manager only, only `scheduled` documents with an empty `subtaskDone`, snapshot keys + `templateRev` + `dueAt` + planned assignee only.
  - `events`: **create-only**, `actorId == uid`, closed `type` list, reason length for the types that need one, never update/delete.
  - Snapshots (`nameBn`, `subtasks`, …) are immutable outside **replan**.
- **Contents — data & providers:** `monthOccurrencesProvider` queries `dateKey >= first && dateKey <= last`, `orderBy dateKey`, `.limit(kMaxOccurrencesPerMonth + 1)`; if the extra document comes back ⇒ `truncated = true` (the UI banner is built in P3-21); soft-deleted documents are filtered client-side (`deletedAt != null`) so the query needs no extra index; keepAlive for the current month only. `ensureOccurrencesOnOpenProvider` runs `EnsureOccurrences` once, swallows `Network` failures silently (it retries on next open), and reports other failures to the global error banner.
- **Interacts with:** everything downstream; rules are the safety net for the use cases of P3-14.
- **Rules / tests:** one allowed and one denied case per transition above (≈ 40 cases); **mandatory emulator test creating 400 occurrences in one batch** (C-11) — if rejected for access-call count, switch the generator chunk size to the largest passing value (write it into `kGenerationChunk` and ADR 0011); contract fixtures; in-memory backend parity tests (the same table run against the backend and against the rules file by the contract suite).
- **Done when:** full transition matrix green in the emulator; 400-create test passes (or the chunk constant is set to the proven maximum); month provider returns merged streams in tests.

#### P3-14 — Completion use cases

- **Type:** DEPENDENT. **Depends on:** P3-11, P3-13. **Parallel with:** P3-04. **Unblocks:** P3-15, P3-25, P3-26.
- **Files:** NEW under `occurrences/domain/usecases/`: `toggle_subtask.dart`, `toggle_parent.dart`, `complete_occurrence.dart`, `uncomplete_occurrence.dart`, `verify_occurrence.dart`, `reopen_occurrence.dart`, `record_completion_exception.dart`, `skip_occurrence.dart`, `unskip_occurrence.dart`, `reassign_occurrence.dart`, `assign_occurrence.dart`, `repair_status.dart`; NEW `lib/features/notifications/domain/inbox_port.dart` (`abstract class InboxPort { NewInboxItem? verificationNeeded(...); … }` with `NoopInboxPort`; real implementation arrives in P3-26 — chores imports notifications, never the reverse); NEW `occurrences/presentation/occurrence_action_providers.dart` (one provider per use case, file-private `newActionProvider()` pattern).
- **Contents:**
  - Every use case: `requirePermission` first (§3.3) → load the item (document, or draft ⇒ `MaterializeDraft` in the same plan) → state-machine check → pure write plan via `SubtaskSync`/builders → audit → `Result<T>`.
  - `CompleteOccurrence` records `completedBy` = actor (the real person, D-P3-14) and, when the actor is not the assignee, a flag in the audit params (`by`).
  - `VerifyOccurrence` fails with `self_verification` when `actor == completedBy`; with `verification_not_required` when the snapshot says off.
  - `ReopenOccurrence(reason)`: `completed` ⇒ by anyone with `commentOnChore`; `verified` ⇒ `manageChoreOccurrences` (`verified_requires_manager`). The original `completedAt` is preserved on the event (`prevCompletedAt`), `reopenCount + 1`, inbox `chore_reopened` to the assignee via `InboxPort`.
  - `ReassignOccurrence(toMember, reason)` is INTEGRITY; `AssignOccurrence` for unassigned items.
  - `RepairStatus` (idempotent): recomputes `effectiveStatus` and writes `status` only if different (D-P3-9); called when the detail screen opens and after a snapshot with a mismatch; EVERYDAY.
  - All writes batch ids generated once per intent (event ids).
- **Interacts with:** `PermissionPolicy`, `AuditWriter`, `InboxPort`; UI in P3-15 only calls these providers.
- **Rules / tests:** per use case: permission table, state-machine failure codes, double-submit (same event id twice ⇒ one event), offline-queued completion then server-side conflict (assignee changed meanwhile ⇒ rules reject, `RepairStatus`/UI shows the new state); two-device tick merge test through the in-memory backend.
- **Done when:** use-case tests green; a projected draft can be completed through `CompleteOccurrence` and materializes exactly once.

---

### Wave D — First-slice screens (P3-15 … P3-19)

#### P3-15 — Task detail, Today, Verify queue

- **Type:** DEPENDENT. **Depends on:** P3-14, P3-04. **Parallel with:** P3-16, P3-17, P3-18. **Unblocks:** P3-23, P3-25, P3-27.
- **Files:** NEW under `occurrences/presentation/`: `occurrence_detail_screen.dart`, `today_screen.dart`, `verify_queue_screen.dart`, `widgets/chore_tile.dart` (**the** tile used by Today, Agenda, Day panel, Verify queue), `widgets/subtask_checklist.dart`, `widgets/occurrence_header.dart`, `widgets/occurrence_timeline.dart` (events), `widgets/occurrence_actions_bar.dart`, `widgets/day_part_section.dart`; NEW providers `today_providers.dart` (`todayItemsProvider`, `todayProgressProvider`, `overdueItemsProvider`, `occurrenceItemProvider(id)` = `ChoreItem` for a document **or** a projected draft); EDIT `chores_module.dart` (routes `choresToday`, `choresOccurrence/:id`, `choresVerify`), `chores_entries.dart` (entries "Today", "Verification queue" with a badge provider), `AppRoutes`; ARB keys (`occurrence*`, `chore*`).
- **Contents:**
  - **Detail screen** top to bottom: header (group icon/colour, name, status chip + `StatusGlyph`, flags), due line ("আজ রাত ৮:০০টার মধ্যে" via formatters), assignee row (avatar, name, "covering for X" when `coverForId`), subtask checklist with `StepProgress` and the **parent checkbox** (rules of P3-11: parent tick = all ticked; partial ⇒ in-progress ring "3/5"; unticking a required box after completion returns to in-progress with a short explanatory snackbar), instructions (`MiniMarkdownView`), estimated time and difficulty, timeline of events (completed by / verified by / reopened with reason / reassigned with reason), and an actions bar.
  - **Actions** (every one behind `PermissionGate`, hide when not allowed, disable with a message when the state forbids it): Complete / Undo, Verify (other person only), Reopen (reason sheet), Reassign (manager; picker + reason), Skip, Record exception (manager; note), "I can't do this" (opens the swap sheet from P3-27 — hidden until `swapsEnabled` and the sheet exists; the entry point is a provider `swapEntryAvailableProvider` that P3-27 overrides, so no step-text appears in UI).
  - **Projected items** open the same screen in read-only "planned" mode (dashed header, FlagChip "planned"); the first action materializes (P3-14).
  - **Self-heal:** `initState` of the detail controller calls `RepairStatus` once if `occurrence.status != effective`. Offline ⇒ silently skipped.
  - **Today screen:** header with `ProgressRing` ("৩/৭ সম্পন্ন"), scope toggle (Mine / Family — `ChoiceWrap`), sections: Overdue (pinned, tone `statusOverdue`), then day-part sections built from `dueMinutes` via `AppFormatters.dayPartKey` (labels from ARB), then Done today (collapsed). Tiles are `Slidable`: swipe right = complete (with undo snackbar, 5 s), swipe left = details. Empty state: "আজ কোনো কাজ নেই 🎉"-style friendly text without emoji dependence (icon instead).
  - **Verify queue:** list from `verifyQueueProvider` filtered to items **not** completed by the viewer; approve / reopen with reason; empty state explaining who can verify.
  - **Chore tile** content: glyph + title + due time chip + assignee `AppAvatar` + subtask `n/m` + flags; one-line max with ellipsis at scale 2.0 the title wraps to two lines.
- **Interacts with:** `nowTickProvider` (only these screens watch it), `SyncBanner` (pending write badge on the tile when `hasPendingWrites`), the comments section slot is added by P3-25, the swap sheet by P3-27.
- **Rules / tests:** widget tests per state (scheduled, partial 2/5, completed, verified, overdue, skipped, projected, unassigned, cover) × bn/en × light/dark × scale 2.0; permission tests (member sees no Reassign; the assignee cannot verify own work); swipe-complete test with undo; `no_role_checks_in_ui` passes.
- **Done when:** the first end-to-end slice works: a member opens Today, ticks steps on a real occurrence, the task becomes completed, and a second member (test) can verify.

#### P3-16 — Template list, editor, recurrence picker

- **Type:** DEPENDENT. **Depends on:** P3-08, P3-05, P3-04. **Parallel with:** P3-15, P3-17, P3-18. **Unblocks:** P3-19.
- **Files:** NEW under `templates/presentation/`: `template_list_screen.dart`, `template_editor_screen.dart` (+ controller `template_editor_controller.dart`, a `Notifier` holding an immutable `TemplateDraft`), `widgets/recurrence_picker_sheet.dart`, `widgets/recurrence_summary_text.dart` (turns `RecurrenceSummary` into ARB sentences), `widgets/slots_editor.dart`, `widgets/subtasks_editor.dart`, `widgets/assignee_editor.dart`, `widgets/instructions_editor.dart` (toolbar: bold, bullet, numbered + live preview toggle), `widgets/next_dates_preview.dart`, `widgets/icon_key_picker.dart` and `presentation/chore_icons.dart` (the only literal map: `iconKey → IconData`, ≈ 40 icons + fallback); EDIT `chores_module.dart` (routes `choresTemplates`, `choresTemplateNew` **before** `choresTemplateEdit/:id`), `chores_entries.dart`, ARB.
- **Contents:**
  - **List:** grouped by group (collapsible; group name/colour from `choreGroupsProvider`), search, filter chips Active / Paused / Archived (labels from ARB, **options are an enum, not strings in widgets**), each row shows name, recurrence sentence, assignee strategy, slot count, "next date" from `RecurrenceEngine.nextAfter`; row actions via `Slidable` + menu: Pause/Resume, Duplicate, Archive; FAB "New chore" for managers (`PermissionGate`).
  - **Editor sections** (single scrolling page with a sticky save bar; no wizard): 1 *Basics* — Bangla name (required), English name (optional), group (picker from catalog, with "manage groups" shortcut to settings for managers), icon, colour; 2 *Schedule* — recurrence picker (kind chips: once, daily, every N days, weekdays, every N weeks, days of month, Nth weekday, last day), start date, optional end date, **slots** (add up to 6; each slot picks a due-time preset chip from `dueTimePresetsProvider` or a custom `MinutesField`; first slot key `main`; extra slot keys are generated from the label, `[a-z0-9]{1,12}`, de-duplicated), "next 5 dates" preview; 3 *Who* — strategy segmented (rotation / fixed / manual); fixed ⇒ `PersonPicker`; rotation ⇒ pick an existing duty group from `dutyGroupsProvider` (an **"own rotation"** option is added to `assignee_editor.dart` by P3-18, which owns `RotationEditor`; in this step the option is simply absent, nothing is stubbed); 4 *Steps* — reorderable subtasks, "required" switch each, hint line; 5 *Instructions* — markdown editor; 6 *Options* — estimated minutes, difficulty segmented, verification switch ("needs another member to check"), reminders block (enabled, at due, offsets chips 5/10/20/30/60 + custom, overdue reminder; **stored only**, with a note key `choreReminderStoredNote`), active switch.
  - **Save flow:** validate (`TemplateValidator`, field errors inline in Bangla) → `CreateTemplate` / `UpdateTemplate` → on edit show `ReplanScope` choice dialog ("শুধু ভবিষ্যতের কাজ / আসন্ন শুরু-না-হওয়া কাজসহ") → `RegenerateRange(templateId, from: today, to: marker.through)` (+ `ReplanOccurrences` when chosen) with a progress snackbar and a **Retry** action if only the second part failed ("Saved; planning the dates failed" — the template save is never rolled back). Unsaved-changes guard on back.
  - **Reminders block** writes `ReminderConfig` exactly per §3.2 so Phase 4 can consume it without migration.
  - Everything list-like (groups, presets) is provider-fed — a custom due time typed once can be saved as a preset via a link to settings (no inline preset creation here).
- **Interacts with:** catalogs (P3-06), rotation preview (P3-09), generator/regenerate (P3-12), duty groups provider (P3-10).
- **Rules / tests:** widget tests: create a daily 3-slot template, edit with each replan scope (use-case spies), validation messages, 31 subtasks blocked, nth-weekday summary text in bn/en, `no_hardcoded_options_test` green (no `'kitchen'`, `'morning'` etc. in this folder).
- **Done when:** a manager can create "ঘর ঝাড়ু দেওয়া" with three slots, assign a rotation, save, and the next five dates and assignees appear in Today/occurrences.

#### P3-17 — Chore settings screen and module settings hub

- **Type:** DEPENDENT. **Depends on:** P3-06, P3-04. **Parallel with:** P3-15, P3-16, P3-18. **Unblocks:** P3-29.
- **Files:** NEW under `settings/presentation/`: `chore_settings_screen.dart` (+ controller), `widgets/calendar_defaults_section.dart`, `generation_section.dart`, `catalog_sections.dart` (three `CatalogEditor` usages: groups, due-time presets, absence reasons), `policies_section.dart`, `house_rules_section.dart`; EDIT `chores_module.dart` (route `choresSettings`), `chores_entries.dart`, the existing Family-settings hub (`settingsEntry`: "Chores settings" tile, permission `manageChoreTemplates`), ARB.
- **Contents:** every field of `ChoreSettings` is editable here — nothing else in the app hard-codes them:
  - *Calendar:* default view (agenda/month/week — `SegmentedChoice` fed from the enum), default scope, week start day (7 chips ordered Saturday-first for bn), show projected, projected months ahead (slider 0–12).
  - *Generation & time:* horizon (14–90), overdue grace minutes.
  - *Catalogs:* **groups** (name bn/en, colour swatch, icon, active; built-in cannot be removed, only deactivated; warning when templates use a group being deactivated), **due-time presets** (label bn/en + `MinutesField`), **absence reasons** (label bn/en, active).
  - *Policies:* absence policy A/B/C as three explanatory radio cards (what happens in plain Bangla, with a tiny example each) → `UpdateRotationPolicy`; swaps enabled + expiry buffer; absence needs approval; workload visible to members; (admin only) "members can complete for others" (`PermissionGate` mode hide for non-admins) → existing permission-settings use case.
  - *House rules:* markdown editor + preview (≤ 2000), shown read-only to everyone from the Chores manage hub ("পারিবারিক নিয়ম").
  - One **Save** bar for the whole page (`UpdateChoreSettings`, INTEGRITY ⇒ "needs internet" message offline), dirty-state guard, **Reset to defaults** per section (confirm dialog; never deletes templates).
- **Interacts with:** every provider listed in §3.5 re-emits instantly after save (Firestore listener) — verify that Today, template editor pickers and the calendar update without restart (integration widget test with an in-memory repository).
- **Rules / tests:** widget tests: add a custom group → appears in the template editor picker; deactivate a due-time preset → disappears from new slots but existing templates still render the stored minutes; member cannot open the screen (redirect + `PermissionGate`); policy radio writes the right enum string.
- **Done when:** changing week start from Saturday to Sunday changes the grid order of the (later) calendar and the weekday chips order in the editor, without code changes.

#### P3-18 — Duty group screens (with rota preview)

- **Type:** DEPENDENT. **Depends on:** P3-10, P3-04, P3-16 (the "own rotation" hook in the template editor). **Parallel with:** P3-15, P3-17. **Unblocks:** P3-19, P3-28.
- **Files:** NEW under `duty_groups/presentation/`: `duty_group_list_screen.dart`, `duty_group_editor_screen.dart`, `widgets/rotation_editor.dart` (members ordered chips with drag handles, add from `activeMembersProvider`, cycle-unit chips, week-start snapshot display, "starts with / starts on" pickers), `widgets/rota_preview.dart` (next 8 cycles: date range + avatar, using `RotationEngine`), `widgets/group_templates_section.dart`, `widgets/change_rotation_sheet.dart` (effective-from picker, default = next cycle boundary, shows "nothing before this date changes"); EDIT `templates/presentation/widgets/assignee_editor.dart` (adds the "own rotation" option using `RotationEditor`), `chores_module.dart` (routes `choresDutyGroups`, `choresDutyGroup/:id`), `chores_entries.dart`, ARB.
- **Contents:** list shows each group's colour, members, **who is on duty now** and the number of templates; editor creates/edits name, colour, members (2–12), cycle unit, first member; templates of the group are listed (from `groupTemplatesProvider`) with an "Add chore to this group" picker that edits the template's `assignee.dutyGroupId` through `UpdateTemplate` (so rotation data stays in one place). Members who are disabled/pending show a red warning chip "না থাকলে কভার লাগবে" (inactive member) and the preview shows "needs cover" cells. After `ChangeRotation` the screen runs `RegenerateRange(templates of group, from: effectiveFrom)` with the same progress/retry pattern as P3-16.
- **Interacts with:** the generator/regenerate, the template editor (shares `RotationEditor`), the rota board (P3-28).
- **Rules / tests:** widget tests for add/remove/reorder with the preview changing; "adding Dave does not change any date before the effective boundary" asserted through the preview; list for a member is read-only.
- **Done when:** a manager creates "দৈনিক রান্নাঘর ডিউটি" with four members, sees the next eight turns, adds a fifth member from next Saturday, and the preview before that date is unchanged.

#### P3-19 — Starter pack: data, use case, wizard

- **Type:** DEPENDENT. **Depends on:** P3-08, P3-10, P3-16, P3-18. **Parallel with:** P3-20 (domain). **Unblocks:** P3-30 (acceptance data).
- **Files:** NEW under `lib/features/chores/starter_packs/`: `domain/starter_pack.dart` (`StarterPack {id, titleKey, groups, dueTimePresets, templates, confidence}`, `StarterTemplate` with `seedKey`, `Confidence {high, medium, low}`), `domain/packs/family_pdf_pack.dart` (data from Appendix A — the **only** file besides `default_chore_settings.dart` allowed to hold seed ids), `domain/usecases/apply_starter_pack.dart`, `presentation/starter_pack_wizard_screen.dart`, `presentation/widgets/pack_review_table.dart`; EDIT `chores_module.dart` (route `choresStarterPack`), `chores_entries.dart` (shown only while no active templates exist **or** when a manager opens it from Manage), ARB (pack text bn + en).
- **Contents:**
  - **Wizard:** (1) *Pick a pack* (cards from the registry list; only one pack now). (2) *Review* — every line with a confidence badge; **High** lines ticked by default, **Medium/Low** unticked and flagged "please confirm" (C-14); each line can be opened in the template editor before applying. (3) *Who does what* — choose the members for the daily rotation duty group(s), the first person and the cycle unit (default week, week start from settings), or "no rotation, assign later". (4) *Apply* — progress, then "Open Today".
  - **`ApplyStarterPack`:** INTEGRITY. Merges missing groups/presets into `settings/chores` by id (never overwrites family edits), creates templates with deterministic ids `tpl_<seedKey>` (a second apply skips existing ids ⇒ `starter_pack_applied` conflict is returned only when **nothing** new would be created), creates the duty group(s), audit `chores.starter_pack_applied`, then calls `RegenerateRange` for today → marker. Everything created has `builtIn = true`, can be edited, paused or archived.
  - Idempotent and resumable (ids are deterministic).
- **Interacts with:** catalogs, templates, duty groups, generator; the wizard is also reachable later from Manage to add missing lines.
- **Rules / tests:** use-case test applies twice ⇒ second run creates nothing and reports it; Medium line unticked ⇒ not created; applying with a pre-existing custom group id keeps the family's name; widget test of the confidence legend.
- **Done when:** **First working slice:** a fresh family runs the wizard, sees today's chores with assignees, completes one in two taps (milestone checklist in Appendix E.2).

---

### Wave E — The calendar (P3-20 … P3-24)

#### P3-20 — Calendar domain (pure)

- **Type:** DEPENDENT. **Depends on:** P3-11, P3-12, P3-02, P3-06. **Parallel with:** P3-15…P3-19. **Unblocks:** P3-21.
- **Files:** NEW under `lib/features/chores/calendar/domain/`: `calendar_enums.dart` (`CalendarView {agenda, month, week}`, `CalendarScope {mine, all}`, `HeatMode {off, workload}`, `Density {comfortable, compact}`, `MarkerStyle {glyphs, dots, count}`), `calendar_filters.dart` (`CalendarFilters {groupIds, statuses, memberIds, onlyNeedsAttention, query}` + `apply(List<ChoreItem>)`), `day_summary.dart`, `calendar_month_model.dart`, `week_model.dart`, `agenda_model.dart`, `marker_policy.dart`, `heat_calculator.dart`, `unavailability_overlay.dart`.
- **Contents:**
  - `CalendarMonthModel.build({month, weekStartDay, items, filters, scope, viewerId, availability, today, settings}) → {weeks: List<List<DaySummary>>, truncated}`. `DaySummary`: `dateKey`, `isToday`, `isOutsideMonth` (**no markers and no counts** for outside days: D-P3-8), `total`, `counts` per `ChoreStatus`, `markers` (≤ 3 by urgency **overdue > in_progress > scheduled > completed > verified > skipped**, then "+N"), `mineCount`, `heatLevel 0–4`, `unavailableMemberIds`, `hasNeedsCover`, `hasProjectedOnly`.
  - `MarkerPolicy`: marker shape = status glyph; if more than 3 distinct statuses, collapse the least urgent into "+N"; "mine" days show a ring.
  - `HeatCalculator`: levels from **weighted workload** of the visible day (difficulty weights 1/2/3) relative to the month's max (quantiles; stable for equal values); `HeatMode.off` ⇒ all 0.
  - `WeekModel` (7 days × items sorted by `dueAt`, grouped by day part), `AgendaModel` (sections: **Overdue** (all open items before today, newest first, capped 100 with "see all"), Today, then consecutive days; empty days collapse into `FreeDays(n)` entries), `UnavailabilityOverlay` (per day the members unavailable, with reason ids).
  - `CalendarFilters.apply` is a pure function; **filters never change a `DaySummary` for outside days**.
- **Interacts with:** `ChoreItem` (P3-11), availability index (empty until P3-26 — a day then simply has no overlay), settings (week start).
- **Rules / tests:** table-driven: month with 0 items; 900 items; item on the last/first day of month; viewer with no chores in "mine"; marker order; heat quantiles; week start 6 vs 7 vs 1; Feb 2028; overdue pinned in agenda; free-days collapsing; filter combinations; model build for 900 items under 30 ms in a plain Dart benchmark test.
- **Done when:** all pure tests green; no Flutter import in `calendar/domain`.

#### P3-21 — Calendar providers and local preferences

- **Type:** DEPENDENT. **Depends on:** P3-20, P3-13. **Parallel with:** P3-15…P3-19. **Unblocks:** P3-22, P3-28.
- **Files:** NEW under `calendar/presentation/`: `calendar_prefs.dart` (`CalendarPrefs` + `SharedPreferences` persistence, **per family id key**, initial values from `choreSettingsProvider`, never overwritten by later settings changes unless the user taps "Use family defaults"), `calendar_providers.dart` (`calendarPrefsProvider`, `calendarViewProvider`, `calendarScopeProvider`, `calendarFiltersProvider`, `focusedMonthProvider`, `selectedDayProvider`, `monthItemsProvider(MonthKey)` = merge(materialized, projected), `projectedItemsProvider(MonthKey)`, `calendarMonthModelProvider(MonthKey)`, `weekModelProvider`, `agendaModelProvider`, `nowTickProvider`), `widgets/truncated_banner.dart`; EDIT `occurrence_providers.dart` only to expose the `truncated` flag.
- **Contents:** the exact graph of §3.5. Projection: `OccurrenceGenerator.drafts` for dates **after the generation marker or without a document**, `today ≤ date ≤ today + projectedMonthsAhead months`, only when `showProjected` (pref overrides family default). Merge by id: materialized wins. A listener-retention rule: the current month `keepAlive`; visited months stay alive for 60 s after leaving (so swiping back is instant and costs no reads). `focusedMonthProvider` and `selectedDayProvider` are kept consistent (selecting a day in another month moves the focused month). `truncated` ⇒ banner "এই মাসে অনেক কাজ — সব দেখানো যাচ্ছে না" with a link to the filters.
- **Interacts with:** the three views, the Today screen (shares `monthItemsProvider(currentMonth)`), the dashboard (Phase 4).
- **Rules / tests:** provider tests with overrides: scope switch costs **zero** extra repository reads (spy counts one listener per month); projected + materialized duplicates collapse to one; changing prefs persists and restores; week start change re-orders the model; `nowTickProvider` is not watched by the month model (asserted by a build-count test).
- **Done when:** a throw-away debug screen (not committed) can print the month model for any month with correct counts.

#### P3-22 — Month view (the hero screen, part 1)

- **Type:** DEPENDENT. **Depends on:** P3-21, P3-04, P3-15 (`ChoreTile`). **Parallel with:** P3-28. **Unblocks:** P3-23, P3-24.
- **Files:** NEW under `calendar/presentation/`: `calendar_screen.dart` (the body of `ChoresHomeScreen`), `widgets/calendar_header.dart`, `view_switcher.dart`, `scope_chip.dart`, `filter_button.dart`, `weekday_header_row.dart`, `month_grid.dart`, `month_pager.dart`, `day_cell.dart`, `day_markers.dart`, `month_year_picker_sheet.dart`; EDIT `chores_home_screen.dart` to host `CalendarScreen`; ARB (`calendar*`).
- **Contents (full visual/behaviour spec in Appendix B):**
  - **Header:** large month title (tap ⇒ month/year picker sheet for fast jumps), previous/next arrows, **Today** pill (appears only when the focused month ≠ today's month or the selected day ≠ today; animates in), view switcher (`SegmentedButton`: আজেন্ডা / মাস / সপ্তাহ — labels from ARB, order from enum), scope chip "আমার কাজ / পুরো পরিবার" (one tap toggles), filter button with active-count badge, bell with unread badge (provider from P3-27, hidden until then via the same override pattern).
  - **Grid:** `WeekdayHeaderRow` in the configured week-start order; `MonthPager` = `PageView` of months (index offset ±120 from a fixed epoch month) so a horizontal swipe changes the month with a `SharedAxisTransition`; each page builds `MonthGrid` from `calendarMonthModelProvider(month)`; **cells ≥ 48 dp** (D-P3-24; below ≈ 336 dp width the view switcher disables Month and shows Week with a one-time explanation); `DayCell` = date number (Bangla digits), today = filled ring, selected = filled `primaryContainer`, markers row (≤ 3 `StatusGlyph`s, 10 dp, + "+N"), heat tint (P3-24), outside-month days dimmed with no markers, tap = select + haptic `selectionClick`, long-press = open the day panel expanded.
  - Below the grid until P3-23: a plain selected-day list of `ChoreTile`s (so the screen is already useful); `LoadingView` → grid skeleton shimmer-free (static placeholder), `ErrorView`, truncated banner.
  - All text through ARB/formatters; semantics label per cell: "২৫ অক্টোবর, ৩টি কাজ, ১টি বিলম্বিত, আজ".
- **Interacts with:** providers of P3-21; tapping a tile opens `OccurrenceDetailScreen` (P3-15).
- **Rules / tests:** widget tests: week start 6 vs 7 ordering; Feb 2028 shows 29; selecting a day outside the month moves the page; swipe to next month; Today pill appears/disappears; 900-item month builds within the frame budget test (`tester.binding` timing smoke); text scale 2.0 no overflow at 360 dp; screen-reader labels exist.
- **Done when:** the Month view is usable end to end with real data and passes the Appendix B acceptance checks B.9-1…B.9-8.

#### P3-23 — Day panel, Agenda, Week

- **Type:** DEPENDENT. **Depends on:** P3-22, P3-15. **Parallel with:** P3-28. **Unblocks:** P3-24, P3-29.
- **Files:** NEW under `calendar/presentation/widgets/`: `day_panel.dart` (`DraggableScrollableSheet`, snaps 0.28 / 0.55 / 0.92 of the screen; header with the date, counts, "add" for managers; list of `ChoreTile`s grouped by day part; unavailable-members strip; friendly empty state), `agenda_view.dart` (`CustomScrollView` with `center` key so the list is **bidirectional around today**; sticky day headers (`DaySectionHeader`), pinned **Overdue** section, `FreeDaysChip`, jump-to-today FAB, pull-to-extend later/earlier by whole weeks up to the model's limits), `week_view.dart` (compact: 7-day strip with counts + the selected day's timeline by day part; **tablet ≥ 840 dp**: seven columns), `calendar_filter_sheet.dart` (groups chips from catalogs, statuses, members, "needs attention", search field), `quick_actions_sheet.dart` (long-press on a tile: complete, details, ask swap, reassign — only the allowed ones), `legend_sheet.dart` (glyph legend); EDIT `calendar_screen.dart` (view switching with `FadeThroughTransition`; remembers each view's scroll offset), `chore_tile.dart` (reuse).
- **Contents:** Agenda is the default on phones (family default from settings); the **same** `ChoreTile` and detail route everywhere; the filter sheet writes `calendarFiltersProvider`; filters show as removable chips under the header; search matches Bangla and English names (case-insensitive, Bangla normalisation of ZWJ/ZWNJ handled by a small pure helper `normalizeBn`, tested).
- **Interacts with:** swap/reassign entries hidden until the relevant providers/permissions exist; comments count badge appears after P3-25 (tile reads `lastCommentAt`/`needsAttention` flags already present).
- **Rules / tests:** agenda: scrolling both directions from today, overdue pinned, free-days collapse, 900 items scroll test; week view tablet layout; filter sheet combinations; `normalizeBn` tests; quick-actions permission matrix.
- **Done when:** all three views share one selection and one filter state, switching views keeps the focused date, and Appendix B acceptance B.9-9…B.9-16 pass.

#### P3-24 — Calendar polish: heat, hatch, motion, accessibility, tablet, goldens

- **Type:** DEPENDENT. **Depends on:** P3-22, P3-23. **Parallel with:** P3-25, P3-26. **Unblocks:** P3-30.
- **Files:** NEW `calendar/presentation/painters/` (`hatch_painter.dart`, `glyph_row_painter.dart` if `StatusGlyph` widgets are too heavy per cell), `widgets/heat_legend.dart`, `widgets/calendar_two_pane.dart`; EDIT cells, header, tests; NEW goldens `test/features/chores/calendar/goldens/` (tag `golden`, Linux CI only).
- **Contents:**
  - **Heat mode** (pref `HeatMode.workload`): cell background = `tokens.chart`-derived 4-step ramp with accessible text colour; legend sheet; works in both themes (ramps defined separately for dark, not inverted).
  - **Hatch** for projected-only days and **unavailable** members' days (diagonal pattern from tokens, never colour alone); a corner mark for "needs cover".
  - **Motion:** month swipe (shared axis), view change (fade through), selection ring grow, Today pill slide, day-panel snap, tile complete check-draw; durations 150–300 ms; **all disabled when `MediaQuery.disableAnimations`** (replaced by instant changes).
  - **Accessibility:** `Semantics` for grid (row/column), cell labels (§Appendix B.7), focus order, large text (cells grow vertically instead of clipping), contrast tests for every status/heat/dark combination, `ExcludeSemantics` for decorative painters.
  - **Tablet/landscape:** ≥ 840 dp two-pane (grid + persistent day panel); landscape phone uses Week/Agenda only.
  - **Performance:** `RepaintBoundary` per week row, `const` markers, `select` on providers; a widget test builds the Month view with 900 items and asserts the model is built once per month change.
  - **Goldens:** month (light/dark, bn/en, 5-row and 6-row months, heat on), agenda, week, day panel, tablet two-pane.
- **Interacts with:** gallery (P3-04) for the painter demos.
- **Rules / tests:** contrast table test, reduced-motion test (pump with `disableAnimations: true` ⇒ no running tickers), golden tests, text scale 2.0 overflow tests for every calendar widget through the gallery harness.
- **Done when:** Appendix B acceptance B.9-17…B.9-24 pass and the golden set is committed.

---

### Wave F — Collaboration (P3-25 … P3-28)

#### P3-25 — Comments

- **Type:** DEPENDENT. **Depends on:** P3-13, P3-15. **Parallel with:** P3-24, P3-26. **Unblocks:** P3-29.
- **Files:** NEW under `comments/`: `domain/occurrence_comment.dart`, `comment_repository.dart`, `usecases/{add_comment, mark_needs_attention, resolve_comment, hide_comment, unhide_comment}.dart`; `data/comment_mappers.dart`, `firestore_comment_repository.dart`; `presentation/comment_providers.dart` (`commentsProvider(id)` ≤ `kMaxCommentsPerOccurrence`, `unreadCommentsProvider(id)` from local last-seen), `widgets/comments_section.dart`, `comment_composer.dart`, `comment_bubble.dart`; EDIT `occurrence_detail_screen.dart` (adds the section), rules (`comments` subcollection carve-out: create by active member with `authorId == uid`, text 1–1000, `hidden == false`; update only `resolvedAt/By` (by assignee or manager), `hidden/hiddenBy/hiddenNote` (manager, note ≥ 3), never text/author; no delete), rules test, fixtures, ARB.
- **Contents:** a comment can be a **flag** ("incorrect/incomplete") — then the batch also sets `needsAttention = true` and `lastCommentAt` on the occurrence and (via `InboxPort`) notifies the assignee; the flagged comment shows **"Reopen with this reason"** which opens `ReopenOccurrence` with the text prefilled. `ResolveComment` by the assignee/manager; `needsAttention` clears when the last flagged comment is resolved. Hidden comments show "hidden by a manager" to everyone and the original text only to managers. Comments **survive reopen, reassign, swap** (they belong to the occurrence). Projected items: the composer materializes the draft in the same batch (P3-14 `MaterializeDraft`). Attachments are **not** in the key set (D-P3-18).
- **Interacts with:** `ChoreTile` shows a comment dot when `lastCommentAt` is newer than the local last-seen; the calendar's day marker gets an "attention" corner via `hasNeedsAttention`.
- **Rules / tests:** use-case tests (flagging sets the occurrence flag, hide needs a note, member cannot hide), rules tests, widget tests incl. reopen-with-reason prefill, bn/en, scale 2.0.
- **Done when:** two test members can discuss a task, flag it, and the assignee sees it highlighted and can resolve or reopen.

#### P3-26 — Availability, swaps, covers, inbox: domain + data + rules

- **Type:** DEPENDENT. **Depends on:** P3-13, P3-09. **Parallel with:** P3-24, P3-25. **Unblocks:** P3-27, P3-28, P3-29.
- **Files:** NEW `availability/domain/{member_availability.dart, availability_index.dart, usecases/{add_availability, cancel_availability, decide_availability, apply_absence_policy}.dart}`, `availability/data/*`; NEW `swaps/domain/{swap_request.dart, usecases/{request_swap, accept_swap, decline_swap, cancel_swap, expire_swaps}.dart}`, `swaps/data/*`; NEW `features/notifications/domain/{inbox_item.dart, inbox_repository.dart, usecases/{mark_inbox_read, archive_inbox_item}.dart, inbox_writer.dart}` and `data/*` and `presentation/inbox_providers.dart`; NEW `chores/presentation/chores_inbox_port.dart` (real `InboxPort` wiring replacing the no-op in `bootstrap.dart`); EDIT rules (carve `memberAvailability`, `swapRequests`, `notificationInbox` out of the deny block, with accept/decline pairing rules), indexes (§3.8), contract fixtures, ARB, `AvailabilityIndex` plugged into `ChoreItem`/calendar providers (the empty index of earlier steps is replaced by `availabilityIndexProvider`).
- **Contents:**
  - **Availability:** `AddAvailability` validates range ≤ 366 days, no overlap with an existing active record of the same member (`availability_overlap`), `typeId` exists in `absenceReasons` (tolerant of removed ones), reason 3–200; creates `active`, or `pending` when `absenceNeedsApproval`; managers can create for anyone. `DecideAvailability` (manager). `CancelAvailability`.
  - **Absence policy (`ApplyAbsencePolicy`, INTEGRITY):** after an availability becomes active, find the member's unstarted occurrences in the range that still belong to them: policy **A** ⇒ nothing is written (the items show "needs cover" derived from the index; the member and managers get one inbox item `needs_cover` with the count); policy **B** ⇒ for each affected occurrence `CoverPicker` selects a candidate and a `cover` `SwapRequest` is created for them (**the occurrence is not touched until they accept**; a decline tries the next candidate once, then falls back to A); policy **C** ⇒ nothing is written; managers see a one-tap "Skip all affected" list that calls `SkipOccurrence` per item (reason = the absence type).
  - **Swaps:** `RequestSwap(occurrenceId, toMember, reason)`: requires `swapsEnabled`, occurrence unstarted (`occurrence_started` otherwise), requester is the assignee, recipient active and not unavailable that day; `expiresAt = dueAt − swapExpiryBufferMinutes`; one pending request per occurrence (`swap_not_pending` for duplicates); projected items are materialized in the same batch. `AcceptSwap` (transaction, **requires server**): checks pending, not expired, occurrence still assigned to `fromMemberId`, recipient == actor; in ONE batch updates the request (`accepted`), the occurrence (`assigneeId = to`, `coverForId = from` for `cover`, `assignmentSource = swap|cover`, `needsCover = false`), writes the `swapped|covered` event with `requestId`, audit, and an inbox item `swap_result` to the requester. `DeclineSwap` (optional reason). `CancelSwap` (requester or manager). `ExpireSwaps` on app open: marks `pending` requests past `expiresAt` as `expired` and informs the requester. **The original assignee and the reason stay on the event and request forever** (spec).
  - **Inbox:** `InboxItem {toMemberId, type, refType, refId, params, readAt, archivedAt}`; `InboxWriter.create(item)` shape-checked; `MarkInboxRead` owner only; list ≤ 50, newest first; `unreadInboxCountProvider`.
  - **Rules:** `swapRequests` create by the requester (`requestedBy == uid`, `fromMemberId == uid` or manager), status `pending`; update only by the recipient (`accepted|declined`, in the same batch as the occurrence update via `getAfter`) or requester/manager (`cancelled`) or anyone active (`expired` when `request.time > expiresAt`); `memberAvailability` create by owner or manager, `status` rules; `notificationInbox` create by any active member for another member (closed `type` list, ≤ 6 params), owner may update only `readAt`/`archivedAt`.
- **Interacts with:** occurrence rules (P3-13) accept the `swapped|covered` event only with an accepted request; generator uses `AvailabilityIndex`; calendar overlay.
- **Rules / tests:** state tables for swaps (pending → accepted/declined/cancelled/expired; every illegal transition), policy A/B/C scenarios with a 3-day sickness over a rotation (Appendix F.3), concurrency test: two accepts of the same request ⇒ exactly one wins; rules tests per collection; `ExpireSwaps` idempotence.
- **Done when:** use-case and rules suites green; policy B scenario creates cover requests and changes nothing until acceptance.

#### P3-27 — Availability, swap, cover and inbox screens

- **Type:** DEPENDENT. **Depends on:** P3-26, P3-04, P3-15. **Parallel with:** P3-28. **Unblocks:** P3-29.
- **Files:** NEW `availability/presentation/{availability_screen.dart, add_availability_sheet.dart, availability_card.dart}`, `swaps/presentation/{swap_sheet.dart, swap_response_sheet.dart, swap_status_banner.dart, needs_cover_board.dart}`, `features/notifications/presentation/{inbox_screen.dart, inbox_tile.dart, inbox_bell.dart}`; EDIT `chores_module.dart` (route `choresAvailability`), the top-level router (`inbox`), `chores_entries.dart`, `chores_providers.dart` (`swapEntryAvailableProvider` override → true), `calendar_header.dart` (bell), `occurrence_detail_screen.dart` (swap banner, "ask someone to cover"), ARB.
- **Contents:**
  - **Availability screen:** "Mine" list and (managers) "Everyone"; FAB → sheet: type chips from `absenceReasonsProvider`, date range, reason, live preview "এতে ৬টি কাজ প্রভাবিত হবে" (computed by the generator over the range) and a plain-language line describing what the current policy will do. Pending records show Approve/Reject for managers.
  - **Swap sheet** ("I can't do this"): reason (`ReasonSheet` rules), `PersonPicker` of **eligible** members (active, not unavailable that day, shows this month's load as a small bar — not a ranking), preview of the request text, send. Recipient's **response sheet** from the inbox/detail banner: Accept / Decline (optional reason). Status banner on the detail screen: "মেহেদীকে অনুরোধ পাঠানো হয়েছে" with Cancel.
  - **Needs-cover board** (managers; also in Manage): items that are unassigned, assigned to an unavailable/inactive member, or have declined/expired requests — one tap to assign (`AssignOccurrence`/`ReassignOccurrence`).
  - **Inbox:** grouped Today / Earlier, unread dot, tap = mark read + deep-link by `refType/refId`; module-off items hidden; bell with count in the calendar header and a tile in Manage. Spark note shown in an info row: "আপনি অ্যাপ খুললে নতুন অনুরোধ দেখতে পাবেন" (D-P3-19).
  - Offline: sends queue (EVERYDAY for `RequestSwap`); accept/decline show "needs internet" (INTEGRITY).
- **Interacts with:** inbox unread count feeds the bell and Phase 4 push later; `AvailabilityIndex` feeds the calendar overlay immediately.
- **Rules / tests:** widget tests for each sheet; eligibility excludes unavailable members; accept updates detail and calendar (provider override test); policy line text per policy; bn/en/dark/scale 2.0.
- **Done when:** end-to-end: Cara records sickness, a cover request reaches Dave, Dave accepts in the inbox, the calendar shows Dave with a "covering for Cara" chip and the history keeps both names and the reason.

#### P3-28 — Rota board and workload

- **Type:** DEPENDENT. **Depends on:** P3-21, P3-04. **Parallel with:** P3-23…P3-27. **Unblocks:** P3-29.
- **Files:** NEW `rota/domain/{workload_calculator.dart, workload_summary.dart, rota_matrix.dart}`, `rota/presentation/{rota_board_screen.dart, widgets/member_share_row.dart, widgets/rota_matrix_view.dart, widgets/on_duty_strip.dart, rota_providers.dart}`; EDIT `chores_module.dart` (route `choresRota`), `chores_entries.dart` (permission: `manageChoreTemplates` **or** `workloadVisibleToMembers`), ARB.
- **Contents:**
  - `WorkloadCalculator.calculate(items, members, month) → WorkloadSummary`: per member `assigned`, `done`, `weightedPoints` (difficulty 1/2/3, minutes tie-break), `coversGiven`, `coversReceived`, `unavailableDays`, share of total. Approved absence and swaps never count against anyone; covers given are shown as "সাহায্য করেছেন" (positive wording). **No ranking, no leaderboard, no colours red/green**; members are listed in a stable order (nickname alphabetical).
  - **Rota matrix:** rows = chores (or duty groups), columns = the 7 days of the selected week (week-start aware), cells = assignee avatar + status glyph, tap opens detail; "on duty today" strip at the top; month switcher for the share bars; export-free (CSV/PDF later).
  - Reads `monthItemsProvider` only — **no new queries**.
- **Interacts with:** the calendar's heat mode uses the same weights through `HeatCalculator`; Phase 4 contribution score will reuse `WorkloadCalculator`.
- **Rules / tests:** calculator table tests (covers, skipped, unassigned, difficulty weights, empty month); access test (member sees "no access" when the switch is off); widget tests; text scale 2.0.
- **Done when:** a manager sees fair-share bars for the month; with `workloadVisibleToMembers` on, members see the same screen.

---

### Wave G — Finish (P3-29 … P3-30)

#### P3-29 — Chores home, manage hub, dashboard cards, activity text, Phase 4 contract

- **Type:** DEPENDENT. **Depends on:** P3-15, P3-17, P3-23, P3-27. **Parallel with:** nothing. **Unblocks:** P3-30.
- **Files:** EDIT `chores_home_screen.dart` (final composition: header + view + FAB: manager "New chore" / member "My today"), `chores_manage_screen.dart` + `chores_entries.dart` (final ordered list, permission-filtered, badges: verify queue, inbox, needs cover; house-rules read-only card), `chores_module.dart` (`dashboardCards`: **Today** (progress ring, next due, link), **Overdue** (count, oldest), **Awaiting verification** (verifiers only), **This week** (mini 7-day strip); `settingsEntry`), the activity-feed text resolver `activityText` (bn + en for every §3.9 type, names resolved from uids), ARB finalisation (remove stub strings), NEW `docs/chores_phase4_contract.md`, EDIT `docs/permission_matrix.md`, `docs/new_collection_checklist.md` (tick all Phase 3 collections), `CLAUDE.md` (folder list, rules), `PROGRESS.md`, `ROADMAP.md` (Step 20–26 marked "done via P3-xx"), `README.md` (feature list).
- **Contents:** dashboard cards read the same providers as Today (`todayProgressProvider`) so the numbers always agree. **`docs/chores_phase4_contract.md`** (what Phase 4 may rely on): `ReminderConfig` shape on templates and occurrence snapshots, `dueAt` UTC instants, `slots`, `completedAt/By` and events for streaks, `verifiedAt` for "detail champion", `assignmentSource == swap|cover` for "helper", `todayProgressProvider` as the celebration trigger (fire once per day via a local `celebratedDateKey` preference), `memberStats` collection reserved (deny-all until Phase 4), the notification enable/disable hierarchy (global → member → template) and the Spark limitation of local notifications; plus the list of data Phase 3 deliberately does **not** compute.
- **Interacts with:** the whole app shell (Home dashboard, Family activity feed, module registry).
- **Rules / tests:** dashboard card widget tests (loading/empty/data), activity text for every audit type in both languages (table test ensures none is missing), manage hub permission test (member sees only member-relevant tiles).
- **Done when:** Home shows the Chores cards with real numbers; every audit type renders a human sentence; the contract document exists.

#### P3-30 — Hardening, performance, acceptance, sign-off

- **Type:** DEPENDENT. **Depends on:** all. **Parallel with:** nothing.
- **Files:** NEW `docs/chores_acceptance.md` (UAT script), `docs/chores_read_budget.md`, `test/architecture/no_hardcoded_options_test.dart` (if not yet added), `test/features/chores/concurrency/*_test.dart`, `test/features/chores/perf/*_test.dart`; EDIT `test/support/screen_states.dart` (every Phase 3 screen × loading/empty/error/data), gallery, `PROGRESS.md`.
- **Contents:**
  1. **Rules:** run the full emulator matrix for every Phase 3 collection (member / manager / admin / pending / other family); confirm the generic deny block no longer lists any chore collection except `memberStats`; add the deny-by-default tests for removed paths.
  2. **Concurrency:** two simulated devices — tick different subtasks; generate the same range; accept the same swap; complete while the other reassigns; all end in a valid state (D-P3-9/10).
  3. **Read budget (measure, don't guess):** emulator run counting document reads for: app open (settings, marker, month listener), switching Mine/Family (**0 extra**), swiping 6 months, opening Today, opening a detail; write the numbers into `chores_read_budget.md` and compare with the Spark daily read quota (**[VERIFY]** current quota); target: a typical family day ≪ 10 % of the free quota.
  4. **Performance:** month with 900 occurrences builds the model < 30 ms and scrolls without dropped frames in a profile run (document the device); generation of 30 days × 20 templates completes with ≤ 3 chunks.
  5. **Offline matrix (manual script):** complete a chore offline → reconnect; tick on two phones; swap request offline (queues) vs accept offline (refused with message).
  6. **Accessibility pass** (TalkBack bn): calendar grid, tile actions, sheets; large text 2.0; reduced motion; contrast tables.
  7. **Localization:** ARB parity test, no English fallback text in bn mode, Bangla digits everywhere, Bangla ordinal/nth-weekday sentences reviewed by the owner.
  8. **Data safety:** index check, `no_unbounded_queries`, soft-delete audit, export hooks note for the later CSV phase.
  9. **UAT with the family** using `docs/chores_acceptance.md` (Appendix E.3): ten tasks, pass/fail recorded.
  10. Update `PROGRESS.md` (every Phase 3 step "Done" or "Written (not run)" honestly), tag `phase-3`.
- **Done when:** all of §6 (acceptance criteria) pass.

---

## 6. Phase 3 acceptance criteria (used by P3-30)

| # | Criterion | How it is proven |
| --- | --- | --- |
| 1 | A fresh family applies the starter pack, chooses members, and sees today's chores with assignees in under 3 minutes. | UAT task 1 (Appendix E.3) |
| 2 | A member completes a chore in two taps from Today; completing the last required subtask completes the parent; unticking one returns it to "in progress" with history kept. | Widget + use-case tests, UAT task 3 |
| 3 | Rotation is calendar-based: adding/removing a member changes **nothing before** the effective date; an absence never shifts the rota. | F.2 property test, UAT task 6 |
| 4 | Every chore group, due-time preset, absence reason, default view/scope, week start, horizon, grace, swap and approval option is editable in the app; `no_hardcoded_options_test` is green. | P3-17, architecture test |
| 5 | The calendar passes Appendix B.9 (24 checks) in Bangla and English, light and dark, at text scale 2.0, with 900 occurrences in a month. | P3-22…P3-24, goldens, perf test |
| 6 | "My chores / Family" and every filter cost **zero** additional reads. | P3-30 read-budget measurement |
| 7 | Two phones ticking different subtasks, generating the same range, or accepting the same swap end in a valid state. | P3-30 concurrency suite |
| 8 | Verification cannot be self-applied; reopen requires a reason and preserves the original completion; comments survive reopen and reassignment. | Use-case + rules tests |
| 9 | A swap/cover needs a reason and the replacement's acceptance; the original assignee and reason stay in the history. | P3-26/27 tests, UAT task 7 |
| 10 | All Phase 3 collections are out of the deny-only rules block, each with allowed/denied rules tests; the access-call limit is proven by the 400-create test. | Rules suite |
| 11 | Works on the Spark plan with no Cloud Functions; no new paid service; only the packages of Appendix D were added. | `pubspec.yaml` diff review |
| 12 | `docs/chores_phase4_contract.md` exists and matches the data actually written. | P3-29 review |

---

## 7. Interaction matrix — who feeds whom

Read a row as: "this piece is produced by … and consumed by …". If you change a producer, re-run the consumers' tests.

| Piece | Produced in | Consumed by |
| --- | --- | --- |
| `ChoreSettings` + catalogs | P3-06 | template editor (groups, presets), settings screen, calendar defaults/prefs, generator (horizon, grace), swaps (enabled, buffer), availability (reasons, approval), rota (visibility) |
| `RecurrenceEngine` | P3-05 | generator, editor preview, rotation `occurrence` unit, calendar projection (through the generator) |
| `RotationEngine`, `AbsenceResolver`, `CoverPicker` | P3-09 | generator, rota preview (P3-18), rota matrix (P3-28), absence policy B (P3-26) |
| `OccurrenceGenerator` | P3-12 | `EnsureOccurrences` (app open), `RegenerateRange` (editor save, rotation change, pause/resume), calendar projection, availability preview (P3-27) |
| `effectiveStatus`, `SubtaskSync`, `ChoreItem` | P3-11 | every screen, calendar model, workload, dashboard cards, completion use cases |
| `monthOccurrencesProvider` | P3-13 | `monthItemsProvider` → calendar models, Today, Overdue, workload, dashboard |
| Completion use cases | P3-14 | detail screen, Today swipe, quick actions, comments ("reopen with reason") |
| `InboxPort` | P3-14 (no-op) → P3-26 (real) | completion, comments, swaps, absence |
| `AvailabilityIndex` | P3-26 | `ChoreItem.needsCover`, calendar overlay/hatch, swap eligibility, generator, cover picker |
| `CalendarMonthModel`, `AgendaModel`, `WeekModel` | P3-20 | Month, Agenda, Week, two-pane, dashboard "this week" card |
| `WorkloadCalculator` | P3-28 | rota board, calendar heat (weights), Phase 4 score |
| Audit types | P3-03 | all use cases, rules mirror, `activityText` (P3-29) |
| Permissions | P3-03 | use cases (`requirePermission`), UI (`ref.can` / `PermissionGate`), rules |

**Ten integration seams to test by hand once the slice is up** (they are the places where two steps meet):
1. Save a template → regenerate → the new dates appear in Today and the calendar without restart.
2. Change settings (week start, groups) → editor pickers and calendar re-order live.
3. Change a rotation → past assignees unchanged, future updated.
4. Complete on a **projected** day → the occurrence is created once, the calendar marker changes.
5. Record an absence → "needs cover" appears on the right days, the policy line matches.
6. Accept a swap → detail, calendar tile, workload and inbox all agree.
7. Pause a template → future unstarted occurrences disappear from the calendar; completed ones stay.
8. Disable the Chores module for the family → routes, dashboard cards and inbox items vanish; data stays.
9. Go offline → complete, comment, request swap queue; accept/decline/settings refuse with a clear message.
10. Switch language and theme → every new string and colour follows.

---

## 8. Things to verify at implementation time **[VERIFY]**

| Topic | Why |
| --- | --- |
| Firestore rules access-call limits (10 per request / 20 per batch) and whether repeated `get()` of the same document counts once | decides `kGenerationChunk` (P3-13) |
| Spark daily free read/write quota | read-budget note (P3-30) |
| `animations` and `flutter_slidable` resolved versions, Dart/Flutter SDK constraints | P3-04 |
| `flutter_local_notifications`, `confetti`/`lottie` current versions | Phase 4 only |
| `SharedPreferences` already in `pubspec.yaml` (used by theme/language) | P3-21 |
| `DateKey` API surface (`addDays`, `isoWeekday`, epoch helpers) | P3-02 may need to add them |
| Existing `stableIndex(uid)` helper name | member colours (§3.7) |

---

# Appendices

## Appendix A — The family's chore list, decoded, and the default catalogs

### A.1 What the PDF says (decoded)

The Bengali PDF's font encoding is damaged, so its text copies as garbage. I decoded it line by line from the character patterns and from the structure the project description gives (daily vs weekly vs monthly; breakfast before 9 AM, lunch before 2 PM; refrigerator gasket every Saturday and a deep clean on the 1st). **Every line carries a confidence level.** The wizard (P3-19) ticks only *High* lines by default; please confirm the rest (Appendix G, Q1).

| # | Seed key | Chore (বাংলা) | When | Slots / time | Group | Confidence | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `sweep` | ঘর ঝাড়ু দেওয়া (সকাল / দুপুর / সন্ধ্যা) | daily | 3 slots: `main` সকাল, `noon` দুপুর, `evening` সন্ধ্যা | cleaning | High | subtask hint: "সোফা ও টেবিলের নিচে পরিষ্কার করবে" (Medium) |
| 2 | `mop` | ঘর মোছা | daily | `main` দুপুরে | cleaning | High | "মাঝখানের রুমের সব কাজ শেষ হওয়ার পরে রুম মুছবে" — Medium |
| 3 | `breakfast` | সকালের নাস্তা বানানো | daily | `main` ৯টার মধ্যে (09:00) | cooking | High | matches the project spec |
| 4 | `lunch` | দুপুরের রান্না | daily | `main` ২টার মধ্যে (14:00) | cooking | High | matches the project spec |
| 5 | `dinner` | রাতের রান্না | daily | `main` রাত ৮টার মধ্যে (20:00) | cooking | Medium | wording garbled: "রাতের ভাত ৮টার মধ্যে রান্না শেষ" |
| 6 | `water` | ফিল্টারে পানি দেওয়া | daily | 3 slots: `main`, `noon`, `evening` | water | High | "৩ বেলা" |
| 7 | `dishes` | থালা-বাসন পরিষ্কার (আগের দিন রাতেই) | daily | `main` রাতে (night preset) | kitchen | Medium | "must be done the night before" |
| 8 | `fridge_check` | ফ্রিজে বাসি খাবার আছে কিনা দেখা | daily | `main` | fridge | High | spec: "checking leftover food" |
| 9 | `kitchen_after` | রান্নার পর চুলা ও রান্নাঘর পরিষ্কার | daily | `main` | kitchen | High | subtasks: চুলা পরিষ্কার; উপরের ও নিচের বেসিন; গ্যাস চুলার ভিতর ও ২টা চাবি খুলে পরিষ্কার (Medium); এক্সহস্ট ফ্যান (Medium) |
| 10 | `bin` | ময়লা ফেলার বেলচা ও বালতি ধুয়ে পরিষ্কার (রান্নার পরে) | daily | `main` | kitchen | Medium | |
| 11 | `cover_wash` | সোফা ও টেবিলের কভার ধোয়া/ঝাড়া | daily | `main` | living | Medium | "ধোয়া" vs "ঝাড়া" unclear |
| 12 | `doormat` | রান্নাঘরের পাপোশ ধোয়া (ঘুমের আগে) | daily | `main` রাতে | kitchen | Low | word uncertain |
| 13 | `rack_spice` | রান্নাঘরের র‍্যাকের ভিতর ও মশলার বয়াম পরিষ্কার | weekly (assumed Saturday) | `main` | kitchen | Medium | frequency not visible in the PDF |
| 14 | `drawing_weekly` | ড্রয়িং রুম পরিষ্কার: ফিল্টার, বেসিন, টেবিলের আশপাশ, ফ্যান | weekly (assumed Saturday) | `main` | living | Medium | "৩ জন … ফ্যান" line is Low: is it three people, or three fans? |
| 15 | `fridge_weekly` | ফ্রিজ পরিষ্কার (সাপ্তাহিক): গ্যাসকেট এবং উপরের/ভিতরের প্রত্যেক অংশ | weekly, **every Saturday** | `main` | fridge | High | spec; verification default **required** for this one [OWNER] |
| 16 | `fridge_monthly` | ফ্রিজ গভীর পরিষ্কার (মাসিক) | monthly, **day 1** | `main` | fridge | High | spec |

**Subtasks for both fridge chores (High; from the project spec):** ১. খাবার ও বাসি খাবার দেখা · ২. খাবার নিরাপদে সরিয়ে তাক ও কম্পার্টমেন্ট পরিষ্কার · ৩. দরজার গ্যাসকেট পরিষ্কার · ৪. দরজা ও বাইরের অংশ পরিষ্কার · ৫. তাক ও ডিভাইডার শুকিয়ে ঠিকভাবে লাগানো.

**Rules in the PDF that are not tasks** (go into `settings/chores.houseRules`, offered by the wizard as an editable text — Medium): রান্নাঘরের বেসিনে কেউ থালা-বাসন জমিয়ে রাখবে না · রান্নাঘরের বেসিন সবসময় পরিষ্কার রাখতে হবে · কেউ কিছু জমিয়ে রাখবে না · ভাত রান্নার সময় তরকারি গরম করে ফেলবে · রান্না সময়মতো শেষ করবে (সকাল ৯টা, দুপুর ২টা, রাত ৮টা).

### A.2 What this means for the roadmap

* Items 1 and 6 are why **slots** exist (D-P3-3).
* Items 13–14's frequency and item 14's "৩ জন" line are the biggest uncertainty; nothing wrong is seeded because only High lines are pre-ticked.
* Starter content is **data**, not code: change the pack file or just edit the templates in the app.

### A.3 Default catalogs (the only seed ids in the app — `default_chore_settings.dart`)

| Catalog | Seed items (`id` — বাংলা / English) |
| --- | --- |
| Groups (`colorIndex`, `iconKey`) | `kitchen` রান্নাঘর / Kitchen (0, `kitchen`) · `cooking` রান্না / Cooking (1, `cooking`) · `cleaning` পরিষ্কার-পরিচ্ছন্নতা / Cleaning (2, `cleaning`) · `water` পানি / Water (3, `water`) · `fridge` ফ্রিজ / Fridge (4, `fridge`) · `living` বসার ঘর / Living room (5, `living`) · `other` অন্যান্য / Other (6, `other`) — all `builtIn`, can be renamed/deactivated |
| Due-time presets | `morning` সকাল ৯টা 540 · `noon` দুপুর ২টা 840 · `evening` সন্ধ্যা ৭টা 1140 · `night` রাত ৮টা 1200 · `bedtime` রাত ১০টা 1320 |
| Absence reasons | `sick` অসুস্থ · `travel` ভ্রমণ · `exam` পরীক্ষা · `work` কাজ/অফিস · `family` পারিবারিক কারণ · `other` অন্যান্য |
| Scalars | `weekStartDay` 6 (Saturday) · `defaultCalendarView` `agenda` · `defaultScope` `mine` · `generationHorizonDays` 30 · `showProjected` true · `projectedMonthsAhead` 3 · `overdueGraceMinutes` 0 · `swapsEnabled` true · `swapExpiryBufferMinutes` 120 · `absenceNeedsApproval` false · `workloadVisibleToMembers` false · `houseRules` "" |

`no_hardcoded_options_test` imports the seed id set from `default_chore_settings.dart` (minus the generic `other`) and fails if any presentation file contains one of them as a string literal.

---

## Appendix B — The chore calendar: product and UI specification

### B.1 Personality

A calm, warm, **glanceable** household calendar — not a project-management Gantt. Rounded surfaces, generous space, large touch targets, one accent, status told by **shape + label + colour**. Bangla first: Bangla digits, Bangla month/weekday names, Saturday-first weeks by default, no tiny text.

### B.2 Anatomy (phone, Month view)

```text
┌──────────────────────────────────────────┐
│  অক্টোবর ২০২৬  ▾      ‹   ›     [আজ]  🔔২ │  header: tap title = month/year picker
│  [আজেন্ডা | মাস | সপ্তাহ]  (আমার কাজ ⇄)  ⚑৩ │  view switcher · scope chip · filter badge
├──────────────────────────────────────────┤
│  শনি  রবি  সোম  মঙ্গল  বুধ  বৃহ   শুক্র  │  week-start aware
│  ২৪   ২৫   ২৬   ২৭    ২৮   ২৯    ৩০   │
│  ◔●    ●◔!  ○     ○     ○    ○     ◌   │  ≤3 status glyphs + "+N"; heat tint behind
│  …                                       │  outside-month days dimmed, no markers
├──────────────────────────────────────────┤
│  ▔▔▔ (drag handle)                       │  day panel (draggable: 28% / 55% / 92%)
│  ২৫ অক্টোবর · রবিবার        ৭টি কাজ       │
│  সকাল     ◔ ঘর ঝাড়ু দেওয়া   ৯:০০  🧑 ৩/৫ │
│  দুপুর    ○ দুপুরের রান্না    ২:০০  🧑    │
│  রাত      ! থালা-বাসন        ১০:০০ 🧑    │
└──────────────────────────────────────────┘
```

* **Agenda (default on phones):** one scrolling list around today; sticky day headers; **Overdue** pinned first; empty days collapse into "৩টি ফাঁকা দিন"; jump-to-today button.
* **Week:** 7-day strip (counts per day) + the selected day's timeline by day part; ≥ 840 dp shows seven columns.
* **Tablet/landscape:** ≥ 840 dp two panes — month grid left, persistent day panel right.
* **Rota board** (P3-28) is a separate screen reached from the header menu, not a fourth calendar mode.

### B.3 Status language (never colour alone)

| Status | Glyph (shape) | Label (bn / en) | Token pair |
| --- | --- | --- | --- |
| Scheduled | hollow ring ○ | নির্ধারিত / Scheduled | `statusScheduled` |
| In progress | half-filled ring ◔ | চলমান / In progress (n/m) | `statusInProgress` |
| Completed | filled circle with ✓ | সম্পন্ন / Completed | `statusCompleted` |
| Verified | filled circle with ✓✓ inside a ring | যাচাইকৃত / Verified | `statusVerified` |
| Overdue | rounded triangle with ! | বিলম্বিত / Overdue | `statusOverdue` |
| Skipped | ring with a dash | বাদ / Skipped | `statusSkipped` |
| Planned (projected) | dashed ring, dashed tile border | পরিকল্পিত / Planned | neutral |
| Needs cover | small person-with-plus corner mark | কভার লাগবে | `statusOverdue` container |
| Needs attention | small speech-bubble corner mark | মনোযোগ দরকার | tertiary |
| Unavailable member | diagonal hatch on the day + strip in the panel | অনুপস্থিত | neutral hatch |

### B.4 Interactions

* Tap a day = select (haptic `selectionClick`), the panel updates; tap again on a selected day = expand the panel. Long-press = expand + quick-add for managers.
* Swipe the grid horizontally = previous/next month (shared-axis transition). Title tap = month/year picker. **Today** pill appears only when you are away from today.
* Tile: tap = detail; swipe right = complete (undo 5 s); swipe left = details/quick actions; long-press = quick-actions sheet (only allowed actions).
* **Mine / Family** chip toggles instantly (in memory). Filter sheet: groups, statuses, members, needs-attention, search (Bangla + English, ZWJ-normalised). Active filters appear as removable chips.
* **Heat mode** (optional, pref): background tint by weighted workload with a legend. **Legend sheet** explains every glyph.
* Planned (future, not yet created) chores appear dashed and read-only; the first action on one creates it.
* Preferences (view, scope, density, marker style, heat, projected, unavailable overlay) are local per user, initial values from family settings; "Use family defaults" resets them.

### B.5 Motion

150–300 ms, `Curves.easeOutCubic`; month swipe = shared axis; view change = fade through; selection ring scales in; Today pill slides; panel snaps; tick draws a check. `MediaQuery.disableAnimations` ⇒ all instant.

### B.6 Theming

Only `context.tokens` (status tokens, `chart` ramp for heat, `placeholderPalette` for groups/members). Dark theme has its own ramps (not inverted). Selected day = `primaryContainer`; today = 2 dp ring in `primary`. Outside-month text at 38% opacity but still ≥ 3:1 against its surface.

### B.7 Accessibility

* Grid semantics: `Semantics(container, label: "মাসের ক্যালেন্ডার")`; each cell label: **"২৫ অক্টোবর, রবিবার, আজ, ৩টি কাজ, ১টি বিলম্বিত, ১টি আপনার"** (omit empty parts); selected state announced.
* Targets ≥ 48 dp (grid cells ≥ 48 × 48; below ≈ 336 dp width Month falls back to Week with a one-time notice).
* Large text: cells grow vertically; markers never clip; tiles wrap to two lines.
* Reduced motion honoured; haptics optional (system setting).
* Contrast: every glyph/label/heat combination in both themes ≥ 4.5:1 (text) / 3:1 (graphics), asserted in a test.

### B.8 Feature list ("feature-rich", all in Phase 3)

Month · Week · Agenda · day panel · Mine/Family · filters + search · heat mode · projected future chores · unavailable overlay · needs-cover/attention marks · swipe-to-complete · quick-actions sheet · month/year jump · Today shortcut · legend · tablet two-pane · local view preferences · Bangla/English digits and names · light/dark · reduced motion · rota board · inbox bell.
*Postponed (not Phase 3):* drag-to-reschedule, device-calendar sync, iCal export, public holidays, drag-and-drop swap, widgets for the home screen.

### B.9 Acceptance checks (P3-22/23/24 must pass all)

Month (P3-22): **1** week starts on the configured day and weekday headers follow it · **2** Bangla digits and month names in bn, Latin in en · **3** today and selected day are distinguishable without colour · **4** ≤ 3 glyphs + "+N" per cell, outside-month cells have no markers · **5** swipe changes month, title tap opens the picker, Today pill logic · **6** cells ≥ 48 dp; narrow screens fall back to Week · **7** no overflow at 360 dp and scale 2.0 · **8** 900 items render and rebuild within budget.
Views (P3-23): **9** day panel snaps and lists tasks grouped by day part · **10** agenda scrolls both ways around today · **11** overdue pinned, free days collapsed · **12** week view (phone strip / tablet columns) · **13** filters apply identically in all views and cost no reads · **14** search finds Bangla and English names · **15** view switching keeps the focused date and each view's scroll · **16** quick actions show only permitted actions.
Polish (P3-24): **17** heat mode + legend, both themes · **18** hatch for projected/unavailable days · **19** reduced motion removes all animation · **20** screen-reader labels per cell and tile · **21** contrast table test passes · **22** tablet two-pane · **23** goldens committed (month 5-row/6-row, agenda, week, panel, two-pane) · **24** truncated-month banner appears when > 900.

### B.10 When to fall back to `table_calendar`

Only if checks B.9-1…B.9-8 cannot be met by the custom grid after two attempts (for example a persistent gesture/scroll conflict inside `PageView`). The fallback keeps `CalendarMonthModel` and swaps only `MonthGrid`, using `table_calendar`'s `calendarBuilders` for cells/markers. Record the decision as ADR 0013's addendum.

---

## Appendix C — Occurrence state machine

Stored `status` ∈ `scheduled | in_progress | completed | verified | skipped`; **overdue is derived**. "Actor" rules are checked by the use case **and** the rules (P3-13).

| Action | From (effective) | To | Who | Writes besides the occurrence | Failure codes |
| --- | --- | --- | --- | --- | --- |
| Tick subtask | scheduled / in_progress / completed | in_progress, or completed if the required set is complete | assignee · manager · anyone if `membersCanCompleteForOthers` | none (audit only on completion) | `not_assigned_to_you`, `occurrence_deleted` |
| Untick subtask | in_progress / completed | in_progress / scheduled | same | event `uncompleted` if it was completed | `verified` ⇒ `already_verified` |
| Parent check | scheduled / in_progress | completed (all subtasks ticked) | same | audit `occurrence_completed` | `required_subtasks_open` (unless exception) |
| Parent uncheck | completed | scheduled (all subtasks unticked) | same | event `uncompleted` | `already_verified` |
| Verify | completed | verified | active member ≠ completer; template `verification == required`; family switch on | event `verified`, audit, inbox to completer | `self_verification`, `verification_not_required`, `not_completed` |
| Reopen | completed | in_progress | anyone who may comment | event `reopened` (+ reason, `prevCompletedAt`), `reopenCount + 1`, inbox to assignee | `reason_required` |
| Reopen verified | verified | in_progress | manager | same | `verified_requires_manager` |
| Record exception | scheduled / in_progress | same (+ `exception`) | manager | event `exception` | `reason_required` |
| Skip | scheduled / in_progress | skipped | manager | event `skipped` | `already_skipped`, `occurrence_started` for completed |
| Unskip | skipped | scheduled | manager | event `unskipped` | `not_skipped` |
| Reassign / assign | scheduled / in_progress | same | manager | event `reassigned` + reason | `reason_required` |
| Swap / cover accepted | scheduled / in_progress | same | recipient (with accepted request) | request update, event `swapped|covered`, inbox | `swap_expired`, `swap_not_pending`, `occurrence_started` |
| Soft delete | scheduled, future | (deleted) | manager (RegenerateRange) | audit generation | — |
| Replan | scheduled, no ticks | same (new snapshots) | manager | audit `occurrences_replanned` | `occurrence_started` |

Derived overdue: `effective ∈ {scheduled, in_progress}` and `now > dueAt + overdueGraceMinutes`. A missed deadline is **never** auto-completed or auto-skipped.

---

## Appendix D — Packages

| Package | Decision | Facts / reasons |
| --- | --- | --- |
| `animations` (3.0.0 at the time of writing) | **Add** (P3-04) | Official Flutter team package, BSD-3; `SharedAxisTransition`, `FadeThroughTransition`, `OpenContainer`. Used for month swipe and view switching. |
| `flutter_slidable` (4.0.3 at the time of writing) | **Add** (P3-04) | MIT; swipe actions on tiles with accessible alternatives (the same actions exist in the detail screen and the quick-actions sheet). |
| `table_calendar` | **Fallback only** (B.10) | Maintained and capable, but its cell/marker customisation fights the glyph + heat + hatch design, and Bangla digits/week-start need builders anyway. |
| `calendar_view` | Rejected | Frequent breaking changes in minor versions; heavy default styling. |
| `kalender` | Rejected | Pre-1.0 API. |
| `rrule` | Rejected | Our recurrence kinds are few and must be local-date based; the package is UTC-oriented, its week start is limited, and it adds an `intl` constraint. In-house `RecurrenceEngine` is smaller and fully tested (Appendix F.1). |
| `syncfusion_flutter_calendar` | Rejected | Commercial licence terms. |
| any markdown package | Rejected | `MiniMarkdown` (bold, bullets, numbers, heading; no links/HTML) removes an injection surface and a dependency. |
| `scrollable_positioned_list` | Rejected | `CustomScrollView(center:)` solves the agenda. |
| `flutter_local_notifications`, `confetti` / `lottie` | **Phase 4** | **[VERIFY]** current versions then. |

Add with `flutter pub add animations flutter_slidable`, commit `pubspec.lock`, record versions in `PROGRESS.md`. CLAUDE.md rule 44 forbids other additions without an ADR.

---

## Appendix E — Working with the AI tool

### E.1 Prompt template (per step)

```text
Read CLAUDE.md and docs/PHASE3_CHORES_ROADMAP.md sections 1-3 and the card for step P3-xx.
Inspect the actual files (the code may differ from your earlier changes) and verify the steps
this one depends on. Implement P3-xx exactly as written. List the files you will create/edit
before coding. Do not start another step. I will run dart format / flutter analyze / flutter test.
End with: files changed, how to verify, assumptions, and PROGRESS.md / CLAUDE.md updates.
Return only the changed files as a zip with the same folder structure.
```

### E.2 First-slice milestone (after P3-19)

1. Fresh family → Chores → starter-pack wizard → pick High lines → choose members → Apply.
2. Today shows chores with assignees and due times; the 3-slot chores appear three times.
3. Tick two subtasks → "২/৫"; tick the rest → completed; untick one → back to in progress.
4. A second member verifies a verification-required chore; the first cannot.
5. Open the template editor, change a name, choose "future only" → today's started chore unchanged, tomorrow's changed.

### E.3 UAT with the family (P3-30) — ten tasks

1 apply the starter pack · 2 add a new weekly chore with subtasks · 3 complete a chore step by step · 4 verify someone else's chore · 5 report a problem in a comment and reopen with a reason · 6 add a member to the rotation and check past weeks did not change · 7 record a sickness, send and accept a cover · 8 find "who does what next Saturday" in Month, Agenda and Rota · 9 switch language, theme and week start · 10 use the app offline for five minutes. Record pass/fail and comments in `docs/chores_acceptance.md`.

---

## Appendix F — Test tables

Dates: 2026-10-24 is a Saturday. ISO weekdays: 1 = Monday … 7 = Sunday.

### F.1 Recurrence

| # | Recurrence | Check | Expected |
| --- | --- | --- | --- |
| 1 | once 2026-11-05 | occursOn 11-05 / 11-06 | true / false |
| 2 | daily, start 10-25, end 10-27 | datesIn 10-24…10-28 | 10-25, 10-26, 10-27 (end inclusive) |
| 3 | every 3 days, anchor 10-01 | 10-04, 10-28, 10-31 / 09-28 / 09-29 | true / true (before anchor) / false |
| 4 | weekdays [6] | Oct 2026 | 3, 10, 17, 24, 31 |
| 5 | weekdays [1,3] | Oct 2026 | 5,7,12,14,19,21,26,28 |
| 6 | every 2 weeks, [6], anchor 10-03, weekStart 6 | Oct–Nov | 10-03, 10-17, 10-31, 11-14 |
| 7 | every 2 weeks, [6], anchor 10-03, weekStart 7 | Oct–Nov | same as #6 |
| 8 | every 2 weeks, [7], anchor 10-03, weekStart 6 | Oct | 10-04, 10-18 |
| 9 | every 2 weeks, [7], anchor 10-03, weekStart 7 | Oct | 10-11, 10-25 (shows why `weekStart` is stored) |
| 10 | days_of_month [31], clamp | 2026-10-31 / 2026-11-30 / 2027-02-28 / 2028-02-29 | all true |
| 11 | days_of_month [31], skip | 10-31 / 11-30 | true / false |
| 12 | days_of_month [29], clamp | 2027-02-28 / 2028-02-29 / 2028-02-28 | true / true / false |
| 13 | days_of_month [1,15] | Nov 2026 | 11-01, 11-15 |
| 14 | nth_weekday 1st Saturday | Oct / Nov 2026 | 10-03 / 11-07 |
| 15 | nth_weekday last Friday | Oct / Nov 2026 | 10-30 / 11-27 |
| 16 | nth_weekday 4th Monday | Nov 2026 | 11-23 |
| 17 | last_day | 2026-10-31, 2026-11-30, 2027-02-28, 2028-02-29 | true |
| 18 | daily, startDate 11-01 | 10-31 | false |
| 19 | weekdays [] | validate | `no_dates` |
| 20 | days_of_month [32] | validate | `invalid_recurrence` |
| 21 | every_n_days n = 1 | validate | `invalid_recurrence` (n must be 2–60) |
| 22 | days_of_month [31] skip only | validate | warning (months without 31 skipped), not an error |
| 23 | once before startDate | validate | `no_dates` |
| 24 | daily with endDate 10-27 | nextAfter(10-27) | null |
| 25 | fuzz | for each kind, `datesIn(range)` == filter of `occursOn` over 365 days | equal |
| 26 | any | datesIn ascending, unique, within the template's span | holds |

### F.2 Rotation (week start Saturday = 6 unless stated)

| # | Setup | Day | Expected |
| --- | --- | --- | --- |
| 1 | [A,B,C], anchor 10-03, idx 0, week | 10-03…10-09 | A |
| 2 | same | 10-10, 10-17, 10-24 | B, C, A |
| 3 | same | 10-02 (day before anchor) | C (cycle −1) |
| 4 | same | 2026-09-12 | A (cycle −3 ⇒ index 0) |
| 5 | same, anchor on a Wednesday 10-07 | 10-03 | A (the cycle containing the anchor) |
| 6 | [A,B,C] unit day, anchor 10-03, idx 1 | 10-03, 10-04, 10-05 | B, C, A |
| 7 | [A,B] unit month, anchor 10-01, idx 0 | Oct, Nov, Dec, Sep | A, B, A, B |
| 8 | weekStart 7, anchor Sunday 10-04, week | Saturday 10-10 | same cycle as 10-04 |
| 9 | [A,B] unit **occurrence**, recurrence Sat–Thu (no Friday), anchor 10-03 | 10-03, 10-04, 10-08, 10-10 | A, B, B, A (Friday skipped, so 10-10 is occurrence #6) |
| 10 | v1 [A,B,C] anchor 09-05 idx 0 from 09-01; v2 [A,B,C,D] from 10-17 anchor 10-17 idx 0 | 10-10, 10-17, 10-24, 10-31, 11-07, 11-14 | C, A, B, C, D, A |
| 11 | property | add member at boundary X | every date < X unchanged |
| 12 | remove B at 10-24 (B was due) from [A,B,C] | 10-24, 10-31, 11-07 | C, A, C |
| 13 | day before any version `from` | any | null |
| 14 | planned member inactive | any | assignee null, needsCover true, **no skip to next** |
| 15 | policy A, planned unavailable | any | planned kept, derived "needs cover" |
| 16 | policy B, A unavailable, load A 3 / C 1 / D 1 | suggested cover | C (tie with D broken by rotation order) |
| 17 | policy B, everyone unavailable | suggested cover | null |
| 18 | policy C | any | planned kept, nothing flagged |
| 19 | 12 members, 20 versions | validate | ok; 21 versions ⇒ `too_many_items` |
| 20 | reorder with "starts with" D at 11-07 | dates before | unchanged |

### F.3 Generator and flows

| # | Scenario | Expected |
| --- | --- | --- |
| 1 | daily 3-slot template on 2026-10-25 | ids `T_20261025`, `T_20261025_noon`, `T_20261025_evening` |
| 2 | weekly Saturday group chore | 10-24, 10-31 assigned A then B (rotation weekly) |
| 3 | monthly day 1 | 2026-11-01 |
| 4 | horizon 30 from 10-25, marker absent | drafts for 10-25…11-24; marker = 11-24 |
| 5 | run `EnsureOccurrences` twice | second plan empty |
| 6 | two devices generate the same range | identical documents; no duplicates; second device retries once |
| 7 | 20 templates × 30 days | ≤ 3 chunks of ≤ 400 writes |
| 8 | template edit, "future only" | only `date > today`, unstarted documents change |
| 9 | template edit, "include upcoming" | unstarted today/future refreshed; started untouched; swapped assignee kept |
| 10 | pause template | future unstarted soft-deleted; completed kept; resume regenerates |
| 11 | member disabled | their future items become unassigned + needs cover |
| 12 | 3-day sickness, policy A | affected days show derived needs-cover, one inbox item |
| 13 | same, policy B | cover requests created, occurrences unchanged until accepted; decline ⇒ next candidate ⇒ then A |
| 14 | same, policy C | nothing written; manager "skip all" list |
| 15 | swap due 20:00, buffer 120 | `expiresAt` 18:00 |
| 16 | accept after expiry | `swap_expired`, nothing changed |
| 17 | two accepts of one request | exactly one succeeds |
| 18 | completion on a projected day | one occurrence created, then completed |
| 19 | Dhaka 23:59 vs 00:00 | `dateKey` follows household time zone |
| 20 | month with 901 occurrences | `truncated` banner |

---

## Appendix G — Questions for the owner (defaults are used if you do not answer)

| # | Question | Default |
| --- | --- | --- |
| Q1 | Please confirm the doubtful PDF lines (A.1 rows 5, 7, 10–14 and the "৩ জন … ফ্যান" line): which are weekly, which daily, are "৩ জন" three people or three fans? | Only *High* lines are pre-ticked; the rest are unticked in the wizard. |
| Q2 | Which chores need another member to **verify** them? | Only the weekly/monthly fridge cleaning. |
| Q3 | May any member complete a chore for someone else ("done by Dave for Cara")? | No (`membersCanCompleteForOthers = false`); managers always can. |
| Q4 | Absence policy: A ask for cover / B auto-pick a cover and ask them / C skip? | A. |
| Q5 | May all members see the fair-share (workload) screen? | Managers only. |
| Q6 | Rotation week starts on Saturday? | Yes (matches "every Saturday"). |
| Q7 | Times for the three-times-a-day chores (সকাল / দুপুর / সন্ধ্যা)? | 09:00 / 14:00 / 19:00. |
| Q8 | One duty group for all daily kitchen chores, or one rotation per chore? | One group "দৈনিক রান্নাঘর ডিউটি", weekly turns. |
| Q9 | How long before a chore is due should a swap request expire? | 120 minutes before. |
| Q10 | Reminders and badges wait for Phase 4 — OK? | Yes; Phase 3 only stores the reminder settings. |
| Q11 | Default calendar view on phones? | Agenda (month and week one tap away). |


---

## Appendix H - Wave R1 spec corrections (docs/PHASE3_REVIEW_ROADMAP.md)

| Finding | Spec change |
| --- | --- |
| B-04 | **Reopen unticks steps.** `ReopenOccurrence` removes `subtaskDone.<id>` for the steps to redo (default: every ticked required step; `redoSubtaskIds` narrows it) in the SAME patch. Choosing only optional steps is refused (`Validation('redoSubtaskIds','pick_required_step')`). Rule 4 allows `subtaskDone` to shrink, never grow. The step list is NOT yet stored on the `reopened` event (open item). |
| B-05 | **Event ids are unique per intent**, generated once by `OccurrenceActionWriter`. The patch carries `lastEventId`; every rule requires that event to be created in the same batch (`!exists` before, `existsAfter`), with the right type, actor and reason. The `type_reopenCount` / `type_assignee` ids are gone. |
| B-06 | **Rule 12 RESTORE** (manager, soft-deleted, `status == scheduled`, no ticks) allows only the replan keys + the delete pair + update stamps; `restoreMap` writes exactly those. |
| B-11 | Rules compile fixes: `prev()`/`next()` declared inside the occurrence match, no regex capture groups, `todayKey` built from `request.time + duration.value(6,'h')` with `year()/month()/day()`. |
| B-01/B-02/B-03 | App-open generation starts from the shell and reports non-network failures; `canVerifyAnyProvider` drives the Verify tile/queue; the queue filter is `verifiableOccurrences`. |
