> **Superseded in part (Nov 2026):** decisions D1 (done/total footer in the cell), D3 (me = viewer avatar with a ring) and the border-painter work are replaced by `docs/CHORES_CALENDAR_REDESIGN_PLAN.md`. Other decisions here still stand.

# Chores Calendar Refresh — Month & Week (Build Plan)

**Target:** `lib/features/chores/calendar/**` and `lib/features/chores/presentation/chores_home_screen.dart`
**Based on:** the code in `android__2_.zip` (read file by file) and the two screenshots (Month and Week, dark theme, December 2026).
**Goal:** make Month and Week easy to read at a glance, modern, and show *who* has chores on *which* day, with *me* clearly visible. No over-engineering: one new small piece of data, one new cell layout, a few layout fixes.

---

## 0. How to use this file

1. Do the steps of §4 in order. One step = one branch = one commit: `CAL-03: bottom clearance and small FAB`.
2. Prompt for the AI tool:
   *"Read CLAUDE.md and `docs/CHORES_CALENDAR_REFRESH_PLAN.md` §1–§3, then implement step CAL-xx exactly as written. List the files you will touch before coding. End with: files changed, how to verify, assumptions."*
3. Before every commit: `dart format .`, `flutter analyze`, `flutter test --exclude-tags golden`. Every file stays ≤ 300 lines (`file_size_test`). No raw colours (tokens only). Status is never shown by colour alone.

---

## 1. What the code audit found (why the screen looks messy)

| # | What you see | Real cause in the code | Fix in |
| --- | --- | --- | --- |
| A1 | Day boxes touch each other | `MonthGrid` and `_WeekStrip` put `DayCell`s in a `Row` of `Expanded` with **no spacing**; each cell fills its whole box with a `Material` colour. | CAL-01 |
| A2 | Everything is brown | The brown is the **workload heat tint** (`HeatMode.workload`, switched on in Display options). `HeatCalculator.levels` is *relative*: "a month where every busy day is alike is level 4 throughout". Here every day has the same load, so **all days get the strongest tint**. Heat competes with the date-state colours. | CAL-01 |
| A3 | Hatched stripes from the 17th on | `HatchPainter` rising lines = `hasProjectedOnly` (chores not yet written; `generationHorizonDays = 30`). The hatch makes scheduled dates hard to distinguish from previous dates. | CAL-01 |
| A4 | Three identical empty circles per day | `DayMarkers` (style `glyphs`) draws **one status glyph per chore**, max 3, then "+N". Here the template "Living Room Clean" has 3 times a day, so you get 3 identical open rings on every date. It says "3 open chores", never **who**. Keep status symbols in the selected-day detail panel, not in the date cell. | CAL-04…06 |
| A5 | Tiny person icon on the date | `DayCell` draws `Icons.person_rounded` (12 dp) when `mineCount > 0` and scope is All. Teal on teal, no name, easy to miss. Replace it with the viewer's avatar in the member row. | CAL-06 |
| A6 | Week has no day names | `_WeekStrip` renders only `DayCell`s. Month adds `WeekdayHeaderRow` above the grid; Week never does. | CAL-02 |
| A7 | New chore button covers the last item | `ChoresHomeScreen` has `FloatingActionButton.extended`. `_WeekStrip` ends with 24 dp bottom padding, `DayPanelList` also 24 dp. The floating pill bar sits below too. The Month panel *also* has an "Add chore" text button that does the same as the FAB (both open `choresTemplateNew`). | CAL-03 |
| A8 | No recognizable member avatars in calendar cells | `Member` has `avatarKey` (preset `p0`–`p11`) and a name. `AppAvatar` renders the member's initial on their stable preset colour; the membership has no photo URL. Reuse this existing avatar treatment rather than introducing a new icon or photo feature. | CAL-05…07 |

What already works and must be **reused, not rebuilt**: `AppAvatar` (member initial on a stable colour from `avatarKey` or a hash of the uid), `membersProvider`, `DaySummaryBuilder` (one place that counts a day for both Month and Week), `StatusGlyph`, `WeekdayHeaderRow`, the day panel and `TodayRow`. Remove heat, hatches, and corner marks from date cells; delete their calendar-only UI only if they have no remaining callers.

---

## 2. Decisions

