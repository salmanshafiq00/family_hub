part of 'chore_settings_screen.dart';

/// Keeps each tab scrollable and preserves state across tab switching.
class _TabScroll extends StatefulWidget {
  const _TabScroll({required this.child});

  final Widget child;

  @override
  State<_TabScroll> createState() => _TabScrollState();
}

class _TabScrollState extends State<_TabScroll>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [widget.child],
    );
  }
}

/// One section: its title, a "Reset section" action with a confirmation, and
/// the section widget.
class _SectionCard extends ConsumerWidget {
  const _SectionCard({
    required this.title,
    required this.section,
    required this.child,
  });

  final String title;
  final ChoreSettingsSection section;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(t.radiusMd),
          boxShadow: t.elevation1,
        ),
        // The transparent Material is what lets the section's switches paint
        // their ink on this card; a bare DecoratedBox hides the splash.
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: TextButton(
                  key: ValueKey<String>('reset_${section.name}'),
                  onPressed: () async {
                    final ok = await _confirmReset(context);
                    if (ok) {
                      ref
                          .read(choreSettingsEditorProvider.notifier)
                          .resetSection(section);
                    }
                  },
                  child: Text(l10n.choresSettingsResetSection),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmReset(BuildContext context) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.choresSettingsResetConfirmTitle),
        content: Text(l10n.choresSettingsResetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('reset_confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.choresSettingsResetConfirmAction),
          ),
        ],
      ),
    );
    return ok ?? false;
  }
}

/// The sticky bar: the failure (or "needs internet") and the one Save button.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.form, required this.onSave});

  final ChoreSettingsFormState form;
  final Future<bool> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final failure = form.failure;
    final message = failure == null
        ? null
        : (form.needsInternet
              ? l10n.choresSettingsNeedsInternet
              : l10n.choresFailureMessage(failure));
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
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        form.needsInternet
                            ? Icons.cloud_off_rounded
                            : Icons.error_outline_rounded,
                        size: 18,
                        color: t.danger,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          message,
                          key: const ValueKey<String>('settings_failure'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              BusyButton(
                key: const ValueKey<String>('settings_save'),
                label: l10n.choresSettingsSave,
                busy: form.saving,
                busyLabel: l10n.loadingSemantics,
                onPressed: form.isDirty ? () => onSave() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
