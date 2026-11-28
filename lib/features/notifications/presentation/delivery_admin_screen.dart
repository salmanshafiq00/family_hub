import 'package:family_hub/app/feature_flags.dart';
import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:go_router/go_router.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:family_hub/features/notifications/presentation/notification_providers.dart';
import 'package:family_hub/features/notifications/presentation/widgets/delivery_type_list.dart';
import 'package:family_hub/features/notifications/presentation/widgets/push_status_card.dart';
import 'package:family_hub/shared/widgets/busy_button.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/permission_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliveryAdminScreen extends ConsumerStatefulWidget {
  const DeliveryAdminScreen({super.key});

  @override
  ConsumerState<DeliveryAdminScreen> createState() =>
      _DeliveryAdminScreenState();
}

class _DeliveryAdminScreenState extends ConsumerState<DeliveryAdminScreen> {
  NotificationDeliverySettings? _draft;
  NotificationDeliverySettings? _saved;
  bool _saving = false;
  bool _confirmingBack = false;

  bool get _dirty => _draft != null && _saved != null && _draft != _saved;

  Future<bool> _confirmDiscard() async {
    final l10n = context.l10n;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.notificationDiscardTitle),
            content: Text(l10n.notificationDiscardMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.actionDiscard),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _save() async {
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    final draft = _draft;
    if (familyId == null || uid == null || draft == null || _saving) return;
    setState(() => _saving = true);
    final result = await ref
        .read(updateNotificationDeliveryProvider)
        .call(actorUid: uid, familyId: familyId, settings: draft);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (result.failureOrNull == null) _saved = draft;
    });
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
    final canManage = ref.can(Permission.editFamilySettings);
    final delivery = familyId == null
        ? AsyncData<NotificationDeliverySettings>(
            NotificationDeliverySettings.defaults(),
          )
        : ref.watch(deliveryPolicyProvider(familyId));
    final remoteValue = delivery.value;
    final value = remoteValue?.copyWith(
      pushEnabled: FeatureFlags.pushBackend && remoteValue.pushEnabled,
    );
    if (value != null && _saved != value) {
      _saved = value;
      if (!_dirty) _draft = value;
    }

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !_dirty || _confirmingBack) return;
        _confirmingBack = true;
        final discard = await _confirmDiscard();
        _confirmingBack = false;
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.notificationDeliveryTitle)),
        body: PermissionGate(
          allowed: canManage,
          child: delivery.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (failure, _) => Center(
              child: ErrorView(
                message: failure is Network
                    ? l10n.errorNetwork
                    : l10n.errorUnknown,
                onRetry: familyId == null
                    ? null
                    : () => ref.invalidate(deliveryPolicyProvider(familyId)),
              ),
            ),
            data: (initial) {
              final settings = _draft ?? initial;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const PushStatusCard(),
                  if (!FeatureFlags.pushBackend)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(l10n.notificationSenderSparkHint),
                      ),
                    ),
                  SwitchListTile(
                    key: const Key('delivery_master'),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.notificationAllowPush),
                    subtitle: Text(
                      FeatureFlags.pushBackend
                          ? l10n.notificationMasterExplanation
                          : l10n.notificationSenderUnavailable,
                    ),
                    value: FeatureFlags.pushBackend && settings.pushEnabled,
                    onChanged: FeatureFlags.pushBackend
                        ? (value) => setState(
                            () =>
                                _draft = settings.copyWith(pushEnabled: value),
                          )
                        : null,
                  ),
                  const SizedBox(height: 8),
                  if (ref.can(Permission.manageChoreTemplates))
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.cleaning_services_outlined),
                        title: Text(l10n.notificationOpenChoreSettings),
                        subtitle: Text(l10n.notificationChoresDeliveryMoved),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go(AppRoutes.choresSettings),
                      ),
                    ),
                  DeliveryTypeList(
                    settings: settings,
                    categories: const [
                      NotificationCategory.bazar,
                      NotificationCategory.family,
                    ],
                    pushMasterEnabled:
                        FeatureFlags.pushBackend && settings.pushEnabled,
                    onChanged: (next) => setState(() => _draft = next),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('delivery_reset_recommended'),
                    onPressed: () {
                      final nextModes = Map<String, DeliveryMode>.from(
                        settings.modes,
                      );
                      for (final type in NotificationTypes.all) {
                        if (type.category != NotificationCategory.chores &&
                            type.pushCapable) {
                          nextModes[type.id] = type.recommendedMode;
                        }
                      }
                      setState(
                        () => _draft = settings.copyWith(modes: nextModes),
                      );
                    },
                    child: Text(l10n.notificationResetRecommended),
                  ),
                  const SizedBox(height: 8),
                  BusyButton(
                    key: const Key('delivery_save'),
                    label: l10n.actionSave,
                    busy: _saving,
                    onPressed: _dirty ? _save : null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
