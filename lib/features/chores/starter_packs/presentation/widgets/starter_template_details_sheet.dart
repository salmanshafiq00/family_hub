import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/confidence_chip.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_describe.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/recurrence_summary_text.dart';
import 'package:flutter/material.dart';

/// Opens the read-only details of one pack line.
///
/// The roadmap asks for "each line can be opened in the template editor before
/// applying". This sheet shows the same draft the wizard would create (schedule,
/// times, steps) without writing anything; the full editor is reachable after
/// applying from the templates list. Documented as a P3-19 deviation.
Future<void> showStarterTemplateDetails(
  BuildContext context, {
  required StarterTemplate template,
  required AppFormatters formatters,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) =>
      StarterTemplateDetailsSheet(template: template, formatters: formatters),
);

/// The body of [showStarterTemplateDetails].
class StarterTemplateDetailsSheet extends StatelessWidget {
  const StarterTemplateDetailsSheet({
    required this.template,
    required this.formatters,
    super.key,
  });

  final StarterTemplate template;
  final AppFormatters formatters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final bn = Localizations.localeOf(context).languageCode == 'bn';
    final name = bn ? template.nameBn : (template.nameEn ?? template.nameBn);
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: t.textSecondary,
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: t.textPrimary),
            ),
            const SizedBox(height: 8),
            ConfidenceChip(confidence: template.confidence),
            const SizedBox(height: 16),
            Text(l10n.choreEditorTimes, style: _labelStyle(context)),
            const SizedBox(height: 4),
            Text(_slotSummary(context, bn), style: bodyStyle),
            const SizedBox(height: 12),
            Text(l10n.starterPackDetailsSchedule, style: _labelStyle(context)),
            const SizedBox(height: 4),
            Text(
              RecurrenceSummaryText.text(
                l10n,
                formatters,
                RecurrenceSummary.of(template.recurrence),
              ),
              style: bodyStyle,
            ),
            if (template.instructions.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(l10n.starterPackDetailsNotes, style: _labelStyle(context)),
              const SizedBox(height: 4),
              Text(template.instructions, style: bodyStyle),
            ],
            if (template.subtasks.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(l10n.starterPackDetailsSteps, style: _labelStyle(context)),
              for (final subtask in template.subtasks)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        Icons.check_box_outline_blank_rounded,
                        size: 18,
                        color: t.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(subtask.title, style: bodyStyle)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle? _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(
        color: context.tokens.textPrimary,
        fontWeight: FontWeight.w700,
      );

  String _slotSummary(BuildContext context, bool bn) {
    final parts = <String>[
      for (final slot in template.slots) _slotLabel(context, slot, bn),
    ];
    return parts.join(' · ');
  }

  String _slotLabel(BuildContext context, TemplateSlot slot, bool bn) {
    final label = bn ? slot.labelBn : (slot.labelEn ?? slot.labelBn);
    if (label != null && label.trim().isNotEmpty) return label;
    final minutes = slot.dueMinutes;
    return minutes == null
        ? context.l10n.starterPackEndOfDay
        : formatters.timeOfDay(minutes);
  }
}
