import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:flutter/material.dart';

class DeliveryTypeList extends StatelessWidget {
  const DeliveryTypeList({
    required this.settings,
    required this.onChanged,
    this.pushMasterEnabled = true,
    this.category,
    this.categories,
    this.enabled = true,
    super.key,
  });

  final NotificationDeliverySettings settings;
  final ValueChanged<NotificationDeliverySettings> onChanged;
  final bool pushMasterEnabled;
  final NotificationCategory? category;
  final List<NotificationCategory>? categories;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final effectiveCategories =
        categories ??
        (category != null
            ? <NotificationCategory>[category!]
            : NotificationCategory.values);
    final showHeaders = category == null && effectiveCategories.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final cat in effectiveCategories) ...[
          if (showHeaders)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(switch (cat) {
                NotificationCategory.chores => l10n.notificationCategoryChores,
                NotificationCategory.bazar => l10n.notificationCategoryBazar,
                NotificationCategory.family => l10n.notificationCategoryFamily,
              }, style: Theme.of(context).textTheme.titleMedium),
            ),
          for (final type in NotificationTypes.all)
            if (type.category == cat)
              _DeliveryTypeTile(
                type: type,
                mode: settings.modes[type.id] ?? type.recommendedMode,
                pushMasterEnabled: pushMasterEnabled,
                enabled: enabled,
                onChanged: (mode) => onChanged(
                  settings.copyWith(modes: {...settings.modes, type.id: mode}),
                ),
              ),
        ],
      ],
    );
  }
}

class _DeliveryTypeTile extends StatelessWidget {
  const _DeliveryTypeTile({
    required this.type,
    required this.mode,
    required this.pushMasterEnabled,
    required this.onChanged,
    this.enabled = true,
  });

  final NotificationType type;
  final DeliveryMode mode;
  final bool pushMasterEnabled;
  final bool enabled;
  final ValueChanged<DeliveryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = _typeName(l10n, type.id);
    final recommended = type.recommendedMode == DeliveryMode.push
        ? l10n.notificationPush
        : l10n.notificationNormal;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleSmall),
            Text(
              type.pushCapable
                  ? !pushMasterEnabled && mode == DeliveryMode.push
                        ? l10n.notificationPushSavedInactive
                        : l10n.notificationRecommended(recommended)
                  : l10n.notificationTypeLocked,
            ),
            const SizedBox(height: 8),
            SegmentedButton<DeliveryMode>(
              segments: [
                ButtonSegment(
                  value: DeliveryMode.normal,
                  label: Text(l10n.notificationNormal),
                ),
                ButtonSegment(
                  value: DeliveryMode.push,
                  label: Text(l10n.notificationPush),
                  enabled: enabled && type.pushCapable,
                ),
              ],
              selected: {type.pushCapable ? mode : DeliveryMode.normal},
              onSelectionChanged: enabled && type.pushCapable
                  ? (selected) => onChanged(selected.first)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _typeName(AppLocalizations l10n, String id) => switch (id) {
    'swap_request' => l10n.notificationTypeSwapRequest,
    'swap_result' => l10n.notificationTypeSwapResult,
    'needs_cover' => l10n.notificationTypeNeedsCover,
    'chore_assigned' => l10n.notificationTypeChoreAssigned,
    'chore_reopened' => l10n.notificationTypeChoreReopened,
    'comment_attention' => l10n.notificationTypeCommentAttention,
    'verification_needed' => l10n.notificationTypeVerificationNeeded,
    'absence_decision' => l10n.notificationTypeAbsenceDecision,
    'member_join_request' => l10n.notificationTypeMemberJoinRequest,
    'member_approved' => l10n.notificationTypeMemberApproved,
    'chore_due' => l10n.notificationTypeChoreDue,
    'chore_overdue' => l10n.notificationTypeChoreOverdue,
    'evening_nudge' => l10n.notificationTypeEveningNudge,
    'morning_summary' => l10n.notificationTypeMorningSummary,
    'contribution_due' => l10n.notificationTypeContributionDue,
    'month_end' => l10n.notificationTypeMonthEnd,
    'budget_alert' => l10n.notificationTypeBudgetAlert,
    'achievement' => l10n.notificationTypeAchievement,
    _ => id,
  };
}
