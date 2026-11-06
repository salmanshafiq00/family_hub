# Family Hub — Phase 4 Detailed Implementation Roadmap (Dashboard, Notifications & Engagement)

**Version:** 2.0 · updated 2026-11-05 against the codebase in `android.zip` (Phase 1 + hardening, Phase 2 Bazar and **Phase 3 Chores through P3-30 are present in the tree**).
**Supersedes:** version 1.0 (2026-11-02). Step numbers changed; the mapping is in §0.2.
**Purpose:** a build plan an AI coding tool can follow with almost no design thinking. Every step lists the exact files, names, data shapes, how the piece plugs into the rest of the app, what it depends on and when it is done. Same format as `PHASE2_BAZAR_ROADMAP.md` and `PHASE3_CHORES_ROADMAP.md`.
**Scope:** `ROADMAP.md` Steps 27–31, re-cut into small steps and extended with four owner requirements (§0.1): **configurable FCM push vs normal notifications**, **role-based dashboard visibility**, **per-user dashboard personalisation**, and **stats privacy as a setting (default private)**.
**Not in Phase 4 (Phase 5):** report text builder + share sheet, CSV/PDF export, release hardening, Play Store packaging. Phase 4 ends with `docs/phase5_contract.md`.

---

## 0. How to use this file

1. Work in the order of **§4**. A step may start only when everything in its **Depends on** line is merged and CI is green.
2. One step = one branch = one prompt = one commit: `P4-07: Home dashboard`. Never start a step on a red CI.
3. Paste into the AI tool: *"Read CLAUDE.md and `docs/PHASE4_DASHBOARD_ENGAGEMENT_ROADMAP.md` §1–§3, then implement step P4-xx exactly as written. List the files you will create before coding. End with: files changed, how to verify, assumptions."* (full template: Appendix E).
4. Each step card has the Phase 3 fields: **Type** (`INDEPENDENT` / `DEPENDENT` / `PARALLEL-SAFE`), **Depends on**, **Parallel with**, **Unblocks**, **Files** (`NEW` / `EDIT` / `DELETE`), **Contents**, **Interacts with**, **Rules / tests**, **Done when**.
5. **[VERIFY]** = depends on current Firebase / Android / package behaviour: check the official docs or a real device. **[OWNER]** = a decision only the family owner can make; a default is given so work is never blocked. **[DEVICE]** = provable only on a physical Android phone. **[BLAZE]** = needs the Firebase Blaze plan (billing account).
6. **Carried over and still binding:** Household Manager = the `moderator` role (it acts as *finance manager* while `settings/permissions.moderatorManagesFinance` is true, rules helper `financeManager(f)`); Admin stays the super power; Bangla default; two themes; **Spark plan for everything except the optional push backend (D-P4-21)**; status is never colour alone; encouragement through positive badges, **never star ratings or rankings**.

### 0.1 What you asked for in this revision, and where it lives

| # | Requirement | Decision | Steps |
| --- | --- | --- | --- |
| R1 | FCM / push notifications, **configurable**: the admin chooses per notification type whether it is **Push** or **Normal**; defaults are my recommendation | D-P4-1, D-P4-21…D-P4-25, Appendix B.7 | P4-09, 11, 14, 15, 16 |
| R2 | **Stats are private**, but kept as a **setting** with private as the default | D-P4-9, D-P4-10, D-P4-26 | P4-19, 20 |
| R3 | Roles do not all see the same dashboard; **admin and the finance-managing role (Household Manager)** decide which component each role can see | D-P4-27, D-P4-28, Appendix A | P4-05, 06, 08 |
| R4 | **Every user** can reorder (drag and drop), hide and show dashboard components; the choice is a user-level preference | D-P4-29, D-P4-30 | P4-05, 06, 08 |
| R5 | Phase 3 is fully implemented, so the old "reconcile Phase 3" work is removed | §1.2 F-1 | P4-01 |

### 0.2 Step number mapping (v1.0 → v2.0)

| v1.0 | v2.0 | | v1.0 | v2.0 |
| --- | --- | --- | --- | --- |
| P4-01 | P4-01 (rewritten) | | P4-11 | P4-17 (rewritten) |
| P4-02 | P4-02 (extended) | | P4-12 | P4-18 |
| P4-03 | P4-03 (extended) | | P4-13 | P4-19 (rewritten) |
| P4-04 | P4-04 | | P4-14 | P4-20 (extended) |
| P4-05 | P4-07 (rewritten) | | P4-15 | P4-21 |
| P4-06 | P4-10 (extended) | | P4-16 | P4-22 |
| P4-07 | P4-11 (rewritten) | | P4-17 | P4-23 |
| P4-08 | P4-12 (extended) | | P4-18 | P4-24 |
| P4-09 | P4-13 | | P4-19 | P4-25 (extended) |
| P4-10 | P4-16 (rewritten) | | — | **new:** P4-05, 06, 08, 09, 14, 15, 26 |

---

## 1. What the audit of the current code found

### 1.1 What already exists and must be reused (do not rebuild)

| Capability | Where | How Phase 4 uses it |
| --- | --- | --- |
| `Role {admin, moderator, member}`; `PermissionPolicy`; `PermissionSettings` incl. `moderatorManagesFinance`; rules helpers `isAdmin`, `isMod`, `isManager`, **`financeManager(f)`** | `core/permissions/`, `firestore.rules` | The dashboard access matrix is editable by exactly `financeManager(f)` (R3). Notification delivery and stats privacy are admin-only (`editFamilySettings`). |
| `FamilyModule.dashboardCards` (`List<WidgetBuilder>`), `visibleModulesProvider`, Bazar cards (month spend, fund balance, budget alert), Chores cards (Today, Overdue, Awaiting verification, This week) | `lib/modules/`, `features/bazar/`, `features/chores/presentation/dashboard/` | Wrapped into `DashboardCardSpec`s (P4-07) without breaking them. |
| `HomeScreen` = `AppBar` + `ListView` of cards + flavour label | `features/dashboard/presentation/home_screen.dart` | Replaced in P4-07. |
| **Inbox is implemented:** `InboxType` (7 closed types), `InboxItem`, `InboxRepository`, `FirestoreInboxRepository`, `InboxScreen`, `InboxBell`, `MarkInboxRead`, `ArchiveInboxItem`; rules block for `notificationInbox` (owner read, `readAt`/`archivedAt` updates) | `features/notifications/`, `firestore.rules` | The **push pipeline is driven by inbox rows** (D-P4-22): the row already exists for every event, so push adds no new write path in the app. |
| `todayItemsProvider`, `todayProgressProvider`, `monthItemsProvider(MonthKey)`, `nowTickProvider`, `templateIndexProvider`, `choreSettingsProvider`, `AvailabilityIndex`, swaps, comments, rota | `features/chores/*` | Reminder planner, stats sync and cards read these; **no new occurrence listener**. |
| `ReminderConfig {enabled, atDue, offsetsMinutes≤5, overdueEnabled, overdueAfterMinutes}` on templates | `templates/domain/template_parts.dart` | Third level of the reminder hierarchy. |
| `settings/notificationDefaults` seeded `{enabled:true}`; `users/{uid}.preferences` + `PreferenceSync` / `ThemePreferenceSync` pattern; `preferencesOk(data)` accepts only `themeId, themeMode, language, banglaDigits` | `family_mappers.dart`, `app/preference_sync.dart`, `firestore.rules` | Pattern copied for notification prefs and **dashboard prefs**; `preferencesOk` is extended. |
| `memberStats` named in `FirestorePaths` and still in the deny-only block of the rules | `firestore_paths.dart`, `firestore.rules` | Carved out in P4-19. |
| `AuditEvent` / `AuditWriter`, closed `eventTypes()` / `refTypes()` mirrored in rules + mirror test; `activityText` + `activity_text_chores.dart` | `core/audit`, `core/localization` | New settings audits only. |
| Status tokens, `placeholderPalette`, `chart[0..9]`, `HeatRamp`, `StatusGlyph`, `FlagChip`, `ProgressRing`, `AppCard`, `EmptyState`, `ErrorView`, `LoadingView`, `SyncBanner`, `PermissionGate`, `AppAvatar` | `app/theme`, `shared/widgets` | Every Phase 4 widget. |
| `Clock`/`FakeClock`, `familyDateKeysProvider`, `DateKey`, `MonthKey`, `AppFormatters` | `core/utils` | Pure planner / scoring. |
| `timezone`, `flutter_timezone`, `shared_preferences`, `animations`, `fl_chart`, `firebase_core 5.0.0`, `cloud_firestore 7.0.0`, `firebase_auth 7.0.0` | `pubspec.yaml` | Reused. |
| Architecture tests (`layer_boundaries`, `file_size`, `no_unbounded_queries`, `no_role_checks_in_ui`, `no_step_todos`, `no_hardcoded_options`, `no_raw_color`), gallery overflow tests at scale 2.0, `screen_states`, rules emulator suite, `check_indexes` | `test/`, `tools/`, `firebase/` | Phase 4 code must pass all of them. |

### 1.2 Gaps and traps found (each one is handled by a step)

| # | Finding | Consequence if ignored | Handled in |
| --- | --- | --- | --- |
| F-1 | **(Resolved)** The tree now contains comments, swaps, availability, rota, the inbox feature and `chores_phase4_contract.md`. **But** `PROGRESS.md` says P3-29/P3-30 were "written without an SDK: nothing compiled or run" and Phase 3 is not signed off. | Phase 4 starts on a tree that may not build. | P4-01 runs the real gate and records it; it no longer re-specs Phase 3. |
| F-2 | `file_size_test` allow-list holds ten over-300-line files (`agenda_view` 439, `recurrence_picker_sheet` 431, `template_list_screen` 406, `template_editor_controller` 369, `template_editor_screen` 347, `chore_item` 334, `occurrence_action` 319, `chore_occurrence` 308, `chore_settings_screen` 305, `catalog_editor` 303). | Debt on the Phase 4 polish path. | P4-01 splits them and empties the allow-list. |
| F-3 | Android manifest has only `INTERNET` / `ACCESS_NETWORK_STATE`; no desugaring; no FCM. | Neither local nor push notifications can build or fire. | P4-13 (local), P4-14 (FCM). |
| F-4 | `ReminderConfig` is on **templates only**. | Reminders never fire, or fire for edited-away config. | P4-10: planner takes `templateIndex`; a template edit re-plans. |
| F-5 | `preferencesOk` accepts a fixed key set; `settings/notificationDefaults` is `{enabled:true}`. | Per-member notification and dashboard preferences cannot be saved/synced. | P4-06, P4-11 (rules + mappers + mirror test). |
| F-6 | **Spark cannot push.** FCM *receiving* is free, but *sending* needs a trusted server holding a service account (HTTP v1 API, OAuth token). The legacy server-key API is shut down, so a phone cannot safely send push to another phone. The only first-party server on Firebase is Cloud Functions, which needs the **Blaze** plan (a billing account with a payment method). | Push is impossible without a server; Blaze has no automatic spend cap. | D-P4-21 (go/no-go), P4-15 (backend), graceful fallback to Normal everywhere. |
| F-7 | Rules `todayKey` is fixed to UTC+6 (ADR 0014). | Date drift if the family timezone changes. | P4-19 reuses the helper; test documents the limit. |
| F-8 | "Points never decrease" vs a full-history read on Spark. | Double counting, huge reads. | D-P4-8 finalised months + watermark. |
| F-9 | `memberStats` is client-written; rules cannot verify scoring. | Tampering by a technical member. | D-P4-9: owner-only write, monotonic, bounded; documented limit (ADR 0017). |
| F-10 | **(Changed)** Privacy is now a *setting*. A shared read of `memberStats` would expose points. | Leaking points. | D-P4-26: `memberStats` stays owner-only **always**; sharing, when allowed, goes through a separate points-free public doc. |
| F-11 | Notification ids must be stable 32-bit ints; ~500 pending alarms on Android. | Duplicates / leaks after edits. | `NotificationIdFactory`, diff sync, cap 60 (P4-10, P4-12). |
| F-12 | `SCHEDULE_EXACT_ALARM` is user-revocable on Android 12+; `USE_EXACT_ALARM` is restricted by Play policy. | Play review problem or silent non-delivery. | D-P4-4. **[VERIFY]** |
| F-13 | Celebration must fire once per day. | Confetti spam. | D-P4-12, P4-21. |
| F-14 | No activity feed screen; `activityText` completeness unproven. | English fallback sentences. | P4-04. |
| F-15 | `WorkloadCalculator` not guaranteed. | Helper highlight blocked. | P4-18 ships `CoverCounter`. |
| F-16 | **Push and local would double-notify** when a type is delivered by both. | Two notifications for one event. | D-P4-23: each type has exactly one effective mode; the local planner skips types whose effective mode is Push; the foreground bridge de-duplicates by `inboxId`. |
| F-17 | A role/permission change can leave a user with a saved dashboard layout that references cards they may no longer see. | Crash or leak of a hidden card. | D-P4-29: the resolver drops disallowed ids every build and keeps them dormant in the prefs. |
| F-18 | **Hiding a dashboard card is not access control.** A member who can read `contributions` by rules can still open the Fund screen by URL. | A false sense of security. | D-P4-28: the matrix UI says so; data stays governed by `PermissionPolicy` + rules. |
| F-19 | FCM tokens rotate and go stale; a signed-out phone must stop receiving the previous user's push. | Wrong-user notifications. | P4-14 (token doc per device, delete on sign-out), P4-15 (prune on `not-registered`). |
| F-20 | A member could spam push by writing many inbox rows for someone. | Notification flood. | P4-15 hourly cap per recipient (`pushLedger`), dedupe by `inboxId`. |
| F-21 | Blaze has no hard spending cap; Spark stops at the quota. | A surprise bill. | P4-15 budget alert checklist **[OWNER]**; the function reads one policy doc and writes at most one status field per push. |

---

## 2. Decisions (defaults are used unless you change them)

