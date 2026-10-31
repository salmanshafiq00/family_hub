# Family Hub - project context (read before every task)

You are a senior Flutter engineer building 'Family Hub', a Bangla-first household app (bazar and family finance + family chores) for one family. Android first, iOS-ready. Backend: Firebase Auth + Cloud Firestore on the free Spark plan. No Cloud Functions, and no hard dependency on Cloud Storage.

ARCHITECTURE: feature-first Clean Architecture. Each feature has data/, domain/, presentation/. domain is pure Dart (no flutter or firebase imports). presentation never touches Firestore: screen -> Riverpod controller -> use case -> repository interface. data implements repositories and maps Firestore documents to domain entities through mappers.

## HARD RULES
1. Money is integer paisa in a Money value object. Quantities are integer milli-units. Never double.
2. Time-based records store a UTC Timestamp plus dateKey (yyyy-MM-dd) and monthKey (yyyy-MM) computed in the family timezone (default Asia/Dhaka). Use an injected Clock; never call DateTime.now() in domain code.
3. All writes go through use cases. A use case checks permission (PermissionPolicy), applies business rules, writes through a repository, and writes audit and activity entries in the same batch/transaction where required.
4. Deterministic IDs: occurrence ids are `{templateId}_{yyyyMMdd}` for the `main` slot and `{templateId}_{yyyyMMdd}_{slotKey}` for other slots (never `add()`; ADR 0009); budgets {yyyy-MM}; contribution plans {yyyy-MM}_{memberId}.
5. Soft delete only (deletedAt, deletedBy). Every document has createdAt, createdBy, updatedAt, updatedBy, schemaVersion.
6. No raw Color(0x...) or hex outside lib/app/theme/. Screens read tokens via context.tokens.
7. No hard-coded user-visible strings. Use ARB localization (bn default, en). Test long Bangla strings for overflow.
8. Riverpod (Notifier/AsyncNotifier), immutable hand-written models with ==/hashCode/copyWith (no code generation; see docs/decisions), go_router with auth and family guards.
9. Use cases return Result<T> with a sealed AppFailure. UI maps failures to localized messages. No silent catches.
10. Business rules live in domain with unit tests. Every screen handles loading, empty, error and offline states.
11. Queries are bounded by a monthKey/dateKey range and a limit. One listener per screen; cancel on dispose.
12. Every permission is enforced in Firestore Security Rules as well as the UI.
13. Accessibility: touch targets >= 48dp, status never by color alone (icon + label + color), text scales with system font size.

## Layer boundaries
| Layer | May import | Must never import |
| --- | --- | --- |
| presentation | domain, shared, core | data, firebase packages |
| domain | Dart core, freezed, core value objects | flutter, firebase, any I/O |
| data | domain, firebase packages | presentation |

Naming: snake_case files; FooRepository (interface), FirestoreFooRepository (impl), FooController, FooScreen, FooMapper, AddFooUseCase. One class per use case file. Split widget files over ~300 lines.

## Folder structure
lib/ main_dev.dart, main_prod.dart; app/ (app, router, bootstrap, flavor, theme/); core/ (errors, utils, firebase, localization, notifications, permissions, constants); shared/ (widgets, services); modules/; features/ auth, onboarding, family, dashboard, settings, notifications, bazar/{expenses, items_categories, budgets, contributions, advances, reports, import, fund, settings}, chores/{settings, templates, duty_groups, occurrences, calendar, rota, swaps, availability, comments, achievements} (each: data/ domain/ presentation/; `calendar` and `rota` have no data layer), notifications (module-neutral inbox: data/ domain/ presentation/). test/ mirrors lib/. firebase/ holds firestore.rules, firestore.indexes.json, rules_test/.

## WORKING METHOD
Before coding, list the files you will create or change. Write tests together with the code. Afterwards run dart format, flutter analyze and flutter test and report the results. Do not add packages not named. When something depends on current Firebase pricing, quotas, or package versions, check official docs instead of guessing. If an instruction is ambiguous, state your assumption and continue; ask only when a wrong guess would be expensive. End every task with: files changed, how to verify, anything you assumed.

## DEFAULT DECISIONS (until changed)
Teal accent token; chore verification off by default; absence policy A (ask for cover); members see only their own contributions; equal-split contributions; onion and potato are items under Vegetables; client-side scoring; Hub Level shown as a plant; Android only; Spark plan only.

## Rules extension (from Step 10 onward)
Every step that adds a collection must extend `firebase/firestore.rules` AND the rules tests in `firebase/rules_test/` in the same commit. For every rule there must be one allowed case and one denied case. Run them with:

