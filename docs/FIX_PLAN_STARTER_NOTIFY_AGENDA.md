# Family Hub — Fix Plan: steps editor, pack title, bulk-assign notification, agenda overdue + filters

**Written:** 2026-11-24 against `android.zip` (Phase 1–4 tree).
**Purpose:** five small, independent changes, each written so any AI coding tool can implement it without design thinking. Every item lists the root cause (with file), exact edits, strings, tests, manual check and "done when".

**How to use:** one item = one branch = one commit (`FIX-1: …`). Paste into the AI tool:
> Read CLAUDE.md and this plan. Implement item FIX-n exactly as written. List the files you will touch first. Do not touch anything else. End with: files changed, how to verify, assumptions.

**Before every commit (CLAUDE.md gates):** `dart format .` · `flutter gen-l10n` (no diff after) · `flutter analyze` (zero issues) · `flutter test --exclude-tags golden`. Architecture tests apply: files ≤ 300 lines, no `Colors.*`, no hard-coded UI strings (ARB only, Bangla in `app_bn.arb` and English in `app_en.arb`), no `TODO(step-`.

**Recommended order:** FIX-2 → FIX-1 → FIX-4+5 (together, same files) → FIX-3. They do not depend on each other except 4 and 5.

---

## Decisions I made (change them if you disagree)

| # | Decision | Why |
| --- | --- | --- |
| A | FIX-3: the "one notification per chore" comes from **auto-share** (`AutoShareAbsentChores`): it moves up to 40 chores of an absent member and each move writes its own `chore_assigned` inbox row, and every row becomes one phone notification. It is the only bulk-assign path in the code. Starter-pack apply and generation write no inbox rows. | Verified in code (see FIX-3). If you meant another flow, tell me which screen. |
| B | FIX-3: manual single "Reassign" on the detail screen keeps one notification (it is one chore). Only bulk paths send a summary. | Matches your request. |
| C | FIX-3: the summary reuses the existing inbox type `chore_assigned` with `params.kind = 'summary'`. **No Firestore rules change, no new notification-type id**, so the user's existing "Chore assigned" notification setting still controls it. | Smallest, safest change. |
| D | FIX-4: the pinned "Overdue" block in Agenda shows **only today's** overdue chores. Chores of earlier days stay under their own date. | Your point 4. |
| E | FIX-5: when **any** filter or the "Mine/Family" scope is used, the agenda is just the normal date-wise list with only matching chores. The pinned block is hidden when a Status filter is on (the day list already shows those chores). | Your point 5: "all things same, just filtered". |
| F | The Today screen's own "Overdue" section (all past days) is **not** changed — you asked only about Agenda. | Scope. |

---

## FIX-1 — Step input too narrow in the chore editor (starter list → edit chore)

**Where:** the wizard's "edit chore" opens the normal `TemplateEditorScreen`, so one fix covers both.
**Root cause:** `lib/features/chores/templates/presentation/widgets/subtasks_editor.dart`, class `_SubtaskRow`: the first `Row` puts the drag handle (≈48 dp) + `ReorderMoveButtons` (2 × 48 dp) + the title field + the delete button (48 dp) side by side. On a 360 dp phone the text field gets ≈ 120 dp, so a step like "গ্যাস চুলার ভিতর ও ২টা চাবি খুলে পরিষ্কার" is cut off. The title field is also single-line.

**Change:**

1. NEW `lib/features/chores/templates/presentation/widgets/subtask_row.dart` — move `_SubtaskRow` here as public `SubtaskRow` (keeps `subtasks_editor.dart` under 300 lines). Same constructor parameters.
2. New layout of one step (a `Column` inside the existing bordered `Container`):
   - **Row 1 (controls):** drag handle (only if `enabled`) · `Expanded(Text(stepLabel))` · `ReorderMoveButtons` · delete `IconButton`. The label is `l10n.choreSubtaskStepNumber(formatters.number(index + 1))` ("ধাপ ১" / "Step 1"); `maxLines: 1`, `overflow: ellipsis`.
   - **Row 2 (title, FULL WIDTH):** `DraftTextField` with `minLines: 1`, `maxLines: 4`, `keyboardType: TextInputType.multiline`, `textInputAction: TextInputAction.newline`, `maxLength: 120`. No sibling widgets in this row.
   - Then the existing "required" `SwitchListTile`, then the existing hint `DraftTextField` (also give it `maxLines: 3`, `keyboardType: multiline`).
