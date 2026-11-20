import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/auth/presentation/auth_providers.dart';
import 'package:family_hub/features/family/presentation/action_controller.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/family_settings_tile.dart';
import 'package:family_hub/features/family/presentation/membership_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/permission_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Family tab.  Step 8 only hosts the Settings entry (Theme, Language) and
/// sign-out; members, invitations and roles arrive with Step 9.
class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final flavor = ref.watch(flavorProvider);
    final membershipAsync = ref.watch(membershipProvider);
    final membership = membershipAsync.value;
    final canInvite = ref.can(Permission.inviteMembers);
    final canChangeRoles = ref.can(Permission.changeRoles);
    final canEditSettings = ref.can(Permission.editFamilySettings);
    final canManageChores = ref.can(Permission.manageChoreTemplates);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navFamily)),
      body: membershipAsync.hasError && membership == null
          ? ErrorView(
              message: l10n.errorUnknown,
              onRetry: () => ref.invalidate(membershipProvider),
            )
          : ListView(
              key: const PageStorageKey<String>('family_tab_list'),
              padding: const EdgeInsets.all(16),
              children: [
                FamilySettingsTile(
                  key: const Key('family_members'),
                  icon: Icons.people_outline_rounded,
                  label: l10n.membersTitle,
                  onTap: () => context.push(AppRoutes.familyMembers),
                ),
                PermissionGate(
                  allowed: canInvite,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FamilySettingsTile(
                      key: const Key('family_invitations'),
                      icon: Icons.mail_outline_rounded,
                      label: l10n.invitationsTitle,
                      onTap: () => context.push(AppRoutes.familyInvitations),
                    ),
                  ),
                ),
                PermissionGate(
                  allowed: canChangeRoles,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FamilySettingsTile(
                      key: const Key('family_roles'),
                      icon: Icons.admin_panel_settings_outlined,
                      label: l10n.rolesTitle,
                      onTap: () => context.push(AppRoutes.familyRoles),
                    ),
                  ),
                ),
                PermissionGate(
                  allowed: canEditSettings,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FamilySettingsTile(
                      key: const Key('family_settings'),
                      icon: Icons.tune_rounded,
                      label: l10n.familySettingsTitle,
                      onTap: () => context.push(AppRoutes.familySettings),
                    ),
                  ),
                ),
                PermissionGate(
                  allowed: canManageChores,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FamilySettingsTile(
                      key: const Key('family_chore_settings'),
                      icon: Icons.checklist_rounded,
                      label: l10n.choresSettingsTitle,
                      onTap: () => context.push(AppRoutes.choresSettings),
                    ),
                  ),
                ),
                PermissionGate(
                  allowed: canEditSettings,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FamilySettingsTile(
                      key: const Key('family_relationships'),
                      icon: Icons.diversity_3_rounded,
                      label: l10n.relationshipsTitle,
                      onTap: () => context.push(AppRoutes.familyRelationships),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                  child: Text(
                    l10n.settingsTitle,
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(color: t.textSecondary),
                  ),
                ),
                // The feed is otherwise reachable only from a dashboard card,
                // which is off by default; admins and finance managers need a stable entry to it.
                PermissionGate(
                  allowed: ref.can(Permission.manageDashboardLayout),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FamilySettingsTile(
                      key: const Key('family_activity'),
                      icon: Icons.history_rounded,
                      label: l10n.activityTitle,
                      onTap: () => context.push(AppRoutes.activity),
                    ),
                  ),
                ),
                FamilySettingsTile(
                  key: const Key('family_dashboard_customize'),
                  icon: Icons.dashboard_customize_outlined,
                  label: l10n.dashboardCustomize,
                  onTap: () => context.push(AppRoutes.customizeDashboard),
                ),
                const SizedBox(height: 8),
                PermissionGate(
                  allowed: ref.can(Permission.manageDashboardLayout),
                  child: FamilySettingsTile(
                    key: const Key('family_dashboard_access'),
                    icon: Icons.dashboard_outlined,
                    label: l10n.dashboardAccess,
                    onTap: () => context.push(AppRoutes.dashboardAccess),
                  ),
                ),
                const SizedBox(height: 8),
                FamilySettingsTile(
                  key: const Key('family_notification_settings'),
                  icon: Icons.notifications_outlined,
                  label: l10n.notificationSettingsTitle,
                  onTap: () => context.push(AppRoutes.notificationSettings),
                ),
                const SizedBox(height: 8),
                PermissionGate(
                  allowed: ref.can(Permission.editFamilySettings),
                  child: FamilySettingsTile(
                    key: const Key('family_notification_delivery'),
                    icon: Icons.compare_arrows,
                    label: l10n.notificationDeliveryTitle,
                    onTap: () => context.push(AppRoutes.notificationDelivery),
                  ),
                ),
                const SizedBox(height: 8),
                FamilySettingsTile(
                  key: const Key('family_settings_theme'),
                  icon: Icons.palette_outlined,
                  label: l10n.settingsThemeTitle,
                  onTap: () => context.push(AppRoutes.settingsTheme),
                ),
                const SizedBox(height: 8),
                FamilySettingsTile(
                  key: const Key('family_settings_language'),
                  icon: Icons.translate_rounded,
                  label: l10n.settingsLanguageTitle,
                  onTap: () => context.push(AppRoutes.settingsLanguage),
                ),
                const SizedBox(height: 8),
                FamilySettingsTile(
                  key: const Key('family_settings_security'),
                  icon: Icons.lock_outline_rounded,
                  label: l10n.securityTitle,
                  onTap: () => context.push(AppRoutes.settingsSecurity),
                ),
                if (flavor == Flavor.dev) ...[
                  const SizedBox(height: 8),
                  FamilySettingsTile(
                    key: const Key('family_dev_tokens'),
                    icon: Icons.color_lens_outlined,
                    label: l10n.homeViewThemeTokens,
                    onTap: () => context.push(AppRoutes.devTokens),
                  ),
                  const SizedBox(height: 8),
                  // The component gallery (Step 11).  A route alone is not reachable
                  // on a phone, so the dev flavor gets an entry next to the tokens.
                  PermissionGate(
                    allowed: ref.can(Permission.manageDashboardLayout),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: FamilySettingsTile(
                        key: const Key('family_dev_gallery'),
                        icon: Icons.widgets_outlined,
                        label: l10n.devGalleryTitle,
                        onTap: () => context.push(AppRoutes.devGallery),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _LeaveFamilyTile(familyId: membership?.familyId),
                const SizedBox(height: 8),
                FamilySettingsTile(
                  key: const Key('family_sign_out'),
                  icon: Icons.logout_rounded,
                  label: l10n.authSignOut,
                  onTap: () => ref.read(signOutProvider).call(),
                ),
              ],
            ),
    );
  }
}