```
npx firebase emulators:exec --only firestore --project demo-family-hub \
  "npm --prefix firebase/rules_test test"
```
(a JDK 21+ must be on `JAVA_HOME`/`PATH`; CI runs this in the `rules` job).

## Routing and session (from Step 8)
- Navigation is decided only by `lib/app/router.dart` (guards = `resolveRedirect`). Screens never navigate on auth/membership changes themselves.
- Providers live in `presentation/` (or `app/`), never in `domain/`. `test/architecture/layer_boundaries_test.dart` enforces the layer table.
- Anything marked `TODO(step-9)` (placeholder session, gate screens) is throwaway and must be deleted in Step 9.

## Data model additions (from Step 9, extends roadmap 12.2)
- `users/{uid}`: profile fields (`fullName`, `nickname`, `gender`, `relationship`, `spouseId`, `avatarKey`), **`familyId`** (set when the user creates or joins a family), and `preferences {themeId, themeMode, language, banglaDigits}`.  "Has a profile" means `fullName` is non-empty (the document may exist earlier because preferences are merged into it).
- `inviteCodes/{code}` -> `{familyId, role, status active|used|revoked, expiresAt, createdBy, usedBy?}`; **exact-id `get` only, never `list`**.  Mirrored at `families/{id}/invitations/{code}`.  Codes are single-use, 8 characters from `ABCDEFGHJKMNPQRSTUVWXYZ23456789`, valid 7 days, role `member`.
- `families/{id}/members/{uid}` carries denormalised `fullName`, `nickname`, `relationship`, `spouseId`, `avatarKey`, `inviteCode` and `removedAt` (a rejected request is soft-deleted; the person returns to family choice and may join again).
- `families/{id}/settings/{general,modules,rotationPolicy,notificationDefaults}` are created with the family.
- Every family use case writes its activity + audit entry in the same batch (`AuditEvent` via `AuditWriter`).

## Permissions (from Step 10)
- One matrix, `lib/core/permissions/permission_policy.dart`: `PermissionPolicy.can(actor, permission, {ownerId, settings, template})`. One `Permission` per row of the roadmap 2.2 matrix; `PermissionActor` is the member reduced to `{uid, role, isActive}` so `core/` never imports a feature; `Member.permissionActor` builds it. `PermissionSettings` carries the module switches and the family verification switch, `PermissionTemplate` the per-template switch.
- `Role` lives in `core/permissions/role.dart`; `features/family/domain/member_role.dart` re-exports it and keeps `MemberRole` as a typedef, so old call sites still compile.
- Every mutating use case calls `requirePermission(...)` in `features/family/domain/permission_access.dart` FIRST. `leavesNoActiveAdmin` (same file) is the last-admin guard; rules cannot express it (a subcollection cannot be enumerated).
- The UI uses `PermissionGate` (`lib/shared/widgets/`): `hide` removes the action, `disable` dims it, blocks it and shows a localized reason (icon + label, never colour alone). The gate takes a `bool`, so no Firebase and no feature import reach the widget.
- Backend mirror: `firebase/firestore.rules` **v2.0** (Step 10 + H4 + H5) with `isMember(f)`, `role(f)`, `isAdmin(f)`, `isMod(f)`. It is tested by `firebase/rules_test/` against the emulator; the roadmap's own permission matrix was never available in this repo, so the table at the top of `permission_policy.dart` is the source of truth.
- H5 hardening of the rules: every member write is validated by `memberProfileOk` (`fullName` 1-80, `nickname`/`spouseId`/`avatarKey` <=40, `inviteCode` <=16) and every `users/{uid}.fullName`/`nickname` by the same limits; members, families, invites, settings and logs use a closed key set (`keys().hasOnly`, lists in ONE place as `*Keys()` and mirrored by `test/contract/rules_key_sets_test.dart`); an `activity`/`auditLogs` create must be by its own actor with a known `type`/`refType`, a bounded `refId`, at most 8 `params` and a SERVER `recordedAt` (never the client `createdAt`); an invite can only be burned in the SAME batch that creates the caller's pending member document; and **every mutating action except the owner's own `users/{uid}` needs a verified email** (`verified()`). Real mapper output is pushed through the emulator by `firebase/rules_test/contract.test.mjs` from fixtures generated by `test/contract/rules_fixtures_test.dart` (CI regenerates them and fails on drift).

