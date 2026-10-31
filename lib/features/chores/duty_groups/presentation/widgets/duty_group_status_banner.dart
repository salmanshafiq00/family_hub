import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_controller.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the last duty-group action did, in one place (P3-18): working, failed
/// (nothing was stored), or stored with the planning failed (Retry).
///
/// A "last group in use" conflict is NOT shown here: the editor turns it into
/// a confirmation dialog.
class DutyGroupStatusBanner extends ConsumerWidget {
  const DutyGroupStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(dutyGroupControllerProvider);

    if (state.saving) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Semantics(
          liveRegion: true,
          label: l10n.dutyPlanning,
          child: const LinearProgressIndicator(),
        ),
      );
    }
    final failure = state.failure;
    if (state.status == DutyGroupStatus.failed &&
        failure != null &&
        !state.needsDeactivateConfirm) {
      return _Box(
        color: t.danger,
        icon: Icons.error_outline,
        text: l10n.choresFailureMessage(failure),
      );
    }
    if (state.status == DutyGroupStatus.planningFailed) {
      final planning = state.planningFailure;
      return _Box(
        color: t.warning,
        icon: Icons.sync_problem_outlined,
        text: planning == null
            ? l10n.dutyPlanFailed
            : '${l10n.dutyPlanFailed} ${l10n.choresFailureMessage(planning)}',
        action: TextButton(
          key: const ValueKey<String>('plan_retry'),
          style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () =>
              ref.read(dutyGroupControllerProvider.notifier).retryPlanning(),
          child: Text(
            l10n.actionRetry,
            style: textTheme.labelLarge?.copyWith(color: t.textPrimary),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.color,
    required this.icon,
    required this.text,
    this.action,
  });

  final Color color;
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.surfaceRaised,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(t.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: t.textPrimary),
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
