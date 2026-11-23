import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_describe.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_controller.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/next_dates_preview.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/recurrence_picker_sheet.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/recurrence_summary_text.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/slots_editor.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section 2 of the template editor: the repeat rule (with a sentence and the
/// next five dates), the start and end date, and the times of day (slots).
class EditorScheduleSection extends ConsumerWidget {
  const EditorScheduleSection({
    required this.draft,
    required this.controller,
    required this.enabled,
    this.showDates = true,
    super.key,
  });

  final TemplateDraft draft;
  final TemplateEditorController controller;
  final bool enabled;

  /// False in the starter-pack editor: a pack line has no start or end date
  /// (a pack is applied "from today").
  final bool showDates;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formatters = ref.watch(appFormattersProvider);
    final today = ref.watch(familyDateKeysProvider).today();
    final weekStart = ref.watch(choreSettingsProvider).weekStartDay;
    final label = Theme.of(context).textTheme.labelLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.choreEditorRepeat, style: label),
        const SizedBox(height: 4),
        RecurrenceSummaryText(
          key: const ValueKey<String>('recurrence_sentence'),
          summary: RecurrenceSummary.of(draft.recurrence),
          formatters: formatters,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          key: const ValueKey<String>('recurrence_change'),
          style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: enabled
              ? () async {
                  final picked = await showRecurrencePicker(
                    context,
                    initial: draft.recurrence,
                    startDate: draft.startDate,
                    weekStart: weekStart,
                    formatters: formatters,
                  );
                  if (picked != null) controller.setRecurrence(picked);
                }
              : null,
          icon: const Icon(Icons.repeat_rounded),
          label: Text(l10n.choreEditorRepeatChange),
        ),
        const SizedBox(height: 12),
        NextDatesPreview(
          recurrence: draft.recurrence,
          startDate: draft.startDate,
          endDate: draft.endDate,
          today: today,
          formatters: formatters,
        ),
        if (showDates) const SizedBox(height: 16),
        if (showDates)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const ValueKey<String>('start_date'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: enabled
                    ? () async {
                        final picked = await _pickDate(
                          context,
                          draft.startDate,
                          first: today.addDays(-366),
                        );
                        if (picked != null) controller.setStartDate(picked);
                      }
                    : null,
                icon: const Icon(Icons.event_available_outlined),
                label: Text(
                  l10n.choreEditorStartDate(_text(formatters, draft.startDate)),
                ),
              ),
              OutlinedButton.icon(
                key: const ValueKey<String>('end_date'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: enabled
                    ? () async {
                        final picked = await _pickDate(
                          context,
                          draft.endDate ?? draft.startDate,
                          first: draft.startDate,
                        );
                        if (picked != null) controller.setEndDate(picked);
                      }
                    : null,
                icon: const Icon(Icons.event_busy_outlined),
                label: Text(
                  draft.endDate == null
                      ? l10n.choreEditorEndDateNone
                      : l10n.choreEditorEndDate(
                          _text(formatters, draft.endDate!),
                        ),
                ),
              ),
              if (draft.endDate != null)
                TextButton(
                  key: const ValueKey<String>('end_date_clear'),
                  onPressed: enabled ? () => controller.setEndDate(null) : null,
                  child: Text(l10n.choreEditorEndDateClear),
                ),
            ],
          ),
        const SizedBox(height: 20),
        Text(l10n.choreEditorTimes, style: label),
        const SizedBox(height: 8),
        SlotsEditor(
          slots: draft.slots,
          enabled: enabled,
          onChanged: controller.setSlots,
        ),
      ],
    );
  }

  static String _text(AppFormatters f, DateKey k) =>
      f.fullDate(DateTime(k.year, k.month, k.day));

  static Future<DateKey?> _pickDate(
    BuildContext context,
    DateKey initial, {
    required DateKey first,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: DateTime(initial.year + 5, 12, 31),
    );
    if (picked == null) return null;
    return DateKey(picked.year, picked.month, picked.day);
  }
}
