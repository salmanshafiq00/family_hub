# Phase 5 data contract

This contract describes Phase 4 data that a later phase may consume. It does
not grant permission to broaden visibility or change existing write semantics.
The implementation and the applicable Firestore rules remain authoritative.

## Stable inputs Phase 5 may consume

- **Chore occurrences:** use the occurrence domain model and
  `monthItemsProvider` for the displayed month. It combines stored and
  projected occurrences by deterministic id (stored wins), applies display
  status, and is the shared source for calendar/dashboard consumers. Do not
  create a second unbounded occurrence listener or recompute status in widgets.
- **Activity:** consume bounded, paged activity entries (`type`, actor uid,
  reference, params, recorded time). Resolve names through the established
  presentation/localization path. Do not treat localized summary text as
  persisted data or add personal details to audit params.
- **Chore completion and covers:** use the existing occurrence state and
  `CoverCounter`/domain calculation. A cover represents who completed the work;
  skipped work counts for nobody. Do not infer cover totals from UI labels.
- **Member stats:** `memberStats/{uid}` is private to its owner, including
  against administrators. It contains points, streak, monthly aggregates,
  badges, and progress markers. It is not a Phase 5 export, ranking, or
  cross-member report source.
- **Public level card:** `memberStatsPublic/{uid}` is opt-in and points-free.
  It may expose only the approved level/badge fields when family visibility
  permits and the member has opted in. It does not expose points, rankings, or
  private stats.
- **Notifications:** consume inbox rows and existing notification settings
  through their repositories/providers. Derived inbox entries are virtual and
  are not persisted. Reminder/device settings are not report/export data.
- **Bazar/finance:** consume the existing bounded report and month-spend
  providers/domain outputs. Do not recompute report totals or read private
  member stats to enrich finance reports.

## Deliberately not computed or promised

- Cross-member points totals, rankings, exports, or public point histories.
- A server-side push sender or scheduled push sweep on the Spark-only setup.
- Historical stats for data outside the configured scoring/finalization window.
- A denormalized mutable fund balance or a second dashboard/report aggregation.
- User-visible localized strings as a stable storage/API contract.
- Device delivery guarantees inferred from reminder plans or emulator tests.

Any Phase 5 feature that needs data beyond these contracts must identify its
source, access policy, query bounds, offline behavior, and rules/tests before
implementation.

## Debts Phase 4 hands over (measured, not assumed)

- **The chore rules and combined rules test run need final verification.** The
  standalone occurrence (101 tests, including the 400-document batch), parity
  (6), and comments (27) suites pass after the local refactor. The combined
  `npm test` run reports 673 passed and 33 failed; occurrence creates that pass
  alone fail when all files are loaded, alongside unrelated denied-case
  failures. Resolve test isolation and rerun the complete suite before
  publishing rules.
- **`memberStats` writes are unguarded.** `MemberStatsRepository.save` is a
  plain batch `set`, so a phone that syncs from a read taken before another
  phone wrote replaces that phone's document, including its finalised month.
  Pinned by the last test in
  `test/features/chores/achievements/concurrency/stats_sync_concurrency_test.dart`.
  Phase 5 must not add a second writer to this document before the write is
  guarded (compare-and-set, or a transaction that re-reads and merges).
- **Widget tests stub out every app-level side-effect provider.**
  `test/support/app_test_side_effect_overrides.dart` overrides the seven
  orchestration hooks with `overrideWithValue(null)`, so their bodies never run
  under test; that is how a startup crash that reproduced on the first device
  boot stayed green through 3275 tests. A hook change is only evidence once its
  real body has been built — see
  `test/features/chores/achievements/presentation/celebration_orchestration_test.dart`
  for the shape to copy.
- **Home's listener inventory is 13, not 7.** Measured in
  `test/features/dashboard/perf/home_listener_census_test.dart`; the ceiling
  that test asserts is the measured number, so a new listener fails it. Do not
  add a per-card stream to Home, and do not quote D-P4-14's seven as the current
  figure. Converging on the shared month sources is Phase 5 work.
- **Firestore document reads are still unmeasured,** so nothing in this contract
  is a claim about quota headroom. See [QUOTA_AUDIT.md](./QUOTA_AUDIT.md).
