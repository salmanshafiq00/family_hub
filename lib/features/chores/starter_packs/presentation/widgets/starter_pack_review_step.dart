import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/pack_review_table.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Step 2: every pack line with its confidence, plus the house rules (P3-19).
class StarterPackReviewStep extends StatelessWidget {
  const StarterPackReviewStep({
    required this.templates,
    required this.selected,
    required this.onToggle,
    required this.houseRules,
    required this.addHouseRules,
    required this.onAddHouseRules,
    required this.onHouseRulesChanged,
    required this.formatters,
    super.key,
  });

  final List<StarterTemplate> templates;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  final String houseRules;
  final bool addHouseRules;
  final ValueChanged<bool> onAddHouseRules;
  final ValueChanged<String> onHouseRulesChanged;

  final AppFormatters formatters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        Text(
          l10n.starterPackReviewBody,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: 12),
        const ConfidenceLegend(),
        const SizedBox(height: 12),
        PackReviewTable(
          templates: templates,
          selected: selected,
          onToggle: onToggle,
          formatters: formatters,
        ),
        if (houseRules.trim().isNotEmpty) ...<Widget>[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.starterPackHouseRulesTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.starterPackHouseRulesHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                ),
                SwitchListTile(
                  key: const ValueKey<String>('starter_add_house_rules'),
                  contentPadding: EdgeInsets.zero,
                  value: addHouseRules,
                  onChanged: onAddHouseRules,
                  title: Text(l10n.starterPackHouseRulesSwitch),
                ),
                TextFormField(
                  key: const ValueKey<String>('starter_house_rules'),
                  initialValue: houseRules,
                  enabled: addHouseRules,
                  minLines: 3,
                  maxLines: 6,
                  onChanged: onHouseRulesChanged,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
