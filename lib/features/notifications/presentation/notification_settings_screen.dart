import 'package:family_hub/app/feature_flags.dart';
import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/notifications/domain/delivery_policy.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/domain/member_notification_prefs.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/presentation/notification_providers.dart';
import 'package:family_hub/features/notifications/presentation/widgets/test_notification_button.dart';
import 'package:family_hub/features/notifications/presentation/widgets/category_section.dart';
import 'package:family_hub/features/notifications/presentation/widgets/family_defaults_section.dart';
import 'package:family_hub/features/notifications/presentation/widgets/permission_banner.dart';
import 'package:family_hub/features/notifications/presentation/widgets/quiet_hours_section.dart';
import 'package:family_hub/features/notifications/presentation/widgets/summary_section.dart';
import 'package:family_hub/features/notifications/presentation/widgets/timings_section.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:family_hub/shared/widgets/home_fallback_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'notification_settings_screen_parts.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _saving = false;

  Future<void> _savePrefs(MemberNotificationPrefs prefs) async {
    final familyId = ref.read(currentFamilyIdProvider);
    final defaultsAsync = familyId == null
        ? null
        : ref.read(familyDefaultsProvider(familyId));
    if (familyId != null && defaultsAsync?.hasValue != true) return;
    final defaults =
        defaultsAsync?.requireValue ?? NotificationDefaults.defaults;
    setState(() => _saving = true);
    final result = await ref
        .read(memberPrefsProvider.notifier)
        .save(prefs: prefs, familyDefaults: defaults);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.failureOrNull != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.notificationSaveFailed)),
      );
    }
  }

  Future<void> _saveDefaults(NotificationDefaults defaults) async {
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null || _saving) return;
    setState(() => _saving = true);
    final result = await ref
        .read(updateNotificationDefaultsProvider)
        .call(actorUid: uid, familyId: familyId, settings: defaults);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.failureOrNull != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.notificationSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final familyId = ref.watch(currentFamilyIdProvider);
    final member = ref.watch(memberPrefsProvider);
    final settingsAsync = ref.watch(reminderSettingsProvider);
    final familyDefaultsAsync = familyId == null
        ? AsyncData<NotificationDefaults>(NotificationDefaults.defaults)
        : ref.watch(familyDefaultsProvider(familyId));
    final canManageDefaults = ref.can(Permission.manageNotificationDefaults);
    final canManageDelivery = ref.can(Permission.editFamilySettings);
    final canManageChores = ref.can(Permission.manageChoreTemplates);

    return HomeFallbackBack(
      child: Scaffold(
        appBar: AppBar(
          leading: homeFallbackLeading(context),
          title: Text(l10n.notificationSettingsTitle),
          actions: [
            IconButton(
              tooltip: l10n.notificationHelpTitle,
              onPressed: () => context.push(AppRoutes.remindersHelp),
              icon: const Icon(Icons.help_outline),
            ),
          ],
        ),
        body: settingsAsync.when(
          loading: () => const LoadingView(),
          error: (failure, _) => Center(
            child: ErrorView(
              message: failure is Network
                  ? l10n.errorNetwork
                  : l10n.errorUnknown,
              onRetry: familyId == null
                  ? null
                  : () => ref.invalidate(familyDefaultsProvider(familyId)),
            ),
          ),
          // P4-24: switches and explanations stay readable on a wide screen
          // instead of stretching their whole width.
          data: (settings) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const PermissionBanner(),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    key: const Key('notifications_master'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.notificationAllEnabled),
                    subtitle: Text(l10n.notificationMasterExplanation),
                    value: settings.globalEnabled,
                    onChanged: _saving
                        ? null
                        : (value) => _savePrefs(
                            member.copyWith(
                              reminderOverrides: member.reminderOverrides
                                  .copyWith(globalEnabled: value),
                            ),
                          ),
                  ),
                  CategorySection(
                    settings: settings,
                    onChanged: (next) {
                      final overrides = member.reminderOverrides.copyWith(
                        choresEnabled:
                            next.choresEnabled != settings.choresEnabled
                            ? next.choresEnabled
                            : null,
                        bazarEnabled: next.bazarEnabled != settings.bazarEnabled
                            ? next.bazarEnabled
                            : null,
                        familyEnabled:
                            next.familyEnabled != settings.familyEnabled
                            ? next.familyEnabled
                            : null,
                      );
                      _savePrefs(member.copyWith(reminderOverrides: overrides));
                    },
                  ),
                  const Divider(),
                  TimingsSection(
                    settings: settings,
                    formatters: ref.watch(appFormattersProvider),
                    onChanged: (next) {
                      final overrides = member.reminderOverrides.copyWith(
                        defaultOffsetsMinutes:
                            _sameInts(
                              next.defaultOffsetsMinutes,
                              settings.defaultOffsetsMinutes,
                            )
                            ? null
                            : next.defaultOffsetsMinutes,
                        overdueEnabled:
                            next.overdueEnabled != settings.overdueEnabled
                            ? next.overdueEnabled
                            : null,
                      );
                      _savePrefs(member.copyWith(reminderOverrides: overrides));
                    },
                  ),
                  SummarySection(
                    summary: settings.morningSummary,
                    onChanged: (next) {
                      final current = settings.morningSummary;
                      final overrides = member.reminderOverrides.copyWith(
                        morningSummaryEnabled: next.enabled != current.enabled
                            ? next.enabled
                            : null,
                        morningSummaryMinutes: next.minutes != current.minutes
                            ? next.minutes
                            : null,
                      );
                      _savePrefs(member.copyWith(reminderOverrides: overrides));
                    },
                  ),
                  QuietHoursSection(
                    quiet: settings.quiet,
                    onChanged: (next) {
                      final current = settings.quiet;
                      final overrides = member.reminderOverrides.copyWith(
                        quietEnabled: next.enabled != current.enabled
                            ? next.enabled
                            : null,
                        quietStartMinutes:
                            next.startMinutes != current.startMinutes
                            ? next.startMinutes
                            : null,
                        quietEndMinutes: next.endMinutes != current.endMinutes
                            ? next.endMinutes
                            : null,
                      );
                      _savePrefs(member.copyWith(reminderOverrides: overrides));
                    },
                  ),
                  SwitchListTile(
                    key: const Key('notifications_push_member'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.notificationPushOnPhone),
                    subtitle: Text(
                      FeatureFlags.pushBackend
                          ? _effectivePushReason(context, ref, member)
                          : l10n.notificationSenderSparkHint,
                    ),
                    value: member.pushEnabled,
                    onChanged: FeatureFlags.pushBackend && !_saving
                        ? (value) =>
                              _savePrefs(member.copyWith(pushEnabled: value))
                        : null,
                  ),
                  if (canManageDefaults && familyDefaultsAsync.hasValue)
                    FamilyDefaultsSection(
                      defaults: familyDefaultsAsync.requireValue,
                      busy: _saving,
                      onSave: _saveDefaults,
                    ),
                  if (canManageDelivery)
                    ListTile(
                      key: const Key('notification_delivery_admin_link'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.compare_arrows),
                      title: Text(l10n.notificationDeliveryTitle),
                      onTap: () => context.push(AppRoutes.notificationDelivery),
                    ),
                  if (canManageChores)
                    ListTile(
                      key: const Key('notification_chores_settings_link'),
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.cleaning_services_outlined),
                      title: Text(l10n.notificationOpenChoreSettings),
                      subtitle: Text(l10n.notificationChoresSettingsLink),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go(AppRoutes.choresSettings),
                    ),
                  ListTile(
                    key: const Key('notification_help_link'),
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.help_outline),
                    title: Text(l10n.notificationHelpTitle),
                    onTap: () => context.push(AppRoutes.remindersHelp),
                  ),
                  const TestNotificationButton(),
                  TextButton(
                    key: const Key('notification_use_family_defaults'),
                    onPressed: _saving
                        ? null
                        : () => _savePrefs(
                            MemberNotificationPrefs.defaults.copyWith(
                              pushEnabled: member.pushEnabled,
                            ),
                          ),
                    child: Text(l10n.notificationUseFamilyDefaults),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