| # | Decision |
| --- | --- |
| D1 | **A date cell shows the date, member avatars, and a compact done/total footer.** Show up to 2 avatars in a narrow cell, but no per-chore status symbols, corner marks, heat or hatch. The footer gives at-a-glance progress; the selected-day panel shows the same counts plus all detailed chore-status symbols. |
| D2 | **Reuse `AppAvatar`; do not add photo support in this task.** It already shows each member's initial and the colour selected by their `avatarKey` (or a stable fallback). The membership model has no photo URL, so the calendar must not add image loading, storage, or profile fields. This keeps identity consistent with other screens without adding data or privacy scope. |
| D3 | **"Me" = the viewer's existing avatar with a clear accent ring, always first when assigned.** No avatar legend strip above the calendar; explain avatars in the existing "What the symbols mean" help sheet. No separate person icon. |
| D4 | Member order inside a cell: **me first, then the others in one fixed order** (by uid). Never ordered by load: no ranking (project rule). |
| D5 | The old marker styles `glyphs`, `dots`, and `count` all produce the same member-avatar cells. Remove the unused marker-style preference; safely ignore the legacy key while decoding. |
| D6 | No workload heat tint in date cells; it conflicts with the scheduled/previous surface colors. |
| D7 | Scheduled dates use a distinct theme surface/text pair instead of hatching or fading. Projected chores retain their row flag and accessible cell description; availability remains in the cell's accessible summary. |
| D8 | Needs-cover and needs-attention marks move out of the date cell and into the selected-day detail panel. |
| D9 | The FAB becomes a **small icon-only FAB** (tooltip + semantics label kept). The duplicate "Add chore" button in the day panel is removed. Lists get bottom clearance so the last row can always scroll clear. |

---

## 3. Cell specification

### 3.1 Month cell (phone, about 50 × 64 dp, 2 dp gap on every side)

```text
┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐
│ 12     │   │ 13     │   │ 14     │   │ 15     │   date (one line; today has its own surface/mark)
│ [M][S] │   │ [R]    │   │ [M][S]+2│  │        │   member avatars; [M] = me (accent ring)
│ 2/3    │   │ 0/1    │   │ 3/12   │   │        │   done/total footer; no status glyph
└────────┘   └────────┘   └────────┘   └────────┘
```

The month avatar row uses compact 18 dp `AppAvatar`s with a small gap. A `FittedBox` scales the row when two avatars and a `+N` count need to fit inside a roughly 50 dp cell. The only other content is a small, localized done/total footer; no status icons appear in the cell.

* Every date is a rounded rectangle (`t.radiusMd`) with 2 dp spacing. Keep all seven weekday/date columns aligned; never wrap or move a date to another line. If needed, allow horizontal scrolling rather than breaking the row.
* **Previous dates:** `t.surfaceSunken` + `t.textSecondary`, including dates without chores. **Future dates with scheduled chores:** `t.statusScheduledContainer` + `t.statusScheduledOn`. Other empty dates use the neutral `t.surface` + `t.textPrimary`.
* **Today:** a unique `t.accent` surface + `t.textOnAccent` and a distinct 2 dp outline/shape, independent of selection. Outside-month dates are dimmed and have no avatars.
* **State border:** if any chore is overdue, use a dashed outline in `t.statusOverdueOn`; otherwise, if at least one non-skipped chore exists and all non-skipped chores are completed/verified, use a double outline in `t.statusCompletedOn`. Name the state in the cell's semantics. The detail panel shows the matching status glyph and label (icon + label + color).
* **Footer:** show localized `done/total` text (10–11 sp); cap large totals as `99+`. Do not add a status glyph next to it.
* Overdue/complete symbols, needs-cover/attention marks, projected flags, and detailed status are shown in the selected-day panel. The cell's single semantics label also announces its date, people, total/done counts, and relevant status.

### 3.2 What the cell shows as the number of chores grows (your question)

Rule: **group chores by member.** Compact avatars = people; the footer is `done/total`. Month cells show at most 2 avatars; `+N` counts additional people. The selected-day panel and accessible cell label also provide exact counts.