## One permission source (H7)
- The UI asks `ref.can(Permission.x, {ownerId})` / `canProvider(PermissionQuery(...))` (`features/family/presentation/permission_providers.dart`) and passes the answer to `PermissionGate`. `currentActorProvider` is derived from the membership; `permissionSettingsProvider` merges `families/{f}/settings/permissions` with the module flags. Nothing in `presentation/` or `shared/` may test a role (`.isAdmin`, `MemberRole.admin`, ...): `test/architecture/no_role_checks_in_ui_test.dart` fails if it does. `Membership` carries the role as data only.
- `families/{f}/settings/permissions` = `{moderatorManagesFinance: true, membersViewFamilyReports: true, membersViewAllContributions: false, membersCanInvite: false, choreVerificationEnabled: false}`, created with the family, readable by active members, writable by admins (`UpdatePermissionSettings`). `requirePermission` loads it when the caller passes no `settings`.
- `FamilyModule.requiredPermission` is a `Permission?`; the shell builds its tabs from `visibleModulesProvider` (enabled AND permitted).
- `docs/permission_matrix.md` is generated from `PermissionPolicy` by `test/core/permissions/permission_matrix_doc_test.dart` (regenerate with `UPDATE_PERMISSION_MATRIX=1`). The owner ratifies it (decision D6).

## Pure domain and one audit writer (H8)
- Every audit/activity entry is an `AuditEvent` (`core/audit/`) written ONLY through `AuditWriter.write(batch, familyId, event)` (`core/firebase/audit_writer.dart`) in the same batch as the change. **Every Phase 2 repository must use it.** Event types are the constants in `AuditEventType` (mirrored in the rules).
- `domain/`, `core/permissions`, `core/errors`, `core/audit` and `core/utils` (except `clock_provider.dart`) are pure Dart, proven transitively by the import-graph test `test/architecture/layer_boundaries_test.dart`. `clockProvider` lives in `core/utils/clock_provider.dart`; `ModuleFlags` in `features/family/domain/module_flags.dart`.
- `familyFailureMessage` and `authFailureCode` are exhaustive switches; `test/core/errors/failure_messages_exhaustive_test.dart` fails when an `AppFailure` subtype is added without a sample.
- `test/architecture/no_step_todos_test.dart` fails on any `TODO(step-` in `lib/` or `test/`.

## Shared widgets and the gallery (from Step 11)
- Every reusable widget lives in `lib/shared/widgets/` and is reachable from the debug-only component gallery at `/dev/gallery` (`lib/app/gallery/`, dev flavour only; entry point next to the theme-tokens tile in the Family tab). Widgets take plain values: no Firebase and no feature import may reach them.
- `lib/app/gallery/gallery_sections.dart` is the single source of truth. A widget is "in the gallery" only by being listed there, and `test/shared/widgets/gallery_golden_test.dart` and `widgets_overflow_test.dart` both iterate that list, so adding a widget (with all of its states) once gives it goldens and overflow coverage.
- A widget that shows a status is announced **once** to assistive tech: `Semantics(label: ...)` with `excludeSemantics: true` (or `ExcludeSemantics` around the visual child), and never by colour alone (rule 13). `MoneyText` and `ProgressRing` replace the platform announcement with a localized label.
- Golden images live in `test/shared/widgets/goldens/` (11 widgets x 2 themes x 2 languages = 44 PNGs). Regenerate after an intentional visual change with `flutter test --update-goldens test/shared/widgets`; the tests skip *with a reason* when the directory is missing, so a fresh clone is green.
- `widgets_overflow_test.dart` renders every section at text scale 2.0 in both themes and both languages (bn/en) and fails on any overflow: this is the mandatory long-Bangla-string check for new widgets.
- Test harness: `test/shared/widgets/shared_widgets_test_support.dart` (`pumpSharedWidget`) - 320dp wide, both themes, `disableAnimations`, plus the `sharedPreferencesProvider` override that Riverpod-backed widgets (`MoneyText`, `ProgressRing`) need. `MoneyText` and `ProgressRing` read the active locale through `appFormattersProvider`, so any test that pumps them needs `SharedPreferences.setMockInitialValues({})` + `sharedPreferencesProvider.overrideWithValue(prefs)`.
- Golden/overflow tests use `createTestImage` inside `tester.runAsync(...)`: it talks to the engine and never completes inside the fake-async zone.
- Gotcha: `flutter analyze` exits **1 on any issue, including info-level lints**, and CI runs it without `--no-fatal-infos`. The tree must be lint-clean, not just error-free.

