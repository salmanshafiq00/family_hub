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
| A2 | Everything is brown | The brown is the **workload heat tint** (`HeatMode.workload`, switched on in Display options). `HeatCalculator.levels` is *relative*: "a month where every busy day is alike is level 4 throughout". Here every day has the same load, so **all days get the strongest tint**. The tint says nothing. | CAL-01 |
| A3 | Hatched stripes from the 17th on | `HatchPainter` rising lines = `hasProjectedOnly` (chores not yet written; `generationHorizonDays = 30`). Correct but loud: the whole second half of the month looks "broken". | CAL-01 |
| A4 | Three identical empty circles per day | `DayMarkers` (style `glyphs`) draws **one status glyph per chore**, max 3, then "+N". Here the template "Living Room Clean" has 3 times a day, so you get 3 identical open rings on every date. It says "3 open chores", never **who**. | CAL-04…06 |
| A5 | Tiny person icon on the date | `DayCell` draws `Icons.person_rounded` (12 dp) when `mineCount > 0` and scope is All. Teal on teal, no name, easy to miss. Replace it with the viewer's avatar in the member row. | CAL-06 |
| A6 | Week has no day names | `_WeekStrip` renders only `DayCell`s. Month adds `WeekdayHeaderRow` above the grid; Week never does. | CAL-02 |
| A7 | New chore button covers the last item | `ChoresHomeScreen` has `FloatingActionButton.extended`. `_WeekStrip` ends with 24 dp bottom padding, `DayPanelList` also 24 dp. The floating pill bar sits below too. The Month panel *also* has an "Add chore" text button that does the same as the FAB (both open `choresTemplateNew`). | CAL-03 |
| A8 | No recognizable member avatars in calendar cells | `Member` has `avatarKey` (preset `p0`–`p11`) and a name. `AppAvatar` renders the member's initial on their stable preset colour; the membership has no photo URL. Reuse this existing avatar treatment rather than introducing a new icon or photo feature. | CAL-05…07 |

What already works and must be **reused, not rebuilt**: `AppAvatar` (member initial on a stable colour from `avatarKey` or a hash of the uid), `membersProvider`, `DaySummaryBuilder` (one place that counts a day for both Month and Week), `StatusGlyph`, `WeekdayHeaderRow`, `HeatRamp`, `DayCornerMarks`, the day panel and `TodayRow`.

---

## 2. Decisions

| # | Decision |
| --- | --- |
| D1 | **A cell shows WHO and HOW MUCH, not one symbol per chore.** Compact member avatars (up to 2 visible in a narrow cell) + one footer "done/total". Its size is the same for 1, 5, 10 or 30 chores (§3.2). |
| D2 | **Reuse `AppAvatar`; do not add photo support in this task.** It already shows each member's initial and the colour selected by their `avatarKey` (or a stable fallback). The membership model has no photo URL, so the calendar must not add image loading, storage, or profile fields. This keeps identity consistent with other screens without adding data or privacy scope. |
| D3 | **"Me" = the viewer's existing avatar with a clear accent ring, always first**, plus a "You" avatar/name first in the legend strip. No separate person icon. |
| D4 | Member order inside a cell: **me first, then the others in one fixed order** (by uid). Never ordered by load: no ranking (project rule). |
| D5 | The old marker style `glyphs` is **retired**; a stored `glyphs` value is read as the new `members`. `dots` and `count` remain as the person's explicit options. New value `MarkerStyle.members` is the default. |
| D6 | Heat tint stays as an option but is **hidden when the month is uniform** (all busy days have the same level) and is a bit lighter. |
| D7 | "Planned, not created yet" days are shown **faded (55 %)**, not hatched. The "away" hatch (falling lines) stays: it is rare and already in the legend. |
| D8 | Corner marks move: **needs cover top-start, needs attention top-end** (the old "mine" icon spot). Nothing sits bottom-end, so the footer has room. |
| D9 | The FAB becomes a **small icon-only FAB** (tooltip + semantics label kept). The duplicate "Add chore" button in the day panel is removed. Lists get bottom clearance so the last row can always scroll clear. |

---

## 3. Cell specification

### 3.1 Month cell (phone, about 50 × 64 dp, 2 dp gap on every side)

```text
┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐
│ ⚑      │   │        │   │   ◯ 5  │   │        │
│   12   │   │   13   │   │   14   │   │   15   │   date (today = ring, selected = filled pill)
│ [M][S] │   │ [R]    │   │ [M][S]+2│  │        │   members: compact AppAvatars; [M] = me (accent ring)
│ ✓ 2/3  │   │ ○ 0/1  │   │ ! 3/12 │   │        │   footer: status glyph + done/total
└────────┘   └────────┘   └────────┘   └────────┘
```