| Day has | Member avatars | Date surface/border | Selected-day panel |
| --- | --- | --- | --- |
| 0 chores | none | neutral | no footer; empty state |
| 1 chore (mine) | [M] | scheduled/past surface; `0/1` | total 1, done 0 |
| 3 chores, all mine | [M] | scheduled/past surface; `0/3` | total 3, done 0 |
| 3 chores, 3 people | [M] [S] `+1` | scheduled/past surface; `0/3` | assignee avatars/statuses |
| 5 chores, 2 people | [M] [R] | completed border if all done; `5/5` | total 5, done 5 |
| 10 chores, 4 people | [M] [S] `+2` | overdue border if any; `4/10` | total 10, done/open counts |
| a chore with no assignee | none | status follows date/chores; count footer | needs-cover mark in panel |
| scope = **My chores** | [M] when assigned | date-state surface/border; my `done/total` | my total and done counts |

Full detail is always one tap away in the day panel (already grouped by day part). The cell is a **summary**, never a list.

### 3.3 Week cell (phone, about 50 × 84 dp)

Same date-state surfaces and border rules as Month, with **18 dp AppAvatars**, up to 2 + `+N`, and the text-only `done/total` footer. No status glyphs appear in the date cell; show detailed chore symbols in the selected-day panel. **Weekday short names above the row** (Sat Sun Mon …), aligned to the same seven columns. Keep the row on one line; scroll horizontally rather than wrapping at narrow widths. Tablet columns (≥ 840 dp) remain aligned.

### 3.4 Selected-day panel and "What the symbols mean" help

* Do not add a legend strip above the calendar.
* The date-cell footer provides quick `done/total` progress. The selected-day panel shows total, done, open, overdue, and skipped counts (when non-zero), assignee avatars on chore rows (announced by member name), and the existing status/needs-cover/needs-attention symbols; skipped is separate from done/open.
* Add an `AppAvatar` example and a short localized explanation ("initial and color identify a member; ring means you") to the existing `LegendSheet`, opened by the existing help (?) control. Also explain the scheduled/past/today surfaces and overdue/completed date borders there.

### 3.5 Accessibility

* The cell stays **one** semantics node and announces date, today/past/scheduled state, all assigned people (not only visible avatars), total/done counts, and overdue/completed status; do not rely on color alone. The selected-day panel announces each status as glyph + localized label + color.
* Touch target = the whole cell (≥ 48 dp wide and ≥ 56 dp high). Date and weekday labels stay one line at text scale 2.0; use horizontal scrolling rather than wrapping.

---

## 4. Steps

Dependency: CAL-01, 02, 03 are independent quick wins. CAL-04 → 05 → 06 → 07 → 08 in order.

### CAL-01 — Rounded date cells, state surfaces, one-line grid
* **Type:** INDEPENDENT. **Files:** EDIT `day_cell.dart`, `month_grid.dart`, `week_view.dart` (`_WeekStrip` gaps/alignment), `domain/day_summary.dart`, `domain/day_summary_builder.dart`, `domain/calendar_month_model.dart`, `domain/week_model.dart`, `calendar_providers.dart`, `calendar_prefs.dart`, `calendar_display_sheet.dart`.
* **Do:**
  1. Give every in-month date a rounded-rectangle surface (`t.radiusMd`) with 2 dp gutters. Keep the seven columns fixed and aligned in one horizontal line; at narrow widths scroll horizontally rather than wrapping.
  2. Use theme token pairs for date state: previous dates = `surfaceSunken`/`textSecondary`; future dates with chores = `statusScheduledContainer`/`statusScheduledOn`; other empty dates = `surface`/`textPrimary`.
  3. Make today unique with `accent`/`textOnAccent` plus a distinct outline/shape, independent of selection. Outside-month dates are dimmed and have no avatars.
  4. Add an overdue border using `statusOverdueOn` when any chore is overdue. Otherwise use `statusCompletedOn` only when all non-skipped chores are completed/verified. Give the two states distinct border treatments; retain a separate selected outline.
  5. Remove cell heat tint, status glyphs, hatches, and corner marks, but keep the compact done/total footer. Put detailed symbols in the selected-day panel. Remove the heat switch/legend and heat-only preference/model plumbing if no longer used; decode older local preferences safely. Preserve status/count information in the cell's single semantics label. Use tokens only, with contrast checked in light and dark themes.
* **Tests:** widget cases for empty, previous, future scheduled, today, overdue, fully completed, and selected dates in light/dark themes; seven columns stay aligned on one line at narrow width; no overflow at text scale 2.0; accessibility labels retain counts/status.
* **Done when:** the grid has rounded, separated cells whose surfaces distinguish previous/scheduled/today dates, with member avatars and a text-only done/total footer.

