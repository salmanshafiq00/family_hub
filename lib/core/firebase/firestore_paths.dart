/// Typed collection and document path helpers for Cloud Firestore.
///
/// Implements the hierarchical data model from roadmap section 12.2 and 12.5.
/// Centralizes all Firestore path strings so no collection or document path
/// is ever duplicated across repositories, use cases, or security rules tests.
abstract final class FirestorePaths {
  // ── Top-level collections ──────────────────────────────────────────────────

  static const String usersCollection = 'users';
  static const String familiesCollection = 'families';
  static const String inviteCodesCollection = 'inviteCodes';

  static String userDoc(String uid) => '$usersCollection/$uid';
  static String userPreferencesDoc(String uid) =>
      '$usersCollection/$uid/preferences/default';

  static String inviteCodeDoc(String code) => '$inviteCodesCollection/$code';

  static String familyDoc(String familyId) => '$familiesCollection/$familyId';

  // ── Family Subcollections ──────────────────────────────────────────────────

  static const String membersSubcollection = 'members';
  static const String settingsSubcollection = 'settings';
  static const String invitationsSubcollection = 'invitations';
  static const String bazarCategoriesSubcollection = 'bazarCategories';
  static const String bazarItemsSubcollection = 'bazarItems';
  static const String expensesSubcollection = 'expenses';
  static const String bazarTripsSubcollection = 'bazarTrips';
  static const String budgetsSubcollection = 'budgets';
  static const String contributionsSubcollection = 'contributions';
  static const String contributionPlansSubcollection = 'contributionPlans';
  static const String fundTransactionsSubcollection = 'fundTransactions';
  static const String memberAdvancesSubcollection = 'memberAdvances';
  static const String settlementsSubcollection = 'settlements';
  static const String choreTemplatesSubcollection = 'choreTemplates';
  static const String starterPackItemsSubcollection = 'starterPackItems';
  static const String dutyGroupsSubcollection = 'dutyGroups';
  static const String choreOccurrencesSubcollection = 'choreOccurrences';
  static const String memberAvailabilitySubcollection = 'memberAvailability';
  static const String swapRequestsSubcollection = 'swapRequests';
  static const String notificationInboxSubcollection = 'notificationInbox';
  static const String activitySubcollection = 'activity';
  static const String auditLogsSubcollection = 'auditLogs';
  static const String memberStatsSubcollection = 'memberStats';
  static const String memberStatsPublicSubcollection = 'memberStatsPublic';
  static const String devicesSubcollection = 'devices';
  static const String monthClosingsSubcollection = 'monthClosings';
  static const String importBatchesSubcollection = 'importBatches';

  // ── Collection Paths ───────────────────────────────────────────────────────

  static String members(String familyId) =>
      '${familyDoc(familyId)}/$membersSubcollection';
  static String memberDoc(String familyId, String memberId) =>
      '${members(familyId)}/$memberId';

  static String settings(String familyId) =>
      '${familyDoc(familyId)}/$settingsSubcollection';
  static String settingsDoc(String familyId, String settingId) =>
      '${settings(familyId)}/$settingId';

  /// The Bazar module's own settings document: `settings/bazar`.
  static String bazarSettingsDoc(String familyId) =>
      settingsDoc(familyId, 'bazar');

  /// The Chores module's own settings document: `settings/chores` (P3-06).
  /// An absent document means the built-in defaults (D-P3-4).
  static String choreSettingsDoc(String familyId) =>
      settingsDoc(familyId, 'chores');

  /// The occurrence generation marker: `settings/choreGeneration` (D-P3-10).
  static String choreGenerationDoc(String familyId) =>
      settingsDoc(familyId, 'choreGeneration');

  /// The absence policy: `settings/rotationPolicy` (D-P3-13).
  static String rotationPolicyDoc(String familyId) =>
      settingsDoc(familyId, 'rotationPolicy');

  // Phase 4 settings documents (road map 3.2).
  static String dashboardSettingsDoc(String familyId) =>
      settingsDoc(familyId, 'dashboard');