3. `SubtaskRow` needs `index` for the label, so `SubtasksEditor` passes `index: i` (already does) and the `WidgetRef`/formatters: make `SubtaskRow` a `ConsumerWidget` and read `ref.watch(appFormattersProvider)` (same provider the editor already uses).
4. **Keep every existing `ValueKey`** (`subtask_title_<id>`, `subtask_required_<id>`, `subtask_hint_<id>`, `subtask_remove_<id>`, `subtask_add`, `move_up_$i`, `move_down_$i`) so current tests and rule 71 (non-drag move buttons) keep working.
5. Do not change `TemplateSubtask`, the 120/200 limits, or the id logic.

**Strings (ARB, both files):** `choreSubtaskStepNumber` — bn `ধাপ {n}`, en `Step {n}`, placeholder `n` of type `String`.

**Tests (`test/features/chores/templates/presentation/`):**
- Widget test: pump the editor with one step of 100 Bangla characters at width 360 and `textScaler` 2.0 → no overflow; `tester.getSize(find.byKey(ValueKey('subtask_title_step_1'))).width` ≥ 360 − 2×(screen/card paddings) (assert > 250).
- Existing editor tests must pass unchanged (they use the keys above).
- Add the new widget to the overflow harness (`test/support/screen_states.dart` / gallery) only if the editor is already there.

**Manual check:** Starter pack → review → open a line → "Steps": the title takes the whole card width, long text wraps to up to 4 lines, up/down/delete are in their own row above.
**Done when:** no overflow at 360 dp / scale 2.0 in bn and en, light and dark; reorder, remove and add still work.

---

## FIX-2 — Remove "(PDF)" from the pack title on step 1 "Pick a pack"

**Where:** `lib/features/chores/starter_packs/presentation/widgets/starter_pack_pick_step.dart` line ≈ 68 uses `l10n.starterPackFamilyPdfTitle`. The only definition is in ARB.

**Change (ARB only):**
- `lib/core/localization/arb/app_bn.arb` line ≈ 3785: `"starterPackFamilyPdfTitle": "পরিবারের কাজের তালিকা"`
- `lib/core/localization/arb/app_en.arb` line ≈ 3786: `"starterPackFamilyPdfTitle": "Our family chore list"`
- Run `flutter gen-l10n` so `lib/core/localization/generated/app_localizations*.dart` update (they are committed; do not hand-edit them).
- Do NOT rename the key or `titleKey` in `family_pdf_pack.dart` (renaming forces churn in tests and data for no user benefit).

**Check:** `grep -rn "(PDF)" lib | grep -v generated` returns nothing; `grep -n "PDF" app_en.arb` shows only `reportExportPdf`. No test references the old text (verified).
**Done when:** the pick-a-pack card reads "পরিবারের কাজের তালিকা" (bn) / "Our family chore list" (en).

---

## FIX-3 — One summary notification instead of one per chore (bulk assign)

### Root cause (verified in code)
- `lib/features/chores/availability/domain/usecases/auto_share_absent_chores.dart` loops over up to `maxPerRun = 40` chores and calls `reassign(...)` for each.
- `ReassignOccurrence.call` (`occurrences/domain/usecases/reassign_occurrence.dart`, ≈ line 129) always attaches `inbox: _inbox.choreReassigned(...)` → one `notificationInbox` row of type `chore_assigned` per chore.
- `lib/features/notifications/presentation/inbox_foreground_bridge_provider.dart` turns every **new** inbox row into a local phone notification (`ForegroundNotificationBridge.showOnce`). 40 rows ⇒ 40 notifications.
- Tapping a row goes through `openInboxItem` (`inbox_open_action.dart`): `refType: occurrence` → opens that one chore.

### Target behaviour
- Bulk move of N chores to one member ⇒ **one** inbox row to that member, one phone notification: *"আব্দুল্লাহ ২৫ অক্টোবর থেকে ৩০ অক্টোবর পর্যন্ত আপনাকে ৬টি কাজ দিয়েছেন"* / *"Abdullah assigned you 6 chores from 25 Oct to 30 Oct"*.
- Tapping it opens the **Chores page** (`AppRoutes.chores`).
- A single manual reassign is unchanged (one chore, one notification, opens that chore).

