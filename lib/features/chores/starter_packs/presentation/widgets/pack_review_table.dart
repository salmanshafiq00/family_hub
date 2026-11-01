import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/confidence_chip.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/starter_template_details_sheet.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_describe.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/recurrence_summary_text.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// The confidence legend of the review step (P3-19).
///
/// High lines are pre-ticked; Medium and Low are offered unticked with a
/// "please confirm" flag (Appendix G Q1). The legend is a widget of its own so
/// the rule is visible even before any row is rendered.
class ConfidenceLegend extends StatelessWidget {
  const ConfidenceLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      key: const ValueKey('starter_confidence_legend'),
      container: true,
      label:
          '${l10n.starterPackConfidenceHigh}, '
          '${l10n.starterPackConfidenceMedium}, '
          '${l10n.starterPackConfidenceLow}',
      excludeSemantics: true,
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Text(
            l10n.starterPackConfidenceLegend,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.tokens.textSecondary,
            ),
          ),
          const ConfidenceChip(confidence: Confidence.high),
          const ConfidenceChip(confidence: Confidence.medium),
          const ConfidenceChip(confidence: Confidence.low),
        ],
      ),
    );
  }
}

/// One tickable line of the review step, with its confidence badge.
class PackReviewTable extends StatelessWidget {
  const PackReviewTable({
    required this.templates,
    required this.selected,
    required this.onToggle,
    required this.formatters,
    super.key,
  });

  final List<StarterTemplate> templates;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final AppFormatters formatters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final template in templates) ...<Widget>[
          AppCard(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            onTap: () => onToggle(template.seedKey),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Checkbox(
                    key: ValueKey<String>('starter_template_${template.seedKey}'),
                    value: selected.contains(template.seedKey),
                    onChanged: (_) => onToggle(template.seedKey),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _name(context, template),
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: context.tokens.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          ConfidenceChip(
                            confidence: template.confidence,
                            compact: true,
                          ),
                          if (template.confidence != Confidence.high)
                            Text(
                              l10n.starterPackPleaseConfirm,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.tokens.warning),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        RecurrenceSummaryText.text(
                          l10n,
                          formatters,
                          RecurrenceSummary.of(template.recurrence),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey<String>('starter_details_${template.seedKey}'),
                  tooltip: l10n.starterPackDetailsTitle,
                  onPressed: () => showStarterTemplateDetails(
                    context,
                    template: template,
                    formatters: formatters,
                  ),
                  icon: const Icon(Icons.info_outline_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// The family's language, falling back to Bangla (the default language).
  static String _name(BuildContext context, StarterTemplate template) =>
      Localizations.localeOf(context).languageCode == 'bn'
      ? template.nameBn
      : (template.nameEn ?? template.nameBn);
}