### CAL-02 — Weekday names in Week
* **Type:** INDEPENDENT. **Files:** EDIT `week_view.dart`.
* **Do:** put `WeekdayHeaderRow(weekStartDay, formatters)` above the strip row, inside the same horizontal padding so all seven weekday labels and date cells line up in a single non-wrapping row. Only in `_WeekStrip`.
* **Tests:** week view test finds seven weekday labels, first = family week start (Sat in the screenshot); labels and cells share column centers and do not wrap at narrow width.
* **Done when:** Week and Month headers look identical and stay on one line.

### CAL-03 — Bottom clearance and a small FAB
* **Type:** INDEPENDENT. **Files:** EDIT `chores_home_screen.dart`, `day_panel.dart`, `week_view.dart`, `month_body.dart`; NEW constant `kCalendarBottomClearance` in `calendar_motion.dart` or a new `calendar_layout.dart`.
* **Do:**
  1. `FloatingActionButton.extended` → `FloatingActionButton.small` (icon only). Keep the keys `chores_fab_new` / `chores_fab_today`, add `tooltip` (the old label) so TalkBack still reads it. Check the Agenda's `calendar_jump_today` small FAB (`end: 16, bottom: 88`) does not collide: stack it above the new FAB.
  2. Find the shell's bottom-bar height (`PillBottomBar`, grep it) and define **one** `kCalendarBottomClearance = 40 (FAB) + 16 + bar height + 16`. Use it as the bottom padding of: `_WeekStrip` scroll view, `_WeekColumns`, `DayPanelList` (replace the `24`), and the Month grid scroll (`reserveForSheet ? height * 0.3 : 12` stays).
  3. Remove the "Add chore" `TextButton` in `DayPanelList` (duplicate of the FAB). Update the test that looked for `calendar_add_chore`.
* **Tests:** a list taller than the screen can scroll its last row fully above the FAB (compare the last row's bottom with the FAB's top); scale 2.0.
* **Done when:** the last chore of a day is never under the button, in Week, Month panel and Agenda.

### CAL-04 — Domain: who has chores on a day
* **Type:** DEPENDENT on nothing visible, but unblocks 05–07. **Files:** EDIT `domain/day_summary.dart`, `domain/day_summary_builder.dart`; NEW `domain/member_load.dart`; EDIT `calendar_prefs.dart`.
* **Do:**
  * `MemberLoad {String? memberId, int count}`; `DaySummary.byMember`: `List<MemberLoad>` built in `DaySummary.of` from `visible`: group by `assigneeId` (null = the unassigned bucket), **viewer first**, then ascending uid, the unassigned bucket last. Add `viewerId` to `DaySummary.of` (the builder already has it).
  * Add `doneCount`, `openCount`, `skippedCount`, `mostUrgent` (`ChoreStatus`, via the existing `MarkerPolicy.urgencyRank`) to `DaySummary` — selected-day panel and semantics data. `done = completed + verified`; skipped counts in neither.
  * Update `==`/`hashCode` with the new fields (the month model depends on equality to avoid rebuilds).
  * Keep `MarkerPolicy` and its tests for selected-day status ordering; old marker preferences resolve to `members`.
* **Tests (pure):** table: 0 chores; 3 chores one person; 3 people; viewer is first; unassigned last; skipped excluded from done/open and counted separately; equality and hash include `byMember`; 30 chores stay O(n); deterministic order across two builds.
* **Done when:** domain tests green; no Flutter import in `calendar/domain`.

### CAL-05 — Presentation data: member avatar styles
* **Type:** DEPENDENT on CAL-04. **Files:** NEW `presentation/calendar_member_styles.dart`.
* **Do:**
  * `memberStylesProvider` = `Map<String, MemberStyle {name, avatarKey}>` from `membersProvider` (**active** members only; a removed member who still owns old chores gets a neutral fallback avatar, never a crash). Build date-cell avatars with `AppAvatar` so initials and colours match other screens. **No new listener**: `membersProvider` is already live in the session.
  * Viewer avatar comes first when assigned and has a visible accent ring. No legend strip or new above-calendar content.
  * **Tests:** calendar avatar matches `AppAvatar` for the same member; viewer avatar is first and ringed; removed member fallback; bn/en; scale 2.0.
  * **Done when:** each date cell identifies its assigned members using the same avatar treatment as the chore tiles and profiles.

