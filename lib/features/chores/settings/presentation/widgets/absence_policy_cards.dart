import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:flutter/material.dart';

/// The three absence policies as explanatory radio cards (P3-17).
///
/// One selected card at a time; the selection is an icon AND a heavier border,
/// never colour alone, and the whole card is one 48 dp+ tap target announced to
/// screen readers as a mutually exclusive choice.
class AbsencePolicyCards extends StatelessWidget {
  const AbsencePolicyCards({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final AbsencePolicy selected;
  final ValueChanged<AbsencePolicy> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        for (final policy in AbsencePolicy.values) ...[
          _PolicyCard(
            key: ValueKey<String>('policy_${policy.id}'),
            policy: policy,
            selected: policy == selected,
            title: _title(l10n, policy),
            description: _description(l10n, policy),
            example: _example(l10n, policy),
            onTap: () => onChanged(policy),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  static String _title(AppLocalizations l10n, AbsencePolicy policy) =>
      switch (policy) {
        AbsencePolicy.askCover => l10n.choresPolicyAskCoverTitle,
        AbsencePolicy.autoCover => l10n.choresPolicyAutoCoverTitle,
        AbsencePolicy.skip => l10n.choresPolicySkipTitle,
        AbsencePolicy.autoAssign => l10n.choresPolicyAutoAssignTitle,
      };

  static String _description(AppLocalizations l10n, AbsencePolicy policy) =>
      switch (policy) {
        AbsencePolicy.askCover => l10n.choresPolicyAskCoverDesc,
        AbsencePolicy.autoCover => l10n.choresPolicyAutoCoverDesc,
        AbsencePolicy.skip => l10n.choresPolicySkipDesc,
        AbsencePolicy.autoAssign => l10n.choresPolicyAutoAssignDesc,
      };

  static String _example(AppLocalizations l10n, AbsencePolicy policy) =>
      switch (policy) {
        AbsencePolicy.askCover => l10n.choresPolicyAskCoverExample,
        AbsencePolicy.autoCover => l10n.choresPolicyAutoCoverExample,
        AbsencePolicy.skip => l10n.choresPolicySkipExample,
        AbsencePolicy.autoAssign => l10n.choresPolicyAutoAssignExample,
      };
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.policy,
    required this.selected,
    required this.title,
    required this.description,
    required this.example,
    required this.onTap,
    super.key,
  });

  final AbsencePolicy policy;
  final bool selected;
  final String title;
  final String description;
  final String example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? t.accentSoft : t.surface,
            borderRadius: BorderRadius.circular(t.radiusMd),
            border: Border.all(
              color: selected ? t.accentStrong : t.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected ? t.accentStrong : t.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: text.titleSmall?.copyWith(color: t.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: text.bodyMedium?.copyWith(color: t.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      example,
                      style: text.bodySmall?.copyWith(color: t.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