## Rules added by the Phase 1 hardening (H1-H13)
14. Offline-first: a "does not exist" snapshot that isFromCache is UNKNOWN, never "absent". Routing/guard decisions use only server-confirmed or cached-and-existing data.
15. Writes go through `guardWrite`. A commit that has not been acknowledged after the ack wait is treated as QUEUED (it will sync later), never as a failure. Retries reuse the same document ids (generate ids once per user intent, not once per attempt).
16. Onboarding and administrative actions (create family, join, approve, reject, role change, transfer admin, leave, cancel, revoke, settings) require the server and fail fast with Network when offline.
17. A user belongs to at most ONE family at a time (enforced in use cases AND rules).
18. Audit/activity entries are written ONLY through AuditWriter (H8), in the same batch as the change. They carry a type + params, never display text.
19. UI permission checks use PermissionPolicy (via canProvider / PermissionGate). `presentation/` must not test roles directly (isAdmin, MemberRole.admin ...). A test enforces it (H7).
20. Every rules `create`/`update` validates field types, string lengths and the closed key set (keys().hasOnly). Every rule has one allowed and one denied test, and the Dart mappers' real output is pushed through the rules in a contract test (H5).
21. domain/ and core/ (except core/firebase and core/localization) are pure Dart: no flutter, firebase, riverpod or go_router imports, directly OR transitively. A graph-based test enforces it (H8).
22. No `Colors.*` (except Colors.transparent) and no `Color(0x` outside lib/app/theme/.
23. No TODO(step-N) may survive its step.
24. Goldens are generated on Linux only (Update goldens workflow). Locally run `flutter test --exclude-tags golden`.

## Part C additions (H9-H12)
- **Account lifecycle (H9):** `ChangePassword` / `ReauthenticateWithPassword` / `DeleteAccount` (`features/settings`, screen `/settings/security`, NOT in `alwaysOpen`). Deletion order: re-authenticate -> leave family (a sole admin of a family with other members gets `Conflict('last_admin_has_members')`) -> soft-delete `users/{uid}` (`deletedAt`, `deletedBy`, PII cleared, names kept) -> delete the Auth user; every step is resumable. Sign-out raises `CacheWipe` (`core/firebase/cache_wipe.dart`); `initializeFirebase(prefs:)` clears the Firestore cache at the next start, before Firestore is used.
- **Events (H10):** no use case sets `summary`; they pass `params`. Localize with `activityText(type, params)`.
- **Relationships (H10):** stored as a `RelationshipId`; the family's list is `settings/relationships` (`RelationshipCatalog`, `UpdateRelationshipCatalog`, screen `/family/relationships`); built-ins are locked. Rules check the id by pattern, not an enum.
- **Action providers (H10):** `newActionProvider()` is `autoDispose`; never reset one by hand.
- **Colours (H11):** foregrounds on placeholder colours come from `placeholderOnLight` / `placeholderOnDark`; `no_raw_color_test` forbids `Colors.*` (except `transparent`) and `Color.fromRGBO/ARGB` outside `lib/app/theme/`.
- **File size (H11):** `file_size_test` caps lib files at 300 lines (documented allow-list).
- **Phase 2 foundations (H12):** dates only through `FamilyDateKeys` (`familyDateKeysProvider`); starter data only through `FamilySeeder`s given to `CreateFamily`; one batch <= 500 writes (`kMaxBatchWrites`, enforced by the runners); collection reads need `.limit(` (`no_unbounded_queries_test`); follow `docs/new_collection_checklist.md` for every new collection.

## Phase 2 rules (Bazar & finance)
25. Money fields in Firestore are integer paisa named *Paisa; quantities are integer *Milli. Never double/num.
26. Everyday writes (expense, trip, contribution, budget, custom item) are ONE batch, NO server probe, so they queue offline. Money-integrity writes (settle advance, close/reopen month, import, undo import, catalog backfill, settings) need the server (probe + transaction/batch).
27. A use case builds a pure write plan; the repository stages it. domain/ never sees TxRunner or Firestore types.
28. fundTransactions, settlements and expense revisions are append-only. Corrections are NEW compensating rows. The original expense/ledger row is never edited by a later settlement or correction.
29. Fund balance is never stored as a mutable number; it is computed from the ledger window (ADR 0007).
30. Reports/budgets/dashboards share ONE spend aggregation (MonthSpend/ReportEngine). Soft-deleted expenses are excluded everywhere.
31. A closed month rejects every write dated in it (use case AND rules). Only ReopenMonth (Admin or Household Manager, with a note) changes that.
32. Every new collection follows docs/new_collection_checklist.md in the same commit; new audit types/refTypes go in AuditEventType AND rules eventTypes()/refTypes().
33. Screens read derived providers (bazar_providers.dart); only providers call use cases/repositories.