### CAL-06 — New Month cell: member avatars and compact progress
* **Type:** DEPENDENT on CAL-01, 04, 05. **Files:** EDIT `day_cell.dart`; NEW `widgets/day_cell_members.dart` (avatar row), NEW `widgets/day_cell_footer.dart` (done/total); EDIT `day_cell_label.dart`, `month_grid.dart` (pass styles), and the selected-day panel to show counts/status details.
* **Do:**
  * The date cell contains its date number, compact `AppAvatar`s (up to 2 visible; viewer first with a 2 dp `t.accent` ring), `+N` when needed, and a text-only `done/total` footer. Show the viewer's avatar in My scope when assigned. Unassigned chores do not get a substitute icon/avatar in the cell.
  * Remove `DayMarkers`, `DayCornerMarks`, heat, hatch, and status glyphs from the cell. Keep the done/total footer; show detailed status symbols and counts in the selected-day panel.
  * `DayCell` gets a `memberStyles` map; retain the rounded date-state surfaces and fixed one-line layout from CAL-01. Keep each file under 300 lines.
  * `dayCellLabel`: announce date state, all assigned people, total/done counts, and relevant overdue/completed/away/cover/attention states in one accessible sentence.
* **Tests:** widget cases for every row of §3.2; date, member avatars and `done/total` footer only; me is first/ringed; `+N`; panel totals/status glyphs; one semantics node per cell; legacy marker preference keys are ignored safely; light/dark, bn/en, scale 2.0, no overflow; month golden (Linux only).
* **Done when:** the date grid shows rounded date cells, member avatars and done/total at a glance, while the selected-day panel explains detailed chore statuses.

### CAL-07 — Week cell
* **Type:** DEPENDENT on CAL-06. **Files:** EDIT `week_view.dart`; NEW `widgets/week_day_cell.dart` (or a `variant` of `DayCell`; pick whichever keeps files ≤ 300 lines).
* **Do:** §3.3: use the same date surfaces, borders, avatars and text-only done/total footer as Month; keep date/weekday columns aligned on one line. The selected-day panel below shows totals and all other symbols.
* **Tests:** avatar initials in bn and en; me first and ringed; `+N`; done/total footer; selecting a day updates the panel; one-line alignment at narrow width; scale 2.0; tablet columns unchanged except padding.
* **Done when:** Week and Month read as one family of cells.

### CAL-08 — Help sheet, strings, final checks
* **Type:** DEPENDENT on all. **Files:** EDIT `legend_sheet.dart` (explain member avatars, scheduled/past/today surfaces, overdue/completed borders, and status symbols shown in the detail panel; remove obsolete hatch/heat entries), selected-day detail panel, ARB bn + en, `calendar_display_sheet.dart` (remove the heat switch/legend), `calendar_prefs.dart` and heat/marker-style model plumbing if unused, `docs/PROGRESS.md`.
* **Checks:** light and dark, Bangla and English, text scale 2.0; touch targets; existing overflow and screen-state tests; `file_size_test`; no raw colours; `no_unbounded_queries` (no new queries were added); a family with 1 member, 6 members, and a removed member who still has old chores; ensure no legend is inserted above the calendar.
* **Done when:** all green and the manual list in §6 passes on a phone.

---

## 5. Out of scope (on purpose)

Photo uploads/avatars, drag-to-reschedule, per-day heat bars, colour pickers per member, a new calendar package, any change to how occurrences are generated or counted.

## 6. Manual check on the phone

1. Month: every date is a rounded box; past and scheduled dates have distinct surface/text pairs; today is uniquely marked; overdue and fully completed dates use their distinct borders.
2. Date cells show the date, member avatars, and a text-only `done/total` footer—no status icons. Your avatar is ringed; there is no legend strip above the calendar.
3. Add 10+ chores on one day (several people): the cell keeps its size and shows up to 2 avatars + `+N` and the done/total footer; selecting it shows detailed counts and status symbols in the panel.
4. Week: weekday names and date cells stay aligned on one line; selecting a day shows its chores and counts.
5. Scroll to the last chore of a day in Week and in the Month panel: it clears the button.
6. Switch scope to My chores: your avatar remains on dates with your chores; selected-day details show the scope's counts. Switch language and theme.
7. Open the existing (?) help sheet: it explains the member avatar and date surfaces/borders; inspect light and dark themes.
8. TalkBack on one date announces date, date state, people, total/done counts, and overdue/completion status in one sentence.
