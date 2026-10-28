import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/features/chores/presentation/chores_home_screen.dart';
import 'package:family_hub/features/chores/presentation/chores_manage_screen.dart';
import 'package:family_hub/features/chores/presentation/occurrence_detail_screen.dart';
import 'package:family_hub/features/chores/presentation/today_screen.dart';
import 'package:family_hub/features/chores/presentation/verify_queue_screen.dart';
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
}