## Phase 2 additions (P2-10 to P2-12)
- Providers: screens read `selectedMonthProvider`, `monthExpensesProvider(month)`, `monthSpendProvider`, `filteredExpensesProvider`, `fundBalanceProvider`, `monthLockedProvider`, `openAdvancesProvider`, `catalogIndexProvider`, `bazarSettingsProvider`; only providers call use cases/repositories. Repository providers are overridden in `bootstrap.dart`.
- A rules check is not a filter: any query a plain member runs over `memberAdvances`/`settlements` must be narrowed to their own uid (see `openAdvancesProvider`).
- Paged range queries order by `(dateKey DESC, document id DESC)` and resume with `startAfter([dateKey, id])`.
- New shared widgets (all in the gallery via `gallery_sections_p2.dart`): `MonthSwitcher`, `AmountField`, `TotalDisplay`, `ProgressBarStatus`, `DaySectionHeader`, `PersonPicker`, `CategoryBadge`. `AmountField` never parses; controllers use `Money.parse` / `Quantity.parse`.
- ARB keys are added to `app_bn.arb`, `app_en.arb` AND the three generated files when no SDK is available; `flutter gen-l10n` must then show no diff.

## Phase 2 additions (P2-13 to P2-16)
- Entry forms (add/edit expense, trip line) read amounts only through `readAmountInput` (domain): quantity x unit price wins over a typed total, a lone quantity or price is an error, text is parsed with `Money.parse`/`Quantity.parse`.  Never parse in a widget.
- A form controller generates its ids (`expenseId`, `eventId`, `newItemId`, trip and line ids) once, keeps them across failed saves, and only `Save and add another` makes new ones.
- Lists are flattened with `buildExpenseListItems` and shown with `ListView.builder`; never build a day group as one big widget.
- Catalog edits that are not covered by an Add/Update/Deactivate use case go through `ReactivateCategory`, `ReactivateItem`, `ReorderCategories`; the UI never calls `CatalogRepository` directly.
- Every mutating control on the catalog and settings screens is hidden or disabled with `PermissionGate`/`ref.can(Permission.manageCatalogAndBudgets)`; people without it see a read-only banner.
- Undo after a delete captures everything it needs (use case, ids, messenger) BEFORE the first `await`, so it keeps working after the screen closes.
- New Bazar routes are nested under `/bazar`; `expenses/new` is declared before `expenses/:id`.

## Phase 2 additions (P2-17 to P2-18)
- Budgets: `budgets/{yyyy-MM}` is a plan, never a ledger row. `SaveBudget` / `CopyLastMonthBudget` run `prepareBudget` (trim names, `quantity x rate` totals, **Dry-groceries estimate = sum of the lines**, zero total = sum of the category estimates). Everyday write: one batch, no probe, queues offline; a closed month does not block it.
- Levels come only from `ComputeBudgetStatus` (exact integer compare) fed by `monthSpendProvider` (rule 30) and the live `settings/bazar.alertThresholds`. Screens read `budgetStatusProvider(month)` / `budgetAlertsProvider`; alerts never block an expense and the Add Expense form never reads them.
- The budget editor keeps TEXT drafts in `budgetControllerProvider(month)`; only `readLineDrafts` / `readCategoryTexts` / `readTotalText` (domain) parse them. A controller makes a new `eventId` after each successful save (log entries are never rewritten).
- `Budget.createdAt/createdBy` are carried so a re-save keeps the author without a read; the rules do not freeze them on update.
- Rules sizes for a budget: 40 category estimates, 150 lines, 4 thresholds (`budgetOk`); the app tolerates a malformed entry when reading.

## Phase 2 additions (P2-19)
- Contributions: only an APPROVED, non-voided contribution is received money and has a ledger row (`con_<id>`). A member's `RequestContribution` writes `pending` and NO ledger row; a manager's `RecordContribution` writes `approved` + the `con_<id>` row in ONE batch. Decisions (approve, reject, change approve/reject), void and the opening balance need the server and read the contribution fresh (`getContribution(fresh: true)`).
- A changed contribution is written as the WHOLE document (`ContributionWriteStager.contribution`); optional fields are left OUT when absent (the rules test `!('fundTxId' in d)`). The rules allow each transition only by its exact changed keys (`contributionUpdateOk`); add a transition there AND in `contributions.test.mjs`.
- Corrections are new rows: a change approval writes `adj_<eventId>` (delta) or the `_out`/`_in` pair when the month changes; a void writes `adj_<eventId>` of `-amount`. The `con_<id>` row is never edited.
- Plans: `contributionPlans/{yyyy-MM}_{memberId}`; `GenerateMonthPlans` never overwrites an override. Every active member reads all contributions and plans (D-P2-5): no role filter in any provider.
- `RecordOpeningBalance` needs `Permission.editFamilySettings` (admin) because only an admin may write an `opening` row (open point for P2-21 `CloseMonth`).

