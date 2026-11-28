import 'package:family_hub/app/feature_flags.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:family_hub/features/notifications/presentation/widgets/delivery_type_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chore notification delivery section (Normal in-app vs Push) for chore alerts.
class ChoreDeliverySection extends ConsumerWidget {
  const ChoreDeliverySection({
    required this.settings,
    required this.onChanged,
    super.key,
  });

  final NotificationDeliverySettings settings;
  final ValueChanged<NotificationDeliverySettings> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final isAdmin = ref.can(Permission.editFamilySettings);
    final pushMasterEnabled = FeatureFlags.pushBackend && settings.pushEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!FeatureFlags.pushBackend)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                borderRadius: BorderRadius.circular(t.radiusMd),
                border: Border.all(color: t.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: t.info, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.notificationSenderSparkHint,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: t.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (!isAdmin)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.choresSettingsDeliveryAdminOnly,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: t.textSecondary),
            ),
          ),
        DeliveryTypeList(
          settings: settings,
          category: NotificationCategory.chores,
          pushMasterEnabled: pushMasterEnabled,
          enabled: isAdmin,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
