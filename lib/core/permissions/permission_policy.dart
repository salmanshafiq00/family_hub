import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/core/permissions/permission_actor.dart';
import 'package:family_hub/core/permissions/permission_settings.dart';

/// The one permission matrix (roadmap 2.2 / Step 10), used by the UI
/// (`PermissionGate`), by the use cases (`requirePermission`) and by the tests.
///
/// ## The matrix
///
/// | Permission | admin | Household Manager | member |
/// | --- | --- | --- | --- |
/// | inviteMembers | yes | yes | no (setting: membersCanInvite) |
/// | approveMembers | yes | yes | no |
/// | removeMembers | yes | no | no |
/// | changeRoles | yes | no | no |
/// | editFamilySettings | yes | no | no |
/// | viewFamilyReports | yes | yes | yes (setting: membersViewFamilyReports) |
/// | exportData | yes | no | no |
/// | manageCatalogAndBudgets | yes | yes (setting: moderatorManagesFinance) | no |
/// | addOwnExpense | yes | yes | yes |
/// | editOthersExpense | yes | yes | no |
/// | recordContribution | yes | yes (setting: moderatorManagesFinance) | no |
/// | viewAllContributions | yes | yes | no (setting: membersViewAllContributions) |
/// | closeBazarMonth | yes | yes (setting: moderatorManagesFinance) | no |
/// | importBazarData | yes | yes (setting: moderatorManagesFinance) | no |
/// | requestContribution | yes | yes | yes |
/// | manageChoreTemplates | yes | yes | no |
/// | reassignChore | yes | yes | no |
/// | requestSwap | own | own | own |
/// | completeOwnChore | own | own | own |
/// | commentOnChore | yes | yes | yes |
/// | verifyChore | other | other | no |
/// | completeChoreForOthers | yes | yes | no (setting: membersCanCompleteForOthers) |
/// | recordOwnAvailability | own | own | own |
/// | manageAvailability | yes | yes | no |
/// | manageChoreOccurrences | yes | yes | no |
/// | moderateChoreComments | yes | yes | no |
///
/// ("own" means `ownerId` must be the actor; "other" means `ownerId` must be
/// somebody else — nobody verifies their own chore.)
///
/// Every cell is additionally false when the actor is not active, and false
/// while the permission's module is switched off in [PermissionSettings].
///
/// The settings come from `families/{f}/settings/permissions` (H7).  The table
/// above shows the DEFAULTS; `docs/permission_matrix.md` is generated from this
/// class by `test/core/permissions/permission_matrix_doc_test.dart`.
///
/// Roadmap 2.2 itself was not present in ROADMAP.md, so this table was derived
/// from the rules the roadmap states elsewhere (Step 9's "admin does
/// everything, moderator invites/approves/rejects"; Step 15's "members may edit
/// only their own expenses, admin/moderator any"; Step 25's "reassign
/// (admin/moderator)"; CLAUDE.md's "members see only their own contributions").
abstract final class PermissionPolicy {
  /// "May this person verify OTHER people's chores at all?" (B-02).
  ///
  /// `verifyChore` needs a completer and a template, so a screen that only
  /// decides whether to SHOW the Verify queue has nobody to ask about. This asks
  /// the same cell with the template switch on and a completer who is never the
  /// actor, so the family switch, the module switch and the role still decide.
  static bool canVerifyOthers(
    PermissionActor actor, {
    PermissionSettings settings = PermissionSettings.defaults,
  }) => can(
    actor,
    Permission.verifyChore,
    ownerId: '${actor.uid}#someone-else',
    settings: settings,
    template: const PermissionTemplate(verificationEnabled: true),
  );

  /// True when [actor] may do [permission].
  ///
  /// [ownerId] is the member an occurrence/expense belongs to: the assignee for
  /// `completeOwnChore`, `completeChoreForOthers` and `requestSwap`, the
  /// completer for `verifyChore`, the member for `recordOwnAvailability`.
  /// [settings] carries the family switches, [template] the template switch.
  static bool can(
    PermissionActor actor,
    Permission permission, {
    String? ownerId,
    PermissionSettings settings = PermissionSettings.defaults,
    PermissionTemplate? template,
  }) {
    if (!actor.isActive) return false;
    if (!settings.isModuleEnabled(permission.module)) return false;

    return switch (permission) {
      // ── Family administration ──────────────────────────────────────────
      Permission.inviteMembers => actor.isManager || settings.membersCanInvite,
      Permission.approveMembers => actor.isManager,
      Permission.removeMembers => actor.isAdmin,
      Permission.changeRoles => actor.isAdmin,
      Permission.editFamilySettings => actor.isAdmin,
      Permission.viewFamilyReports =>
        actor.isManager || settings.membersViewFamilyReports,
      Permission.exportData => actor.isAdmin,

      // ── Bazar and family finance ───────────────────────────────────────
      Permission.manageCatalogAndBudgets => _managesFinance(actor, settings),
      Permission.addOwnExpense => true,
      Permission.editOthersExpense => actor.isManager,
      Permission.recordContribution => _managesFinance(actor, settings),
      Permission.viewAllContributions =>
        actor.isManager || settings.membersViewAllContributions,
      Permission.closeBazarMonth => _managesFinance(actor, settings),
      Permission.importBazarData => _managesFinance(actor, settings),
      // Any active member may offer a contribution for the manager to decide.
      Permission.requestContribution => true,

      // ── Chores ─────────────────────────────────────────────────────────
      Permission.manageChoreTemplates => actor.isManager,
      Permission.reassignChore => actor.isManager,
      Permission.requestSwap => _owns(actor, ownerId),
      Permission.completeOwnChore => _owns(actor, ownerId),
      Permission.commentOnChore => true,

      // Verification needs the family switch, the template switch and a
      // *different* person: self-verification is never allowed.
      Permission.verifyChore =>
        actor.isManager &&
            settings.choreVerificationEnabled &&
            (template?.verificationEnabled ?? false) &&
            ownerId != null &&
            ownerId != actor.uid,

      // ── Chores, Phase 3 (road map 3.3) ─────────────────────────────────
      // Somebody else's chore, or an unassigned one (`ownerId == null`), which
      // is never "own": a plain member needs the family switch (D-P3-14).
      Permission.completeChoreForOthers =>
        actor.isManager ||
            (settings.membersCanCompleteForOthers && !_owns(actor, ownerId)),
      Permission.recordOwnAvailability => _owns(actor, ownerId),
      Permission.manageAvailability => actor.isManager,
      Permission.manageChoreOccurrences => actor.isManager,
      Permission.moderateChoreComments => actor.isManager,
    };
  }

  /// Admin always; a moderator only while the family lets moderators manage
  /// finance (spec section 6, "Configurable").
  static bool _managesFinance(
    PermissionActor actor,
    PermissionSettings settings,
  ) => actor.isAdmin || (actor.isModerator && settings.moderatorManagesFinance);

  /// The actor owns the record.  An unknown owner (`ownerId == null`) is never
  /// "own", so a caller that forgets the context is denied rather than trusted.
  static bool _owns(PermissionActor actor, String? ownerId) =>
      ownerId != null && ownerId == actor.uid;
}
