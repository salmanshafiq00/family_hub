import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/confidence_chip.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Step 1: the pack cards (only one pack exists in Phase 3).
class StarterPackPickStep extends StatelessWidget {
  const StarterPackPickStep({
    required this.pack,
    required this.formatters,
    super.key,
  });

  final StarterPack pack;
  final AppFormatters formatters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final high = pack.templates
        .where((template) => template.confidence == Confidence.high)
        .length;
    final medium = pack.templates
        .where((template) => template.confidence == Confidence.medium)
        .length;
    final low = pack.templates
        .where((template) => template.confidence == Confidence.low)
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        Text(
          l10n.starterPackPickBody,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: 16),
        AppCard(
          raised: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: t.accentSoft,
                      borderRadius: BorderRadius.circular(t.radiusMd),
                    ),
                    child: Icon(
                      Icons.auto_awesome_outlined,
                      color: t.accentStrong,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.starterPackFamilyPdfTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.starterPackTemplateCount(
                            formatters.number(pack.templates.length),
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle_rounded, color: t.success),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.starterPackFamilyPdfDescription,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _CountChip(
                    confidence: Confidence.high,
                    label: l10n.starterPackCountHigh(
                      formatters.number(high),
                    ),
                  ),
                  _CountChip(
                    confidence: Confidence.medium,
                    label: l10n.starterPackCountMedium(
                      formatters.number(medium),
                    ),
                  ),
                  _CountChip(
                    confidence: Confidence.low,
                    label: l10n.starterPackCountLow(
                      formatters.number(low),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.starterPackPickHint,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.confidence, required this.label});

  final Confidence confidence;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      ConfidenceChip(confidence: confidence, compact: true),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