  static String notificationDefaultsDoc(String familyId) =>
      settingsDoc(familyId, 'notificationDefaults');

  static String notificationDeliveryDoc(String familyId) =>
      settingsDoc(familyId, 'notificationDelivery');

  static String engagementSettingsDoc(String familyId) =>
      settingsDoc(familyId, 'engagement');

  static String invitations(String familyId) =>
      '${familyDoc(familyId)}/$invitationsSubcollection';
  static String invitationDoc(String familyId, String invitationId) =>
      '${invitations(familyId)}/$invitationId';

  static String bazarCategories(String familyId) =>
      '${familyDoc(familyId)}/$bazarCategoriesSubcollection';
  static String bazarCategoryDoc(String familyId, String categoryId) =>
      '${bazarCategories(familyId)}/$categoryId';

  static String bazarItems(String familyId) =>
      '${familyDoc(familyId)}/$bazarItemsSubcollection';
  static String bazarItemDoc(String familyId, String itemId) =>
      '${bazarItems(familyId)}/$itemId';

  static String expenses(String familyId) =>
      '${familyDoc(familyId)}/$expensesSubcollection';
  static String expenseDoc(String familyId, String expenseId) =>
      '${expenses(familyId)}/$expenseId';

  /// Revision history under one expense.
  static String expenseRevisions(String familyId, String expenseId) =>
      '${expenseDoc(familyId, expenseId)}/revisions';
  static String expenseRevisionDoc(
    String familyId,
    String expenseId,
    String revisionId,
  ) => '${expenseRevisions(familyId, expenseId)}/$revisionId';

  static String bazarTrips(String familyId) =>
      '${familyDoc(familyId)}/$bazarTripsSubcollection';
  static String bazarTripDoc(String familyId, String tripId) =>
      '${bazarTrips(familyId)}/$tripId';

  /// Deterministic ID: `{yyyy-MM}`
  static String budgets(String familyId) =>
      '${familyDoc(familyId)}/$budgetsSubcollection';
  static String budgetDoc(String familyId, String monthKey) =>
      '${budgets(familyId)}/$monthKey';

  static String contributions(String familyId) =>
      '${familyDoc(familyId)}/$contributionsSubcollection';
  static String contributionDoc(String familyId, String contributionId) =>
      '${contributions(familyId)}/$contributionId';

  /// Deterministic ID: `{yyyy-MM}_{memberId}`
  static String contributionPlans(String familyId) =>
      '${familyDoc(familyId)}/$contributionPlansSubcollection';
  static String contributionPlanDoc(String familyId, String planId) =>
      '${contributionPlans(familyId)}/$planId';

  static String fundTransactions(String familyId) =>
      '${familyDoc(familyId)}/$fundTransactionsSubcollection';
  static String fundTransactionDoc(String familyId, String transactionId) =>
      '${fundTransactions(familyId)}/$transactionId';

  static String memberAdvances(String familyId) =>
      '${familyDoc(familyId)}/$memberAdvancesSubcollection';
  static String memberAdvanceDoc(String familyId, String advanceId) =>
      '${memberAdvances(familyId)}/$advanceId';

  static String settlements(String familyId) =>
      '${familyDoc(familyId)}/$settlementsSubcollection';
  static String settlementDoc(String familyId, String settlementId) =>
      '${settlements(familyId)}/$settlementId';

  /// Deterministic ID: `{yyyy-MM}`
  static String monthClosings(String familyId) =>
      '${familyDoc(familyId)}/$monthClosingsSubcollection';
  static String monthClosingDoc(String familyId, String monthKey) =>
      '${monthClosings(familyId)}/$monthKey';

  static String importBatches(String familyId) =>
      '${familyDoc(familyId)}/$importBatchesSubcollection';
  static String importBatchDoc(String familyId, String importBatchId) =>
      '${importBatches(familyId)}/$importBatchId';

  static String choreTemplates(String familyId) =>
      '${familyDoc(familyId)}/$choreTemplatesSubcollection';
  static String choreTemplateDoc(String familyId, String templateId) =>
      '${choreTemplates(familyId)}/$templateId';

