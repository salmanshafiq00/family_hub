import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:flutter/material.dart';

/// Icon + label + colour for one [Confidence], so the level is never conveyed
/// by colour alone (CLAUDE.md rule 13).
class ConfidenceChip extends StatelessWidget {
  const ConfidenceChip({
    required this.confidence,
    this.compact = false,
    super.key,
  });

  final Confidence confidence;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = confidenceLabel(context.l10n, confidence);
    final (foreground, background) = switch (confidence) {
      Confidence.high => (t.statusCompletedOn, t.statusCompletedContainer),
      Confidence.medium => (t.statusOverdueOn, t.statusOverdueContainer),
      Confidence.low => (t.textSecondary, t.surfaceSunken),
    };
    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 24),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(t.radiusPill),
          border: Border.all(color: foreground.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(_icon, size: compact ? 12 : 14, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (confidence) {
    Confidence.high => Icons.check_circle_outline_rounded,
    Confidence.medium => Icons.help_outline_rounded,
    Confidence.low => Icons.report_problem_outlined,
  };

  /// Localized label of [confidence].
  static String confidenceLabel(
    AppLocalizations l10n,
    Confidence confidence,
  ) => switch (confidence) {
    Confidence.high => l10n.starterPackConfidenceHigh,
    Confidence.medium => l10n.starterPackConfidenceMedium,
    Confidence.low => l10n.starterPackConfidenceLow,
  };
}