## Phase 2 additions (P2-21 to P2-22)
- `opening` rows are now writable by `financeManager(f)` (admin, or moderator while `moderatorManagesFinance` is on) — the same people `closeBazarMonth` admits, because `CloseMonth` writes the carry-forward row. That resolved the P2-19 open point; `RecordOpeningBalance` keeps the stricter admin permission.
- `CloseMonth` / `ReopenMonth` are money-integrity writes (server probe + ONE batch).  The carry-forward is a pure rule (`MonthCarryForwardRules`): no `open_<next>` row -> one `opening` row; a row already there (re-close after a reopen) -> one `adj_<eventId>_carry` row of the delta; a zero delta writes nothing.  The opening row is never edited.
- The closing balance is a SERVER read taken just before the batch (the SDK cannot query in a transaction).  `balanceDriftProvider` compares the stored closing with the ledger and the Fund screen warns a manager; Reopen -> fix -> Close repairs it.  `CloseMonth` reads the existing `open_<next>` row through `ExistingOpeningLedger` (one exact-id `get`), not a collection scan.
- The fund balance and the closing never double count: the closing writes no money, it only carries the balance into the next month's window.
- The Fund screen (`/bazar/fund`) reads only derived providers: `fundSummaryProvider`, `fundBalanceProvider`, `monthFundTransactionsProvider`, `contributionStatusProvider(month)`, `ledgerIntegrityProvider(month)` (managers), `balanceDriftProvider`, `fundWindowOverflowProvider`, `monthLockedProvider(month)`.  Every member sees every member's row (D-P2-5); mutating controls use `ref.can` / `PermissionGate`, never a role test.
- `checkLedger` judges only expense references: a live fund expense must sum to `-total`, a deleted/member-funded one to `0`, an expense-looking row with no expense is an orphan.  Contribution, settlement and month rows are never reported.
- The contribution sheet is driven by `contributionFormProvider(args)` (`ContributionFormMode` record / request / editPending / requestChange): one event id per sheet, text parsed only in `submit()`/`saveOpening()` through `Money.parse`, and a second tap while saving is ignored.
- 63 `fund*` ARB keys were hand-added to both ARBs and the three generated files; `flutter gen-l10n` must then show no functional diff.