The month avatar row uses 18 dp `AppAvatar`s with the same compact overlap as `AvatarStack`, leaving room for a `+N` bubble inside a roughly 50 dp cell.

* Surface: `t.surface` (neutral), `radiusMd`, 2 dp gap. Outside-month days: no fill, dimmed number, nothing else.
* **Footer** = one `StatusGlyph` + `done/total` (10–11 sp, `formatters.number`, Bangla digits). The glyph is the **most urgent state of the day**: overdue → `!`, otherwise in-progress/scheduled → open ring, all completed/verified → check. Total shows `99+` above 99.
* **Today** keeps the 2 dp ring on the number. **Selected** keeps the filled pill and adds a 2 dp accent outline on the cell.
* Planned-only day: whole content at 55 % opacity (D7).

### 3.2 What the cell shows as the number of chores grows (your question)

Rule: **group chores by member.** Compact avatars = people, footer = totals. Month cells show at most 2 avatars; `+N` counts additional people.

| Day has | Member avatars | Footer | Notes |
| --- | --- | --- | --- |
| 0 chores | none | none | cell is empty and calm (no empty circles) |
| 1 chore (mine) | [M] | `○ 0/1` | |
| 3 chores, all mine (your screenshot) | [M] | `○ 0/3` | one avatar, not three status circles |
| 3 chores, 3 people | [M] [S] `+1` | `○ 0/3` | me first; narrow cells show at most 2 avatars |
| 5 chores, 2 people | [M] [R] | `○ 1/5` | |
| 10 chores, 4 people | [M] [S] `+2` | `○ 4/10` | `+2` = two more **people** |
| 25 chores, 5 people | [M] [S] `+3` | `! 9/25` | cell size never changes |
| any, scope = **My chores** | none (all would be me) | bigger count | the avatars add nothing in this scope |
| a chore with no assignee | one grey dashed-ring "?" avatar | counts in total | it also triggers the "needs cover" corner mark |

Full detail is always one tap away in the day panel (already grouped by day part). The cell is a **summary**, never a list.

### 3.3 Week cell (phone, about 50 × 84 dp)

Same data and rules, roomier: use **18 dp AppAvatars** (me = accent ring), still up to 2 + `+N` so the row fits a phone-width column; footer as above. **Weekday short names above the row** (Sat Sun Mon …), same widget and week-start as Month. Tablet columns (≥ 840 dp) already have day names: only bottom clearance changes there.

### 3.4 Legend strip (under the filter row, only in "Whole family" scope)

A single horizontally scrollable row, 28 dp high: the viewer's `AppAvatar` + "You" first, then each active member's `AppAvatar` + name in the same fixed order as the cells. Hidden in "My chores" scope. Initials distinguish members even when two members share a preset colour; they can change their preset avatar in their profile (not part of this task).

### 3.5 Accessibility

* The cell stays **one** semantics node. Its label gains the people and progress: "1 December, Tuesday, 3 chores, 0 of 3 done, you 3" and, in family scope with ≤ 3 people, "Salma 2, Rahim 1".
* Member identity uses the same `AppAvatar` as other screens: each avatar shows its initial on its preset/fallback colour. The legend and the cell's spoken label reinforce the identity. Status stays glyph + text.
* Touch target = the whole cell (≥ 48 dp wide and ≥ 56 dp high). Works at text scale 2.0 (cell height = `64 × scale.clamp(1, 2)`).

---

## 4. Steps

Dependency: CAL-01, 02, 03 are independent quick wins. CAL-04 → 05 → 06 → 07 → 08 in order.

### CAL-01 — Calm cell shell: gaps, neutral surface, faded planned days, honest heat
* **Type:** INDEPENDENT. **Files:** EDIT `day_cell.dart`, `month_grid.dart`, `week_view.dart` (`_WeekStrip` only for gaps), `heat_ramp.dart` (lighter alphas), `domain/day_summary_builder.dart`.
* **Do:**
  1. Wrap each cell in `Padding(EdgeInsets.all(2))`; surface `t.surface` with `radiusMd`; selected = filled number pill **and** a 2 dp `t.accent` outline.
  2. Remove the rising (planned) hatch: when `hasProjectedOnly`, draw the cell content at 55 % opacity. Keep the falling hatch for "someone is away".
  3. In `DaySummaryBuilder.build`: if the heat levels of all busy days are the same value (one distinct level), set every `heatLevel` to 0. Do **not** change `HeatCalculator` (its tests keep their meaning).
  4. Lower the dark alphas a little (≈ 0.08 / 0.14 / 0.20 / 0.28) and re-run `heat_ramp_test` (contrast must still pass).
