/// Query discipline (CLAUDE.md rule 11, H12): every collection read is bounded.
///
/// Phase 2 screens page with [defaultPageSize] and never ask for more than
/// [kMaxListenerDocs] documents on one listener.  `test/architecture/
/// no_unbounded_queries_test.dart` fails when a `.collection(...)` read in a
/// data layer has no `.limit(...)`.
const int defaultPageSize = 30;

/// Hard cap for one live listener (a month of expenses fits comfortably).
const int kMaxListenerDocs = 500;

/// Hard cap for one catalog listener (11 categories + 54 built-in items plus
/// room for custom entries; the rules cap the same collections implicitly).
const int kMaxCatalogDocs = 500;

/// Page size of the report range loader (`report_loader.dart`, P2-24).
const int kReportPageSize = 500;

/// Most expenses one report loads.  Past this the report is marked truncated
/// instead of paging forever, so a long range can never stall the screen.
const int kMaxReportDocs = 5000;

// ── Chores (Phase 3, road map 3.3 / 3.12) ─────────────────────────────────────

/// One template listener (the rules cap the collection at the same order of
/// magnitude; a family with 200 templates is already far past the design).
const int kMaxChoreTemplates = 200;

/// One starter-pack list listener (the family's own editable pack).
const int kMaxStarterItems = 100;

/// One duty-group listener.
const int kMaxDutyGroups = 50;

/// One month of occurrences (C-2: [kMaxListenerDocs] is too small; 15 daily
/// templates are about 450 documents a month, 30 are about 900).
const int kMaxOccurrencesPerMonth = 900;

/// Absence records kept live: max(startDateKey, today - 7), status active or
/// pending.
const int kMaxAvailabilityDocs = 200;

/// Pending/expiring swap requests one listener shows.
const int kMaxSwapDocs = 50;

/// Unread + recent inbox items one listener shows.
const int kMaxInboxDocs = 50;

/// The manager's verification queue (`completed` + verification required).
const int kMaxVerifyQueue = 50;

/// Comments of one occurrence.
const int kMaxCommentsPerOccurrence = 200;

/// Lifecycle events of one occurrence (append-only, never deleted).
const int kMaxEventsPerOccurrence = 100;

// ── Dashboard, notifications and engagement (Phase 4, road map 3.2) ──────────

/// One page of the activity feed (P4-04).
const int kMaxActivityPage = 30;

/// Recent-activity card on Home: the five newest entries (P4-07).
const int kMaxDashboardActivity = 5;

/// Most points one stats sync may add in one write; the rules bound the same
/// step so a tampered client cannot jump (ADR 0017).
const int kMaxPointsPerSync = 3000;

/// Most local notifications scheduled at once: the planner looks at 7 days and
/// stays far below the iOS limit of about 64 pending (P4-10).
const int kMaxPlannedNotifications = 60;

/// Months kept in `memberStats.monthly` (D-P4-8).
const int kMaxStatsMonths = 40;

/// Largest `order`, `hidden` or `shown` list in a member's dashboard
/// preferences (the rules check the same size).
const int kMaxDashboardPrefIds = 24;

/// Pushes one recipient may get in one hour; the Cloud Function enforces it
/// through `pushLedger` (ADR 0020).
const int kMaxPushPerHour = 30;
