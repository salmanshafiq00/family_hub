import 'package:family_hub/features/auth/presentation/auth_routes.dart';

/// Every route path of the app, declared once.
///
/// Auth paths live in [AuthRoutes] (next to their screens) and are re-exposed
/// here so the router and its redirect rules read from a single place.
abstract final class AppRoutes {
  // ── Bootstrapping ─────────────────────────────────────────────────────────
  static const String splash = '/splash';

  // ── Auth (signed out / unverified) ────────────────────────────────────────
  static const String welcome = AuthRoutes.welcome;
  static const String login = AuthRoutes.login;
  static const String signUp = AuthRoutes.signUp;
  static const String forgotPassword = AuthRoutes.forgotPassword;
  static const String verifyEmail = AuthRoutes.verifyEmail;

  // ── Onboarding gates (signed in, not yet in a family) ─────────────────────
  static const String profileSetup = '/profile-setup';
  static const String familyChoice = '/family-choice';
  static const String pending = '/pending';
  static const String disabled = '/disabled';

  // ── Shell tabs ────────────────────────────────────────────────────────────
  static const String home = '/home';
  static const String chores = '/chores';
  static const String bazar = '/bazar';
  static const String family = '/family';

  // ── Chores sub-routes (nested under [chores]) ─────────────────────────────
  //
  // P3-03 declares the whole Phase 3 vocabulary (road map 3.10) so later steps
  // only wire screens. A constant whose screen does not exist yet is NOT
  // registered in the router: a link to it must not resolve before the step
  // that adds the screen.
  static const String choresManage = '/chores/manage';
  static const String choresToday = '/chores/today';

  /// P3-15. `choresTemplateNew` must be registered BEFORE this pattern.
  static const String choresOccurrencePattern = '/chores/occurrence/:id';
  static String choresOccurrence(String id) => '/chores/occurrence/$id';
  static const String choresVerify = '/chores/verify';
  static const String choresTemplates = '/chores/templates';
  static const String choresTemplateNew = '/chores/templates/new';
  static const String choresTemplateEditPattern = '/chores/templates/:id';
  static String choresTemplateEdit(String id) => '/chores/templates/$id';
  static const String choresSettings = '/chores/settings';
  static const String choresDutyGroups = '/chores/duty-groups';

  /// P3-18. Registered BEFORE [choresDutyGroupPattern].
  static const String choresDutyGroupNew = '/chores/duty-groups/new';
  static const String choresDutyGroupPattern = '/chores/duty-groups/:id';
  static String choresDutyGroup(String id) => '/chores/duty-groups/$id';
  static const String choresStarterPack = '/chores/starter-pack';

  /// The family's editable starter list. `...ItemNew` is registered BEFORE the
  /// `:id` pattern.
  static const String choresStarterList = '/chores/starter-pack/list';
  static const String choresStarterItemNew = '/chores/starter-pack/list/new';
  static String choresStarterItemEdit(String id) =>
      '/chores/starter-pack/list/$id';
  static const String choresAvailability = '/chores/availability';
  static const String choresNeedsCover = '/chores/needs-cover';
  static const String choresRota = '/chores/rota';

  /// The module-neutral inbox: a top-level route above the shell (P3-27).
  static const String inbox = '/inbox';

  /// One inbox row, opened from its notification (P4-16).
  static const String inboxItemPattern = '/inbox/:itemId';
  static String inboxItem(String id) => '/inbox/$id';

  // ── Phase 4 (road map 3.10) ───────────────────────────────────────────────
  //
  // P4-02 declares the constants only. A route is registered by the step that
  // adds its screen (the step is named on each line), so a link to one cannot
  // resolve before then.

  /// P4-04. The family activity feed, a top-level route above the shell.
  static const String activity = '/activity';

  /// P4-20. Achievements and badges of the signed-in member.
  static const String choresAchievements = '/chores/achievements';

  /// P4-20. Scoring, levels and privacy settings (`manageEngagement`).
  static const String choresEngagementSettings = '/chores/engagement';

  // ── Bazar sub-routes (nested under [bazar]) ───────────────────────────────
  static const String bazarExpenses = '/bazar/expenses';
  static const String bazarExpenseNew = '/bazar/expenses/new';
  static const String bazarExpensePattern = '/bazar/expenses/:id';
  static String bazarExpense(String id) => '/bazar/expenses/$id';
  static const String bazarExpenseEditPattern = '/bazar/expenses/:id/edit';
  static String bazarExpenseEdit(String id) => '/bazar/expenses/$id/edit';
  static const String bazarTripNew = '/bazar/trip/new';
  static const String bazarCatalog = '/bazar/catalog';
  static const String bazarBudget = '/bazar/budget';
  static const String bazarFund = '/bazar/fund';
  static const String bazarFundPending = '$bazarFund?section=pending';
  static const String bazarAdvances = '/bazar/advances';
  static const String bazarMonthClose = '/bazar/month-close';
  static const String bazarReports = '/bazar/reports';
  static const String bazarSettings = '/bazar/settings';

  // ── Onboarding sub-routes ─────────────────────────────────────────────────
  static const String createFamily = '/family-choice/create';
  static const String joinFamily = '/family-choice/join';

  // ── Family tab sub-routes ─────────────────────────────────────────────────
  static const String familyMembers = '/family/members';
  static const String familyMemberPattern = '/family/members/:uid';
  static String memberProfile(String uid) => '/family/members/$uid';
  static const String familyInvitations = '/family/invitations';
  static const String familyRoles = '/family/roles';
  static const String familySettings = '/family/settings';
  static const String familyRelationships = '/family/relationships';
  static const String profileEdit = '/family/profile';

  // ── Settings (full-screen, outside the shell) ─────────────────────────────
  static const String settingsTheme = '/settings/theme';
  static const String settingsLanguage = '/settings/language';

  /// Password and account deletion (H9).  Account data: NOT in [alwaysOpen].
  static const String settingsSecurity = '/settings/security';

  /// P4-08. Every member orders, hides and shows their own dashboard cards.
  static const String customizeDashboard = '/settings/dashboard';

  /// P4-08. Which cards each role sees (`manageDashboardLayout`).
  static const String dashboardAccess = '/settings/dashboard-access';

  /// P4-16. Reminder switches, timings and quiet hours.
  static const String notificationSettings = '/settings/notifications';

  /// P4-16. Push or normal delivery per notification type (admin).
  static const String notificationDelivery = '/settings/notifications/delivery';

  /// P4-16. "Reminders not working?" diagnostics.
  static const String remindersHelp = '/settings/notifications/help';

  // ── Developer tools (dev flavor only) ─────────────────────────────────────
  static const String devTokens = '/dev/tokens';

  /// Component gallery: every shared widget in every state (Step 11).
  static const String devGallery = '/dev/gallery';

  /// Routes a signed-out visitor may open.
  static const Set<String> publicAuth = {
    welcome,
    login,
    signUp,
    forgotPassword,
  };

  /// Gate screens that only make sense before a member is active.  An active
  /// member who lands on one (stale deep link) is sent home.
  static const Set<String> gates = {
    splash,
    welcome,
    login,
    signUp,
    forgotPassword,
    verifyEmail,
    profileSetup,
    familyChoice,
    pending,
    disabled,
  };

  /// Local-only preference screens: no account data, so they stay reachable in
  /// every phase (a user can switch language before signing in).
  static const Set<String> alwaysOpen = {
    settingsTheme,
    settingsLanguage,
    devTokens,
    devGallery,
  };
}