* **Tests:** builder test "uniform month ⇒ all levels 0, varied month ⇒ unchanged"; widget test for faded planned cell; existing heat tests green.
* **Done when:** your December screenshot shows separated neutral cells, no stripes, no brown wash.

### CAL-02 — Weekday names in Week
* **Type:** INDEPENDENT. **Files:** EDIT `week_view.dart`.
* **Do:** put `WeekdayHeaderRow(weekStartDay, formatters)` above the strip row, inside the same horizontal padding so columns line up with the cells. Only in `_WeekStrip`.
* **Tests:** week view test finds seven weekday labels, first = family week start (Sat in the screenshot).
* **Done when:** Week and Month headers look identical.

### CAL-03 — Bottom clearance and a small FAB
* **Type:** INDEPENDENT. **Files:** EDIT `chores_home_screen.dart`, `day_panel.dart`, `week_view.dart`, `month_body.dart`; NEW constant `kCalendarBottomClearance` in `calendar_motion.dart` or a new `calendar_layout.dart`.
* **Do:**
  1. `FloatingActionButton.extended` → `FloatingActionButton.small` (icon only). Keep the keys `chores_fab_new` / `chores_fab_today`, add `tooltip` (the old label) so TalkBack still reads it. Check the Agenda's `calendar_jump_today` small FAB (`end: 16, bottom: 88`) does not collide: stack it above the new FAB.
  2. Find the shell's bottom-bar height (`PillBottomBar`, grep it) and define **one** `kCalendarBottomClearance = 40 (FAB) + 16 + bar height + 16`. Use it as the bottom padding of: `_WeekStrip` scroll view, `_WeekColumns`, `DayPanelList` (replace the `24`), and the Month grid scroll (`reserveForSheet ? height * 0.3 : 12` stays).
  3. Remove the "Add chore" `TextButton` in `DayPanelList` (duplicate of the FAB). Update the test that looked for `calendar_add_chore`.
* **Tests:** a list taller than the screen can scroll its last row fully above the FAB (compare the last row's bottom with the FAB's top); scale 2.0.
* **Done when:** the last chore of a day is never under the button, in Week, Month panel and Agenda.

### CAL-04 — Domain: who has chores on a day
* **Type:** DEPENDENT on nothing visible, but unblocks 05–07. **Files:** EDIT `domain/day_summary.dart`, `domain/day_summary_builder.dart`; NEW `domain/member_load.dart`; EDIT `domain/calendar_enums.dart` (`MarkerStyle.members`, retire `glyphs`: `fromId('glyphs')` returns `members`, default = `members`); EDIT `calendar_prefs.dart` (default).
* **Do:**
  * `MemberLoad {String? memberId, int count}`; `DaySummary.byMember`: `List<MemberLoad>` built in `DaySummary.of` from `visible`: group by `assigneeId` (null = the unassigned bucket), **viewer first**, then ascending uid, the unassigned bucket last. Add `viewerId` to `DaySummary.of` (the builder already has it).
  * Add `doneCount`, `openCount`, `mostUrgent` (`ChoreStatus`, via the existing `MarkerPolicy.urgencyRank`) to `DaySummary` — footer data. `done = completed + verified`; skipped counts in neither.
  * Update `==`/`hashCode` with the new fields (the month model depends on equality to avoid rebuilds).
  * Keep `MarkerPolicy` and its tests (the old styles still use it).
* **Tests (pure):** table: 0 chores; 3 chores one person; 3 people; viewer is first; unassigned last; skipped excluded from done; equality and hash include `byMember`; 30 chores stay O(n); deterministic order across two builds.
* **Done when:** domain tests green; no Flutter import in `calendar/domain`.

### CAL-05 — Presentation data: member styles and the legend strip
* **Type:** DEPENDENT on CAL-04. **Files:** NEW `presentation/calendar_member_styles.dart`, NEW `presentation/widgets/member_legend_strip.dart`; EDIT `calendar_screen.dart` (insert the strip under `FilterChipsRow`), ARB (`calendarLegendYou`, `calendarLegendMembers`).
* **Do:**
  * `memberStylesProvider` = `Map<String, MemberStyle {name, avatarKey}>` from `membersProvider` (**active** members only; a removed member who still owns old chores gets a neutral fallback avatar, never a crash). Build cell and legend avatars with `AppAvatar` so initials and colours match other screens. **No new listener**: `membersProvider` is already live in the session.
  * `MemberLegendStrip`: scrollable row, viewer's avatar + `You` first. Shown only when scope = Whole family and ≥ 2 members.
  * **Tests:** calendar avatar matches `AppAvatar` for the same member; viewer avatar is first and ringed; removed member fallback; strip hidden in My scope; bn/en; scale 2.0.
  * **Done when:** the strip shows every active member using the same avatar treatment as the chore tiles and profiles.