### Edits

1. **`lib/features/notifications/domain/inbox_port.dart`**
   - Add to `InboxPort`:
     ```dart
     /// ONE row for a bulk move ("N chores from A to B were given to you").
     NewInboxItem? choresAssignedSummary({
       required String batchId,      // stable per run + recipient
       required String toMemberId,
       required String byMemberId,
       required int count,
       required String from,         // first dateKey yyyy-MM-dd
       required String to,           // last dateKey yyyy-MM-dd
     });
     ```
   - `NoopInboxPort`: return `null`.
2. **`lib/features/chores/presentation/chores_inbox_port.dart`** (real port) — implement:
   ```dart
   @override
   NewInboxItem? choresAssignedSummary({...}) => NewInboxItem(
     toMemberId: toMemberId,
     type: InboxType.choreAssigned,
     refType: AuditRefType.choreSettings,   // any 1–40 char string is accepted by the rules
     refId: batchId,
     params: <String, String>{
       'kind': 'summary', 'count': '$count',
       'from': from, 'to': to, 'by': byMemberId,   // 5 params ≤ 6 (rules limit)
     },
   );
   ```
3. **`test/features/chores/occurrences/domain/usecases/completion_test_support.dart`** — `RecordingInboxPort` must implement the new method (record `'chore_assigned_summary -> $toMemberId x$count'`; return a `NewInboxItem` so the stage can be asserted).
4. **`reassign_occurrence.dart`** — add a named parameter `bool notify = true` to `call(...)`; use `inbox: notify ? _inbox.choreReassigned(...) : null`. Default keeps all current behaviour and tests.
5. **`auto_share_absent_chores.dart`**
   - Add constructor deps `required this.inbox` (`InboxPort`) and `required this.clock` (`Clock`, same one `ApplyAbsencePolicy` uses).
   - In the loop call `reassign(..., notify: false)`. On success, record `movedTo.putIfAbsent(to, () => <ChoreOccurrence>[]).add(occurrence)`.
   - After the loop, for each `(to, list)` where `to != actorUid`:
     ```dart
     list.sort((a, b) => a.dateKey.compareTo(b.dateKey));
     final row = inbox.choresAssignedSummary(
       batchId: 'as_${list.first.id}',             // chore ids are unique ⇒ idempotent retry
       toMemberId: to, byMemberId: actorUid,
       count: list.length,
       from: list.first.dateKey.toString(), to: list.last.dateKey.toString(),
     );
     if (row != null) rows.add(row.withId('ib_as_${list.first.id}'));
     ```
     then ONE write: `await occurrences.stageIntegrity(familyId, OccurrenceWritePlan(actorId: actorUid, at: clock.nowUtc(), inbox: rows));` (same inbox-only-plan technique `ApplyAbsencePolicy` already uses; `occurrences` is already a dependency). Ignore a failure of this write (best effort; the moves already happened) — do not change the returned `moved` count.
   - Update the provider in `availability/presentation/availability_providers.dart` (`autoShareAbsentChoresProvider`): pass `inbox: ref.watch(inboxPortProvider)` and `clock: ref.watch(clockProvider)` (both providers already used 20 lines below in `applyAbsencePolicyProvider`).
6. **Inbox text** — `lib/features/notifications/presentation/inbox_text.dart`, `case InboxType.choreAssigned:` becomes:
   ```dart
   case InboxType.choreAssigned:
     if (item.params['kind'] == 'summary') {
       return l10n.inboxChoresAssignedSummary(
         who('by'),
         int.tryParse(item.params['count'] ?? '') ?? 0,
         _day(formatters, item.params['from']),
         _day(formatters, item.params['to']),
       );
     }
     return l10n.inboxReassigned(who('by'), chore, date);
   ```
   (`who`, `_day`, `chore`, `date` already exist in that function.)
7. **Tap target** — `lib/features/notifications/presentation/inbox_open_action.dart`: right before `switch (item.refType)` add
   ```dart
   if (item.type == InboxType.choreAssigned && item.params['kind'] == 'summary') {
     context.go(AppRoutes.chores);
     return;
   }
   ```
   The phone-notification tap already routes through `AppRoutes.inboxItem(id)` → this code, so it needs no change.