## Phase 2 additions (P2-20 settlement, P2-23 screens)
- `SettleAdvance` builds its plan with the pure `buildSettlementPlan` from the advance the repository reads from the SERVER, so an overpayment (`overpayment`), a voided advance (`advance_voided`) or a missing one (`NotFound`) is judged on current state.  ONE batch: settlement + `stl_<id>` ledger row + the advance's `settled/status` update + audit.  The original expense and its `exp_` row are never touched, so no category total changes when a member is paid back.  Needs the server (rule 26).
- A settlement's audit entry uses `AuditRefType.settlement` (there is no `advance` ref type in the closed vocabulary) and carries the advance id in `params`.
- The Advances screen reads `openAdvancesProvider` (already narrowed to the caller's uid for a plain member — a rules check is not a filter) and groups with the pure `groupAdvances`; only people with `recordContribution` see the settle action.
- The settled history of one advance is shown on the expense detail (`watchSettlements(advanceId:)`); the Advances screen only filters the open list, so it never opens a second unbounded query.
- Month close is `closeBazarMonth` only: `MonthCloseScreen` shows a DERIVED preview (`monthClosePreviewProvider`) and the Close confirmation / Reopen note dialog.  Reopen needs a note of at least `kMinReopenNote` characters; the use case checks it again.
- `LockedMonthBanner` is the one closed-month notice for entry sheets (`monthLockedProvider(month)`); it renders nothing while the month is open.
- P2-23 ARB keys (`advance*`, `monthClose*`, `monthReopen*`, `monthClosedChip`) were hand-added to both ARBs and the three generated files.

## Phase 2 additions (P2-24 report engine)
- `features/bazar/reports/domain/` is PURE Dart: `ReportQuery` carries an ALREADY-RESOLVED `range` (the engine never reads a clock); `ReportQuery.resolve` / `.thisMonth` resolve a preset against an injected `today` and the family `weekStartDay`, and `withRange` rebuilds the query for the comparison period.
- `ReportEngine.build({expenses, query, budget})` applies the SAME `applyFilters` the expense list uses, so a report and a filtered list can never disagree, and it excludes soft-deleted rows.  One pass feeds every view (rule 30).  `ReportEngine.compare` uses `previousComparable` (previous full month/year or an equal-length range).
- Money is integer paisa everywhere: `averageMoney` (half-up) and `halfUpRatioBp` (half-away-from-zero, `null` base-free case handled by the caller) are the only division helpers.
- `days` is always every calendar day of the range, zero-filled and ascending; `shareBp` is `null` when the total is zero.
- Dry-grocery matching: a line by `itemId`, else by `normalizeSearch(name)`; each spent row is claimed by at most one line, and unplanned spend is appended with a zero estimate so `actual` never double counts.
- `loadRange` is the only report read: pages of `kReportPageSize` (500) via `queryRange` + `startAfter`, capped at `kMaxReportDocs` (5000) with a `truncated` flag; a failure returns the failure, never a partial report.  Only `memberId`/`funding` are pushed to Firestore (single-field filters); category/item filters run in the engine so the breakdowns stay complete.
- A future reports screen (P2-25) reads these domain types only; it must not re-aggregate.

## Phase 2 additions (P2-25 reports screen)
- `fl_chart` (`^1.3.0`) is the ONE chart dependency (D-P2-15).  Chart colours come only from `context.tokens.chart[0..9]` and `chartGrid` (rule 22); no `Color(...)` in the reports feature.
- `reportQueryProvider` resolves the preset against the injected clock AND `bazarSettingsProvider.weekStartDay`, so the family week-start setting re-resolves "This week" immediately (D-P2-12).  The domain stays clock-free.
- `reportRowsProvider(range)` reuses the LIVE `monthExpensesProvider` for a range that is exactly one whole month (zero extra reads, and it updates with a new expense); every other range goes through `loadRange`.  `reportDataProvider` runs the engine once and attaches `withComparison`; the screen never adds anything up (rule 30).
- `viewFamilyReports` decides the whole screen: with it, seven tabs; without it, ONLY the contributions tab (no TabBar), because contributions are visible to every active member (D-P2-5).
- Every chart is wrapped in ONE `Semantics(label:)` with `excludeSemantics` and a generated text alternative; the table beneath each chart is the accessible content.  `DataTable`s scroll HORIZONTALLY so bn at 2.0 text scale never overflows; chart `duration` is zero when `MediaQuery.disableAnimationsOf` is true.
- The pie caps at 10 slices (the token colours) and folds the rest into "Other", so `tokens.chart[i % length]` never crashes and the label list stays short.
- 56 `report*`/`chart*` ARB keys were hand-added to both ARBs and the three generated files; `flutter gen-l10n` must then show no functional diff.

## Phase 2 additions (P2-26 spreadsheet import)
- `features/bazar/import/domain/` is PURE Dart; `excel` is imported in ONE file, `data/xlsx_workbook_reader.dart`.  Cells are neutral (`String`, `int`, `DateTime`, `null`), numbers are converted to DECIMAL STRINGS immediately, so no float ever reaches money code.
- **Formula cells are dropped** (`null`): the library does not evaluate them, and `Bazar.xlsx`'s day/category totals are formulas the importer recomputes.
- `cleanLabel` strips emoji/symbols from both ends; `labelKey` = `cleanLabel` + `normalizeSearch`, so one normaliser compares every label.
- `parseExpenseRows`: date CARRY-FORWARD over blank date cells, `0`/blank price rows skipped (placeholders, not errors), and every bad row COLLECTED as an `ImportRowIssue` — never thrown.  `today` is injected for the `future_date` check.
- The label table (`category_mapping.dart`) maps `পিয়াজ`/`আলু` to an item id, but generic labels (`সবজি`, `বাজার`, `মাছ`) NEVER link a catalog item; an unknown label stays unresolved for the wizard, never a guess.
- `parseBanglaQuantity` is integer-only: fractions round half-up to milli-units (`১/৩` -> 333); `১০০ টাকার` is value-based and carries no quantity.
- The dry-grocery table's typed `মোট` wins over `quantity x rate`; a blank amount (electricity in Oct-26) becomes `SkippedEstimateLine(no_amount)`.
- `planImport` writes nothing: it produces `ImportPlan` + `ImportReport` (`sheetTotal` vs `importTotal`, `reconciles`) for the wizard to confirm (P2-27).

## Phase 3 rules (Chores) - binding from P3-01

Source of truth: `docs/PHASE3_CHORES_ROADMAP.md` (sections 1-3 and the step card); the decisions are restated in `docs/decisions/0009`-`0013`.

34. No literal option list (group, due-time preset, absence reason, calendar view) in chores presentation code; lists come from the `settings/chores` providers (D-P3-4).
35. Dates, assignees and statuses are derived only by the pure engines `RecurrenceEngine`, `RotationEngine`, `OccurrenceGenerator`, `effectiveStatus`, `SubtaskSync` and `CalendarMonthModel`; widgets never compute them.
36. The stored `status` is a cache. The UI reads `ChoreItem.status` (effective), never `occurrence.status` directly (ADR 0012).
37. One Firestore listener per visible month; scope ("mine / family") and filters are in memory; no per-day queries.
38. Occurrence documents are written with deterministic ids only (ADR 0009).
39. Occurrence snapshots (`nameBn`, `subtasks`, ...) never change except by `ReplanOccurrences` on unstarted documents.
40. Reassign, swap, reopen, skip, exception and absence need a reason (3-300 characters) collected by the shared `ReasonSheet`.
41. Rotation follows the calendar, never "who completed last"; every rotation version snapshots its own `weekStartDay`.
42. Comments are never deleted; managers may hide one with a note.
43. Calendar targets are at least 48 dp; status = glyph + label + colour; honour reduced motion.
44. Only the packages in roadmap Appendix D may be added in Phase 3 (`animations`, `flutter_slidable`); anything else needs an ADR.
45. Rules limits (Wave R3): the occurrence rules cannot read WHICH `subtaskDone` keys are ticked nor who ticked one (`subtaskDone.size() >= requiredCount` also counts optional ticks). The use cases enforce the exact required set and the tick author; never relax a use case because "the rules allow it". Any new transition needs a rules test AND a Dart state-machine row.
46. The occurrence rules' `todayKey` is fixed to UTC+6 (Asia/Dhaka, no DST) and ignores `settings/general.timezone` (ADR 0014). Do not compare it with a family-timezone date in another timezone; if the timezone setting is ever honoured, change the rules, the ADR and the rules tests together.

**P3-01 seams.** The Chores tab is `ChoresHomeScreen` (route `/chores`; the calendar replaces its body in P3-22). `/chores/manage` is `ChoresManageScreen`, which renders `choresEntries` (`lib/features/chores/chores_entries.dart`) and hides a tile the viewer lacks `requires` for. Every later step appends one `ChoresEntry`; new routes are child routes of `ChoresModule`'s `/chores` route and constants in `AppRoutes`. ADR files live in `docs/decisions/` (the roadmap card says `docs/adr/`; this repo already uses `decisions`).
47. Completion patches (Wave R4): "is a required step open?" and "tick the optional steps" live only in `SubtaskSync.completionPatch`; use cases add permission, event and audit. A use case that loaded the member and `PermissionSettings` through `loadOccurrenceContext` asks `context.require(...)` / `checkPermission(...)` and never calls `requirePermission` again (one read per tap, rule 26). `stateFailure` must name the real cause, never default to `not_assigned_to_you`. `ChoreItem` is changed only through `copyWith`.
48. Chore list rows (Wave R5): every row is a `ChoreTile`; a swipe is a `Slidable` pane that exists ONLY when its action can work (open status, `mayComplete`, not projected), and every swipe action is also a `CustomSemanticsAction` on the tile. A projected item is never opened (U-03). A tile's `trailing` stays outside its `excludeSemantics` node. Screens that read a listener show loading only while there is NO value, an `ErrorView` with Retry when it failed with no value, and a distinct "all done" state; progress is computed from the list a screen shows (`TodayProgress.of`). A screen that must act on the first non-null document uses `ref.listenManual(..., fireImmediately: true)`, never a one-shot post-frame read.
49. Parity (Wave R6): a chore transition that both a use case and a rule decide is added to `firebase/rules_test/fixtures/occurrence_transitions.json`, which `occurrence_transition_parity_test.dart` and `chore_occurrence_parity.test.mjs` both run. Never add a case on one side only, and never edit the table to make a failing side pass. `no_hardcoded_options_test` guards rule 34: a seed id (`seedOptionIds`) may not appear as a quoted literal in chores presentation or `lib/shared/widgets`.
50. Duty groups (P3-18): a group stores NO chore list; "add a chore" edits the template's `assignee.dutyGroupId`. A stored rotation changes only through `ChangeRotation` (the sheet previews the same `RotationBuilder` result), then the controller re-plans from the boundary; a planning failure is reported with Retry and never undoes the stored change. Screens read `dutyGroupsStreamProvider` for loading/error, `dutyRosterProvider` (active) / `dutyMemberIndexProvider` (everyone) for names, and never show a raw uid.
