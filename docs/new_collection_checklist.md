# New collection checklist (H12)

Every step that adds a Firestore collection does ALL of these in the same commit
(CLAUDE.md rules 11, 12, 18, 20):

1. **Paths** - the collection is in `lib/core/firebase/firestore_paths.dart`
   (no path string is written twice) and removed from `pending` in
   `test/core/firebase/paths_match_rules_test.dart` once it has rules.
2. **Rules** - `firebase/firestore.rules`: a `match` block composed from the H12
   helpers (`canReadFamilyData`, `verified` + `createsAsSelf`, `moneyOk`,
   `dateKeyOk`, `monthKeyOk`, `softDeleteOnly`), a closed key set (`*Keys()` +
   `hasOnly`), field types and lengths, and no hard delete.
   A helper that nothing calls is a compile error in the emulator, so compose an
   existing helper or write the condition inline - never park one for later.
3. **Rules tests** - copy `firebase/rules_test/templates/collection.test.mjs.tmpl`:
   one allowed and one denied case per rule.
4. **Contract fixtures** - real mapper output pushed through the rules
   (`test/contract/rules_fixtures_test.dart`).
5. **Indexes** - `firebase/firestore.indexes.json` for every range + order query
   (two or more fields only; `tools/check_indexes.mjs` enforces it).
6. **Writes** - go through a use case; audit/activity through `AuditWriter` in the
   same batch; permission through `requirePermission` / `ref.can`; offline through
   `guardWrite`.
7. **Reads** - bounded by `.limit(...)` (`core/firebase/query_limits.dart`) and a
   `monthKey`/`dateKey` range; one listener per screen.
8. **Dates** - `dateKey` / `monthKey` from `FamilyDateKeys`, never the phone zone.
9. **UI** - loading, empty, error, offline states; gallery + goldens for new shared
   widgets; ARB strings in bn and en.
10. **Seed data** - starter documents come from a `FamilySeeder` (never by editing
    `CreateFamily`); at most 500 writes per batch including the family's own.

## Phase 3 collections (Chores) - checked in P3-29

Every item above was applied to: `settings/chores`, `settings/choreGeneration`, `settings/rotationPolicy`, `choreTemplates`, `dutyGroups`, `choreOccurrences` (+ `events`, `comments`), `memberAvailability`, `swapRequests`, and `notificationInbox`. Phase 4 adds `settings/engagement`, `memberStats`, `memberStatsPublic`, and `users/{uid}/devices`; their paths, rules, and tests are in the Phase 4 implementation. The P4-25 emulator run is still required as sign-off evidence; see `firebase/README.md` for the current rules-suite status.
