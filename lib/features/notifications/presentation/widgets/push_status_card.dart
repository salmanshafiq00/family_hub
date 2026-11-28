import 'package:family_hub/app/feature_flags.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/notifications/presentation/push_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PushStatusCard extends ConsumerWidget {
  const PushStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final diagnostics = ref.watch(pushDiagnosticsProvider);
    if (!FeatureFlags.pushBackend) {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const Icon(Icons.cloud_off_outlined),
          title: Text(l10n.notificationSenderUnavailable),
          subtitle: Text(l10n.notificationSenderSparkHint),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: diagnostics.when(
        loading: () => ListTile(
          leading: const Icon(Icons.cloud_outlined),
          title: Text(l10n.notificationSenderChecking),
        ),
        error: (_, _) => ListTile(
          leading: const Icon(Icons.error_outline),
          title: Text(l10n.notificationSenderError),
        ),
        data: (value) => ListTile(
          leading: Icon(
            value.lastError == null ? Icons.cloud_done_outlined : Icons.error,
          ),
          title: Text(
            value.lastError == null
                ? l10n.notificationSenderReady
                : l10n.notificationSenderLastFailed,
          ),
        ),
      ),
    );
  }
}
