part of 'template_editor_screen.dart';

/// "Step 2 of 4" plus a progress bar, above the page area.
class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.label, required this.progress});

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            key: const ValueKey<String>('editor_step_label'),
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: t.accent,
              backgroundColor: t.surfaceSunken,
              semanticsLabel: label,
            ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.actionKey,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final Key? actionKey;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: t.warning, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: t.textPrimary),
                ),
                if (actionLabel != null)
                  TextButton(
                    key: actionKey,
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Back/Continue bar for the steps before the last one.
class _NextBar extends StatelessWidget {
  const _NextBar({required this.onBack, required this.onNext});

  final VoidCallback? onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return Material(
      color: t.surfaceRaised,
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey<String>('editor_back'),
                  onPressed: onBack,
                  child: Text(l10n.actionBack),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  key: const ValueKey<String>('editor_next'),
                  onPressed: onNext,
                  child: Text(l10n.actionContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.failure,
    required this.saving,
    required this.canSave,
    required this.onSave,
    required this.onBack,
  });

  final AppFailure? failure;
  final bool saving;
  final bool canSave;
  final Future<void> Function() onSave;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final f = failure;
    return Material(
      color: t.surfaceRaised,
      elevation: 8,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (f != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: t.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.choresFailureMessage(f),
                          key: const ValueKey<String>('editor_failure'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  OutlinedButton(
                    key: const ValueKey<String>('editor_back'),
                    onPressed: saving ? null : onBack,
                    child: Text(l10n.actionBack),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BusyButton(
                      key: const ValueKey<String>('editor_save'),
                      label: l10n.actionSave,
                      busy: saving,
                      busyLabel: l10n.loadingSemantics,
                      onPressed: canSave ? () => onSave() : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
