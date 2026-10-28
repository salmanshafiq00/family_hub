# Phase 1 security review (H13)

Evidence is `file:line` in `firebase/firestore.rules` as of the H13 commit, plus the rules test
that proves it (`firebase/rules_test/firestore.rules.test.mjs`, `describe` block name).
Line numbers drift: re-run the greps in the last section after any rules change.

**Method and limit.** This review was done by reading the rules and tests. The rules tests were
NOT executed by the author (no emulator). Every "Pass" below means "the rule and a test for it
exist", and becomes "verified" only when `tools/phase1_evidence.sh` reports the rules suite green.

| # | Checklist item | Result | Evidence |
| --- | --- | --- | --- |
| 1 | Every collection has `hasOnly` key sets and type checks | **Pass, one finding (F-31)** | families `:549,:561` (`familyKeys`), members `:380,:579,:610,:631,:649,:667` (`memberKeys`), invitations `:509,:519,:682,:688` (`invitationKeys`), settings `:206` (`settingsKeys`), activity/auditLogs `:251` (`eventKeys`). Tests: `H5 closed key sets`, `H5 member profile validation`. **F-31:** `users/{uid}` (`:441-487`) validates field types (`userDocOk`) but has no `hasOnly` key set, so a user can store extra junk fields on their own document. Impact is low (only the owner can read it and no rule reads other fields), fix is one `userKeys()` list mirrored by a Dart test. |
| 2 | No rule uses `get()` on a user-controlled id without an existence guard | **Pass** | `codeDoc` guards with `exists()` `:362-364`; `familyPointerChangeOk` guards with `!exists(memberPath(before, uid))` before `get(...)` `:473-480`; `adminIdsRewritten` `:347-349` runs only on member updates of an existing family (`!adminSetChanges() \|\| adminIdsRewritten(f)` at `:596,:614,:654`); `creatingFamily` uses `!exists` `:357`. Tests: `H4 one family per user`, `H6 active-admin set`. |
| 3 | Logs are append-only and actor-bound | **Pass** | `activity` `:724-729` and `auditLogs` `:731-737`: `allow update, delete: if false`; create requires `verified()` and `eventOk` (actor must be the caller, `:251`). Tests: `H5 log integrity`, `activity and auditLogs`. |
| 4 | Invites are single-use, revocable, and burned in the same batch | **Pass** | Single-use: used code cannot be reused (`:519`, `:690` allow only `status/usedBy/updatedAt/updatedBy`); burn in the same batch as joining via `joiningNow`/`existsAfter` `:412-422`. Revoke: `:534`. Tests: `inviteCodes/{code}` ("marks a live code used in the same batch", "denies joining with an already-used code", "denies marking an expired code used"), `H4 revoke invitation`. |
| 5 | One family per user | **Pass** | `familyPointerChangeOk` `:473-480` (used at `:484`). Tests: `H4 one family per user`, `H4 acceptance: leave and join another family`. |
| 6 | Verified email is required for mutating actions | **Pass** | `verified()` `:74-76` is used by 23 rules (family/invite/member/activity/audit creates, `inviteCodes` get `:498`). The owner may still write their own profile unverified (`:483-484`, deliberate: needed for sign-up flow). Tests: `H5 verified email`. |
| 7 | No hard deletes anywhere | **Pass** | `allow delete: if false` on users `:487`, inviteCodes `:538`, families `:563`, members `:672`, invitations `:706`, settings `:720`; Phase 2/3 collections are deny-all `:751-754`. Tests: `financial and chore data`, plus delete denials in each block. |
| 8 | Unauthenticated access is denied | **Pass** | Default deny `:757-759`; every `allow` requires `signedIn()`/`verified()`/membership. Tests: `unauthenticated access`, "denies an unauthenticated read/get". |
| 9 | Cross-family reads are denied | **Pass** | Reads need `isActiveMember(f)` (`:553,:711,:725`) or `isAdmin(f)` (`:732`). Tests: "[roadmap] denies a member of another family reading this family", "denies reading another family's financial data", "denies a manager of ANOTHER family revoking this family's code". |
| 10 | Roles cannot be self-promoted; last admin cannot be removed | **Pass** | `memberKeys` + role/status checks `:566-672`; `adminSetChanges`/`adminIdsRewritten` `:341-349`. Tests: `H6 active-admin set`, "member cannot make themselves admin". |
| 11 | Account deletion is a soft delete | **Pass** | `accountDeletionOk` `:458-464`, no hard delete `:487`. Tests: `H9 account soft-delete`. |

## Phase 2 additions (P2-05)

