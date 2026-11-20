import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/rota/presentation/rota_providers.dart';
import 'package:family_hub/features/chores/swaps/presentation/needs_cover_providers.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One tile on the "Manage chores" hub.
///
/// Same shape as `BazarEntry`: every later Phase 3 step appends one entry and
/// the hub renders this list, hiding a tile when the viewer lacks [requires]
/// (H7, never a role test).  No copy lives here: labels are resolved by the
/// screen from [AppLocalizations].
class ChoresEntry {
  const ChoresEntry({
    required this.id,
    required this.icon,
    required this.title,
    required this.route,
    this.subtitle,
    this.requires,
    this.gate,
    this.badge,
  });

  /// Stable id, used by tests; never shown.
  final String id;

  final IconData icon;

  /// Localized title.
  final String Function(AppLocalizations) title;

  /// Optional localized second line.
  final String Function(AppLocalizations)? subtitle;

  /// Absolute route, e.g. `AppRoutes.choresTemplates`.
  final String route;

  /// Permission the viewer needs to see this tile; `null` = everybody.
  final Permission? requires;

  /// An extra yes/no the tile needs (B-02): for a cell like `verifyChore` that
  /// cannot be answered without a chore, so [requires] cannot express it.
  final Provider<bool>? gate;

  /// Optional count shown on the tile (for example open verifications).  A
  /// value of zero shows nothing.
  final Provider<int>? badge;
}

/// The Manage hub tiles, in display order.
///
/// Each Phase 3 step appends its entry (templates P3-16, settings P3-17, duty
/// groups P3-18, ...); keep the order of the road map's route table (3.10).
final List<ChoresEntry> choresEntries = <ChoresEntry>[
  // "Today" is NOT here: the Chores tab already has its own Today shortcut in
  // the app bar, so a second tile only duplicated it.
  ChoresEntry(
    id: 'verify',
    icon: Icons.fact_check_outlined,
    title: (l10n) => l10n.verifyTitle,
    subtitle: (l10n) => l10n.verifyEmptyMessage,
    route: AppRoutes.choresVerify,
    gate: canVerifyAnyProvider,
    badge: verifyQueueCountProvider,
  ),
  // P3-16. Managers create and edit chores; the screens re-check the permission
  // because the route itself is open to every active member.
  ChoresEntry(
    id: 'templates',
    icon: Icons.assignment_outlined,
    title: (l10n) => l10n.choreTemplatesTitle,
    subtitle: (l10n) => l10n.choreTemplatesSubtitle,
    route: AppRoutes.choresTemplates,
    requires: Permission.manageChoreTemplates,
  ),
  // P3-17.
  ChoresEntry(
    id: 'settings',
    icon: Icons.tune_outlined,
    title: (l10n) => l10n.choresSettingsTitle,
    subtitle: (l10n) => l10n.choresSettingsSubtitle,
    route: AppRoutes.choresSettings,
    requires: Permission.manageChoreTemplates,
  ),
  ChoresEntry(
    id: 'achievements',
    icon: Icons.emoji_events_outlined,
    title: (l10n) => l10n.achievementsTitle,
    route: AppRoutes.choresAchievements,
  ),
  ChoresEntry(
    id: 'engagementSettings',
    icon: Icons.auto_awesome_outlined,
    title: (l10n) => l10n.engagementSettingsGeneral,
    subtitle: (l10n) => l10n.permissionManageEngagement,
    route: AppRoutes.choresEngagementSettings,
    requires: Permission.manageEngagement,
  ),
  // P3-18. No `requires`: every member may READ the groups; the screens hide
  // the controls a member may not use.
  ChoresEntry(
    id: 'dutyGroups',
    icon: Icons.groups_outlined,
    title: (l10n) => l10n.dutyGroupsTitle,
    subtitle: (l10n) => l10n.dutyGroupsSubtitle,
    route: AppRoutes.choresDutyGroups,
  ),
  // P3-19. Managers add the family's PDF list; shown at any time so missing
  // lines can be added later (a second apply skips what already exists).
  ChoresEntry(
    id: 'starterPack',
    icon: Icons.auto_awesome_outlined,
    title: (l10n) => l10n.starterPackTitle,
    subtitle: (l10n) => l10n.starterPackSubtitle,
    route: AppRoutes.choresStarterPack,
    requires: Permission.manageChoreTemplates,
  ),
  // P3-27. Everybody records their own absence; the screen shows managers more.
  ChoresEntry(
    id: 'availability',
    icon: Icons.event_busy_outlined,
    title: (l10n) => l10n.availabilityTitle,
    subtitle: (l10n) => l10n.availabilitySubtitle,
    route: AppRoutes.choresAvailability,
  ),
  // P3-27. Managers see what still needs somebody.
  ChoresEntry(
    id: 'needsCover',
    icon: Icons.person_search_outlined,
    title: (l10n) => l10n.needsCoverTitle,
    subtitle: (l10n) => l10n.needsCoverSubtitle,
    route: AppRoutes.choresNeedsCover,
    requires: Permission.reassignChore,
    badge: needsCoverCountProvider,
  ),
  // P3-28. Managers always; members only while the family shows the workload.
  ChoresEntry(
    id: 'rota',
    icon: Icons.table_chart_outlined,
    title: (l10n) => l10n.rotaTitle,
    subtitle: (l10n) => l10n.rotaSubtitle,
    route: AppRoutes.choresRota,
    gate: rotaVisibleProvider,
  ),
  // P3-27. The module-neutral inbox, with its unread count.
  ChoresEntry(
    id: 'inbox',
    icon: Icons.notifications_none_rounded,
    title: (l10n) => l10n.inboxTitle,
    subtitle: (l10n) => l10n.inboxSparkNote,
    route: AppRoutes.inbox,
    badge: unreadInboxCountProvider,
  ),
];
