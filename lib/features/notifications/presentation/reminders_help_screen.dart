import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/notifications/presentation/widgets/diagnostics_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RemindersHelpScreen extends StatelessWidget {
  const RemindersHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationHelpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.notificationHelpIntro),
          const SizedBox(height: 12),
          const DiagnosticsList(),
          const Divider(),
          Text(l10n.notificationChecklistTitle),
          for (final (index, text) in [
            l10n.notificationChecklistAllow,
            l10n.notificationChecklistAlarms,
            l10n.notificationChecklistBattery,
            l10n.notificationChecklistForceStop,
            l10n.notificationChecklistOpen,
          ].indexed)
            ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(text),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.notificationNoSenderHonesty),
            ),
          ),
          TextButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.notificationSettings),
            child: Text(l10n.notificationSettingsTitle),
          ),
        ],
      ),
    );
  }
}