final _leaveActionProvider = newActionProvider();

/// "Leave family": a confirmation first, and disabled with a reason (icon +
/// text) while the user is the only admin.
class _LeaveFamilyTile extends ConsumerWidget {
  const _LeaveFamilyTile({required this.familyId});

  final String? familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final soleAdmin = ref.watch(soleAdminProvider);
    final busy = ref.watch(_leaveActionProvider).busy;

    ref.listen(_leaveActionProvider, (_, next) {
      final f = next.failure;
      if (f != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.familyFailureMessage(f))));
      }
    });

    Future<void> onTap() async {
      final uid = ref.read(currentUidProvider);
      final fid = familyId;
      if (uid == null || fid == null || busy) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(l10n.familyLeaveConfirmTitle),
          content: Text(l10n.familyLeaveConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              key: const Key('family_leave_confirm'),
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(l10n.familyLeave),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      // On success the membership stream makes the router open family choice.
      await ref
          .read(_leaveActionProvider.notifier)
          .run(
            () => ref.read(leaveFamilyProvider)(actorUid: uid, familyId: fid),
          );
    }

    return PermissionGate(
      allowed: !soleAdmin,
      mode: PermissionGateMode.disable,
      deniedMessage: l10n.familyLeaveLastAdminReason,
      child: FamilySettingsTile(
        key: const Key('family_leave'),
        icon: Icons.exit_to_app_rounded,
        label: l10n.familyLeave,
        onTap: onTap,
      ),
    );
  }
}
