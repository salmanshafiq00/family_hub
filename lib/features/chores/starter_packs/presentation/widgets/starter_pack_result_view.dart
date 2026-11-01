import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack_outcome.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:family_hub/shared/widgets/busy_button.dart';
import 'package:flutter/material.dart';

/// Step 4: what the apply created, then "Open Today" (P3-19).
///
/// The content writes are never rolled back when planning fails, so a failed
/// generation is reported beside the result instead of pretending that the
/// whole application failed (the next apply resumes from the same ids).
class StarterPackResultView extends StatelessWidget {
  const StarterPackResultView({
    required this.outcome,
    required this.formatters,
    required this.onOpenToday,
    this.onOpenTemplates,
    super.key,
  });

  final StarterPackOutcome outcome;
  final AppFormatters formatters;
  final VoidCallback onOpenToday;
  final VoidCallback? onOpenTemplates;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final generated = outcome.generation?.created ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        AppCard(
          raised: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.check_circle_rounded, color: t.success, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.starterPackResultTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (outcome.templatesCreated > 0)
                _Line(
                  icon: Icons.assignment_turned_in_outlined,
                  text: l10n.starterPackResultTemplates(
                    formatters.number(outcome.templatesCreated),
                  ),
                ),
              if (outcome.templatesSkipped > 0)
                _Line(
                  icon: Icons.skip_next_outlined,
                  text: l10n.starterPackResultSkipped(
                    formatters.number(outcome.templatesSkipped),
                  ),
                ),
              if (outcome.catalogGroupsAdded > 0)
                _Line(
                  icon: Icons.category_outlined,
                  text: l10n.starterPackResultGroups(
                    formatters.number(outcome.catalogGroupsAdded),
                  ),
                ),
              if (outcome.catalogPresetsAdded > 0)
                _Line(
                  icon: Icons.schedule_outlined,
                  text: l10n.starterPackResultPresets(
                    formatters.number(outcome.catalogPresetsAdded),
                  ),
                ),
              if (outcome.dutyGroupsCreated > 0)
                _Line(
                  icon: Icons.groups_outlined,
                  text: l10n.starterPackResultDutyGroups(
                    formatters.number(outcome.dutyGroupsCreated),
                  ),
                ),
              if (outcome.houseRulesAdded)
                _Line(
                  icon: Icons.menu_book_outlined,
                  text: l10n.starterPackResultRules,
                ),
              if (outcome.generationFailure == null && generated > 0)
                _Line(
                  icon: Icons.today_outlined,
                  text: l10n.starterPackResultGenerated(
                    formatters.number(generated),
                  ),
                ),
            ],
          ),
        ),
        if (outcome.generationFailure case final failure?) ...<Widget>[
          const SizedBox(height: 12),
          AppCard(
            color: t.statusOverdueContainer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.warning_amber_rounded, color: t.statusOverdueOn),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.starterPackResultGenerationFailed,
                        style: TextStyle(color: t.statusOverdueOn),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.choresFailureMessage(failure),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: t.statusOverdueOn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        BusyButton(
          key: const ValueKey<String>('starter_open_today'),
          label: l10n.starterPackOpenToday,
          onPressed: onOpenToday,
        ),
        if (onOpenTemplates != null) ...<Widget>[
          const SizedBox(height: 8),
          TextButton(
            key: const ValueKey<String>('starter_open_templates'),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: onOpenTemplates,
            child: Text(l10n.choreTemplatesTitle),
          ),
        ],
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: t.accentStrong),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