`bazarCategories` and `bazarItems` have closed key sets (`categoryKeys`, `itemKeys`)
and field validation (`categoryOk`, `itemOk`), allow soft delete only
(`allow delete: if false`), and gate manager writes through `financeManager`.
Any active member may create a custom item, and may change only the six usage
fields with a `useCount` delta of 1..40 per write. Tests:
`families/{f}/bazarCategories`, `families/{f}/bazarItems` and
`creating a family with the default catalog` in
`firebase/rules_test/catalog.test.mjs`.

## Phase 2 additions (P2-10)

The expense, ledger and advance collections each have a closed key set and a
shape guard (`expenseKeys`/`expenseOk`, `tripKeys`/`tripOk`,
`fundTxKeys`/`fundTxOk`, `advanceKeys`/`advanceOk`,
`settlementKeys`/`settlementOk`, `closingKeys`/`closingOk`,
`revisionKeys`/`revisionOk`). They are append-only where the ADR 0006 ledger
rule requires it (`fundTransactions`, `settlements` and the nested
`expenses/{e}/revisions` allow no update or delete), `expenses` allows only a
soft delete/restore or a content edit that keeps the provenance fields, and
`monthClosings` is manager-written. `monthOpen` blocks new expenses, trips,
ledger rows and settlements in a closed month. Tests planned in
`firebase/rules_test/expenses.test.mjs`, `fund.test.mjs` and
`advances.test.mjs`.

Collections: `expenses` (with nested `revisions`), `bazarTrips`,
`fundTransactions`, `memberAdvances`, `settlements`, `monthClosings`.

## Phase 3 additions (P3-08, P3-10)

`choreTemplates` and `dutyGroups` have closed key sets
(`templateKeys`/`templateOk`, `dutyGroupKeys`/`dutyGroupOk`), manager-or-admin
writes, any active member reads, and `allow delete: if false`. A template's
`revision` must increase by exactly one and its `seedKey`/`builtIn` are
immutable; a duty group's `rotation` is capped at 20 versions, with the first
and last version shape-checked (rules cannot loop, so `RotationValidator` is the
authority for every version in between). Tests:
`firebase/rules_test/chore_templates.test.mjs` and
`firebase/rules_test/duty_groups.test.mjs`.

## Phase 3 additions (P3-13)

`choreOccurrences` is carved out of the deny-only block. Any active member may
CREATE one (D-P3-7: a plain member must be able to complete today's chore even
if no manager opened the app); the rules check the closed key set, the
deterministic id (`{templateId}_{yyyyMMdd}[_{slot}]`, its date must equal
`dateKey`), `status == scheduled` and a fresh document (no ticks, no
completion, no skip, no exception). They cannot verify rotation correctness -
no trusted server on the Spark plan, recorded as an accepted limit in ADR 0011.
The create uses ONE membership lookup, so a 400-document generation batch stays
inside the access-call budget (C-11, proven by the emulator test).

Every update is its own transition with `affectedKeys().hasOnly(...)`: tick
(only `subtaskDone.<id>` + status + completion), complete/uncomplete (the real
actor, `completedBy == uid`), verify (never the completer, snapshot
`verification == required`, the family switch, plus the `verified` event in the
same batch via `getAfter`), reopen (a reason, `reopenCount + 1`, the cleared
completion on the event), exception/skip/unskip/reassign (manager), swap/cover
(with the `swapped`/`covered` event), the attention flag, replan (manager,
unstarted only) and the soft delete (manager, future only). A plain member may
act on somebody else's chore only while `settings/permissions` says
`membersCanCompleteForOthers`. `choreOccurrences/{id}/events` is create-only by
its own actor with a closed type list. Tests:
`firebase/rules_test/chore_occurrences.test.mjs` (including the 400-create
batch) and the contract fixture `chore_occurrence.json`.

## Findings

| Id | Severity | Finding | Recommended fix |
| --- | --- | --- | --- |
| F-31 | Low | `users/{uid}` has no closed key set | Add `userKeys()` (`uid, fullName, nickname, gender, relationship, spouseId, avatarKey, familyId, preferences, createdAt, createdBy, updatedAt, updatedBy, schemaVersion, deletedAt, deletedBy`) with `hasOnly` in `userDocOk`, mirror it in `rules_key_sets_test.dart`, add an allow/deny rules test. Not done in H13 because H13 makes no feature changes and the fix cannot be verified without the emulator. |
| F-32 | Info | App Check is not enabled (Spark, no server) | Phase 6 decision (roadmap). Rules are the only server-side defense. |
| F-33 | Info | Client-side scoring and stats will be tamper-able (Spark) | Known and documented for Phase 3; rules must bound increments. |

## Re-checking line numbers

```bash
grep -n "hasOnly\|allow delete\|email_verified\|exists(/databases\|get(/databases\|getAfter" firebase/firestore.rules
```
