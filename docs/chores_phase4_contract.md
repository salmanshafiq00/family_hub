# Chores - what Phase 4 may rely on (written in P3-29)

Phase 3 stores the data Phase 4 (reminders, badges, Hub Level, celebration, dashboard restyle) needs. This file lists it, and what Phase 3 deliberately does NOT compute. Source of truth for shapes: the occurrence and template mappers in `lib/features/chores/`, and ADRs 0009-0013.

## Data that exists

| Need | Where | Notes |
| --- | --- | --- |
| Reminder settings | `choreTemplates.reminders` `{enabled, atDue, offsetsMinutes[<=5], overdueEnabled, overdueAfterMinutes}` | Stored by the template editor, consumed by nobody yet. Occurrence snapshots do not copy it: read the template by `templateId` (`templateRev` says which revision the occurrence was planned with). |
| Deadline | `choreOccurrences.dueAt` (UTC instant) + `dueMinutes?` | No `dueMinutes` means end of the family day. Convert with `FamilyDateKeys`, never the phone zone. |
| Slots | `slotKey` on the occurrence, `slots` on the template | `main` plus up to 5 more; one occurrence per template, date and slot. |
| Completion history (streaks) | `completedAt`, `completedBy` and the `events` subcollection (`completed`, `uncompleted`, `reopened`) | `uncompleted` carries `prevCompletedAt`. Count a completion only when the final state is completed/verified. |
| "Detail champion" | `verifiedAt`, `verifiedBy` | Only on templates with `verification == required`. |
| "Helper" | `assignmentSource` in `swap` or `cover`, `coverForId` | The member who does a covered chore is `assigneeId`. |
| Absence | `memberAvailability` (`active` records) | Approved absence must stay neutral in any score. |
| Today's progress | `dashboardTodayProgressProvider` / `todayProgressProvider` | Celebration trigger: fire once per day when `isComplete` turns true, remembered in a LOCAL preference `celebratedDateKey` (no Firestore). |
| Workload weights | `WorkloadCalculator` (easy 1 / normal 2 / hard 3) | Reuse it for a contribution score; do not copy the weights. |

## Reserved

* `memberStats` stays deny-all in the rules until Phase 4 adds its own rules and tests.
* Notification enable hierarchy to implement: global switch -> per member -> per template (`reminders.enabled`).

## Limits to design around

* Spark plan, no Cloud Functions: only LOCAL notifications are possible. A device learns of a swap request or a reopened chore when the app opens (the inbox says so); there is no push.
* The occurrence rules fix `todayKey` to UTC+6 (ADR 0014).
* `overdue` is derived from the clock and never stored; a scheduled reminder must compute it from `dueAt` + `overdueGraceMinutes`.

## Not computed in Phase 3

Streaks, badges, Hub Level, contribution score, per-member statistics documents, reminder scheduling, the celebration animation, push delivery, any ranking or leaderboard.