  static String starterPackItems(String familyId) =>
      '${familyDoc(familyId)}/$starterPackItemsSubcollection';
  static String starterPackItemDoc(String familyId, String itemId) =>
      '${starterPackItems(familyId)}/$itemId';

  static String dutyGroups(String familyId) =>
      '${familyDoc(familyId)}/$dutyGroupsSubcollection';
  static String dutyGroupDoc(String familyId, String dutyGroupId) =>
      '${dutyGroups(familyId)}/$dutyGroupId';

  /// Deterministic ID: `{templateId}_{yyyyMMdd}`
  static String choreOccurrences(String familyId) =>
      '${familyDoc(familyId)}/$choreOccurrencesSubcollection';
  static String choreOccurrenceDoc(String familyId, String occurrenceId) =>
      '${choreOccurrences(familyId)}/$occurrenceId';

  // Sub-subcollections under choreOccurrences
  static String occurrenceEvents(String familyId, String occurrenceId) =>
      '${choreOccurrenceDoc(familyId, occurrenceId)}/events';
  static String occurrenceEventDoc(
    String familyId,
    String occurrenceId,
    String eventId,
  ) => '${occurrenceEvents(familyId, occurrenceId)}/$eventId';

  static String occurrenceComments(String familyId, String occurrenceId) =>
      '${choreOccurrenceDoc(familyId, occurrenceId)}/comments';
  static String occurrenceCommentDoc(
    String familyId,
    String occurrenceId,
    String commentId,
  ) => '${occurrenceComments(familyId, occurrenceId)}/$commentId';

  static String memberAvailability(String familyId) =>
      '${familyDoc(familyId)}/$memberAvailabilitySubcollection';
  static String memberAvailabilityDoc(String familyId, String availabilityId) =>
      '${memberAvailability(familyId)}/$availabilityId';

  static String swapRequests(String familyId) =>
      '${familyDoc(familyId)}/$swapRequestsSubcollection';
  static String swapRequestDoc(String familyId, String swapRequestId) =>
      '${swapRequests(familyId)}/$swapRequestId';

  static String notificationInbox(String familyId) =>
      '${familyDoc(familyId)}/$notificationInboxSubcollection';
  static String notificationInboxDoc(String familyId, String inboxItemId) =>
      '${notificationInbox(familyId)}/$inboxItemId';

  /// Shorter names for the inbox, used by `features/notifications` (P3-27).
  static String inbox(String familyId) => notificationInbox(familyId);
  static String inboxDoc(String familyId, String inboxItemId) =>
      notificationInboxDoc(familyId, inboxItemId);

  static String activity(String familyId) =>
      '${familyDoc(familyId)}/$activitySubcollection';
  static String activityDoc(String familyId, String activityId) =>
      '${activity(familyId)}/$activityId';

  static String auditLogs(String familyId) =>
      '${familyDoc(familyId)}/$auditLogsSubcollection';
  static String auditLogDoc(String familyId, String auditLogId) =>
      '${auditLogs(familyId)}/$auditLogId';

  static String memberStats(String familyId) =>
      '${familyDoc(familyId)}/$memberStatsSubcollection';
  static String memberStatsDoc(String familyId, String memberId) =>
      '${memberStats(familyId)}/$memberId';

  /// The points-free public card of a member (D-P4-26); exists only while the
  /// family shares levels.
  static String memberStatsPublic(String familyId) =>
      '${familyDoc(familyId)}/$memberStatsPublicSubcollection';
  static String memberStatsPublicCollection(String familyId) =>
      memberStatsPublic(familyId);
  static String memberStatsPublicDoc(String familyId, String memberId) =>
      '${memberStatsPublic(familyId)}/$memberId';

  /// Push-token documents of one user (`users/{uid}/devices/{deviceId}`),
  /// owner-only (road map 3.2).
  static String deviceDocs(String uid) =>
      '${userDoc(uid)}/$devicesSubcollection';
  static String deviceDoc(String uid, String deviceId) =>
      '${deviceDocs(uid)}/$deviceId';
}
