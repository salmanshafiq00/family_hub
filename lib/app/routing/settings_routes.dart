import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/dev_tokens_screen.dart';
import 'package:family_hub/features/activity/presentation/activity_feed_screen.dart';
import 'package:family_hub/features/dashboard/presentation/customize_dashboard_screen.dart';
import 'package:family_hub/features/dashboard/presentation/dashboard_access_screen.dart';
import 'package:family_hub/features/notifications/presentation/delivery_admin_screen.dart';
import 'package:family_hub/features/notifications/presentation/inbox_screen.dart';
import 'package:family_hub/features/notifications/presentation/notification_settings_screen.dart';
import 'package:family_hub/features/notifications/presentation/reminders_help_screen.dart';
import 'package:family_hub/features/settings/presentation/language_settings_screen.dart';
import 'package:family_hub/features/settings/presentation/security_screen.dart';
import 'package:family_hub/features/settings/presentation/theme_settings_screen.dart';
import 'package:family_hub/app/gallery/dev_gallery_screen.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> settingsRoutes(Flavor flavor) => [
  GoRoute(
    path: AppRoutes.settingsTheme,
    builder: (context, state) => const ThemeSettingsScreen(),
  ),
  GoRoute(
    path: AppRoutes.settingsLanguage,
    builder: (context, state) => const LanguageSettingsScreen(),
  ),
  GoRoute(
    path: AppRoutes.inbox,
    builder: (context, state) => const InboxScreen(),
  ),
  GoRoute(
    path: AppRoutes.inboxItemPattern,
    builder: (context, state) =>
        InboxScreen(focusItemId: state.pathParameters['itemId']),
  ),
  GoRoute(
    path: AppRoutes.activity,
    builder: (context, state) => const ActivityFeedScreen(),
  ),
  GoRoute(
    path: AppRoutes.notificationSettings,
    builder: (context, state) => const NotificationSettingsScreen(),
  ),
  GoRoute(
    path: AppRoutes.notificationDelivery,
    builder: (context, state) => const DeliveryAdminScreen(),
  ),
  GoRoute(
    path: AppRoutes.remindersHelp,
    builder: (context, state) => const RemindersHelpScreen(),
  ),
  GoRoute(
    path: AppRoutes.settingsSecurity,
    builder: (context, state) => const SecurityScreen(),
  ),
  GoRoute(
    path: AppRoutes.customizeDashboard,
    builder: (context, state) => const CustomizeDashboardScreen(),
  ),
  GoRoute(
    path: AppRoutes.dashboardAccess,
    builder: (context, state) => const DashboardAccessScreen(),
  ),
  if (flavor == Flavor.dev)
    GoRoute(
      path: AppRoutes.devTokens,
      builder: (context, state) => const DevTokensScreen(),
    ),
  if (flavor == Flavor.dev)
    GoRoute(
      path: AppRoutes.devGallery,
      builder: (context, state) => const DevGalleryScreen(),
    ),
];