8. **Icon** — none (`choreAssigned` already has one in `inbox_tile.dart`).
9. **ARB (both files)** — ICU plural so Bangla/English grammar is right:
   - en: `"inboxChoresAssignedSummary": "{name} assigned you {count, plural, =1{1 chore} other{{count} chores}} from {from} to {to}"`
   - bn: `"inboxChoresAssignedSummary": "{name} {from} থেকে {to} পর্যন্ত আপনাকে {count}টি কাজ দিয়েছেন"`
   - placeholders: `name` String, `count` int, `from` String, `to` String. (Follow how other plural keys are declared in `app_en.arb`; if the project avoids ICU plurals, use the bn-style wording in English too: "{count} chore(s)".) Then `flutter gen-l10n`.

### Not needed
- No change to `firestore.rules` (`chore_assigned` already in `inboxTypes()`, `refType` free text 1–40, params ≤ 6), no new index, no change to `NotificationTypes` (so the user's "Chore assigned" setting still applies).

### Tests
- `test/features/chores/availability/…auto_share…_test.dart` (create if missing, use `InMemoryChoresBackend` + `RecordingInboxPort`): absent member with 6 chores over 6 days and one other available member → `moved == 6`, recording shows **exactly one** `chore_assigned_summary -> dave x6` and **zero** per-chore `chore_assigned`; second run → `moved == 0`, no new row; two recipients → two summary rows; chore moved to the actor themself → no row.
- Existing `verify_reopen_skip_reassign_test.dart:365` (`'chore_assigned -> dave'`) must still pass (single reassign still notifies).
- `inbox_text` test: summary row renders the sentence in bn and en with Bangla digits in bn.
- `inbox_open_action` widget/provider test: tapping a summary row navigates to `/chores`; tapping a normal `chore_assigned` row still opens the occurrence.
- Foreground-bridge test (existing `inbox_providers`/bridge tests): one new inbox row ⇒ one `showNow`.

### Manual check
Two phones (manager + member). Member sick for 6 days with policy "auto assign" → manager opens app → colleague's phone gets **one** notification; tap → Chores page.
### Done when
N moved chores ⇒ 1 inbox row + 1 phone notification per recipient; tap opens Chores; single reassign unchanged; all tests green.

> **Check before you start:** if you actually saw the many notifications right after applying the *starter pack*, send me the screen/step — that path writes no inbox rows today, so it would be a different cause (local reminders in `reminder_planner.dart`).

---

## FIX-4 — Agenda "Overdue" section: today only

### What it does today (answer to your question)
`AgendaModel.build` (`lib/features/chores/calendar/domain/agenda_model.dart`) builds an `AgendaOverdue` block from **every open chore of every earlier day** (up to 100, newest first, "see all") and **removes those chores from their own date**. So yes: it is an "all overdue of previous days at a glance" list. That is what you do not want.

### Change
In `AgendaModel.build`:
1. Replace the overdue computation by today only:
   ```dart
   final pinOverdue = filters.statuses.isEmpty;          // FIX-5: a status filter lists them by date instead
   final overdue = pinOverdue
       ? <ChoreItem>[
           for (final item in visible[today] ?? const <ChoreItem>[])
             if (item.status == ChoreStatus.overdue) item,
         ]
       : const <ChoreItem>[];
   // Order the block with the same helper the day lists use: sortByDeadline(overdue)
   // (it is already imported in agenda_model.dart via week_model.dart); build it as a list first.
   ```
2. Per-day list: **no more `_isLate` exclusion for past days.** Every day (past, today, future) lists its own items; only today's overdue items are removed when `pinOverdue` is true (they are in the block):
   ```dart
   final dayItems = <ChoreItem>[
     for (final item in visible[day] ?? const <ChoreItem>[])
       if (!(pinOverdue && day == today && item.status == ChoreStatus.overdue)) item,
   ];
   ```
3. Simplify `AgendaOverdue`: keep `items`, **delete** `total`, `hasMore`, `AgendaModel.overdueCap`, `_isLate`, `_newestFirst` (dead). Today's overdue list is small, no "see all".
4. `agenda_view_parts.dart` `_OverdueBlock`: header text stays `"${l10n.todaySectionOverdue} · ${count}"` using `overdue.items.length`; keep key `calendar_agenda_overdue`. Rename its title to a today-specific string: new ARB key `calendarAgendaOverdueToday` — bn `আজকের বিলম্বিত কাজ`, en `Overdue today` (use it instead of `todaySectionOverdue` in this block only).
5. `agenda_view.dart` needs no structural change (the block is already rendered at the scroll centre, i.e. at today).
6. Where do older overdue chores go? They are simply in their own date (past days scroll upward from today; "Show earlier weeks" extends up to 8 weeks) and reachable through the Status filter (FIX-5).

### Tests (update + add)
`test/features/chores/calendar/domain/agenda_model_test.dart`:
- Rewrite "overdue is pinned first…": items overdue 3 days ago, yesterday, and today → block contains **only the today one**; the older ones appear in their own `AgendaDay` (past dates), not in the block.
- "a chore overdue today stays in today" → becomes "today's overdue is in the block and not repeated in today's list".
- Delete "capped with a total for see all" (and the `overdueCap` usage).
- New: no overdue today ⇒ `model.overdue == null` even with overdue items on past days.
`test/features/chores/calendar/presentation/calendar_providers_test.dart` ≈ line 400 ("the agenda pins an open chore of last month as overdue") → change to expect **no** `AgendaOverdue` first entry and the 30 Sep chore inside a past `AgendaDay`.
`test/features/chores/calendar/presentation/calendar_views_test.dart` ≈ line 74 → seed the overdue chore on today's date for the `calendar_agenda_overdue` expectation, and add a case where only yesterday's is overdue ⇒ block absent.

**Done when:** the block shows only today's late chores; yesterday's and older chores appear under their dates; no cap/"see all" code remains.

---

## FIX-5 — Filters (status, group, people) keep the date-wise agenda layout

### Today's problems
1. `AgendaModel` already applies `filters` + scope before building (`DaySummaryBuilder.visibleByDay`), but with the **overdue** status filter the old pinned block swallowed all past overdue chores and left their dates empty (collapsed to "free days"). FIX-4 removes this.
2. Days further than ±2 from today start **collapsed** behind their header (`_kOpenDaysAroundToday` in `agenda_view.dart`), so a filtered result looks empty even when it is not.
3. With a filter on and nothing matching, the list is only "N free days" chips; there is no explanation.
4. The default window reaches only 1 week back, so "overdue of last weeks" is not loaded until the user taps "earlier weeks".

### Target
Turning on any filter (Status, Group, People, needs-attention, search) or Mine/Family keeps **the same list** — date header, then that date's chores — but only the matching chores; empty dates collapse to free-day chips as now. This must hold for **every** filter type identically (the code path is the single `CalendarFilters.matches`).

### Edits
1. **Domain** (`agenda_model.dart`, done in FIX-4): `pinOverdue = filters.statuses.isEmpty`. Nothing else in the filter code changes — `CalendarFilters.matches` already handles `statuses`, `groupIds`, `memberIds`, `onlyNeedsAttention`, `query` the same way.
2. **Open all days while filtering** — `agenda_view.dart`:
   ```dart
   bool _isOpen(DateKey day, DateKey today, {required bool filtering}) =>
       filtering || ((today.daysUntil(day).abs() <= _kOpenDaysAroundToday) != _toggledDays.contains(day));
   ```
   `filtering = !ref.watch(calendarFiltersProvider).isEmpty || scope == CalendarScope.mine` is computed once in `build` and passed to `_list`, `_headerOf`, `_rowsOf`. Headers keep their expand arrow; with `filtering == true` taps toggle nothing visible, so also hide the arrow (`expanded` forced true → pass `showToggle: !filtering` to `_DayHeader`, or leave the arrow and let `_toggledDays` invert it — choose hiding, simpler to reason about). Add a one-line comment explaining why.
3. **Wider default window while filtering** — in `_AgendaViewState.build`, `final effective = filtering ? _window.atLeastBack(4) : _window;` and use `effective` for `agendaWindowModelProvider`. Add to `AgendaWindow` (`calendar_agenda_providers.dart`):
   ```dart
   AgendaWindow atLeastBack(int weeks) => weeksBack >= weeks ? this : AgendaWindow(weeksBack: weeks.clamp(1, maxBack), weeksAhead: weeksAhead);
   ```
   (Cost: up to 2 extra month listeners for the session; they are retained 60 s and auto-disposed. The existing "Show earlier weeks" button still extends to 8 weeks. Note it in `docs/chores_read_budget.md` as "+≤2 month listeners while filtering".)
4. **Empty result state** — when `filtering` and the model has no `AgendaDay` with items and no `AgendaOverdue`, show `EmptyState` (existing shared widget) instead of the list: icon `filter_alt_off_outlined`, title `calendarAgendaNoMatch`, action button "Clear filters" → `ref.read(calendarFiltersProvider.notifier).clear()` (use the method the filter sheet/chips row already calls to reset; `filter_chips_row.dart` has it). ARB: `calendarAgendaNoMatch` bn `এই ফিল্টারে কোনো কাজ পাওয়া যায়নি`, en `No chores match these filters`; reuse the existing "clear filters" string if the chips row already has one (check `filter_chips_row.dart` before adding a key).
5. **Month and Week views** need no change: `DaySummaryBuilder` / `WeekModel` already filter per day. Do verify by test (below) that the three views agree.
6. **Consistency check for "overdue" as a status filter:** the status is derived (`month_items.dart` marks an open chore overdue when `now > dueAt + grace`, re-evaluated by `nowTickProvider` every 60 s). Past-day open chores are therefore `overdue` and match. A completed or verified chore never matches Overdue.

### Tests
`agenda_model_test.dart`:
- Status filter `{overdue}`: items overdue on d−5, d−2, today and a completed one on d−2 → `AgendaDay` for d−5, d−2 and today each contain **only** their overdue chores; **no** `AgendaOverdue` entry; days between are free-days chips.
- Group filter and member filter produce the same shape (parametrised test over the three filter kinds — one assertion helper).
- Mine scope + overdue filter combine (AND).
`calendar_views_test.dart` (widget): with the Overdue status filter on, a day 10 days back is **expanded** (its chore tile visible without tapping); with no filter it is collapsed. With a filter matching nothing, the empty state and "Clear filters" are shown and pressing it restores the list.
`calendar_providers_test.dart`: setting `calendarFiltersProvider` to `{overdue}` makes `agendaWindowModelProvider` widen to ≥ 4 weeks and the repository spy still shows **one listener per month** (no per-filter queries — CLAUDE.md rule 37).
Parity test: for the same fixture and filter, the sum of agenda day items == sum of `CalendarMonthModel` day totals for those dates (proves Month and Agenda agree).

**Manual check:** Agenda → Filter → Status → Overdue: dates with overdue chores appear in order with their chores listed (open), nothing else; repeat with a Group and with a Person; combine two; clear.
**Done when:** any filter shows the normal date layout with only matching chores, all those dates expanded, helpful empty state, no extra queries.

---

## Combined file list

| File | FIX |
| --- | --- |
| `templates/presentation/widgets/subtasks_editor.dart`, NEW `subtask_row.dart` | 1 |
| `core/localization/arb/app_bn.arb`, `app_en.arb` (+ regenerated `generated/*`) | 1, 2, 3, 4, 5 |
| `notifications/domain/inbox_port.dart`, `chores/presentation/chores_inbox_port.dart` | 3 |
| `occurrences/domain/usecases/reassign_occurrence.dart` | 3 |
| `availability/domain/usecases/auto_share_absent_chores.dart`, `availability/presentation/availability_providers.dart` | 3 |
| `notifications/presentation/inbox_text.dart`, `inbox_open_action.dart` | 3 |
| `calendar/domain/agenda_model.dart` | 4, 5 |
| `calendar/presentation/calendar_agenda_providers.dart`, `widgets/agenda_view.dart`, `widgets/agenda_view_parts.dart` | 4, 5 |
| tests: `agenda_model_test`, `calendar_providers_test`, `calendar_views_test`, `completion_test_support`, new auto-share + inbox tests, editor widget test | all |
| Docs: `PROGRESS.md` (one line per FIX), `docs/chores_read_budget.md` (FIX-5 note) | all |

## Copy-paste prompt (per item)
```text
Read CLAUDE.md and docs/FIX_PLAN_STARTER_NOTIFY_AGENDA.md (the "Decisions" table and item FIX-n).
Inspect the real files first; names/line numbers may have moved. Implement FIX-n exactly as written,
nothing else. List the files you will edit/create before coding. Update/add the tests listed.
Do not weaken existing tests; if one must change, say why. ARB strings in both app_bn.arb and
app_en.arb, then flutter gen-l10n. End with: files changed, how to verify, assumptions.
Return only changed files as a zip with the same folder structure.
```