### CAL-06 — New Month cell: member avatars, "me" marker, footer
* **Type:** DEPENDENT on CAL-01, 04, 05. **Files:** EDIT `day_cell.dart`; NEW `widgets/day_cell_members.dart` (avatar row), NEW `widgets/day_cell_footer.dart`; EDIT `day_markers.dart` (keeps `dots`/`count`; `members` is handled by the new widgets), `day_corner_marks.dart` (D8), `day_cell_label.dart`, `month_grid.dart` (pass styles), ARB.
* **Do:**
  * Implement §3.1/§3.2 exactly: compact overlapping `AppAvatar` row (up to 2 visible in a month cell; viewer first with a 2 dp `t.accent` ring), `+N` people overflow, footer glyph + `done/total`, `99+` cap, My-scope variant (no avatars, bigger count), unassigned grey dashed-ring "?" avatar.
  * Remove the old `Icons.person_rounded` "mine" icon from `DayCell`; the viewer's avatar represents them in the member row.
  * `DayCell` gets a `memberStyles` map; cell height = `64 × scale.clamp(1, 2)`; keep each file under 300 lines (that is why the two new widgets).
  * `dayCellLabel`: add progress and, in family scope with ≤ 3 people, the names.
  * Corner marks per D8.
* **Tests:** widget tests for every row of the §3.2 table (finds the expected avatars, `+N`, footer text); me first and ringed; scale 2.0 + bn + dark/light, no overflow; one semantics node per cell; `dots` and `count` styles still work; golden (Linux only) of one month with 0/1/3/10/25-chore days.
* **Done when:** your December screenshot shows your ringed avatar and `0/3` on the 1st instead of three status circles, and finding your own days takes one glance.

### CAL-07 — Week cell
* **Type:** DEPENDENT on CAL-06. **Files:** EDIT `week_view.dart`; NEW `widgets/week_day_cell.dart` (or a `variant` of `DayCell`; pick whichever keeps files ≤ 300 lines).
* **Do:** §3.3: taller cell, 18 dp `AppAvatar`s (me = accent ring), footer, same corner marks and fading; selected day outline. The list below stays (`DayPartSection` + `TodayRow`).
* **Tests:** avatar initials in bn and en; me first and ringed; `+N`; selecting a day updates the list; scale 2.0; tablet columns unchanged except padding.
* **Done when:** Week and Month read as one family of cells.

### CAL-08 — Legend sheet, strings, final checks
* **Type:** DEPENDENT on all. **Files:** EDIT `legend_sheet.dart` (explain: ringed avatar = you, other avatars = members, `done/total`, faded = planned, "+N" = more people, corner marks, away hatch; remove the rising-hatch row and `HatchSwatch` use if unused), `calendar_display_sheet.dart` (marker options: Members (default) / Dots / Count), ARB bn + en, `docs/PROGRESS.md`.
* **Checks:** light and dark, Bangla and English, text scale 2.0; touch targets; existing overflow and screen-state tests; `file_size_test`; no raw colours; `no_unbounded_queries` (no new queries were added); a family with 1 member, 6 members, and a removed member who still has old chores.
* **Done when:** all green and the manual list in §6 passes on a phone.

---

## 5. Out of scope (on purpose)

Photo uploads/avatars, drag-to-reschedule, per-day heat bars, colour pickers per member, a new calendar package, any change to how occurrences are generated or counted.

## 6. Manual check on the phone

1. Month: no touching boxes, no stripes, no brown wash; the 1st shows your ringed avatar and `0/3`.
2. Your days show your ringed avatar; the legend strip starts with your avatar and "You".
3. Add 10+ chores on one day (several people): the cell keeps its size, shows up to 2 avatars and `+N`, footer `x/10+`.
4. Week: weekday names visible; same cell style; selecting a day lists its chores.
5. Scroll to the last chore of a day in Week and in the Month panel: it clears the button.
6. Switch scope to My chores: avatars disappear, count stays. Switch language and theme.
7. Display options: Dots and Count styles still work.
8. TalkBack on one cell reads date, count, progress, and people in one sentence.
