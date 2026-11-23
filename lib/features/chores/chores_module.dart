import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_screen.dart';
import 'package:family_hub/features/chores/achievements/presentation/screens/achievements_screen.dart';
import 'package:family_hub/features/chores/achievements/presentation/screens/engagement_settings_screen.dart';
import 'package:family_hub/features/chores/achievements/presentation/widgets/hub_level_card.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_editor_screen.dart';
import 'package:family_hub/features/chores/rota/presentation/rota_board_screen.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_list_screen.dart';
import 'package:family_hub/features/chores/presentation/chores_home_screen.dart';
import 'package:family_hub/features/chores/presentation/chores_manage_screen.dart';
import 'package:family_hub/features/chores/presentation/dashboard/chores_dashboard_cards.dart';
import 'package:family_hub/features/chores/presentation/dashboard/chores_week_card.dart';
import 'package:family_hub/features/dashboard/domain/dashboard_card_spec.dart';
import 'package:family_hub/features/chores/presentation/occurrence_detail_screen.dart';
import 'package:family_hub/features/chores/presentation/today_screen.dart';
import 'package:family_hub/features/chores/presentation/verify_queue_screen.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_screen.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_item_editor_screen.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_pack_list_screen.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_pack_wizard_screen.dart';
import 'package:family_hub/features/chores/swaps/presentation/needs_cover_board.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_screen.dart';
import 'package:family_hub/features/chores/templates/presentation/template_list_screen.dart';
import 'package:family_hub/modules/family_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Chores module.  Routes nest under [AppRoutes.chores]; every later
/// Phase 3 screen is added as a child route (roadmap 3.10).
class ChoresModule extends FamilyModule {
  const ChoresModule();

  @override
  String get id => 'chores';

  @override
  String get nameBn => 'কাজ';

  @override
  String get nameEn => 'Chores';

  @override
  String label(AppLocalizations l10n) => l10n.navChores;

  @override
  IconData get icon => Icons.checklist_rtl_rounded;

  @override
  IconData get selectedIcon => Icons.checklist_rounded;

  @override
  String get basePath => AppRoutes.chores;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutes.chores,
      builder: (context, state) => const ChoresHomeScreen(),
      routes: [
        GoRoute(
          path: 'manage',
          builder: (context, state) => const ChoresManageScreen(),
        ),
        GoRoute(
          path: 'today',
          builder: (context, state) => const TodayScreen(),
        ),
        GoRoute(
          path: 'verify',
          builder: (context, state) => const VerifyQueueScreen(),
        ),
        GoRoute(
          path: 'templates',
          builder: (context, state) => const TemplateListScreen(),
          routes: [
            // `new` BEFORE `:id`, or it would be read as a template id.
            GoRoute(
              path: 'new',
              builder: (context, state) => const TemplateEditorScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  TemplateEditorScreen(templateId: state.pathParameters['id']),
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const ChoreSettingsScreen(),
        ),
        GoRoute(
          path: 'achievements',
          builder: (context, state) => const AchievementsScreen(),
        ),
        GoRoute(
          path: 'engagement',
          builder: (context, state) => const EngagementSettingsScreen(),
        ),
        // P3-19. Reachable from Manage at any time; the use case skips what
        // already exists, so opening it again never duplicates a chore.
        GoRoute(
          path: 'starter-pack',
          builder: (context, state) => const StarterPackWizardScreen(),
          routes: [
            GoRoute(
              path: 'list',
              builder: (context, state) => const StarterPackListScreen(),
              routes: [
                // `new` BEFORE `:id`, or it would be read as a line id.
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const StarterItemEditorScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) => StarterItemEditorScreen(
                    itemId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: 'duty-groups',
          builder: (context, state) => const DutyGroupListScreen(),
          routes: [
            // `new` BEFORE `:id`, or it would be read as a group id.
            GoRoute(
              path: 'new',
              builder: (context, state) => const DutyGroupEditorScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  DutyGroupEditorScreen(groupId: state.pathParameters['id']),
            ),
          ],
        ),
        // P3-28.
        GoRoute(
          path: 'rota',
          builder: (context, state) => const RotaBoardScreen(),
        ),
        // P3-27.
        GoRoute(
          path: 'availability',
          builder: (context, state) => const AvailabilityScreen(),
        ),
        GoRoute(
          path: 'needs-cover',
          builder: (context, state) => const NeedsCoverBoard(),
        ),
        // Declared AFTER the fixed paths above so `today`/`verify` are never
        // captured by the id pattern.
        GoRoute(
          path: 'occurrence/:id',
          builder: (context, state) =>
              OccurrenceDetailScreen(occurrenceId: state.pathParameters['id']!),
        ),
      ],
    ),
  ];

  /// P3-29: Today, Overdue, Awaiting verification and This week. The Chores
  /// settings tile stays in the Family tab (P3-17), so `settingsEntry` is unused.
  @override
  List<WidgetBuilder> get dashboardCards => choresDashboardCards;

  @override
  List<DashboardCardSpec<DashboardCardBuilder>> get dashboardCardSpecs =>
      <DashboardCardSpec<DashboardCardBuilder>>[
        DashboardCardSpec<DashboardCardBuilder>(
          id: 'chores_today',
          builder: (_, _) => const ChoresTodayCard(),
        ),
        DashboardCardSpec<DashboardCardBuilder>(
          id: 'chores_overdue',
          builder: (_, _) => const ChoresOverdueCard(),
        ),
        DashboardCardSpec<DashboardCardBuilder>(
          id: 'chores_verify',
          builder: (_, _) => const ChoresVerifyCard(),
        ),
        DashboardCardSpec<DashboardCardBuilder>(
          id: 'chores_week',
          builder: (_, _) => const ChoresWeekCard(),
        ),
        DashboardCardSpec<DashboardCardBuilder>(
          id: 'hub_level',
          builder: (_, _) => const HubLevelCard(),
        ),
      ];
}
