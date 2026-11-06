/// Which part of the app a permission belongs to.
///
/// The policy uses this to honour the per-family module switches
/// (`families/{id}/settings/modules`): a bazar permission is denied while the
/// bazar module is off, and so on.  Family administration is never switchable.
enum PermissionModule { family, bazar, chores }

/// One permission per row of the roadmap 2.2 matrix (Step 10).
///
/// Names are the roadmap's names, verbatim, so the code and the matrix can be
/// diffed by eye.
enum Permission {
  // Family administration.
  inviteMembers(PermissionModule.family),
  approveMembers(PermissionModule.family),
  removeMembers(PermissionModule.family),
  changeRoles(PermissionModule.family),
  editFamilySettings(PermissionModule.family),
  viewFamilyReports(PermissionModule.family),
  exportData(PermissionModule.family),

  // Bazar and family finance.
  manageCatalogAndBudgets(PermissionModule.bazar),
  addOwnExpense(PermissionModule.bazar),
  editOthersExpense(PermissionModule.bazar),
  recordContribution(PermissionModule.bazar),
  viewAllContributions(PermissionModule.bazar),
  closeBazarMonth(PermissionModule.bazar),
  importBazarData(PermissionModule.bazar),
  requestContribution(PermissionModule.bazar),

  // Chores.
  manageChoreTemplates(PermissionModule.chores),
  reassignChore(PermissionModule.chores),
  requestSwap(PermissionModule.chores),
  completeOwnChore(PermissionModule.chores),
  commentOnChore(PermissionModule.chores),
  verifyChore(PermissionModule.chores),

  // Chores, Phase 3 (road map 3.3).
  /// Completing a chore assigned to somebody else ("done by"). `ownerId` is
  /// the assignee. A plain member needs `membersCanCompleteForOthers`; an
  /// unassigned occurrence is always "somebody else's".
  completeChoreForOthers(PermissionModule.chores),

  /// Recording an absence for oneself. `ownerId` is the member id.
  recordOwnAvailability(PermissionModule.chores),

  /// Recording, approving or rejecting an absence for anybody.
  manageAvailability(PermissionModule.chores),

  /// Skip / unskip, completion exception, reopening a verified task.
  manageChoreOccurrences(PermissionModule.chores),

  /// Hide / unhide a comment (comments are never deleted, D-P3-18).
  moderateChoreComments(PermissionModule.chores),

  // Dashboard, notifications and engagement (Phase 4, road map 3.3). Both sit
  // in the `family` module: they span every module and are never switchable.
  /// Notification defaults and the badge / level settings (admin or manager).
  manageEngagement(PermissionModule.family),

  /// Which dashboard cards each role sees (D-P4-28): admin, or a Household
  /// Manager while `moderatorManagesFinance` is on.
  manageDashboardLayout(PermissionModule.family),

  /// Family-wide reminder defaults (P4-11): admin or Household Manager.
  manageNotificationDefaults(PermissionModule.family);

  const Permission(this.module);

  /// The module switch that gates this permission.
  final PermissionModule module;
}