| # | Decision | Default in this roadmap |
| --- | --- | --- |
| D-P4-1 | **Two delivery modes** per notification type (**changed from "local only"**) | **Normal** = in-app inbox + an on-device local notification (scheduled for time-based types; immediate while the app is alive for event types). **Push** = Firebase Cloud Messaging, delivered by a Cloud Function even when the app is closed. The admin picks the mode per type (D-P4-24). Both ship in Phase 4; push is dormant until the backend is deployed and the master switch is on. |
| D-P4-2 | Local planning horizon | Next **7 days**, hard cap **60 pending**. `ReminderPlanner.plan(input)` is pure. |
| D-P4-3 | Packages | **Add three:** `flutter_local_notifications`, `android_intent_plus`, `firebase_messaging`. Functions folder uses `firebase-functions` + `firebase-admin`. **Do not add:** `confetti`, `lottie`, `workmanager`, `permission_handler`, `share_plus` (Phase 5), any drag-and-drop package (Flutter's `ReorderableListView` is enough). Any other package needs an ADR (rule 62). |
| D-P4-4 | Exact alarms (local) | Request `SCHEDULE_EXACT_ALARM`; fall back to inexact windows; never `USE_EXACT_ALARM`. |
| D-P4-5 | Switch hierarchy | Global master → category (`chores`, `bazar`, `family`) → template. All three must be on. Off keeps saved timings. |
| D-P4-6 | Virtual inbox items | Budget alerts, pending approvals and "contribution due" are **derived**, never written. Stored inbox types: the 7 of Phase 3 plus **two added in P4-17** (`chore_assigned`, `member_approved`). |
| D-P4-7 | Where preferences live | Member notification **and dashboard** preferences: local first (`SharedPreferences`, per family id), mirrored to `users/{uid}.preferences.*` through `PreferenceSync` (local wins at startup). Family-level policies live in `settings/*`. |
| D-P4-8 | Scoring windows | Per month; current month recomputed from the live listener; earlier months read once, frozen (`final`), counting starts at `settings/engagement.startedOn`; stored points use `max(stored, computed)`. |
| D-P4-9 | Stats are private by default and unaudited | `memberStats/{uid}` is readable and writable **only by its owner**, always, admins included. No activity or audit entry for stats writes (ADR 0017). |
| D-P4-10 | Highlight without leaking | "This month's helpers" counts **covers given** from occurrences; never reads stats. Off by default. |
| D-P4-11 | Scoring is data | Bases, factors, levels, thresholds in `settings/engagement`; frozen months keep their `specVersion`. |
| D-P4-12 | Celebration | Once per day per member (state table in Appendix D). |
| D-P4-13 | Visuals | Plant, badges, confetti are `CustomPainter`s with token colours; reduced motion ⇒ static. |
| D-P4-14 | Dashboard listener budget | The Home tab holds at most **7** data listeners (members, templates, current-month occurrences, current-month expenses, current-month contributions, activity limit 5, inbox ≤ 50) plus own `memberStats` (1 doc) and the two small policy docs (`settings/dashboard`, `settings/engagement`) which are already session-level. A test counts them (P4-07). |
| D-P4-15 | Soft dependencies | Anything needing data that may be empty reads a provider that returns empty; no crash. |
| D-P4-16 | Card contract | Each module contributes `DashboardCardSpec`s; **visibility and order are decided only by `DashboardResolver`** (D-P4-27…29). A card never opens its own listener. |
| D-P4-17 | Ask-AI | Dormant widget behind `FeatureFlags.askAi = false`. |
| D-P4-18 | Tablet | ≥ 840 dp: `NavigationRail`, two-column dashboard, two-pane detail. |
| D-P4-19 | Language of notifications | Local: built from ARB at planning time in the member's language and digit setting. Push: the function uses a small bn/en template table and the `lang` stored on the device doc. |
| D-P4-20 | Streak rule | A day counts when ≥ 1 eligible chore and all finished; no eligible chore or full approved absence **pauses**; an unfinished eligible chore breaks. |
| **D-P4-21** | **Push backend is an owner go/no-go** **[OWNER][BLAZE]** | **Default: build the client and the functions code now; deploy only when you upgrade to Blaze.** Without Blaze every type simply stays Normal and the Settings screen says why. Recommendation: upgrade **with a budget alert at a very low amount**; for a single family the function usage is expected to stay inside the monthly free tier **[VERIFY]**, but Blaze has no hard cap. |
| D-P4-22 | Push is driven by stored events | A Cloud Function triggers on `notificationInbox` **create** (and on a pending `members` create for join requests). The app's write path is unchanged; the client never sends push and never holds a service account. |
| D-P4-23 | One effective mode per type | `DeliveryPolicy.effective(type, policy, capability)` returns `push` or `normal` plus a reason. Local planner and bridge obey it (F-16). |
| D-P4-24 | **Admin chooses the mode per type; recommended defaults** | `settings/notificationDelivery {pushEnabled (master), modes{typeId: push\|normal}}`. Defaults = the "recommended" column of Appendix B.7: **Push** for things another person does that needs your action or changes your day (swap request, swap result, needs cover, chore assigned, chore reopened, join request, approval); **Normal** for everything informational or time-based. Master `pushEnabled` defaults to **off** until the backend is confirmed; flipping it on immediately gives the recommended behaviour. |
| D-P4-25 | Types that cannot be pushed | Scheduled types (due reminders, overdue, nudge, morning summary, contribution due, month end) and derived types (budget alert, achievements) are `pushCapable = false` in Phase 4: they are computed on the phone and no server event exists. The admin screen shows them locked to Normal with the reason. Optional later step P4-26 adds a scheduled sweeper. |
| **D-P4-26** | **Stats privacy is a setting** | `settings/engagement.statsVisibility ∈ {private (default), levels}`; admin only. `levels` lets each member **opt in** (`sharing` flag, default off) to publish a points-free card (`level`, `badges`) to `memberStatsPublic/{uid}`. **Points, streaks and per-month numbers are never shared**, and there is no ranking (alphabetical lists only). Changing the setting back to `private` makes the public docs unreadable at once and the owner's app deletes its own. |
| **D-P4-27** | **Dashboard access is a role matrix** | `settings/dashboard.roles{moderator, member}{cardId: access}` with `access ∈ {hidden, on, off, required}`: `hidden` = never visible, `on` = visible and the user may hide it, `off` = available but hidden until the user turns it on, `required` = always visible, cannot be hidden. Absent ⇒ catalog defaults (Appendix A.3). **Admin always has every card available** (cannot be locked out) and customises only their own view. |
| D-P4-28 | Who edits the matrix | `manageDashboardLayout` = admin, or Household Manager while `moderatorManagesFinance` (rules: `financeManager(f)`). A role cell is **disabled** when the role lacks the permission the card needs. UI text: hiding a card does not remove access to the data. Audited `family.dashboard_policy_updated`. |
| **D-P4-29** | **User dashboard preferences** | `users/{uid}.preferences.dashboard {order[], hidden[], shown[], updatedAt}`: `order` = card ids in the user's order, `hidden` = optional cards the user switched off, `shown` = default-`off` cards the user switched on. The resolver ignores ids the user may no longer see but keeps them stored, so a role change loses nothing. |
| D-P4-30 | How the user edits | A **Customize dashboard** screen with drag handles (`ReorderableListView`), a switch per optional card, a lock icon on required cards, **Move up / Move down semantic actions** for TalkBack, and "Reset to default". |

---

## 3. Shared blueprint (every step refers to this section)

### 3.1 Folder layout to create

```text
lib/core/notifications/
├── domain/                      PURE Dart
│   ├── notification_type.dart       NotificationType catalog (id, category, kind, pushCapable, recommendedMode, mutable)
│   ├── delivery_policy.dart         DeliveryMode, DeliveryPolicy.effective(...) + reason
│   ├── reminder_settings.dart       ReminderSettings, CategorySwitch, QuietHours, MorningSummary
│   ├── reminder_precedence.dart     three-level switch resolution (+ reason)
│   ├── planned_notification.dart    PlannedNotification, NotificationKind, ChannelId
│   ├── notification_id_factory.dart FNV-1a 31-bit ids, collision probe
│   ├── reminder_planner.dart        the pure planner
│   ├── reminder_explainer.dart      "why am I (not) getting this?"
│   └── reminder_scheduler.dart      port: schedule/cancel/pending/permissions
├── data/
│   ├── local_notifications_scheduler.dart   the ONLY file importing flutter_local_notifications
│   ├── notification_channels.dart
│   ├── push_messaging_service.dart          the ONLY file importing firebase_messaging
│   ├── device_token_repository.dart         users/{uid}/devices/{deviceId}
│   └── notification_tap_router.dart         payload → go_router location (shared by local and push)
└── presentation/ (providers only)
lib/features/notifications/
├── domain/   (existing inbox files) + virtual_inbox.dart, usecases/mark_all_read.dart, notification_delivery_settings.dart, usecases/{update_notification_delivery, update_notification_defaults, save_member_notification_prefs}.dart
├── data/     (existing) + delivery_mappers.dart, firestore_delivery_repository.dart, local_notification_prefs_store.dart, firestore_notification_pref_sync.dart
└── presentation/ inbox_* (existing), notification_settings_screen.dart, delivery_admin_screen.dart, reminders_help_screen.dart, widgets/
lib/features/dashboard/
├── domain/   card_catalog.dart, card_access.dart, dashboard_policy.dart, dashboard_prefs.dart, dashboard_resolver.dart, dashboard_card_spec.dart, greeting.dart, dashboard_refresh.dart, usecases/{update_dashboard_policy, save_dashboard_prefs}.dart
├── data/     dashboard_policy_mappers.dart, firestore_dashboard_policy_repository.dart, local_dashboard_prefs_store.dart, firestore_dashboard_pref_sync.dart
└── presentation/ home_screen.dart, dashboard_header.dart, dashboard_grid.dart, dashboard_providers.dart,
                  customize_dashboard_screen.dart, dashboard_access_screen.dart, widgets/
lib/features/activity/{domain,data,presentation}/
lib/features/chores/achievements/
├── domain/   scoring/*, levels/*, badges/*, member_stats.dart, public_stats.dart, stats_sync.dart, cover_counter.dart, celebration_state.dart, usecases/{sync_member_stats, mark_celebrated, update_engagement_settings, set_stats_sharing}.dart
├── data/     member_stats_mappers.dart, public_stats_mappers.dart, firestore_*_repository.dart, engagement_settings_mappers.dart
└── presentation/ achievements_screen.dart, hub_level_card.dart, helpers_strip.dart, family_levels_strip.dart, celebration_overlay.dart, engagement_settings_screen.dart, painters/*
lib/app/feature_flags.dart · lib/app/gallery/gallery_sections_p4.dart
functions/                                  [BLAZE] Cloud Functions (TypeScript), NOT part of the Flutter build
├── package.json · tsconfig.json · src/index.ts
├── src/{on_inbox_created.ts, on_member_pending.ts, delivery_policy.ts, push_texts.ts, push_ledger.ts, tokens.ts}
└── test/*.test.ts   (emulator + unit)
test/features/** mirrors lib/ · test/support/{in_memory_engagement_backend, fake_reminder_scheduler, fake_push_service}.dart
```
Import rules: `core/notifications/domain` imports nothing from `features/`. Only `local_notifications_scheduler.dart` / `notification_channels.dart` import `flutter_local_notifications`; only `push_messaging_service.dart` imports `firebase_messaging`; only one file imports `android_intent_plus` (architecture test, P4-01).

### 3.2 Collections and document shapes

All documents carry the `BaseMapper` fields. "Key set" = the exact `hasOnly` list in the rules, mirrored in `test/contract/rules_key_sets_test.dart`. Every absent field falls back to the table default in the mapper (like `settings/chores`, no backfill).

| Path | Doc id | Fields | Notes |
| --- | --- | --- | --- |
| `settings/notificationDelivery` **(new, R1)** | doc | `pushEnabled` bool (false), `modes` map `typeId → 'push'\|'normal'` (only `pushCapable` ids; defaults = Appendix B.7 "recommended"), `quietRespectedByPush` bool (true), `updatedAt` | **Admin write only** (`editFamilySettings`); all active members read. Audited `family.notification_delivery_updated`. The Cloud Function reads it on every send. |
| `settings/notificationDefaults` (exists) | doc | `enabled` bool, **new:** `chores`, `bazar`, `family` bool (true), `defaultOffsetsMinutes` list≤5 of int 1..1440 (`[30]`), `overdueEnabled` (false), `overdueAfterMinutes` 1..1440 (60), `morningSummaryEnabled` (true), `morningSummaryMinutes` 0..1439 (420), `quietEnabled` (true), `quietStartMinutes` 0..1439 (1380), `quietEndMinutes` 0..1439 (360) | Manager/admin write; audited `family.notification_defaults_updated`. |
| `users/{uid}.preferences.notifications` | map | same field names as defaults per member, plus `pushEnabled` bool (true), `updatedAt` | Owner write; `preferencesOk` extended. Missing ⇒ inherit family defaults. |
| `users/{uid}.preferences.dashboard` **(new, R4)** | map | `order` list ≤ 24 of string ≤ 40, `hidden` list ≤ 24, `shown` list ≤ 24, `updatedAt` | Owner write; `preferencesOk` extended with list-size checks. |
| `users/{uid}/devices/{deviceId}` **(new, R1)** | local install id | `token` string ≤ 4096, `platform` `'android'`, `lang` `'bn'\|'en'`, `appVersion`, `flavor`, `createdAt`, `lastSeenAt` | **Owner read/write/delete only** (the one place a hard delete is allowed: device ephemera, not financial or chore data). The function reads it with the admin SDK. |
| `settings/dashboard` **(new, R3)** | doc | `roles` map `{moderator: {cardId: access}, member: {cardId: access}}` with `access ∈ hidden\|on\|off\|required`, `version` int ≥ 1, `updatedAt` | **`financeManager(f)` write**; all active members read. Audited `family.dashboard_policy_updated`. Not a security boundary (F-18): rules check shape and size only; the app mapper ignores unknown ids and values. |
| `settings/engagement` | doc | `enabled` (true), `startedOn` dateKey, `celebrationEnabled` (true), `showHelpersHighlight` (false), **`statsVisibility` `'private'\|'levels'` (`'private'`)**, `pointBases{easy,normal,hard}` (10/20/30), `latePermille` (600), `verifiedPermille` (1200), `coverBonusPermille` (500), `levels` list ≤ 12 `{id,minPoints,nameBn,nameEn}`, `badgeThresholds{consistentDays 7, reliablePercent 90, reliableMinDone 10, helperCovers 3, detailCount 10}`, `specVersion` | Scoring fields: manager/admin write. **`statsVisibility`: admin only** (rules compare old and new value: only an admin may change that single key). Audited `engagement.settings_updated`, and `engagement.privacy_updated` for the visibility key. |
| `memberStats/{uid}` | member uid | `totalPoints`, `level`, `completedTotal`, `onTimeTotal`, `coversTotal`, `verifiedCleanTotal`, `streak{current,best,asOfDateKey,pausedDays}`, `badges{badgeId→{earnedAt,monthKey?}}` ≤ 12, `monthly{monthKey→{points,done,onTime,covers,verifiedClean,final,specVersion}}` ≤ 40, `processedThrough`, `lastCelebratedDateKey`, `startedOn`, **`sharing` bool (false)** | **Owner read/write only. No exception for admins.** Monotonic and bounded (P4-19). |
| `memberStatsPublic/{uid}` **(new, R2)** | member uid | `level` int, `badgeIds` list ≤ 12, `updatedAt` | **No points, no streak, no monthly.** Owner write only while `statsVisibility == 'levels'` **and** own `sharing == true`; active members read only while `statsVisibility == 'levels'`; owner may always delete. |
| `notificationInbox` (exists) | random | existing fields + **new type values** `chore_assigned`, `member_approved` (P4-17) | Server-only keys `pushStatus`, `pushAt` are written by the function (admin SDK); the client `hasOnly` lists already forbid them. |
| `pushLedger/{uid_yyyyMMddHH}` **(new, F-20)** | hourly bucket | `count` int | Server-only (rules deny all client access); the function caps pushes per recipient per hour (30). |
| `activity` (exists) | random | existing | New index `(actorId ASC, createdAt DESC)`. |

### 3.3 Permissions → use cases

New `Permission` rows (matrix regenerated in P4-02): **`manageEngagement`** (admin yes, Household Manager yes, member no) and **`manageDashboardLayout`** (admin yes, Household Manager **yes while `moderatorManagesFinance`**, member no). Delivery policy and stats visibility reuse `editFamilySettings` (admin only).

| Use case | Permission checked first |
| --- | --- |
| `UpdateDashboardPolicy` | `manageDashboardLayout` |
| `SaveDashboardPrefs`, `SaveMemberNotificationPrefs`, `SetStatsSharing`, `SyncMemberStats`, `MarkCelebrated`, `MarkInboxRead`, `MarkAllRead`, `RegisterDeviceToken` | owner of the data only (`requireActiveMember` + id equality) |
| `UpdateNotificationDelivery` | `editFamilySettings` (admin) |
| `UpdateNotificationDefaults`, `UpdateEngagementSettings` | `manageEngagement`; changing `statsVisibility` additionally requires `editFamilySettings` |
| Reading activity, inbox (own), dashboard cards | any active member; each card additionally uses the permission of its module |

### 3.4 Write patterns

* **EVERYDAY (batch, queues offline):** `SyncMemberStats`, `MarkCelebrated`, `MarkInboxRead`, `SaveMemberNotificationPrefs`, `SaveDashboardPrefs`, `SetStatsSharing`, `RegisterDeviceToken`.
* **INTEGRITY (with probe, refuses offline):** `UpdateNotificationDelivery`, `UpdateNotificationDefaults`, `UpdateDashboardPolicy`, `UpdateEngagementSettings`.
* Stats writes are idempotent (replace-with-max, finalised months frozen).
* Reminder scheduling and push receipt are **not** Firestore writes: side effects behind ports (`ReminderScheduler`, `PushMessagingService`).

### 3.5 Provider graph

```text
sessionProviders (family, member, modules) ─► visibleModulesProvider
dashboardPolicyProvider (settings/dashboard, defaults when absent) ┐
dashboardPrefsProvider  (local + synced user prefs)                ├─► dashboardLayoutProvider = DashboardResolver.resolve(...)
cardCatalogProvider (module specs) · ref.can · module flags        ┘      → ordered visible cards (+ hidden-by-user list for the Customize screen)
existing: monthItemsProvider(m) · todayItemsProvider · todayProgressProvider · templateIndexProvider · choreSettingsProvider · bazar providers

deliveryPolicyProvider (settings/notificationDelivery) ─► effectiveModeProvider(typeId) = DeliveryPolicy.effective(type, policy, pushCapabilityProvider)
pushCapabilityProvider = { tokenRegistered, permissionGranted, policy.pushEnabled }
reminderSettingsProvider = merge(familyDefaultsProvider, memberPrefsProvider)
reminderPlanInputProvider = (nowTick(15 min), monthItemsProvider, templateIndexProvider, reminderSettings, effective modes, bazarSettings, locale)
reminderPlanProvider = ReminderPlanner.plan(input)  (pure)
reminderSyncController ── diff vs scheduler.pending() ──► ReminderScheduler (single-flight, debounced 2 s)
pushController ── token register/refresh, foreground messages ──► PushMessagingService ──► ForegroundNotificationBridge (dedupe by inboxId)
inboxProvider + virtualInboxProvider → mergedInboxProvider → unreadInboxCountProvider → bell
recentActivityProvider(limit 5) · activityFeedProvider (paged 30)
engagementSettingsProvider · memberStatsProvider (own doc) · publicStatsProvider (only while visibility == levels)
statsSyncController ──► SyncMemberStats ──► memberStats (and memberStatsPublic when sharing)
celebrationControllerProvider · helpersProvider(month) = CoverCounter over monthItemsProvider
```
Rules: (1) screens call use-case providers, never repositories; (2) numbers come from pure classes or existing derived providers; (3) `now` only through `clockProvider` / `nowTickProvider`; (4) one listener per data set; (5) **only `DashboardResolver` decides which cards show and in which order**; (6) **only `DeliveryPolicy` decides push vs normal**.

### 3.6 Stable failure codes (map in `engagementFailureMessage` / `notificationFailureMessage` / `dashboardFailureMessage`, bn + en)

`Validation`: `invalid_minutes`, `invalid_offsets`, `too_many_offsets`, `invalid_quiet_hours`, `invalid_levels`, `levels_not_ascending`, `too_many_levels`, `invalid_threshold`, `invalid_points`, `invalid_permille`, `unknown_card`, `invalid_access`, `unknown_notification_type`, `type_not_push_capable`, `invalid_visibility`.
`Conflict`: `permission_denied_by_os`, `exact_alarm_denied`, `scheduler_unavailable`, `push_unavailable`, `stats_not_owner`, `stats_regression` (blocked, logged not shown), `engagement_disabled`, `already_celebrated`, `sharing_not_allowed`.
`NotFound`: `inboxItem`, `memberStats`.

### 3.7 UI conventions for every Phase 4 screen

Same as Phase 3 §3.7 (tokens only, `LoadingView` → data / `EmptyState` / `ErrorView(onRetry)`, status = icon + label + colour, ARB bn + en + generated files, scale 2.0, ≥ 48 dp). Additional rules:
* A dashboard card never shows a spinner outside its own area: use `DashboardCardFrame`.
* Painters take colours as constructor arguments; animation lengths come from `engagementMotion(context)` (zero under `disableAnimations`).
* **Drag and drop always has a non-drag alternative** (Move up / Move down buttons or semantic actions).
* ARB prefixes: `dashboard*`, `greeting*`, `activity*`, `inbox*`, `reminder*`, `notif*`, `push*`, `engagement*`, `hubLevel*`, `badge*`, `celebration*`.

### 3.8 Indexes to add

`activity (actorId ASC, createdAt DESC)`. Nothing else: policy and stats are document reads.

### 3.9 Audit vocabulary added in P4-02 (Dart `AuditEventType` **and** rules `eventTypes()`/`refTypes()`)

| `type` | `refType` | Written by |
| --- | --- | --- |
| `family.notification_defaults_updated` | `notificationSettings` | UpdateNotificationDefaults |
| `family.notification_delivery_updated` | `notificationSettings` | UpdateNotificationDelivery |
| `family.dashboard_policy_updated` | `dashboardSettings` | UpdateDashboardPolicy |
| `engagement.settings_updated` | `engagementSettings` | UpdateEngagementSettings |
| `engagement.privacy_updated` | `engagementSettings` | UpdateEngagementSettings (only when `statsVisibility` changed) |

New `refTypes`: `notificationSettings`, `dashboardSettings`, `engagementSettings`. `activityText` gets all five in bn + en. User-level preferences and stats are **not** audited.

### 3.10 Routes

| Constant | Path | Screen | Step |
| --- | --- | --- | --- |
| `home` (exists) | `/home` | `HomeScreen` | P4-07 |
| `customizeDashboard` | `/settings/dashboard` | `CustomizeDashboardScreen` (every member) | P4-08 |
| `dashboardAccess` | `/settings/dashboard-access` | `DashboardAccessScreen` (`manageDashboardLayout`) | P4-08 |
| `activity` | `/activity` | `ActivityFeedScreen` | P4-04 |
| `inbox` (exists) | `/inbox` | `InboxScreen` | P4-17 |
| `notificationSettings` | `/settings/notifications` | `NotificationSettingsScreen` | P4-16 |
| `notificationDelivery` | `/settings/notifications/delivery` | `DeliveryAdminScreen` (admin) | P4-16 |
| `remindersHelp` | `/settings/notifications/help` | `RemindersHelpScreen` | P4-16 |
| `choresAchievements` | `/chores/achievements` | `AchievementsScreen` | P4-20 |
| `choresEngagementSettings` | `/chores/engagement` | `EngagementSettingsScreen` | P4-20 |

Notification taps (local **and** push) map payloads to existing routes through the single `NotificationTapRouter` (Appendix B.4).

### 3.11 Test pattern for every step

Same table as Phase 3 §3.11. Fixtures: `FakeClock(DateTime.utc(2026,11,2,6))` (Monday 12:00 Dhaka), `FakeReminderScheduler`, `FakePushService`, `InMemoryEngagementBackend`. Before every commit: `dart format .`, `flutter analyze` (zero infos), `flutter test --exclude-tags golden`, rules suite, `node tools/check_indexes.mjs`. Steps touching `functions/` also run `npm test` there.

---

## 4. Execution plan

### 4.1 Dependency table (read this before anything else)

| Step | Title | Type | Depends on | Can run in parallel with |
| --- | --- | --- | --- | --- |
| P4-01 | Preflight gate, ADRs, split oversize files | INDEPENDENT (gate) | Phase 3 tree | — |
| P4-02 | Phase 4 vocabulary: audit, permissions, paths, limits, flags, ARB base | DEPENDENT | P4-01 | P4-03 |
| P4-03 | Shared widgets + gallery | INDEPENDENT | P4-01 | Waves A–C |
| P4-04 | Activity feed | DEPENDENT | P4-02, P4-03 | P4-05, P4-09, P4-18 |
| P4-05 | **Dashboard domain: catalog, access policy, user prefs, resolver (pure)** | DEPENDENT | P4-02 | P4-04, P4-09, P4-18 |
| P4-06 | **Dashboard data: policy doc, prefs sync, rules, use cases** | DEPENDENT | P4-05 | P4-09, P4-10 |
| P4-07 | Home dashboard: card specs, header, cards, listener budget | DEPENDENT | P4-05, P4-06, P4-03 | P4-10 |
| P4-08 | **Customize dashboard (drag and drop) + access-by-role screens** | DEPENDENT | P4-06, P4-07, P4-03 | P4-11 |
| P4-09 | **Notification catalog and delivery policy (pure)** | DEPENDENT | P4-02 | P4-04…P4-08, P4-18 |
| P4-10 | Reminder domain: settings, precedence, planner, explainer (pure) | DEPENDENT | P4-02, P4-09 | P4-04…P4-08 |
| P4-11 | Notification data: delivery policy, defaults, member prefs, rules | DEPENDENT | P4-09, P4-10 | P4-18 |
| P4-12 | Reminder orchestration | DEPENDENT | P4-10, P4-11 | P4-19 |
| P4-13 | Local notification adapter **[DEVICE]** | DEPENDENT | P4-12 | P4-19 |
| P4-14 | **Push client (FCM) [DEVICE]** | DEPENDENT | P4-11, P4-13 | P4-19 |
| P4-15 | **Push backend: Cloud Functions [BLAZE][OWNER]** | DEPENDENT | P4-11, P4-14, owner go/no-go (D-P4-21) | P4-19, P4-20 |
| P4-16 | Notification settings, **admin delivery screen**, help page, "why" line | DEPENDENT | P4-11, P4-13, P4-14, P4-03 | P4-20 |
| P4-17 | Inbox: derived items, bell, two new types, foreground bridge | DEPENDENT | P4-07, P4-13, P4-14 | P4-20 |
| P4-18 | Engagement domain (pure) | DEPENDENT | P4-02 | P4-04…P4-17 |
| P4-19 | **Stats + engagement settings + privacy**: data, rules, use cases | DEPENDENT | P4-18 | P4-12…P4-17 |
| P4-20 | Achievements UI, Hub Level, **privacy controls**, engagement settings | DEPENDENT | P4-19, P4-03, P4-07 | P4-16, P4-17 |
| P4-21 | Celebration domain and controller | DEPENDENT | P4-19 | P4-20 |
| P4-22 | Celebration overlay UI | DEPENDENT | P4-21, P4-20 | — |
| P4-23 | Accessibility and states audit | DEPENDENT | P4-07…P4-22 | P4-24 |
| P4-24 | Tablet layouts | DEPENDENT | P4-07, P4-20 | P4-23 |
| P4-25 | Hardening, read budget, real-device and push tests, UAT, sign-off | DEPENDENT | all | — |
| P4-26 | *(Optional, after the beta)* Scheduled push sweeper **[BLAZE]** | DEPENDENT | P4-15, P4-25 | — |

### 4.2 Recommended order (single developer / single AI)

`P4-01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11 → 12 → 13 → 14 → 15 → 16 → 17 → 18 → 19 → 20 → 21 → 22 → 23 → 24 → 25`

**Why this order:** the role-aware dashboard (P4-05…P4-08) is the quick visible win and needs only existing providers. Notifications follow because they have the longest feedback loop ([DEVICE]); the pure catalog, policy and planner land first and are fully tested before platform code exists. **P4-15 can wait for your Blaze decision without blocking anything else**: until it ships, every type runs as Normal. Engagement is last among features because it reads everything else.
**First working slice = P4-07** (real, role-aware Home). **Second slice = P4-08** (you reorder and hide cards, a manager sets what a Member sees). **Third = P4-13** (a reminder fires with the app closed). **Fourth = P4-15** (a swap request arrives as push on a phone with the app closed).

### 4.3 Parallel lanes (if you run several agents)

| Lane | Steps in order | Folders touched |
| --- | --- | --- |
| **A — Dashboard & activity** | P4-04, P4-05, P4-06, P4-07, P4-08, P4-17 | `features/dashboard`, `features/activity`, `features/notifications` |
| **B — Notifications** (critical path for device tests) | P4-09 → 10 → 11 → 12 → 13 → 14 → 16 | `core/notifications`, `android/`, `features/notifications` |
| **B2 — Push backend** | P4-15 | `functions/`, `firebase/` |
| **C — Engagement** | P4-18 → 19 → 20 → 21 → 22 | `chores/achievements`, `firestore.rules` |
| **D — UI kit** | P4-03 | `shared/widgets`, `app/gallery` |
| **E — Finish** | P4-23, P4-24, P4-25 | whole app |

Conflict hot-spots (append, never reorder): `firestore.rules`, `firestore.indexes.json`, `firestore_paths.dart`, `app_bn.arb` / `app_en.arb` (+ regenerate l10n), `app_routes.dart`, `audit_event_type.dart`, `permission.dart`, `bootstrap.dart` overrides, `preferencesOk` in the rules, `test/contract/rules_fixtures_test.dart`, `gallery_sections_p4.dart`, `AndroidManifest.xml`, `pubspec.yaml`. Merge one lane at a time; re-run `flutter gen-l10n`.

---

## 5. Step cards

Conventions: paths relative to the Flutter project root (`functions/` is a sibling folder with its own `npm` project); `NEW` / `EDIT` / `DELETE`. Hot-spot files are only appended to. Every step ends with the checklist of §3.11.

---

### Wave A — Foundations (P4-01 … P4-03)

#### P4-01 — Preflight gate, ADRs, split oversize files

- **Type:** INDEPENDENT (gate). **Depends on:** Phase 3 tree. **Unblocks:** everything.
- **Why:** F-1 (P3-29/P3-30 were never compiled), F-2 (file-size debt).
- **Files:** EDIT `PROGRESS.md`, `CLAUDE.md`, `docs/ROADMAP.md` (Step 27–31 "re-cut as P4-xx"). NEW `docs/PHASE4_DASHBOARD_ENGAGEMENT_ROADMAP.md` (this file), `docs/decisions/0015-two-delivery-modes-local-and-push.md`, `0016-virtual-inbox-items.md`, `0017-stats-privacy-and-client-side-stats.md`, `0018-custom-painters-no-confetti-package.md`, `0019-dashboard-resolver-and-role-matrix.md`, `0020-push-via-cloud-functions-blaze.md`. NEW `test/architecture/notification_plugin_boundary_test.dart`. EDIT (split only, no behaviour change) the ten files of F-2.
- **Contents:**
  1. **Gate** (paste outputs into `PROGRESS.md` under "P4-01 gate"): `dart format --set-exit-if-changed .` → `flutter pub get` → `flutter gen-l10n` (no diff) → `flutter analyze` → `flutter test --exclude-tags golden` → rules suite → `node tools/check_indexes.mjs`. Red ⇒ fix **only that** in `P4-00: repair base` (P3-29/P3-30 were written without a compiler; expect small compile fixes listed at the end of their PROGRESS sections).
  2. **Phase 3 is not re-specified.** Instead write `docs/phase3_state.md`: a one-page table of what Phase 4 reads (inbox repository, swaps, availability index, `needs_cover_providers`, `todayProgressProvider`, chore dashboard cards) with *works / compile-fixed / broken* after the gate. Anything broken is fixed as `P3-fix-xx` before Phase 4 continues.
  3. **Split the ten oversize files** into `widgets/` or `*_parts.dart` files, no logic change; existing tests stay green; the `file_size_test` allow-list becomes empty.
  4. **CLAUDE.md rules 56–72:** 56 reminders are produced only by `ReminderPlanner` and scheduled only through `ReminderScheduler`; widgets never call a plugin. 57 Notification text is built from ARB keys at planning time (local) or from the function's bn/en table (push). 58 The three reminder switches are resolved only by `ReminderPrecedence`. 59 `memberStats` is owner-only, always; sharing goes only through the points-free `memberStatsPublic`; no audit for stats (ADR 0017). 60 Scoring numbers come from `settings/engagement`. 61 Painters take colours as arguments; animation lengths from `engagementMotion`. 62 Only `flutter_local_notifications`, `android_intent_plus` and `firebase_messaging` may be added in Phase 4. 63 Dashboard visibility and order are decided only by `DashboardResolver`; a card never opens its own listener. 64 Derived inbox items are never written. 65 Celebration at most once per day per member. 66 Every user-visible Phase 4 string has bn + en ARB keys. **67 Hiding a dashboard card is presentation only; access is always `PermissionPolicy` + rules.** **68 Push vs normal is decided only by `DeliveryPolicy`; a type has exactly one effective mode.** **69 The client never sends push and never holds a service account; push is sent only by the Cloud Function.** **70 Push text carries no names, amounts or ids, only a route in `data`.** **71 Drag and drop must have a non-drag alternative.** **72 Stats are never exported or shown to another member except the points-free public card (D-P4-26).**
  5. **Architecture tests:** only `local_notifications_scheduler.dart` / `notification_channels.dart` import `flutter_local_notifications`; only `push_messaging_service.dart` imports `firebase_messaging`; only one file imports `android_intent_plus`.
  6. **ADR 0020** records the Blaze decision and its alternatives (no push; third-party push relay; a self-hosted sender) and why Cloud Functions was chosen **[OWNER]**.
- **Done when:** gate green and recorded; `phase3_state.md` committed; ADRs 0015–0020 exist; rules 56–72 in CLAUDE.md; `file_size_test` green with an empty allow-list.

#### P4-02 — Phase 4 vocabulary

- **Type:** DEPENDENT. **Depends on:** P4-01. **Parallel with:** P4-03.
- **Files:** EDIT `core/audit/audit_event_type.dart`, `audit_ref_type.dart`, `firebase/firestore.rules` (`eventTypes()`, `refTypes()`), `test/contract/audit_vocabulary_mirror_test.dart`, `core/permissions/permission.dart` + `permission_policy.dart` (**`manageEngagement`**, **`manageDashboardLayout`**), `docs/permission_matrix.md`, `core/firebase/firestore_paths.dart` (`dashboardSettings`, `notificationDelivery`, `engagementSettings`, `memberStatsPublic`, `deviceDocs`), `core/firebase/query_limits.dart` (`kMaxActivityPage = 30`, `kMaxDashboardActivity = 5`, `kMaxPointsPerSync = 3000`, `kMaxPlannedNotifications = 60`, `kMaxStatsMonths = 40`, `kMaxDashboardPrefIds = 24`, `kMaxPushPerHour = 30`), `app/router/app_routes.dart` (constants of §3.10; no route registered before its screen exists), NEW `lib/app/feature_flags.dart` (`askAi = false`), `core/localization/app_bn.arb` / `app_en.arb` + generated (module labels, permission labels, failure codes of §3.6, the five audit sentences, notification channel names, level names, dashboard card names).
- **Contents:** vocabulary only; no behaviour. `activityText` for the five new audit types (bn + en). `manageDashboardLayout` policy = admin, or moderator while `moderatorManagesFinance`.
- **Rules / tests:** mirror test green; `permission_policy_test` rows `manageEngagement` and `manageDashboardLayout` × admin / manager (finance on and off) / member / pending / disabled; ARB parity test.
- **Done when:** analyzer clean; matrix doc shows exactly two new rows; `flutter gen-l10n` produces no diff.

#### P4-03 — Shared widgets and gallery

- **Type:** INDEPENDENT. **Depends on:** P4-01. **Unblocks:** P4-04, P4-07, P4-08, P4-16, P4-20.
- **Files (NEW in `lib/shared/widgets/`, data/callback only, no providers):** `dashboard_card_frame.dart` (title, icon, trailing action, body; modes loading skeleton / error with retry / content; whole card tappable, ≥ 48 dp semantics; honours `disableAnimations`), `greeting_header.dart`, `bell_button.dart` (badge with a number and semantic label, caps at "৯+"), `alert_strip.dart`, `activity_tile.dart`, `stat_pill.dart`, `time_offset_chips.dart`, `quiet_hours_picker.dart`, `switch_tile_with_reason.dart`, `level_ring.dart`, `badge_medal.dart` (shape + label, not colour alone), `plant_stage_view.dart` and `confetti_view.dart` (thin wrappers taking a painter and a `reduced` flag), `diagnostic_row.dart`, **`reorderable_card_tile.dart`** (drag handle, title, switch or lock icon, Move up / Move down `CustomSemanticsAction`s, ≥ 48 dp), **`access_cell.dart`** (the 4-state picker for `hidden/on/off/required`, each state = icon + label + colour, disabled state with a reason), **`delivery_mode_tile.dart`** (type name, Push/Normal segmented control, "Recommended" tag, locked state with reason). NEW `lib/app/gallery/gallery_sections_p4.dart` + index entry; EDIT `app_tokens.dart` only if a token is missing.
- **Rules / tests:** widget tests per widget (states, semantics, reduced motion, **semantic move actions fire the callbacks**); gallery overflow tests at scale 2.0 bn/en light/dark pick the sections up automatically; contrast for `badge_medal` and `access_cell` states.
- **Done when:** the gallery renders every new widget without overflow; goldens only on Linux CI.

---

### Wave B — Role-aware dashboard and activity (P4-04 … P4-08)


#### P4-04 — Activity feed

- **Type:** DEPENDENT. **Depends on:** P4-02, P4-03. **Parallel with:** P4-05, P4-09, P4-18. **Unblocks:** P4-07 (recent-activity card).
- **Files:** NEW `features/activity/domain/{activity_entry.dart, activity_repository.dart, activity_filter.dart, usecases/(none: read-only)}`, `data/{activity_mappers.dart, firestore_activity_repository.dart}`, `presentation/{activity_providers.dart, activity_feed_screen.dart, widgets/activity_filter_bar.dart, activity_target.dart}`. EDIT `firebase/firestore.indexes.json` (`activity (actorId, createdAt DESC)`), rules only if the current read rule is not "any active member" **[VERIFY]**, `test/support/screen_states.dart`, router (route `/activity` above the shell), `core/localization/activity_text*.dart`.
- **Contents:**
  - `ActivityEntry {id, type, actorId, params, refType, refId, createdAt}` mapped tolerantly (unknown type ⇒ generic sentence "কিছু একটি পরিবর্তন হয়েছে", never a crash).
  - `recentActivityProvider(limit)` = one listener `orderBy createdAt DESC .limit(limit)`; the dashboard uses limit 5 (`kMaxDashboardActivity`). `activityFeedProvider` pages 30 at a time with `startAfterDocument`; **one** listener for page 1, one-shot `get` for older pages (no growing listener).
  - Filters: **module** (client-side over loaded pages; module = prefix of `type`: `bazar.`, `chores.`, `family.`, `engagement.`) and **member** (server-side `where actorId ==` + the new index). Filter state is in memory.
  - Tap target: `ActivityTarget.from(entry)` maps `refType/refId` to a route (occurrence → detail, expense → expense detail, member → member profile) and returns `null` for deleted/unknown targets (tile is then not tappable).
  - **Completeness test (the roadmap's "exactly one entry" check):** a table-driven test iterates `AuditEventType.all` and fails if any type lacks a bn **and** an en `activityText` sentence, or lacks a `refType`→route mapping decision (explicit "no target" is allowed). A second test runs a representative use case per module against the in-memory backend and asserts exactly one activity entry is written.
- **Interacts with:** `AuditWriter` (unchanged), dashboard card, notification tap routing (Appendix B.4 reuses `ActivityTarget`).
- **Rules / tests:** pager test (page 2 appends, no duplicate listener), filter combinations, empty / error / offline states, bn + en, scale 2.0, rules test: member A cannot read another family's activity.
- **Done when:** `/activity` shows real entries with sentences in both languages and every audit type has text.


#### P4-05 — Dashboard domain: card catalog, access policy, user preferences, resolver (pure)

- **Type:** DEPENDENT. **Depends on:** P4-02. **Parallel with:** P4-04, P4-09, P4-18. **Unblocks:** P4-06, P4-07, P4-08.
- **Why:** R3 and R4. One pure class decides what each person sees and in what order, so the Home screen, the Customize screen, the matrix screen and the tests can never disagree.
- **Files (NEW, `lib/features/dashboard/domain/`, no Flutter, Firebase or Riverpod):** `card_catalog.dart`, `card_access.dart`, `dashboard_policy.dart`, `dashboard_prefs.dart`, `dashboard_resolver.dart`, `dashboard_defaults.dart`. NEW `test/features/dashboard/domain/*`.
- **Contents:**
  - **`DashboardCardDef {id, moduleId ('core'|'bazar'|'chores'), defaultOrder, size (full|half), requiredPermission?}`** and the closed **`CardCatalog`**: `budget_alert` 10, `approvals` 15, `chores_today` 20, `chores_overdue` 30, `chores_verify` 40, `bazar_month` 50, `bazar_fund` 60, `upcoming` 70, `chores_week` 80, `hub_level` 90, `recent_activity` 100. (`approvals` = pending join requests + pending contribution requests, for people who can act on them.)
  - **`enum CardAccess { hidden, on, off, required }`** (D-P4-27) with `parse` tolerant of unknown values (⇒ the catalog default).
  - **`DashboardPolicy {Map<Role, Map<String, CardAccess>> roles, int version}`**; `accessFor(role, cardId)` returns the stored cell or `DashboardDefaults.accessFor(role, cardId)` (Appendix A.3). **Admin is not stored:** `accessFor(admin, …)` is always `on`.
  - **`DashboardPrefs {List<String> order, Set<String> hidden, Set<String> shown}`**; `moveCard(id, newIndex)`, `setVisible(id, visible, access)`, `reset()`.
  - **`DashboardResolver.resolve({role, policy, prefs, modulesEnabled, can(permission)}) → DashboardLayout {List<ResolvedCard> visible, List<ResolvedCard> optionalHidden, List<ResolvedCard> required}`**. Rules, in this order:
    1. Drop a card whose module is off, or whose `requiredPermission` the viewer lacks, or whose access is `hidden`.
    2. `required` ⇒ visible and `canHide = false`.
    3. `on` ⇒ visible unless the id is in `prefs.hidden`.
    4. `off` ⇒ hidden unless the id is in `prefs.shown`.
    5. Order = ids in `prefs.order` that survived steps 1–4, then the remaining visible cards by `defaultOrder`; a **new `required` card with no stored position goes to the top**.
    6. Ids in the prefs that are not allowed now are ignored but **not deleted** (F-17); a role change or a policy change simply re-resolves.
    7. Admin: every catalog card with a met permission is available; admin prefs apply as for others.
  - `DashboardLayout.optionalHidden` feeds the Customize screen ("cards you can add back").
- **Rules / tests (≥ 30 cases, Appendix F.4):** each access state × each role; permission missing for an `on` cell; module off; prefs ordering with unknown / stale ids; new required card placement; role change keeps dormant prefs; admin cannot be locked out; idempotence; policy with unknown card ids ignored.
- **Done when:** F.4 green; no Flutter / Firebase import in `features/dashboard/domain` (architecture test).

#### P4-06 — Dashboard data: policy document, user preferences, sync, rules

- **Type:** DEPENDENT. **Depends on:** P4-05. **Parallel with:** P4-09, P4-10. **Unblocks:** P4-07, P4-08.
- **Files:** NEW `features/dashboard/data/{dashboard_policy_mappers.dart, firestore_dashboard_policy_repository.dart, local_dashboard_prefs_store.dart, firestore_dashboard_pref_sync.dart}`, `features/dashboard/domain/usecases/{update_dashboard_policy.dart, save_dashboard_prefs.dart}`, `features/dashboard/presentation/dashboard_providers.dart` (`dashboardPolicyProvider`, `dashboardPrefsProvider`, `dashboardLayoutProvider`, `updateDashboardPolicyProvider`, `saveDashboardPrefsProvider`); EDIT `firebase/firestore.rules` (`settings/dashboard` with `dashboardPolicyOk`; `preferencesOk` accepts a bounded `dashboard` map), NEW `rules_test/dashboard_settings.test.mjs`, `test/contract/rules_key_sets_test.dart`, fixtures, `bootstrap.dart` (sync override).
- **Contents:**
  - **`settings/dashboard` rules:** read for active members; create/update only `verified() && financeManager(f) && writesAsSelf()`; key set `{roles, version, updatedAt + BaseMapper}`; `roles` is a map whose keys ⊆ `{moderator, member}`; each role map `size() ≤ 16`; `version` int ≥ 1 and **increases by exactly one** on update; no delete. The rules do not verify cell values (F-18: this is presentation policy).
  - **`UpdateDashboardPolicy`** (INTEGRITY): requires `manageDashboardLayout`; validates every id against `CardCatalog` (`unknown_card`) and every value (`invalid_access`); refuses a cell that would grant a card whose permission the role never has (informational: UI already disables it); writes policy + audit `family.dashboard_policy_updated` in one batch; **never accepts an `admin` key**.
  - **`SaveDashboardPrefs`** (EVERYDAY): validates `order/hidden/shown` sizes (`kMaxDashboardPrefIds`), writes the local store first (instant), then mirrors to `users/{uid}.preferences.dashboard` through `PreferenceSync` (local wins at startup; remote applied once per sign-in).
  - `preferencesOk` extension: `dashboard` is a map, the three lists are lists of strings with `size() ≤ 24`, each string ≤ 40 chars (check first and last element; the app tolerates malformed entries).
  - Mapper tolerance: unknown cards ⇒ ignored; unknown access ⇒ default; absent doc ⇒ pure defaults (no write at family creation, no backfill).
- **Rules / tests:** use-case validation table; mapper tolerance; local-wins sync test; rules: admin ✔; Household Manager ✔ **only while `moderatorManagesFinance` is true** and ✘ when it is false; member ✘; `version` jump ✘; `admin` role key ✘; oversize map ✘; user prefs owner ✔ / other member ✘.
- **Done when:** `dashboardLayoutProvider` re-emits when the policy changes on another device and when the user saves prefs.

#### P4-07 — Home dashboard: card specs, header, cards, listener budget

- **Type:** DEPENDENT. **Depends on:** P4-05, P4-06, P4-03 (P4-04 for the activity card). **Parallel with:** P4-10. **Unblocks:** P4-08, P4-17, P4-20, P4-24.
- **Files:** NEW `features/dashboard/domain/{dashboard_card_spec.dart, greeting.dart, dashboard_refresh.dart}`, `features/dashboard/presentation/{home_screen.dart (EDIT), dashboard_header.dart, dashboard_grid.dart, widgets/{recent_activity_card.dart, upcoming_card.dart, approvals_card.dart, ask_ai_entry.dart}}`; EDIT `modules/family_module.dart` (`List<DashboardCardSpec> get dashboardCardSpecs`, default wraps the old `dashboardCards` so nothing breaks), `features/bazar/bazar_module.dart`, `features/chores/chores_module.dart` (return specs keyed by the catalog ids), `app/feature_flags.dart` use, `test/support/screen_states.dart`.
- **Contents:**
  - **`DashboardCardSpec {id, builder(context, ref)}`** only; **order, size and visibility come from `CardCatalog` + `DashboardResolver`** (the old per-spec `order` and `requiredPermission` fields are gone). `dashboardCardsProvider` = resolver output joined to the specs by id; an id with no spec is skipped silently (and logged in debug).
  - **Header:** `GreetingHeader` — greeting by day part via ARB, nickname, avatar (tap → profile), `BellButton` bound to `unreadInboxCountProvider`, and a **"Customize" menu entry** (→ `/settings/dashboard`; managers also see "Dashboard access by role").
  - **Cards** (existing providers; see Appendix A.2): Today (`todayProgressProvider`), Overdue, Awaiting verification, Month spend vs budget, Fund balance / contribution status, Upcoming (mine, next 3), This week, Recent activity (`recentActivityProvider(5)`), Approvals (join requests + contribution requests, built from existing providers), Budget alert strip, Hub Level (stub until P4-20).
  - **Pull to refresh:** `DashboardRefresh.run(ref)` = `EnsureOccurrences` (if marker stale) + invalidate one-shot providers + request a reminder re-plan + run `SyncMemberStats` once; streams update themselves; offline ⇒ snackbar only for the server part.
  - **Ask-AI:** `AskAiEntry` only when `FeatureFlags.askAi` is true (const false); test asserts absence.
  - Layout: one column on phones; `half` cards pair in two columns ≥ 600 dp (full tablet treatment in P4-24). Flavour label only when `flavorProvider != prod`.
  - **Empty dashboard** (a member whose role sees no cards, or every card hidden): `EmptyState` with a "Customize" button, never a blank screen.
- **Rules / tests:** **visibility matrix by role** (admin / Household Manager with finance on and off / member) × module on/off × policy cells; **listener-count test** (D-P4-14): a counting spy asserts ≤ 7 data listeners after the Home tab settles and 0 extra when switching tabs and back; per-card error isolation; skeleton → data; goldens 2 themes × 2 languages; `no_unbounded_queries` green; `no_role_checks_in_ui` green (visibility only through the resolver).
- **Done when:** **First working slice:** Home shows real numbers only; a Member and a Household Manager see different cards; every card is tappable; the listener budget test passes.

#### P4-08 — Customize dashboard (drag and drop) and access-by-role screens

- **Type:** DEPENDENT. **Depends on:** P4-06, P4-07, P4-03. **Parallel with:** P4-11.
- **Files:** NEW `features/dashboard/presentation/{customize_dashboard_screen.dart, dashboard_access_screen.dart, dashboard_access_controller.dart, customize_dashboard_controller.dart}`; EDIT router (`/settings/dashboard`, `/settings/dashboard-access`), Family settings hub tiles ("Customize dashboard" for everyone; "Dashboard access by role" behind `PermissionGate(manageDashboardLayout)`), ARB, gallery.
- **Contents:**
  - **Customize dashboard (every member, R4):** a `ReorderableListView` of the cards the viewer may see, one `ReorderableCardTile` per card: drag handle, localized name, a **switch** for optional cards (state from `canHide`), a **lock icon + "Required"** label for `required` cards (no switch), and a section "Hidden cards" listing `optionalHidden` with an "Add back" action. **Move up / Move down** semantic actions and visible buttons in a long-press menu (rule 71). Changes apply immediately through `SaveDashboardPrefs` (EVERYDAY, offline-safe) with a `SyncBanner`; "Reset to default" asks for confirmation and clears `order/hidden/shown`. A short note: "Only you see this layout."
  - **Dashboard access by role (admin / finance manager, R3):** a matrix: rows = catalog cards (localized names), columns = **Household Manager** and **Member**; the Admin column is shown fixed ("always") so nobody wonders. Each cell is an `AccessCell` with the four states (**Hidden / Visible / Off by default / Required**); a cell is **disabled with a reason** when the role lacks the permission the card needs ("Members cannot verify chores"). A banner states F-18 in plain words: "Hiding a card does not remove access to the data; permissions do that." One Save bar, dirty guard, "Reset to recommended" (Appendix A.3), INTEGRITY offline message. **Preview as:** a segmented control that renders the resolver output for the chosen role so the manager sees the result before saving (pure call, no data).
  - Everything behind `PermissionGate` where family-level; the Customize screen needs no permission.
- **Rules / tests:** widget tests: drag reorders and persists; switch hides and the card appears under "Hidden cards"; required card has no switch; semantic move actions reorder; reset; matrix cell disabled when the permission is missing; preview matches `DashboardResolver` for each role; a member cannot open the matrix route (redirect); bn/en/dark/scale 2.0; two-device test: a policy change on device B re-resolves device A's Home without restart.
- **Done when:** **Second working slice:** you drag a card to the top and hide another on your phone and Home follows after restart; a Household Manager sets "Fund balance = Hidden" for Members and a Member's Home loses the card.

---


### Wave C — Notifications: Normal (local) and Push (FCM) (P4-09 … P4-17)

#### P4-09 — Notification catalog and delivery policy (pure)

- **Type:** DEPENDENT. **Depends on:** P4-02. **Parallel with:** P4-04…P4-08, P4-18. **Unblocks:** P4-10, P4-11.
- **Why:** R1. The decision "push or normal" must live in one tested place (rule 68), and the catalog is the list the admin screen shows.
- **Files:** NEW `lib/core/notifications/domain/{notification_type.dart, delivery_policy.dart}`; NEW `test/core/notifications/{notification_type_test.dart, delivery_policy_test.dart}`.
- **Contents:**
  - **`NotificationType {id, category (chores|bazar|family), kind (event|scheduled|derived), pushCapable, recommendedMode, userMutable, labelKey}`** and the closed catalog of **Appendix B.7** (18 types). `pushCapable == (kind == event)` in Phase 4 (D-P4-25).
  - **`enum DeliveryMode { normal, push }`**; **`DeliveryPolicySettings {pushEnabled, Map<String, DeliveryMode> modes}`** with `defaults()` = the recommended column; an unknown id or a non-push-capable id set to `push` is ignored.
  - **`DeliveryPolicy.effective({type, settings, capability}) → EffectiveDelivery {mode, reason}`**, `reason ∈ {pushChosen, normalChosen, masterOff, notPushCapable, backendUnavailable, noPermission, noToken, memberOptedOut}`. `capability = {tokenRegistered, osPermissionGranted, memberPushEnabled}`. **Push is effective only if** the type is push-capable **and** the admin chose Push **and** the master switch is on **and** (for the viewer's own planning) the phone can receive it; otherwise the effective mode is Normal with the reason (this is the graceful fallback of D-P4-21).
  - `NotificationTypes.forInbox(String inboxType)` maps the stored inbox types to catalog ids (the function and the app share this table through `functions/src/delivery_policy.ts`, kept in sync by a contract test that compares both id lists).
- **Rules / tests:** table-driven (≥ 25 cases): every type × master on/off × admin choice × capability; scheduled type forced to Normal; unknown id ignored; defaults equal the recommended column; fallback reasons are exact; the id list equals `InboxType.all` plus the two new types plus the trigger-based types.
- **Done when:** green; `core/notifications/domain` has no Flutter, Firebase or `features/` import.


#### P4-10 — Reminder domain (pure)

- **Type:** DEPENDENT. **Depends on:** P4-02, P4-09. **Parallel with:** P4-04…P4-08. **Unblocks:** P4-11, P4-12.
- **Files:** NEW under `lib/core/notifications/domain/` (see §3.1): `reminder_settings.dart`, `reminder_precedence.dart`, `planned_notification.dart`, `notification_id_factory.dart`, `reminder_planner.dart`, `reminder_explainer.dart`, `reminder_scheduler.dart` (port), NEW `test/support/fake_reminder_scheduler.dart`.
- **Contents:**
  - `ReminderSettings {globalEnabled, categories {chores, bazar, family}, defaultOffsetsMinutes, overdueEnabled, overdueAfterMinutes, morningSummary {enabled, minutes}, quiet {enabled, startMinutes, endMinutes}}` with `inheritFrom(familyDefaults)`; every switch off keeps its timings (D-P4-5).
  - `ReminderPrecedence.resolve({settings, category, templateConfig}) → PrecedenceResult {fires, offsets, overdue, reason}` where `reason ∈ {globalOff, categoryOff, templateOff, templateNoTimings, ok}`.
  - `ReminderPlanner.plan(PlanInput) → List<PlannedNotification>`; `PlanInput {now, windowDays = 7, viewerId, items (ChoreItem), templateIndex, settings, bazar {contributionDueDay, unpaidThisMonth, canCloseMonth, monthEndKey}, familyTz, l10n strings resolver}`. Rules:
    1. **Chore reminders** only for items where `assigneeId == viewerId`, effective status `scheduled|in_progress`, not skipped/projected-past, not unavailable-derived-neutral, `dueAt` within the window.
    2. Per item: *at due* (`dueAt`), *before due* (`dueAt − offset` for each offset, ≤ 5), *overdue once* (`dueAt + overdueAfter`) when enabled. Template `ReminderConfig.enabled` wins over defaults; a template with `enabled == false` suppresses **only itself**; with `enabled == true` and no offsets and `atDue == false` ⇒ `templateNoTimings` (nothing).
    3. Items with no `dueMinutes` (due at end of day) use `endOfDay` as `dueAt`, and "at due" is replaced by a **gentle evening nudge** at the family's `eveningNudgeMinutes` (fixed 1140 = 19:00) only if the item is still open (scheduled once; documented).
    4. **Morning summary:** one per day in the window at `morningSummary.minutes`, text "আজ N টি কাজ" built from the items due that day; omitted when N = 0; recomputed on each plan.
    5. **Bazar:** *contribution due* at 09:00 on `contributionDueDay` (and one day before) when the viewer has an unpaid plan; *month-end* reminder at 18:00 on the last day for members with `closeBazarMonth`. Category `bazar` switch applies.
    6. **Quiet hours:** a notification whose time falls inside `[start, end)` (wrap-around aware) is moved to `end`; if the moved time is later than `dueAt + 6 h` for chores it is dropped (stale). The morning summary is never moved earlier than `quiet.end`.
    7. Past times (`< now + 5 s`) are dropped; the result is sorted ascending, capped at `kMaxPlannedNotifications` (nearest first), ids are deterministic: `NotificationIdFactory.of(kind, refId, discriminator)` = FNV-1a 32-bit masked to 31 bits; a duplicate id inside one plan is probed `+1` until unique.
    8. Title/body come from an injected `ReminderTexts` interface (ARB-backed in the app, a fake in tests) so the planner stays pure; payload = route string (Appendix B.4).
  - `ReminderExplainer.explain(item, settings, templateConfig, now) → ReminderExplanation {willFire, nextAt?, reasons[]}`: the "why am I (not) getting this?" line, built from the same `ReminderPrecedence` + planner internals so the two cannot disagree.
  - **Delivery modes (v2):** `PlanInput` also takes `effectiveModes` (resolved by `DeliveryPolicy`, P4-09). A type whose effective mode is **Push** produces **no local notification** (F-16); `ReminderExplainer` then says "পাঠানো হবে পুশ হিসেবে / delivered as push". Scheduled types are always Normal (D-P4-25).
- **Interacts with:** nothing outside `core/` at this step (pure). `ChoreItem` is a dependency of the planner **input type only**: to keep `core/` free of `features/`, the planner takes its own small `PlannableChore {id, templateId, dueAt, status, assigneeId, nameBn, nameEn, categoryHint}` and a mapper in `features/chores` converts `ChoreItem` → `PlannableChore` (P4-12).
- **Rules / tests:** Appendix F.1 (≥ 35 cases): quiet hours (wrap-around 23:00–06:00), multiple offsets, overdue reminder, a disabled template suppressing only itself, global off keeps timings, assignment change (item no longer mine ⇒ not planned), 7-day cap and 60-item cap, id stability and collision probe, end-of-day nudge, morning summary count, Dhaka midnight, dropped-stale rule, deterministic ordering, idempotence (same input ⇒ identical output).
- **Done when:** F.1 green; `core/notifications/domain` has no Flutter, Firebase or `features/` import (architecture test).


#### P4-11 — Notification data: delivery policy, family defaults, member preferences

- **Type:** DEPENDENT. **Depends on:** P4-09, P4-10. **Parallel with:** P4-18. **Unblocks:** P4-12, P4-14, P4-15, P4-16.
- **Files:** NEW `features/notifications/domain/{notification_delivery_settings.dart, notification_defaults.dart, member_notification_prefs.dart, usecases/{update_notification_delivery, update_notification_defaults, save_member_notification_prefs}.dart}`, `data/{delivery_mappers, notification_defaults_mappers, firestore_delivery_repository, firestore_notification_defaults_repository, local_notification_prefs_store, firestore_notification_pref_sync}.dart`, `presentation/notification_providers.dart` (`deliveryPolicyProvider`, `effectiveModeProvider`, `familyDefaultsProvider`, `memberPrefsProvider`, `reminderSettingsProvider`, use-case providers); EDIT `firebase/firestore.rules` (`settings/notificationDelivery` **admin only**; `settings/notificationDefaults` key set + `notificationDefaultsOk`, manager/admin write; `preferencesOk` accepts a bounded `notifications` map), NEW `rules_test/notification_settings.test.mjs`, `test/contract/rules_key_sets_test.dart`, fixtures, `family_mappers.dart` (seeded doc stays `{enabled:true}`; new fields default per field).
- **Contents:**
  - **`settings/notificationDelivery`** (R1, D-P4-24): `{pushEnabled, modes}`; rules: read for active members; create/update **only `isAdmin(f)`** + `writesAsSelf()`; `pushEnabled` bool; `modes` map with `size() ≤ 20` and every value in `['push','normal']` for the keys the rules know (ids are a fixed list, checked with `hasOnly` on the known push-capable ids); no delete. Absent doc ⇒ `DeliveryPolicySettings.defaults()` with `pushEnabled = false`.
  - **`UpdateNotificationDelivery`** (INTEGRITY): permission `editFamilySettings`; validates `unknown_notification_type` and **`type_not_push_capable`** (a scheduled/derived id set to `push` is rejected, not silently stored); audits `family.notification_delivery_updated`; "Reset to recommended" is just `defaults()` written back.
  - **Per-member:** `SaveMemberNotificationPrefs` writes the local store first, then mirrors to `users/{uid}.preferences.notifications` via `PreferenceSync` (local wins). Includes the member's own `pushEnabled` switch (default on) and quiet hours; the function honours both (P4-15).
  - Per-field fallback in mappers (absent family field ⇒ table default; absent member field ⇒ family value). Validation: offsets 1..1440 ≤ 5 unique, quiet start ≠ end, minutes 0..1439.
- **Rules / tests:** use-case validation table (incl. `type_not_push_capable`), mapper tolerance, sync precedence (local wins), rules: **admin ✔, Household Manager ✘ for `notificationDelivery`**, member ✘; manager ✔ for defaults; owner ✔ / other ✘ for the preferences map; oversize ✘; unknown mode value ✘.
- **Done when:** `reminderSettingsProvider` merges defaults with member overrides, and `effectiveModeProvider('swap_request')` returns Normal/`masterOff` on a fresh family and Push once an admin turns the master switch on and the phone has a token.


#### P4-12 — Reminder orchestration

- **Type:** DEPENDENT. **Depends on:** P4-10, P4-11. **Parallel with:** P4-19. **Unblocks:** P4-13, P4-16.
- **Files:** NEW `features/notifications/presentation/reminder_providers.dart`, `reminder_sync_controller.dart`, `lifecycle_observer.dart`, `reminder_diagnostics.dart`, `reminder_plan_providers.dart`, `reminder_texts.dart`; NEW `features/chores/presentation/plannable_chore_mapper.dart` (`ChoreItem` → `PlannableChore`); NEW `features/bazar/presentation/bazar_reminder_input.dart`; EDIT `bootstrap.dart` (start the controller once per signed-in active family; stop on sign-out / leave family), `test/support/fake_reminder_scheduler.dart`.
- **Contents:**
  - `reminderPlanInputProvider` reads: `monthItemsProvider(current)` (+ `monthItemsProvider(next)` **only** while the 7-day window crosses the month end), `templateIndexProvider`, `reminderSettingsProvider`, `bazarSettingsProvider` + contribution status, `familyDateKeysProvider`, the locale/digit setting, and a 15-minute tick (not the 60 s overdue tick). `reminderPlanProvider` is the pure planner result.
  - `ReminderSyncController` (single-flight, 2 s debounce): `sync()` = `scheduler.pending()` → diff by id **and** a content hash (title/body/time) → `cancel(stale)` + `schedule(new/changed)`; stores `lastPlanHash` to skip no-ops. Triggers: app start, `AppLifecycleState.resumed`, plan change, settings change, locale change (D-P4-25), timezone change (compare `flutter_timezone` result with the stored one on resume), pull-to-refresh, after `EnsureOccurrences`. **Sign-out / leaving a family / disabling Chores or Bazar ⇒ `cancelAll()`** for that category.
  - Failure handling: scheduler errors never crash the app; they set `reminderDiagnosticsProvider.lastError` and the help page shows it (P4-16).
  - Offline-safe: planning only uses cached data; a pending Firestore write does not block it.
  - **Delivery policy (v2):** the plan input includes `effectiveModeProvider` for every type; a change of the admin delivery policy, of the master switch, or of the device's push capability triggers a re-plan (cancel the now-Push ids, schedule the now-Normal ones).
- **Interacts with:** `ReminderScheduler` port (fake in tests), `monthItemsProvider` retention (no new listener), `EnsureOccurrences`.
- **Rules / tests:** with `FakeReminderScheduler`: edit a template's offsets ⇒ exactly the affected ids replaced; reassign an item away ⇒ its ids cancelled; switch off the chores category ⇒ chores ids cancelled, bazar ids kept; switching language ⇒ texts re-planned; debounce coalesces 10 rapid changes into one sync; sign-out cancels all; no sync storm on resume (hash equal ⇒ zero calls).
- **Done when:** the fake scheduler shows the correct pending set for every scenario above.


#### P4-13 — Platform adapter [DEVICE]

- **Type:** DEPENDENT. **Depends on:** P4-12. **Parallel with:** P4-19. **Unblocks:** P4-14, P4-16, P4-17.
- **Files:** EDIT `pubspec.yaml` (`flutter_local_notifications`, `android_intent_plus`; **[VERIFY]** resolved versions with `flutter pub add`, commit `pubspec.lock`, record in `PROGRESS.md`), `android/app/build.gradle*` (core-library desugaring + `desugar_jdk_libs` as required by the plugin README; confirm `compileSdk`/`minSdk` against the plugin), `android/app/src/main/AndroidManifest.xml`, `android/app/proguard-rules.pro` (keep rules the plugin README requires for release/R8), NEW `android/app/src/main/res/drawable/ic_stat_family_hub.xml` (monochrome small icon), NEW `core/notifications/data/{local_notifications_scheduler.dart, notification_channels.dart, notification_tap_router.dart}`, EDIT `bootstrap.dart` (initialise plugin + `tz` database + location), `main_dev.dart`/`main_prod.dart` if the initialiser is flavour-specific.
- **Contents:**
  - **Manifest:** `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE`, and the plugin's `ScheduledNotificationReceiver` / `ScheduledNotificationBootReceiver` (+ `ActionBroadcastReceiver` if actions are used). **[VERIFY]** the exact snippet in the current plugin README, and Play policy for `SCHEDULE_EXACT_ALARM` (F-12).
  - **Channels** (Appendix B.1): `chores_due` (high), `chores_overdue` (default), `daily_summary` (default), `bazar` (default), `family` (default); names/descriptions from ARB; created at initialise; users can tune them in system settings.
  - **`LocalNotificationsScheduler implements ReminderScheduler`:** `schedule(PlannedNotification)` → `zonedSchedule` with `tz.TZDateTime.from(whenUtc, tz.getLocation(familyTz))`, `AndroidScheduleMode.exactAllowWhileIdle` when exact alarms are allowed else `inexactAllowWhileIdle`, `payload = route`; `cancel(ids)`, `cancelAll()`, `pending()` (reads `pendingNotificationRequests`), `showNow(...)`, `permissionState()` (`notificationsGranted`, `exactAlarmGranted`), `requestNotifications()`, `requestExactAlarms()`, `diagnostics()` (permission states, pending count, next fire time, last error, Android SDK int), `openBatterySettings()` / `openExactAlarmSettings()` via `android_intent_plus`.
  - **Permission flow:** never at first launch. The first request happens from the notification settings screen (P4-16) or the first time a template enables reminders, with a one-screen explanation before the system dialog; "denied" shows the help page link; "permanently denied" offers the system settings intent.
  - **Tap routing:** `getNotificationAppLaunchDetails` for cold start and the response callback for warm start both call `NotificationTapRouter.go(payload)`, which validates the payload against an allow-list of route prefixes (`/chores/`, `/bazar/`, `/inbox`, `/activity`, `/settings/notifications`) before `router.go`; a payload for a module that is now off falls back to `/home`.
  - **Reboot / update:** rely on the plugin boot receiver for already scheduled items; additionally the controller re-syncs on every app start (diff makes it cheap).
  - **Shared with push (v2):** the notification tap router, the allow-list of B.4 and the Android 13 `POST_NOTIFICATIONS` explanation screen are written once here and reused by P4-14; the channel list of B.1 includes `push_events` (created in P4-14).
- **Interacts with:** the orchestrator (P4-12) and settings screens (P4-16).
- **Rules / tests:** adapter unit tests with a mocked plugin interface for id/time conversion and payload validation (Dhaka offset, no DST); tap-router allow-list table; architecture test (only this file imports the plugin). **[DEVICE] manual checklist** `docs/reminders_manual_test.md` (Appendix H): schedule a 2-minute reminder with the app swiped away; battery saver on; after reboot; after changing device timezone and back; Android 12, 13 and 14+ behaviour; two phone brands with aggressive battery managers.
- **Done when:** a reminder fires at its configured offset on a real Android phone with the app closed; disabling one template's reminders suppresses only that template.


#### P4-14 — Push client (FCM) [DEVICE]

- **Type:** DEPENDENT. **Depends on:** P4-11, P4-13. **Parallel with:** P4-19. **Unblocks:** P4-15, P4-16, P4-17.
- **Why:** R1. The phone side of push: permission, token, receiving, tapping. It works against the Firebase **emulator and a manual test message** even before the backend of P4-15 exists, and costs nothing on Spark (receiving FCM is free).
- **Files:** EDIT `pubspec.yaml` (`firebase_messaging` — **[VERIFY]** the version compatible with `firebase_core 5.0.0`; commit `pubspec.lock`; record in `PROGRESS.md`), `android/app/src/main/AndroidManifest.xml` (`com.google.firebase.messaging.default_notification_channel_id` = `push_events`, default small icon `ic_stat_family_hub`, default colour), NEW `core/notifications/data/{push_messaging_service.dart, device_token_repository.dart}`, NEW `core/notifications/presentation/{push_controller.dart, push_providers.dart}`, EDIT `notification_channels.dart` (add channel `push_events`, importance high), `notification_tap_router.dart` (accept the FCM `data.route`), `bootstrap.dart` (register the top-level background handler `@pragma('vm:entry-point')`, start `PushController` after sign-in), `firebase/firestore.rules` (**`users/{uid}/devices/{deviceId}`**: owner read, create, update, **delete**; key set and size checks; nobody else), NEW `rules_test/devices.test.mjs`, NEW `test/support/fake_push_service.dart`.
- **Contents:**
  - **`PushMessagingService`** (port + the only `firebase_messaging` importer): `requestPermission()`, `getToken()`, `onTokenRefresh`, `onForegroundMessage`, `onOpenedApp`, `getInitialMessage()`, `deleteToken()`. Android 13+ uses the same `POST_NOTIFICATIONS` runtime permission as local notifications (one explanation screen for both, never at first launch).
  - **Device registration:** a stable local install id `deviceId` (random, stored in `SharedPreferences`); `RegisterDeviceToken` (EVERYDAY) writes `users/{uid}/devices/{deviceId} {token, platform:'android', lang, appVersion, flavor, createdAt, lastSeenAt}` on sign-in, on token refresh, on language change and at most once per day on resume; **sign-out and leaving the family delete this device's doc and the FCM token** (F-19).
  - **Receiving:** while the app is in the **background or closed**, a message with a `notification` block is shown by the system (no Dart code runs); while in the **foreground**, `onForegroundMessage` hands it to the **`ForegroundNotificationBridge`** (P4-17) which shows one local notification on channel `push_events` and de-duplicates by `data.inboxId` (F-16). **Tap routing** (background, terminated, foreground) goes through the single allow-listed `NotificationTapRouter` (Appendix B.4); a payload for a module that is off falls back to `/home`.
  - **Capability provider:** `pushCapabilityProvider` = `{tokenRegistered, osPermissionGranted, memberPushEnabled}` feeds `DeliveryPolicy.effective`. A denied permission shows the banner on the notification settings screen (P4-16); the types silently fall back to Normal (`noPermission`).
  - **Payload contract (shared with P4-15, Appendix B.8):** `data: {route, inboxId, type}`; the `notification` title/body are generic bn/en text; **no names, amounts or ids of other people** (rule 70).
  - **Diagnostics:** `pushDiagnosticsProvider` = permission, token present (first 6 chars only), last token refresh, last received message time, last error — shown on the help page.
- **Interacts with:** `DeliveryPolicy` (capability), the inbox bridge, the Android channels of P4-13.
- **Rules / tests:** `FakePushService` tests: token registered once per sign-in, refreshed on change, deleted on sign-out; foreground message → exactly one local notification, a second message with the same `inboxId` → none; tap payload table (allow-list, unknown ⇒ `/home`, module off ⇒ `/home`); rules: owner ✔ / other ✘ / unauthenticated ✘; language change updates `lang`. **[DEVICE] checklist** (Appendix H.2): send a test message from the Firebase console to the token; app in foreground, background, swiped away; tap each; Android 13 permission denied then granted; sign out and confirm no further delivery to that phone.
- **Done when:** a test message from the Firebase console arrives on a real phone with the app closed, tapping it opens the right screen, and signing out stops it.

#### P4-15 — Push backend: Cloud Functions [BLAZE][OWNER]

- **Type:** DEPENDENT. **Depends on:** P4-11, P4-14 and the **owner go/no-go (D-P4-21)**. **Parallel with:** P4-19, P4-20. **Unblocks:** P4-16 (live status), P4-25.
- **Why:** F-6. Only a trusted server can call the FCM HTTP v1 API; Cloud Functions is the first-party option and needs the Blaze plan.
- **Go/no-go checklist [OWNER] (do before coding):** (1) Upgrade `familyhub-prod` (and `familyhub-dev` if you want to test live) to Blaze; (2) create a **billing budget with email alerts at a very low amount** (suggestion: the smallest your bank allows, with alerts at 50 / 90 / 100 %) — Blaze has **no automatic cap** (F-21); (3) confirm the current free-tier numbers for Cloud Functions, Firestore and FCM **[VERIFY]**; (4) confirm your payment method works for Google Cloud billing in your country. **If the answer is no, skip this step:** every type stays Normal, the admin screen shows "Push needs one-time setup", and nothing else in Phase 4 changes. The code can be deployed later with no app update.
- **Files (NEW, all under `functions/`):** `package.json` (`firebase-functions`, `firebase-admin`, `typescript`, test runner), `tsconfig.json`, `.gitignore`, `src/index.ts`, `src/on_inbox_created.ts`, `src/on_member_pending.ts`, `src/delivery_policy.ts` (the same id table as `core/notifications/domain/notification_type.dart`), `src/push_texts.ts` (bn/en title and body per type), `src/push_ledger.ts`, `src/tokens.ts`, `test/*.test.ts`. EDIT `firebase.json` (functions source, emulator `functions`), `firebase/firestore.rules` (`pushLedger/{id}` deny all clients; `notificationInbox` keeps `hasOnly` so `pushStatus`/`pushAt` cannot be written by clients), NEW `docs/PUSH_BACKEND.md` (deploy, rollback, budget alert, how to disable: set `pushEnabled=false` or `firebase functions:delete`), `.github/workflows` job for `npm test` in `functions/`, NEW `test/contract/push_ids_contract_test.dart` (the Dart catalog and the TypeScript table list the same ids; reads `functions/src/delivery_policy.ts` as text).
- **Contents:**
  - **Runtime and region [VERIFY]:** a currently supported Node runtime, 2nd-gen functions, **the same location as the Firestore database** (a Firestore trigger must match it). `maxInstances` small (e.g. 3) as a second brake against runaway cost.
  - **`onInboxCreated`** — trigger: create of `families/{f}/notificationInbox/{id}`. Steps: (1) read `settings/notificationDelivery`; if `pushEnabled == false` or `modes[type] != 'push'` or the type is not push-capable ⇒ **return without writing anything**; (2) confirm the recipient is an **active** member of family `f` (never trust `toMemberId` blindly); (3) read the recipient's `users/{uid}.preferences.notifications` (member `pushEnabled`, quiet hours) — if the member opted out, or it is inside quiet hours and `quietRespectedByPush` is true ⇒ no push (the inbox row and the in-app bridge still exist); (4) **rate limit:** increment `pushLedger/{uid_yyyyMMddHH}`; above `kMaxPushPerHour` (30) ⇒ skip and log; (5) read the recipient's `users/{uid}/devices/*` (≤ 5 devices; ignore tokens not seen for 60 days); (6) build the message per device language from `push_texts.ts`: `notification {title, body}`, `data {route, inboxId, type}`, `android {priority: 'high', ttl: 24 h, notification: {channelId: 'push_events', tag: inboxId}}`; (7) send with the Admin SDK (per-token send; **[VERIFY]** the current multicast method name); (8) remove tokens answered with an "unregistered / invalid token" error; (9) write **one** status field back to the inbox row: `pushStatus: 'sent' | 'no_devices' | 'failed'` and `pushAt`.
  - **`onMemberPending`** — trigger: create of `families/{f}/members/{uid}` with `status == 'pending'`. Sends type `member_join_request` to every active admin and Household Manager under the same policy and rate limit (no inbox row is needed; the in-app item is derived, D-P4-6). Payload route `/family/members`.
  - **Idempotency:** triggers can be retried; `pushStatus` present ⇒ skip; `tag = inboxId` makes a duplicate collapse on the device.
  - **Texts (generic, rule 70):** e.g. `swap_request` → "একটি কাজ বদলের অনুরোধ এসেছে" / "A chore swap request arrived". No names.
  - **Security:** the function never exposes the service account; it runs with the default service account; it ignores any client-written `pushStatus`; deny-all rules on `pushLedger`.
  - **Observability:** structured logs (type, family hash, result) with no personal data.
- **Rules / tests:** unit tests with a fake messaging client: master off ⇒ no send; mode Normal ⇒ no send; recipient not active ⇒ no send; member opted out; quiet hours; rate limit at 30; stale token pruned; two devices both receive; retry does not duplicate; text by language. Emulator test: write an inbox row ⇒ function runs ⇒ `pushStatus` set. Rules tests: a client cannot write `pushStatus`, cannot read or write `pushLedger`.
- **Done when:** **Fourth working slice [DEVICE][BLAZE]:** with the master switch on, a swap request created on phone A arrives on phone B (app swiped away) within seconds; switching that type to Normal in the admin screen stops the push but the inbox row still appears; the Firebase budget alert exists.


#### P4-16 — Notification settings, admin delivery screen, help page, "why" line

- **Type:** DEPENDENT. **Depends on:** P4-11, P4-13, P4-14, P4-03. **Parallel with:** P4-20.
- **Files:** NEW `features/notifications/presentation/{notification_settings_screen.dart, delivery_admin_screen.dart, reminders_help_screen.dart, widgets/{category_section.dart, timings_section.dart, quiet_hours_section.dart, summary_section.dart, permission_banner.dart, diagnostics_list.dart, family_defaults_section.dart, delivery_type_list.dart, push_status_card.dart}}`, `reminder_why_line.dart`; EDIT router (`/settings/notifications`, `/settings/notifications/delivery`, `/settings/notifications/help`), Family settings hub tiles ("Notifications" for everyone; "Push or normal" for admin), `occurrence_detail_screen.dart` (the "why" line below the due row), `reminders_block.dart` (link "How reminders work"), ARB.
- **Contents:**
  - **Member screen (`/settings/notifications`):** top `PermissionBanner` (notifications granted / denied / exact-alarm missing, with the right button); **three-level switches** with plain explanations and, when off, the reason chain; master → categories (Chores, Bazar, Family) → text pointing to the per-chore switch in the template editor; default offsets (`TimeOffsetChips`, ≤ 5 + custom), overdue reminder, morning summary, quiet hours; **"Receive push notifications on this phone"** member switch (shows the effective state and reason: "off because the admin turned push off" / "off because notifications are blocked"); **"Send a test notification in 10 seconds"** (local) and, when push is live, **"Send me a test push"** (writes an inbox row of a `test` type to self — **[VERIFY]** whether a dedicated `test` type is worth a rules change; otherwise the test is local only); "Use family defaults" reset. Managers also see **Family defaults**.
  - **Admin delivery screen (`/settings/notifications/delivery`, R1, admin only via `PermissionGate(editFamilySettings)`):** a **master switch "Allow push notifications"** with a `PushStatusCard` (backend state: "Not set up" / "Ready" from the last `pushStatus` seen / "Last push failed"), then the catalog of Appendix B.7 grouped by category, one `DeliveryModeTile` per type: a **Push | Normal** segmented control, a **"Recommended: Push/Normal"** tag with a one-line reason, and for non-push-capable types a **locked Normal with the reason** ("Computed on each phone; no server event"). A **"Reset to recommended"** button, one Save bar, dirty guard, INTEGRITY offline message, and a banner explaining that the master switch is off until the backend is set up (D-P4-21) with a link to `docs/PUSH_BACKEND.md` wording in plain Bangla. Choosing Push while the master switch is off is allowed (it is stored) and shows "will start when push is turned on".
  - **Help page ("Reminders not working?")**: `DiagnosticRow`s for notification permission, exact-alarm permission, battery optimisation (opens settings), pending local count, next scheduled time, **push: token present, last push received, backend status**, last error, device SDK, language + timezone; a numbered checklist (allow notifications, allow alarms, disable battery restriction for Family Hub, don't force-stop the app, open the app once a day); the **honesty note**: Normal reminders are scheduled on this phone from data it has loaded; only **Push** types reach a closed app when someone else acts (F-6).
  - **Why line** on the task detail: `ReminderExplainer` text, e.g. "রিমাইন্ডার: আজ বিকাল ৫:৩০-এ (৩০ মিনিট আগে)" or "রিমাইন্ডার নেই — এই কাজের জন্য বন্ধ".
- **Rules / tests:** widget tests for each banner state, switch-reason text, test-notification flow with the fake scheduler, defaults reset, **a Member and a Household Manager do not see the delivery screen; an admin does**, locked types cannot be switched to Push, "Reset to recommended" equals the catalog defaults, master-off state text, bn/en/dark/scale 2.0, `no_role_checks_in_ui` green.
- **Done when:** toggling Chores off removes chores reminders (pending count on the help page) while saved timings remain; an admin switches `comment_attention` to Push and back and the change reaches another phone's `effectiveModeProvider`.

#### P4-17 — Inbox: derived items, bell, two new stored types, foreground bridge

- **Type:** DEPENDENT. **Depends on:** P4-07, P4-13, P4-14. **Parallel with:** P4-20.
- **Why:** the inbox screen, repository, tiles and bell **already exist** (Phase 3). This step only adds what Phase 4 needs.
- **Files:** EDIT `features/notifications/domain/inbox_port.dart` (`InboxType.choreAssigned = 'chore_assigned'`, `InboxType.memberApproved = 'member_approved'`, added to `all`), the writers for them (reassignment in `ReassignOccurrence` / approval in `ApproveMember`, **built into the existing batches, never a second call**), `firebase/firestore.rules` (`inboxOk` type list + params limits), `rules_test` (both new types ✔, an unknown type ✘), `test/contract` mirror; NEW `domain/virtual_inbox.dart`, `domain/usecases/mark_all_read.dart`, `presentation/foreground_notification_bridge.dart`; EDIT `inbox_screen.dart`, `inbox_providers.dart`, `inbox_text.dart` (bn + en sentences for the two new types).
- **Contents:**
  - **Merged list:** stored items (≤ 50, Today / Earlier groups) + **virtual items** from pure `VirtualInbox.build(...)`: *budget alert*, *pending join requests* (managers), *pending contribution requests* (people with `recordContribution`), *contribution due* (member with an unpaid plan on/after the due day), *awaiting verification* count (verifiers). Virtual items have stable ids (`v:budget:2026-11`), are never written, vanish when the cause is gone, and their read state is local (SharedPreferences, per month).
  - `unreadInboxCountProvider` = stored unread + virtual unacknowledged → dashboard bell and Manage hub badge. "Mark all read". The Spark note in the help text now reads: "Push types reach you even when the app is closed; other types appear when you open the app."
  - **`ForegroundNotificationBridge`:** while the app process is alive, a **new** unread stored item whose effective mode is **Normal** triggers one immediate local notification (`ReminderScheduler.showNow`, channel `family` or `chores`); an item whose effective mode is **Push** is shown by the FCM foreground handler instead; both de-duplicate through one persisted set keyed by `inboxId` (F-16). Best effort, documented.
- **Rules / tests:** merge and ordering, virtual-item table tests (each cause appears and disappears), mark-all-read, module-off hiding, **bridge de-duplication between a Normal local and a Push foreground message for the same `inboxId`**, rules tests for the two new types, bn/en/dark/scale 2.0.
- **Done when:** the bell count is right; a manager sees "2 join requests" and "budget 85 %" as derived items that disappear when resolved; a reassigned chore produces a `chore_assigned` row and (with push on) a push to the new assignee.


### Wave D — Engagement and stats privacy (P4-18 … P4-22)


#### P4-18 — Engagement domain (pure)

- **Type:** DEPENDENT. **Depends on:** P4-02. **Parallel with:** P4-04…P4-17. **Unblocks:** P4-19.
- **Files:** NEW under `lib/features/chores/achievements/domain/`: `engagement_settings.dart` (+ `default_engagement_settings.dart`, the only place with the placeholder numbers, each constant named and commented "PLACEHOLDER — owner may change"), `scoring/{score_spec.dart, score_calculator.dart, streak_calculator.dart}`, `levels/level_table.dart`, `badges/{badge_catalog.dart, badge_evaluator.dart}`, `member_stats.dart`, `stats_sync.dart` (the pure algorithm), `cover_counter.dart`.
- **Contents (all integer math, no `double`):**
  - **`ScoreCalculator.pointsFor(item, spec)`** for one completed chore of the viewer: `base = spec.pointBases[difficulty]`; `onTimePermille = completedAt ≤ dueAt + graceMinutes ? 1000 : spec.latePermille`; `verifiedPermille = (verifiedAt != null && reopenCount == 0) ? spec.verifiedPermille : 1000`; `points = roundHalfUp(base × onTimePermille × verifiedPermille / 1 000 000)`. **Cover bonus:** when `coverForId != null && completedBy == viewer` add `roundHalfUp(base × coverBonusPermille / 1000)`. Absence / skipped / unassigned ⇒ 0 and neutral. Points belong to **`completedBy`** (the real actor, D-P3-14), the cover bonus to the accepting assignee. Items before `startedOn` count 0.
  - **`StreakCalculator.advance(prev, dayFacts)`** implements D-P4-20 over days `(asOfDateKey, yesterday]` (plus today when all eligible are done): `eligible(day)` = viewer's non-skipped, non-projected chores due that day excluding items neutralised by an approved absence. Output `{current, best, asOfDateKey, pausedDays}`.
  - **`LevelTable`**: ascending `minPoints`, `levelFor(points)`, `progress(points) → {level, into, needed, fraction}` (integer), names bn/en from settings; validates ascending and ≤ 12 levels. Default 8 levels (stages of the plant): Seed 0 · Sprout 100 · Seedling 250 · Sapling 500 · Young tree 900 · Flowering 1400 · Fruiting 2000 · Grand tree 3000 (**placeholder thresholds, [OWNER]**).
  - **`BadgeCatalog`** (closed ids, labels via ARB): `fresh_start` (first completed chore after `startedOn`), `consistent` (streak.current ≥ `consistentDays`), `reliable` (a **finalised** month with `done ≥ reliableMinDone` and `onTime×100/done ≥ reliablePercent`), `helper` (`coversTotal ≥ helperCovers`), `detail_champion` (`verifiedCleanTotal ≥ detailCount`, where a verified-clean chore has `subtasks.isNotEmpty`, every subtask ticked, `verifiedAt != null`, `reopenCount == 0`). `BadgeEvaluator.evaluate(stats, spec) → Set<badgeId>`; the stored set is the **union** (earned, never lost).
  - **`StatsSync.compute({previous, currentMonthItems, finalisingMonths, spec, today, viewerId, absenceNeutral}) → MemberStats`** — the one algorithm of D-P4-8: recompute the current month; for each non-final earlier month in `[monthOf(max(startedOn, asOf)) … previous month]` compute from its items and set `final = true`; `monthly[m].points = max(stored, computed)`; `totalPoints = Σ monthly.points`; counters likewise; badges union; `lastCelebratedDateKey` untouched. Months beyond `kMaxStatsMonths` fold into a `legacy` bucket. Pure and idempotent (running twice yields the same output).
  - **`CoverCounter.count(monthItems, month) → Map<memberId, int>`** (covers given = items with `coverForId != null` grouped by assignee; alphabetical listing is the caller's job).
- **Rules / tests:** Appendix C tables (≥ 40 cases): points for easy/normal/hard × on-time/late × verified/reopened, cover bonus, absence neutrality, before-`startedOn`, rounding half-up, streak with pause/break/gap, level boundaries (99/100/249/250), badge thresholds incl. "reliable only when final" and "union never loses", `StatsSync` idempotence, a month finalised once and never recomputed, spec change does not alter frozen months, 40-month fold. Property: totals never decrease across any sequence of syncs.
- **Done when:** all tables green; no Flutter, Firestore or Riverpod import in `achievements/domain`.


#### P4-19 — Stats, engagement settings and privacy: data, rules, use cases, providers

- **Type:** DEPENDENT. **Depends on:** P4-18. **Parallel with:** P4-12 … P4-17. **Unblocks:** P4-20, P4-21.
- **Files:** NEW `achievements/data/{member_stats_mappers.dart, public_stats_mappers.dart, firestore_member_stats_repository.dart, firestore_public_stats_repository.dart, engagement_settings_mappers.dart, firestore_engagement_settings_repository.dart}`, `achievements/domain/{public_stats.dart, usecases/{sync_member_stats.dart, mark_celebrated.dart, update_engagement_settings.dart, set_stats_sharing.dart}}`, `achievements/presentation/engagement_providers.dart` (`engagementSettingsProvider`, `memberStatsProvider`, `publicStatsProvider`, `levelProvider`, `badgesProvider`, `hubLevelViewProvider`, `statsSyncControllerProvider`, `previousMonthItemsLoader`), EDIT `firebase/firestore.rules` (carve `memberStats` out of the deny block; add `memberStatsPublic` and `settings/engagement`), NEW `rules_test/{member_stats, member_stats_public, engagement_settings}.test.mjs`, fixtures, contract entries, `bootstrap.dart` (override + start the sync controller), `test/support/in_memory_engagement_backend.dart`.
- **Contents:**
  - **Rules for `memberStats/{uid}` (private, always):** `uid == request.auth.uid` and active member; **no one else reads or writes, admins included**; key set §3.2; `totalPoints` int, `≥ old`, `≤ old + kMaxPointsPerSync`; counters monotonic; `badges` keeps every old key (check first and last key; rules cannot loop, the app tolerates malformed entries); `monthly` size ≤ 40; `lastCelebratedDateKey` `≥ old` and `≤ todayKey` (ADR 0014 helper, F-7); `startedOn` immutable once set; `sharing` bool; create once with zeros; no delete. **Honest limit** (ADR 0017): a determined member can still write plausible numbers about themselves; nothing else is exposed or affected because stats carry no money or permission.
  - **Rules for `memberStatsPublic/{uid}` (R2):** key set `{level, badgeIds, updatedAt + BaseMapper}`, `level` int 0..12, `badgeIds` list ≤ 12 of strings; **read:** active members only while `get(settings/engagement).statsVisibility == 'levels'`; **write:** owner only, only while `statsVisibility == 'levels'` **and** the owner's own `memberStats.sharing == true`; **delete:** owner always. No points, no streak, no monthly fields can exist (the key set forbids them).
  - **Rules for `settings/engagement`:** manager/admin write for scoring fields (key set + range checks of §3.2, level list ≤ 12 with first and last item checked); **`statsVisibility` may change only when the writer is an admin** (compare `resource.data.get('statsVisibility','private')` with the new value; a manager writing any other key while leaving this one unchanged is fine); first enabling stamps `startedOn = todayKey` (never backwards).
  - **`SyncMemberStats`** (EVERYDAY): loads own `memberStats`, the current month items (already live) and **at most one** one-shot read per non-final earlier month (`orderBy dateKey`, `limit(kMaxOccurrencesPerMonth)`), runs `StatsSync.compute`, writes only when the result differs (hash compare), never when `engagement.enabled == false`. **After the private write, if `statsVisibility == 'levels'` and `sharing == true`, it mirrors `{level, badgeIds}` to `memberStatsPublic/{uid}` in the same batch; if visibility is `private` or sharing is off, it deletes the member's own public doc.**
  - **`SetStatsSharing(bool)`** (EVERYDAY): permitted only while `statsVisibility == 'levels'` (`sharing_not_allowed` otherwise); flips `sharing`, and writes or deletes the public doc in one batch. Default off for every member (opt-in).
  - **`statsSyncControllerProvider`:** runs on app start, on resume (at most once per 10 min), and whenever the viewer completes or verifies a chore (listener on `todayProgressProvider`), debounced 3 s; offline ⇒ computes from cache and queues the write.
  - **`MarkCelebrated(dateKey)`** writes `lastCelebratedDateKey` (local first).
  - **`UpdateEngagementSettings`** (INTEGRITY): `manageEngagement`; changing `statsVisibility` also requires `editFamilySettings` (`invalid_visibility` for other values); validates levels / thresholds / points / permille; bumps `specVersion` only when scoring numbers changed; audits `engagement.settings_updated` and, when visibility changed, `engagement.privacy_updated`.
  - **Switching to `private`:** the next sync of every member deletes their public doc; meanwhile the rules already deny reads, so nothing leaks during the gap.
- **Rules / tests:** use-case tests with the in-memory backend (first sync creates, second is a no-op, previous month finalised once, offline queue, **public doc mirrored only when allowed and opted in, deleted when visibility returns to private**); rules tests: owner ✔; **other member ✘ (read and write); admin ✘ (read of `memberStats`)**; decrease ✘; +3001 ✘; badge removal ✘; future celebration date ✘; delete ✘; other family ✘; **public doc: member A reads B ✔ only with `levels` on, ✘ when `private`; writing a `totalPoints` key ✘; writing without `sharing` ✘**; engagement settings: manager ✔ scoring keys, **manager ✘ changing `statsVisibility`, admin ✔**; contract fixtures with real mapper payloads.
- **Done when:** a member's stats document appears after completing a chore and only that member can read it; with visibility `levels` and sharing on, another member can read the level and badges but never points; flipping back to `private` hides it again.


#### P4-20 — Achievements UI, Hub Level plant, helpers strip, engagement settings screen

- **Type:** DEPENDENT. **Depends on:** P4-19, P4-03, P4-07. **Parallel with:** P4-16, P4-17. **Unblocks:** P4-21, P4-22, P4-24.
- **Files:** NEW `achievements/presentation/{achievements_screen.dart, hub_level_card.dart (dashboard card), helpers_strip.dart, engagement_settings_screen.dart, widgets/{level_header.dart, badge_grid.dart, badge_detail_sheet.dart, stats_summary.dart, levels_editor.dart}, painters/{plant_painter.dart, badge_painter.dart}, engagement_motion.dart}`; EDIT `chores_module.dart` (routes `choresAchievements`, `choresEngagementSettings`, dashboard spec `hub_level`), `chores_entries.dart` (tiles "My achievements", "Engagement settings" for `manageEngagement`), ARB, gallery.
- **Contents:**
  - **`PlantPainter(stage 0..7, growth 0..1, colours)`**: a stylised plant drawn with paths — pot/soil, stem, leaves, buds/flowers/fruit by stage — colours supplied from `tokens.chart`, `statusCompleted` and surface tokens; stage count = number of levels (scaled if the owner changes the table). Static in reduced motion; otherwise a 600 ms grow when the stage changes.
  - **Achievements screen:** top `LevelHeader` (plant, level name, points, `LevelRing` to the next level with "১২০ পয়েন্ট বাকি"), streak line ("চলমান ধারা: ৫ দিন"; paused days shown as "বিরতি", not a loss), `BadgeGrid` with earned and locked badges (locked = outlined shape + progress hint, e.g. "২/৩ কভার"), tap → sheet with how to earn it and the date earned, small stats (completed, on time %, covers). **No leaderboard and no ranking.** Other members' data is shown only through the opt-in, points-free **Family levels strip** (see Privacy controls below) and only while the admin has set `statsVisibility = levels`. Disabled engagement ⇒ `EmptyState` explaining it was turned off.
  - **Dashboard card `hub_level`:** plant + level + ring; tap → Achievements; hidden when engagement is off.
  - **Helpers strip** (`showHelpersHighlight`): "এই মাসে যারা সাহায্য করেছেন" — avatars + "N বার" from `CoverCounter` over `monthItemsProvider(current)`, alphabetical, hidden when nobody helped; appears on the dashboard (This week area) and Today.
  - **Engagement settings screen** (`manageEngagement`): enabled, celebration on/off, helpers highlight, point bases, late / verified / cover factors (permille shown as %), the levels table (`levels_editor`: reorder not needed, ascending enforced, add/remove, names bn/en), badge thresholds, "Reset to defaults" per section, a prominent note "বদলালে আগের মাসের পয়েন্ট বদলাবে না" (frozen months). One Save bar, dirty guard, INTEGRITY offline message.
  - **Privacy controls (R2, D-P4-26):** the Achievements screen has a **"Share my level and badges"** switch (`SetStatsSharing`), visible only while `statsVisibility == levels`, default off, with the exact wording of what is shared (level and badge names; **never points, streak or monthly numbers**) and what is not. A **Family levels strip** (`family_levels_strip.dart`) lists members who opted in, **alphabetically**, showing avatar, name, level name and badges, never points or order by level. The **Engagement settings screen** gets a **Stats privacy** section (admin only, `PermissionGate(editFamilySettings)`): a two-option control **Private (recommended, default)** / **Share level and badges (members opt in)**, with a confirmation dialog and the sentence "Points are never shared."; changing it writes `statsVisibility` (audited `engagement.privacy_updated`). Managers without the admin role see the current value read-only.
- **Rules / tests:** widget tests per state (new member level 0, mid, max level, all badges, none, engagement off, stats loading/error), badge locked/earned semantics, ring text, helpers strip hidden/visible, settings validation messages, member cannot open settings (redirect), bn/en/dark/scale 2.0, painter golden (Linux only) for stages 0, 3, 7.
- **Done when:** a member sees their own plant and badges; the admin can switch stats between Private and level-sharing and a member's opt-in appears or disappears in the Family levels strip accordingly; a manager can change the level table and the plant stage count follows.


#### P4-21 — Celebration domain and controller

- **Type:** DEPENDENT. **Depends on:** P4-19. **Parallel with:** P4-20. **Unblocks:** P4-22.
- **Files:** NEW `achievements/domain/celebration_state.dart` (pure state machine), `achievements/presentation/celebration_controller.dart` (`Notifier<CelebrationState>`), `celebration_prefs.dart` (local `celebratedDateKey` per family + member).
- **Contents:** `CelebrationInput {todayKey, mineToday {done, total, lastCompletedAt?}, sessionStartedAt, sawIncompleteThisSession, lastCelebratedLocal, lastCelebratedStats, engagementEnabled, celebrationEnabled, nowMinusLastCompletion}`. `CelebrationEngine.decide(input) → Decision {none, celebrate, quietDone}` (state table in Appendix D): **celebrate** iff enabled, `total > 0`, `done == total`, `lastCelebrated* != today`, and (`sawIncompleteThisSession` **or** last completion ≤ 30 min ago); **quietDone** when all done but the above is not met (no animation, a still "সব কাজ শেষ" banner); **none** otherwise. "Mine" = the viewer's eligible chores of today (same filter as `StreakCalculator.eligible`, so projected, skipped and absence-neutral items never block or trigger). On `celebrate` the controller (1) calls `SyncMemberStats` immediately to get before/after (level, new badges), (2) `MarkCelebrated(today)` (local first), (3) emits `CelebrationShown{levelBefore, levelAfter, newBadges, pointsToday}`. If chores are un-completed later the same day, nothing re-triggers (already celebrated).
- **Rules / tests:** Appendix D table (≥ 20 cases): first completion of the day, last-of-three completes, cold start already complete & celebrated, cold start complete & not celebrated with recent completion, with old completion (quiet), two phones, undo then redo, no chores today, day rollover at Dhaka midnight, engagement off, celebration off, offline.
- **Done when:** table green; `celebrate` is emitted exactly once per day in the simulation of two sessions.


#### P4-22 — Celebration overlay UI, painters, wiring

- **Type:** DEPENDENT. **Depends on:** P4-21, P4-20. **Unblocks:** P4-23.
- **Files:** NEW `achievements/presentation/{celebration_overlay.dart, celebration_host.dart}`, `painters/confetti_painter.dart`; EDIT the app shell / `HomeScreen` (host placed once above the tab content so any tab can show it), `today_complete.dart` only if needed to call the sync, ARB, gallery.
- **Contents:** `CelebrationHost` listens to `celebrationControllerProvider`; on `CelebrationShown` shows `CelebrationOverlay` as a modal bottom sheet / dialog (not a full-screen route): `ConfettiPainter` (deterministic particle list from a seed, ≤ 80 particles, 1.8 s, token colours only), a localized message ("আজকের সব কাজ শেষ! 🎉" without relying on emoji glyphs — use an icon), points earned today, level progress (`LevelRing`, plant grows when the level changed), newly earned badges with `BadgeMedal`, a "Done" button; haptic `mediumImpact` if the system allows. **Reduced motion:** no particles, no growth animation, the same content as a static card. The overlay never opens while another dialog or the swap/reason sheet is on screen (queued until idle) and never over a text field with the keyboard open.
  `quietDone` shows a calm banner on Today ("সব কাজ শেষ"), no sheet.
- **Rules / tests:** widget tests: shown once (second `pump` after rebuild does not show again), reduced motion shows a static card with zero running tickers, badge list, queued behind an open dialog, semantics announcement ("আজকের সব কাজ সম্পন্ন"), bn/en/dark/scale 2.0; golden of the static state.
- **Done when:** **Engagement milestone:** completing the last chore of the day on a phone shows the celebration once; reopening the app the same day does not; reduced motion shows the static card.


---

### Wave E — Finish (P4-23 … P4-26)


#### P4-23 — Accessibility and states audit + fixes

- **Type:** DEPENDENT. **Depends on:** P4-07…P4-22. **Parallel with:** P4-24.
- **Files:** NEW `docs/phase4_polish_audit.md` (the **written list first**: category, file, line, issue, severity), then small fix commits; EDIT `test/support/screen_states.dart` (every Phase 4 screen × loading / empty / error / offline / data), gallery.
- **Contents (ROADMAP Step 31 checklist, applied to the whole app, not only Phase 4):** every screen has loading, empty, error and offline states; no information by colour alone (status chips, badges, plant stages, heat, bell count); touch targets ≥ 48 dp; text to 200 % in Bangla without overflow (long Bangla strings in notification settings and help page are the likeliest offenders); TalkBack labels for avatars, status chips, charts, calendar cells, badge medals, plant ("লেভেল ৪: তরুণ গাছ"), level ring, bell ("৩টি অপঠিত"); contrast test over every registered theme including new tokens; reduced motion respected everywhere (`engagementMotion`, `calendarMotion`, the Today pill, the dashboard skeleton); focus order on the dashboard (header → alert strip → cards in order); chart text alternatives re-checked; hard-coded string scan; ARB parity; bn digits everywhere including notification texts.
  - **New in v2:** audit the Customize dashboard and Dashboard access screens: every drag has a Move up / Move down alternative (rule 71), the access-cell states are icon + label + colour, the matrix is operable with TalkBack row by row, and the admin delivery screen announces Push / Normal and the locked reason.
- **Rules / tests:** the state harness must be green; an a11y smoke test using `tester.ensureSemantics()` per screen asserting no unlabeled tappable (tolerating a small, listed allow-list); goldens for dashboard, achievements, notification settings, activity (Linux CI) in 2 themes × 2 languages.
- **Done when:** the audit list has no open High items and the harness covers all screens.


#### P4-24 — Tablet layouts

- **Type:** DEPENDENT. **Depends on:** P4-07, P4-20. **Parallel with:** P4-23.
- **Files:** EDIT the app shell (`app/shell/*`): `NavigationRail` at ≥ 840 dp (labels from the module registry, selected state with indicator + label), `PillBottomBar` below; EDIT `dashboard_grid.dart` (2 columns ≥ 840 dp, `half` cards pair, header spans), `occurrence_detail_screen.dart` (two-pane: details left, timeline/comments right ≥ 840 dp), `achievements_screen.dart` (plant left, badges right), `notification_settings_screen.dart` (centered max width 640), `activity_feed_screen.dart` and `inbox_screen.dart` (list + detail target pane optional → keep list with max width 720). The calendar's existing two-pane is reused.
- **Contents:** a pure `LayoutClass.of(width, shortSide)` (`compact`, `medium`, `expanded`) used by all of the above; landscape phones stay compact. No change of routes between layouts (same URLs).
- **Rules / tests:** widget tests at 360, 600, 840, 1024 dp; rail ↔ bar switch preserves the selected tab and scroll; goldens (Linux).
- **Done when:** on a 10″ emulator the dashboard shows two columns and the detail screen is two-pane, with no overflow at scale 2.0.


#### P4-25 — Hardening, read budget, real-device tests, UAT, sign-off, Phase 5 contract

- **Type:** DEPENDENT. **Depends on:** all.
- **Files:** NEW `docs/phase4_acceptance.md` (UAT script), `docs/phase4_read_budget.md`, `docs/reminders_manual_test.md` (from P4-13, filled with results), `docs/phase5_contract.md`, `test/features/dashboard/perf/*`, `test/features/chores/achievements/concurrency/*`; EDIT `PROGRESS.md`, `docs/new_collection_checklist.md` (`memberStats`, `settings/engagement`), `CLAUDE.md`, `README.md`, `ROADMAP.md` (Steps 27–31 "done via P4-xx").
- **Contents:**
  1. **Rules:** run the whole emulator matrix; confirm the deny-only block lists **no** Phase 3/4 collection; add deny-by-default tests for removed paths; re-run the 400-create test if generation changed.
  2. **Read budget (measure):** emulator run counting document reads for: cold open to Home, switching all tabs, pull-to-refresh, opening the Activity feed (2 pages), opening Achievements, first stats sync of a member with one finalised previous month (expected ≈ one month of occurrences), a normal day for a 4-member family; compare with the Spark daily read quota **[VERIFY]**; target: a typical family day ≪ 10 % of the quota. Document the listener inventory (D-P4-20).
  3. **Concurrency:** two simulated phones of one member syncing stats; two phones planning reminders; celebration decided on two sessions (still once).
  4. **Real devices [DEVICE]:** run `docs/reminders_manual_test.md` on **two Android brands** (one with an aggressive battery manager) on Android 12 and 13+: app closed, swiped from recents, battery saver on, after reboot, after timezone change and back, notification permission denied then granted, exact alarm revoked; record screenshots and results.
  5. **Offline matrix:** complete a chore offline → stats queue → reconnect; settings saves offline refuse with the "needs internet" message where INTEGRITY; reminders still plan from cache.
  6. **Localization:** ARB parity, Bangla digits in every notification string, no English fallback in bn mode; owner reviews the notification copy (Appendix B.5).
  7. **Security review:** stats privacy (another member cannot read), payload allow-list, no personal data in notification payloads (only a route), no secrets in logs.
  8. **UAT with the family** (Appendix G.3), ten tasks.
  9. **`docs/phase5_contract.md`:** what reports/sharing may rely on (activity entries, `monthItemsProvider`, `CoverCounter`, month `final` flags, `ReminderSettings` not exported, privacy rule that stats are never exported), and the data Phase 4 deliberately does not compute.
  10. Update `PROGRESS.md` honestly ("Done" vs "Written, not run"), tag `phase-4`.
  11. **Dashboard checks:** the role-visibility matrix tests for all three roles with finance on and off; a role change on one device re-resolves another device's Home; the Customize layout survives sign-out and sign-in and a re-install (synced prefs).
  12. **Push checks [BLAZE]:** run `docs/reminders_manual_test.md` H.2 on two brands; confirm in the Firebase console the function invocation count and the **billing budget alert** exist; measure Firestore reads per push (target ≤ 4) and add them to `docs/phase4_read_budget.md`; adversarial rules tests (client cannot write `pushStatus`, cannot touch `pushLedger`, cannot read another user's `devices`); confirm nothing is notified twice (F-16) and that disabling the master switch or the function stops all push.
  13. **Privacy checks:** with `statsVisibility = private` no member can read another's `memberStats` **or** `memberStatsPublic`; with `levels` only the points-free doc is readable; admin cannot read `memberStats`.
- **Done when:** every row of §6 passes.


#### P4-26 — *(Optional, after the beta)* Scheduled push sweeper [BLAZE]

- **Type:** DEPENDENT. **Depends on:** P4-15, P4-25. **Not required for Phase 4 sign-off.**
- **Why:** lets the admin choose Push for the **time-based** types (due reminders, overdue, morning summary, contribution due, month end), which D-P4-25 locks to Normal. Only worth building if device-level local reminders prove unreliable on the family's phones.
- **Contents (design only, to be specced with a spike first):** a scheduled function (Cloud Scheduler, a few runs per hour) that reads today's open occurrences for each family and sends push for the types whose mode is Push; cost is dominated by Firestore reads, so it must read **only today's occurrences with a `limit`** and write a per-day ledger to avoid repeats. Spike questions: Firestore read cost per run, Scheduler free allowance **[VERIFY]**, interplay with local reminders (the planner already skips Push types, F-16), quiet hours and timezones. Flip `pushCapable` for those ids only when this step is deployed.
- **Done when:** a spike document with measured reads and a go/no-go.


---


## 6. Phase 4 acceptance criteria (used by P4-25)

| # | Criterion | How it is proven |
| --- | --- | --- |
| 1 | The Home tab shows **real data only**; every card hides when its module is off, the permission is missing or the role matrix says so; a failing card does not break the others. | P4-07 tests, UAT 1–2 |
| 2 | **Role-based dashboards:** a Household Manager (finance on) and an admin can set, per card, **Hidden / Visible / Off by default / Required** for the Household Manager and Member roles; a Member's Home follows the change without restart; admin can never be locked out; the matrix says hiding is not access control. | P4-05, P4-06, P4-08 tests, UAT 3 |
| 3 | **Personal layout:** every user can drag cards to reorder, hide and show optional cards, reset to default; the layout survives restart and re-install (synced), required cards cannot be hidden, drag has a non-drag alternative, and a role change never crashes or leaks a card. | P4-05, P4-08, P4-23 tests, UAT 4 |
| 4 | The dashboard holds **≤ 7 data listeners** and switching tabs adds none. | Listener-count test |
| 5 | **Delivery modes:** the admin can set each push-capable type to **Push or Normal**; defaults equal the recommended table (Appendix B.7); scheduled and derived types cannot be set to Push; non-admins cannot change it; "Reset to recommended" works. | P4-09, P4-11, P4-16 tests |
| 6 | **Push works end to end** [BLAZE]: with push on, a swap request / cover request / assignment arrives on a phone with the app closed; Normal types do not push; no type is notified twice; sign-out stops push; a stale token is pruned; the hourly cap holds. **Without Blaze, every type stays Normal and nothing breaks.** | P4-14 / P4-15 tests, [DEVICE] checklist H.2 |
| 7 | A local reminder fires at the configured offset **on a real Android phone with the app closed**; disabling one chore's reminders suppresses only that chore; after reboot and a timezone change reminders are still correct. | [DEVICE] checklist H.1 |
| 8 | The three reminder switches behave exactly as labelled, turning one off keeps the timings, and the screen says **why** a reminder is or is not coming. | P4-10/12/16 tests |
| 9 | Quiet hours, multiple reminders, overdue reminder, morning summary, 7-day / 60-item cap and stable ids are proven by pure planner tests. | Appendix F.1 |
| 10 | Points, levels, streak and badges are deterministic and **never decrease**; two phones syncing change nothing; finalised months are never recomputed. | Appendix C, P4-19 concurrency |
| 11 | **Stats are private by default:** `memberStats` is readable and writable only by its owner (admins included). The admin can change the setting to `levels`; each member must then opt in; **only level and badges are ever shared, never points, never a ranking**; switching back to private hides everything immediately. | Rules suite, P4-19 / P4-20 tests, UAT 7 |
| 12 | The daily celebration appears **once per day**, never on a cold start without a recent completion, and respects reduced motion. | Appendix D, P4-22 tests |
| 13 | No star ratings and no ranking anywhere. | Review checklist |
| 14 | Every audit type has bn + en activity text; the Activity feed filters and pages without growing a listener. | P4-04 completeness test |
| 15 | The inbox merges stored and derived items; the bell count is right; derived items vanish when resolved. | P4-17 tests |
| 16 | Accessibility: no unlabeled tappable, 200 % text without overflow in Bangla, contrast for all themes, tablet layouts at ≥ 840 dp. | P4-23 / P4-24 harness |
| 17 | Packages added are only `flutter_local_notifications`, `android_intent_plus`, `firebase_messaging` (+ the `functions/` project); Spark remains sufficient for everything except the optional push backend. | `pubspec.yaml` diff review, ADR 0020 |
| 18 | `docs/phase5_contract.md` exists and matches the data written. | P4-25 review |

---

## 7. Interaction matrix — who feeds whom

| Piece | Produced in | Consumed by |
| --- | --- | --- |
| `CardCatalog`, `DashboardResolver`, `DashboardPolicy` | P4-05 | Home, Customize screen, access-matrix screen + preview, tablet grid, listener test |
| `settings/dashboard`, `users/{uid}.preferences.dashboard` | P4-06 | `dashboardLayoutProvider` |
| `NotificationType` catalog, `DeliveryPolicy` | P4-09 | planner (skips Push types), admin delivery screen, push client capability, bridge, Cloud Function id table |
| `settings/notificationDelivery` | P4-11 | `effectiveModeProvider`, function `onInboxCreated`, admin screen |
| `ReminderPlanner`, `ReminderPrecedence` | P4-10 | orchestrator, explainer, settings "why" text |
| `ReminderScheduler` port | P4-10 → P4-13 | orchestrator, test notification, foreground bridge, diagnostics |
| `PushMessagingService`, `users/{uid}/devices` | P4-14 | `PushController`, function (reads tokens), diagnostics |
| `NotificationTapRouter` | P4-13 / P4-14 | local taps, push taps, `ActivityTarget` |
| `ActivityTarget` | P4-04 | activity feed, inbox, tap router |
| `VirtualInbox`, `ForegroundNotificationBridge` | P4-17 | inbox screen, bell, Manage-hub badge |
| `ScoreCalculator`, `StreakCalculator`, `BadgeEvaluator`, `LevelTable` | P4-18 | `StatsSync`, achievements UI, celebration |
| `memberStats` (private), `memberStatsPublic` (opt-in) | P4-19 | Hub Level card, achievements, family-levels strip, celebration |
| `CelebrationEngine` | P4-21 | `CelebrationHost` |
| `CoverCounter` | P4-18 | helpers strip, Helper badge |
| Audit types | P4-02 | settings use cases, rules mirror, `activityText` |

**Fourteen integration seams to test by hand once the slices are up:**
1. Complete a chore → Home progress ring, Today and Hub Level points update without restart.
2. Edit a template's offsets → exactly that chore's local notifications change on the help page.
3. Reassign a chore away from you → its local notifications disappear after the next sync; the new assignee gets `chore_assigned` (push if enabled).
4. Turn Chores off for the family → dashboard cards, reminders, achievements entry and inbox items vanish; data stays.
5. Change the language → pending local texts are re-planned; the device doc `lang` updates so the next push is in the new language.
6. Complete the last chore offline → celebration shows from cache; points queue; reconnect produces no duplicate.
7. A cover is accepted → Helper counter and helpers strip agree.
8. Change point values → current month changes, frozen months do not.
9. Revoke the exact-alarm permission → help page shows it; reminders still arrive late.
10. Switch theme and week start → every new screen and the planner follow.
11. **Manager hides "Fund balance" for Members → a Member's Home loses it at once; the Member's saved order is unchanged when it returns.**
12. **Promote a Member to Household Manager → Home re-resolves; the dormant prefs for newly allowed cards apply.**
13. **Admin switches `swap_request` from Push to Normal → no push is sent, the inbox row and bridge still work, and nothing is notified twice.**
14. **Admin sets stats visibility to `levels`, a member opts in, then admin sets it back to `private` → the public card disappears for everyone.**

---

## 8. Things to verify at implementation time **[VERIFY]**

| Topic | Why |
| --- | --- |
| `flutter_local_notifications` current version, README manifest snippet, desugaring + R8 requirements, `zonedSchedule` / `AndroidScheduleMode` names | P4-13 |
| `firebase_messaging` version compatible with `firebase_core 5.0.0`, Android 13 permission behaviour, background handler setup | P4-14 |
| Cloud Functions: supported Node runtime, 2nd-gen Firestore trigger region = Firestore location, current Admin SDK send method names, `maxInstances` | P4-15 |
| **Blaze plan:** payment method acceptance, free-tier numbers for Functions / Firestore / FCM, budget alert setup, no hard spend cap | P4-15, D-P4-21 |
| Play policy for `SCHEDULE_EXACT_ALARM` vs `USE_EXACT_ALARM`; Android 14 default | F-12, P4-13 |
| Pending-alarm limits on OEMs; boot reschedule | the 60-item cap |
| `android_intent_plus` actions for battery and exact-alarm settings | P4-13/16 |
| Spark daily free read/write quota | read-budget note (P4-25) |
| Existing `activity` read rule and fields | P4-04 |
| `PreferenceSync` extension points and the exact `preferencesOk` shape | P4-06, P4-11 |
| Rules `todayKey` helper name and its UTC+6 behaviour (ADR 0014) | P4-19 |
| Whether a `test` inbox type is worth the rules change for "Send me a test push" | P4-16 |

---

# Appendices

## Appendix A — Dashboard specification

### A.1 Anatomy (phone)

```text
┌──────────────────────────────────────────┐
│ 🧑  শুভ সকাল, সালমান        ⚙  🔔 ৩     │  GreetingHeader (avatar · greeting · Customize · bell)
│     সোমবার, ২ নভেম্বর                    │
├──────────────────────────────────────────┤
│ ⚠ বাজেট ৮৫% ব্যবহার হয়েছে      ›        │  AlertStrip (only when an alert exists and the role may see it)
│ ┌────────────────────────────────────┐   │
│ │ আজকের কাজ   ◔ ৩/৭ সম্পন্ন     ›    │   │  Today (ProgressRing)
│ └────────────────────────────────────┘   │
│ ┌───────────────┐ ┌──────────────────┐   │
│ │ বিলম্বিত  ▲ ২ │ │ যাচাই বাকি   ✓ ১ │   │  half cards pair on ≥ 600 dp
│ └───────────────┘ └──────────────────┘   │
│ │ এই মাসের খরচ │ ফান্ড │ আসন্ন │ লেভেল │ │  order and visibility come from the resolver
│ │ সাম্প্রতিক কার্যক্রম (৫টি)   সব দেখুন › │ │
└──────────────────────────────────────────┘
```

### A.2 Card catalog

| Card id | Module | Default order | Size | Source providers | Needs permission | Tap |
| --- | --- | --- | --- | --- | --- | --- |
| `budget_alert` | bazar | 10 | strip | `budgetAlertsProvider` | — | `/bazar/budget` |
| `approvals` | core | 15 | full | members + contribution providers | `approveMembers` or `recordContribution` | `/inbox` |
| `chores_today` | chores | 20 | full | `todayProgressProvider`, `todayItemsProvider` | — | `/chores/today` |
| `chores_overdue` | chores | 30 | half | `overdueItemsProvider` | — | `/chores` (overdue pinned) |
| `chores_verify` | chores | 40 | half | `verifyQueueProvider` | `verifyChore` | `/chores/verify` |
| `bazar_month` | bazar | 50 | full | `monthSpendProvider`, `budgetStatusProvider` | — | `/bazar/expenses` |
| `bazar_fund` | bazar | 60 | full | `fundBalanceProvider`, `contributionStatusProvider` | — (members see only their own contribution) | `/bazar/fund` |
| `upcoming` | core | 70 | full | `todayItemsProvider`, `monthItemsProvider` | — | `/chores/today` |
| `chores_week` | chores | 80 | full | `weekModelProvider` | — | `/chores` (week) |
| `hub_level` | chores | 90 | half | `memberStatsProvider`, `levelProvider` | — (own data only) | `/chores/achievements` |
| `recent_activity` | core | 100 | full | `recentActivityProvider(5)` | — | `/activity` |

A card is also hidden when its module is off or its source has nothing to show by design (e.g. the budget strip with no alert).

### A.3 Recommended default access per role (used until a manager changes `settings/dashboard`)

| Card | Admin | Household Manager | Member |
| --- | --- | --- | --- |
| `budget_alert` | on | on | off |
| `approvals` | on | on | hidden |
| `chores_today` | on | on | **required** |
| `chores_overdue` | on | on | on |
| `chores_verify` | on | on | hidden |
| `bazar_month` | on | on | on |
| `bazar_fund` | on | on | on (own contribution only) |
| `upcoming` | on | on | on |
| `chores_week` | on | on | off |
| `hub_level` | on | on | on |
| `recent_activity` | on | on | off |

Rationale: a Member's Home stays focused on their own day (Today is required), while money overviews are visible but optional, and manager-only work queues (approvals, verification) are hidden. A manager can change any cell except the Admin column. **Admin is always `on` and cannot be edited.**

### A.4 Visibility, privacy and honesty
Members see only **their own** contribution status; people with `recordContribution` see the family view (existing Bazar rule, unchanged). The Hub Level card shows only the viewer's own data. The role matrix is **presentation policy**: it hides cards, it does not revoke access (rule 67, F-18).

### A.5 Refresh semantics
Pull-to-refresh = `DashboardRefresh.run` (P4-07). It never blocks the UI on the network.

---

## Appendix B — Notification specification

### B.1 Channels

| Channel id | Name (bn / en) | Importance | Used for |
| --- | --- | --- | --- |
| `chores_due` | কাজের সময় / Chore reminders | high | local at-due and before-due reminders |
| `chores_overdue` | বিলম্বিত কাজ / Overdue chores | default | overdue reminder, evening nudge |
| `daily_summary` | সকালের সারাংশ / Morning summary | default | daily summary |
| `bazar` | বাজার ও ফান্ড / Bazar & fund | default | contribution due, month end |
| `family` | পরিবার / Family | default | local bridge for Normal inbox items |
| `push_events` | জরুরি বিজ্ঞপ্তি / Push alerts | high | every FCM push (set by the function as `channelId`) |

### B.2 Local notification ids
`id = FNV1a32("$kind|$refId|$discriminator") & 0x7fffffff`; kinds: `due`, `before`, `overdue`, `nudge`, `summary`, `contribDue`, `monthEnd`, `inbox`. A duplicate inside one plan is probed `+1`.

### B.3 Local scheduling rules
7-day window; ≤ 60 pending (nearest first); UTC instants converted with `tz` using the **family** timezone; exact when permitted else inexact; re-planned on every trigger of P4-12; stale ids cancelled by diff; **types whose effective mode is Push are never scheduled locally**.

### B.4 Payload → route allow-list (local payload and FCM `data.route` use the same table)

| Payload | Opens |
| --- | --- |
| `/chores/occurrence/{id}` | task detail (falls back to Today when the id is gone) |
| `/chores/today` | Today |
| `/bazar/fund` | fund screen |
| `/family/members` | members list (join requests) |
| `/inbox` | inbox |
| anything else | `/home` |

Payloads contain **a route only** — no names, amounts or ids of other people.

### B.5 Local copy (bn first; the owner reviews in P4-25)

| Kind | Title (bn) | Body (bn) |
| --- | --- | --- |
| at due | `{chore}` এখন করার সময় | সময়: {time} |
| before | `{chore}` — {offset} পর | {time}-এর মধ্যে সম্পন্ন করুন |
| overdue | `{chore}` বিলম্বিত | এখনও সম্পন্ন হয়নি |
| nudge | আজকের কাজ বাকি আছে | {n}টি কাজ এখনও বাকি |
| summary | সুপ্রভাত! | আজ আপনার {n}টি কাজ |
| contribution due | ফান্ডে জমার দিন | এই মাসের জমা এখনও বাকি |
| month end | মাস শেষ হচ্ছে | হিসাব বন্ধ করার সময় |

### B.6 What the app promises (and does not)
**Normal** reminders are scheduled **on this phone** from data it has already loaded. If someone assigns you a chore while your app is closed, a Normal type reaches you after you next open the app. **Push** types are sent by a server and reach a closed app — but only after the family owner has set up the push backend and an admin turned push on. If push is off or unavailable, those types quietly behave as Normal. This is shown on the help page and in the first-time permission explanation.

### B.7 Notification type catalog and recommended defaults (R1, D-P4-24)

Admin screen order. "Push-capable" = a stored event exists that a server can react to. The **recommended** column is the default written by `DeliveryPolicySettings.defaults()`.

| # | Type id | Category | Kind | Who receives | Push-capable | **Recommended** | Why |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `swap_request` | chores | event | the member asked to take a chore | yes | **Push** | A person is waiting for an answer and the app is usually closed. |
| 2 | `swap_result` | chores | event | the member who asked | yes | **Push** | Their plan depends on the answer. |
| 3 | `needs_cover` | chores | event | next available member / managers | yes | **Push** | A chore may go undone without action. |
| 4 | `chore_assigned` | chores | event | the member given a chore | yes | **Push** | A manager changed your day. |
| 5 | `chore_reopened` | chores | event | the assignee | yes | **Push** | Work must be redone. |
| 6 | `comment_attention` | chores | event | the assignee | yes | Normal | Informational; can wait for the inbox. |
| 7 | `verification_needed` | chores | event | verifiers | yes | Normal | Frequent; better batched in the inbox. |
| 8 | `absence_decision` | chores | event | the member who reported absence | yes | Normal | Informational. |
| 9 | `member_join_request` | family | event (member doc) | admins and Household Managers | yes | **Push** | Rare, and someone is waiting to get in. |
| 10 | `member_approved` | family | event | the joiner | yes | **Push** | They are waiting outside the app. |
| 11 | `chore_due` (at / before due) | chores | scheduled | the assignee | **no** | Normal | Computed on the phone; works offline. |
| 12 | `chore_overdue` | chores | scheduled | the assignee | **no** | Normal | Same. |
| 13 | `evening_nudge` | chores | scheduled | the assignee | **no** | Normal | Same. |
| 14 | `morning_summary` | chores | scheduled | each member | **no** | Normal | Same. |
| 15 | `contribution_due` | bazar | scheduled | members with an unpaid plan | **no** | Normal | Same. |
| 16 | `month_end` | bazar | scheduled | people who can close the month | **no** | Normal | Same. |
| 17 | `budget_alert` | bazar | derived | finance managers | **no** | Normal | Derived from live data; no server event. |
| 18 | `achievement` | chores | derived | the member | **no** | Normal | Private and computed on the device. |

**Rule of thumb behind the defaults:** use Push when *another person's action* needs your response or changes your day and waiting until you open the app has a real cost; use Normal for anything informational, frequent, or time-based. Types 11–18 become Push-capable only through the optional P4-26.

### B.8 Push message contract (shared by `functions/` and the app)

```text
notification: { title, body }            // generic, bn or en by the device doc's `lang`; no names or amounts
data:         { route, inboxId, type }   // route from the B.4 allow-list
android:      { priority: high, ttl: 24h, notification: { channelId: push_events, tag: inboxId } }
```
Inbox row after a send: `pushStatus: sent | no_devices | failed`, `pushAt` (written by the function only).

---

## Appendix C — Scoring tables (placeholders; the owner may change them in the app)

| Item | Easy | Normal | Hard |
| --- | --- | --- | --- |
| Base points | 10 | 20 | 30 |
| On time × verified-clean (1.2) | 12 | 24 | 36 |
| On time, not verified | 10 | 20 | 30 |
| Late (0.6) | 6 | 12 | 18 |
| Late × verified-clean | 7 | 14 | 22 (21.6 → half-up) |
| Cover bonus (+50 % of base, extra) | +5 | +10 | +15 |

Test cases (≥ 40) include: `completedAt == dueAt + grace` counts on time; reopened-then-completed loses the verified factor; skipped (absence) = 0 and does not break the streak; a cover completed late still earns the bonus; items before `startedOn` = 0; level at 99 / 100 / 249 / 250 points; streak: 6 full days + 1 paused + 1 full = 7 (pause neither counts nor breaks) — **[OWNER]** confirm whether a paused day should count toward the 7; month finalised once; spec change leaves frozen months alone.

---


## Appendix D — Celebration state table

| # | Situation | Decision |
| --- | --- | --- |
| 1 | Session saw 2/3 done, user completes the 3rd; not celebrated today | celebrate |
| 2 | Cold start, 3/3 done, `lastCelebrated == today` | none (banner optional) |
| 3 | Cold start, 3/3 done, not celebrated, last completion 10 min ago | celebrate |
| 4 | Cold start, 3/3 done, not celebrated, last completion 5 h ago | quietDone |
| 5 | 0 eligible chores today | none |
| 6 | Un-complete then re-complete after celebrating | none (already celebrated) |
| 7 | Done on phone A at 18:00, phone B opens at 21:00 | quietDone, and B reads `lastCelebratedDateKey` from stats once synced |
| 8 | Engagement off or celebration off | none (quietDone allowed) |
| 9 | Day rolls over at 00:00 Dhaka while the app is open | state resets for the new day |
| 10 | Another dialog is open at the moment of completion | celebrate, queued until idle |

---


## Appendix E — Working with the AI tool

### E.1 Prompt template (per step)
```text
Read CLAUDE.md and docs/PHASE4_DASHBOARD_ENGAGEMENT_ROADMAP.md sections 1-3 and the card for step P4-xx.
Inspect the actual files (the code may differ from the roadmap) and verify the steps this one depends on.
Implement P4-xx exactly as written. List the files you will create/edit before coding. Do not start another step.
I will run dart format / flutter analyze / flutter test. For [DEVICE] work, give me the manual checklist instead of claiming it works.
End with: files changed, how to verify, assumptions, and PROGRESS.md / CLAUDE.md updates.
Return only the changed files as a zip with the same folder structure.
```

### E.2 Milestones
* **After P4-07:** open Home → real greeting, progress ring, spend vs budget, recent activity; bell shows a count (if the inbox exists).
* **After P4-13:** on a phone: enable reminders, set a 2-minute test, swipe the app away, the notification arrives; the help page shows pending count.
* **After P4-22:** complete the last chore of the day → celebration once; open Achievements → plant and badges.
* **After P4-08:** on your phone drag a card to the top and hide another; as a manager hide "Fund balance" for Members and watch a Member's Home change.
* **After P4-15 [BLAZE]:** turn push on as admin; create a swap request on one phone and see it arrive on another phone with the app swiped away; set that type to Normal and confirm the push stops.

---


## Appendix F — Planner test tables (dates: Monday 2026-11-02; Dhaka = UTC+6, no DST)

### F.1 Cases (excerpt of the ≥ 35)

| # | Setup | Expected |
| --- | --- | --- |
| 1 | chore due 20:00, offsets [30], atDue true, global/category/template on | 19:30 and 20:00 |
| 2 | same, template `enabled == false` | none for this chore; other chores unchanged |
| 3 | global off, offsets saved | none; saved offsets still in settings |
| 4 | category chores off, bazar on | no chore ids; contribution reminders kept |
| 5 | quiet 23:00–06:00, reminder at 05:30 | moved to 06:00 (if not stale) |
| 6 | quiet 22:00–07:00, due 06:30, before-30 reminder = 06:00 | moved to 07:00 (after the due time but within due + 6 h ⇒ kept) |
| 7 | overdue enabled, 60 min | one at due + 60 |
| 8 | item reassigned to another member | not planned for the viewer |
| 9 | item skipped or completed | not planned |
| 10 | 70 candidates | 60 nearest, ascending |
| 11 | no `dueMinutes` | evening nudge at 19:00 only if open |
| 12 | 3 chores due today | one morning summary "আজ ৩টি কাজ" |
| 13 | 0 chores due today | no summary |
| 14 | two items with colliding hashes | second id probed +1 |
| 15 | plan twice with identical input | identical lists |
| 16 | `contributionDueDay = 5`, unpaid | 09:00 on the 4th and 5th |
| 17 | member lacks `closeBazarMonth` | no month-end reminder |
| 18 | locale en, digits bn | English words with Bangla digits |
| 19 | time before `now + 5 s` | dropped |
| 20 | 23:59 → 00:00 Dhaka boundary item | correct date key and instant |

### F.2 Orchestrator cases
Edit offsets → replace exact ids; sign-out → cancelAll; language change → texts replaced; resume with equal plan hash → zero scheduler calls; scheduler throws → diagnostics `lastError`, app continues.


### F.3 Delivery policy cases (P4-09)

| # | Setup | Expected |
| --- | --- | --- |
| 1 | master off, type `swap_request` set to Push | Normal, reason `masterOff` |
| 2 | master on, `swap_request` = Push, token + permission present | Push |
| 3 | master on, `swap_request` = Push, no OS permission | Normal, `noPermission` |
| 4 | master on, `swap_request` = Push, member opted out | Normal, `memberOptedOut` |
| 5 | `chore_due` set to Push in stored data | Normal, `notPushCapable` (value ignored) |
| 6 | unknown id in `modes` | ignored |
| 7 | fresh family (no doc) | every type Normal, master off; `defaults()` modes equal the B.7 recommended column |
| 8 | `comment_attention` = Normal, master on | Normal, `normalChosen`; the local bridge shows it, no push |
| 9 | planner input with `swap_request` effective Push | no local notification planned for it |
| 10 | Dart catalog ids vs `functions/src/delivery_policy.ts` ids | identical sets |

### F.4 Dashboard resolver cases (P4-05)

| # | Setup | Expected |
| --- | --- | --- |
| 1 | Member, default policy | visible: `chores_today` (required), overdue, month spend, fund, upcoming, hub level; not visible: approvals, verify |
| 2 | Member, `bazar_fund = hidden` | fund card absent, even if the user's prefs list it |
| 3 | Member, `chores_week = off`, user never touched it | hidden; appears in `optionalHidden` |
| 4 | same, user id in `shown` | visible |
| 5 | `on` card, user id in `hidden` | hidden |
| 6 | `required` card, user id in `hidden` | still visible, `canHide = false` |
| 7 | user order `[upcoming, chores_today]` | those first in that order, the rest by default order |
| 8 | stale id in `order` (removed card) | ignored |
| 9 | new `required` card, no stored position | placed at the top |
| 10 | role changes Member → Household Manager | `approvals` becomes available; dormant prefs for it apply |
| 11 | role changes back | `approvals` disappears; prefs kept, not deleted |
| 12 | Chores module off | all chores cards absent |
| 13 | card needs `verifyChore`, viewer lacks it, cell `on` | absent |
| 14 | Admin, policy says `hidden` for everyone else | admin still sees all available cards |
| 15 | policy contains an unknown card id and an unknown access value | unknown id ignored, unknown value ⇒ default |
| 16 | resolve twice with identical input | identical output |

---

## Appendix G — Questions for the owner and UAT

### G.1 Questions (defaults are used if you do not answer)

| # | Question | Default |
| --- | --- | --- |
| Q1 | Default local reminder: 30 minutes before + at due? | Yes |
| Q2 | Quiet hours 11 PM–6 AM and morning summary 7:00 AM? | Yes |
| Q3 | Evening nudge at 7 PM for chores without a time? | Yes |
| Q4 | Point values 10/20/30, late 60 %, verified ×1.2, cover +50 % as placeholders? | Yes |
| Q5 | Level thresholds 0/100/250/500/900/1400/2000/3000 and the plant stages? | Yes |
| Q6 | Does a paused day count toward the 7-day "Consistent" streak? | No |
| Q7 | "Reliable" only when a month is finished? | Yes |
| Q8 | Show "this month's helpers" to everyone? | Off |
| Q9 | Contribution-due reminder one day before and on the day? | Yes |
| **Q10** | **Do you want push now? It needs the Firebase Blaze plan (a payment method; no automatic spending cap). If no, push stays dormant and every type runs as Normal.** | **Build the code, deploy later when you decide** |
| **Q11** | **Is the recommended Push/Normal split in Appendix B.7 right?** (Push: swap request, swap result, needs cover, chore assigned, chore reopened, join request, approval.) | Yes |
| **Q12** | **Push text: generic only (no names), as in B.8?** | Yes |
| **Q13** | **Is the recommended default dashboard per role (Appendix A.3) right, especially "Today = required for Members"?** | Yes |
| **Q14** | **Should the Household Manager edit the dashboard matrix only while "moderator manages finance" is on (as you described), or always?** | Only while finance is on |
| **Q15** | **Stats stay private by default. Do you want the optional `levels` mode (members may opt in to show level and badges) available at all, or should the setting offer only Private?** | Available, default Private |
| **Q16** | **Can a Member's Home ever hide the "Today" card?** | No (required) |

### G.2 Optional later (not Phase 4)
Home-screen widget; WorkManager background refresh; scheduled push for time-based types (P4-26); sound customisation per chore; a per-type member mute for Normal types.

### G.3 UAT with the family (P4-25) — fourteen tasks
1 read the Home dashboard and open three cards · 2 find "who did what yesterday" in Activity · **3 (manager) hide the Fund card for Members and confirm a Member's Home loses it; set one card to Required** · **4 (any user) drag two cards, hide one, restart the app, confirm the layout stayed; reset it** · 5 enable reminders and receive a test notification · 6 turn one chore's reminder off and see why it stops · **7 (admin) turn push on, set one type to Normal, confirm a swap request arrives as push and a Normal type does not; sign out and confirm the phone stops receiving** · 8 open "Reminders not working?" and read the diagnosis · 9 clear the inbox · 10 complete the last chore of the day and see the celebration once · **11 open Achievements; confirm other members cannot see your points; (admin) switch stats to `levels`, opt in as a member, confirm only level and badges are visible, then switch back to private** · 12 switch language, theme and a tablet-width window · 13 use the app offline for five minutes and reconnect · 14 change a member's role and confirm their Home re-arranges. Record pass/fail in `docs/phase4_acceptance.md`.

---


## Appendix H — Real-device checklists (copied to `docs/reminders_manual_test.md`)

### H.1 Local reminders checklist

For **each of two Android brands**, Android 12 and 13+: (1) grant notifications; schedule a reminder 2 minutes ahead; swipe the app away; expect delivery · (2) enable battery saver; repeat · (3) restart the phone; before opening the app expect an already-scheduled reminder to fire; open the app and confirm the pending count · (4) change the device timezone to another zone and back; expect the help page to re-plan and the times to stay correct for Dhaka · (5) deny notifications; expect the banner and the help text; re-grant from system settings · (6) revoke "alarms & reminders"; expect the inexact fallback note and a late but delivered reminder · (7) force-stop the app from system settings; note that delivery stops until reopened (documented limit) · (8) tap a notification when the app is closed and when it is open; expect the right screen · (9) 60-item cap: create many chores and verify the pending count never exceeds 60. Record device model, Android version, result and a screenshot per row.


### H.2 Push checklist [DEVICE][BLAZE] (add to `docs/reminders_manual_test.md`)

For **each of two Android brands**: (1) with push on and a type set to Push, create the event on phone A; phone B has the app **swiped away** → expect delivery within seconds, correct language, no names in the text · (2) battery saver on; repeat · (3) app in the foreground → expect exactly one notification, not two · (4) tap from a closed app, a background app and a foreground app → correct screen each time; a module that is off → Home · (5) set the same type to Normal → no push, the inbox row still appears and the Normal bridge notifies once while the app is alive · (6) deny notification permission → the type falls back to Normal and the help page says why · (7) sign out → no further push to that phone; sign in as another user → the first user's events do not arrive · (8) reinstall the app → a new device doc, the old token is pruned after the first failed send · (9) send 31 events to one member in an hour → the 31st push is skipped, the inbox rows all exist · (10) set a quiet-hours window and create an event inside it → no push, the inbox row exists · (11) switch language → the next push is in the new language · (12) master switch off → nothing is pushed for any type. Record device model, Android version, result and a screenshot per row.
