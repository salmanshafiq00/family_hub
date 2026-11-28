import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Reminders section of the chore settings page: default reminder offsets,
/// overdue alerts, morning summary, and link to family-level quiet hours.
class RemindersSection extends ConsumerStatefulWidget {
  const RemindersSection({
    required this.defaults,
    required this.onChanged,
    super.key,
  });

  static const List<int> quickOffsets = <int>[5, 10, 20, 30, 60];

  final NotificationDefaults defaults;
  final ValueChanged<NotificationDefaults> onChanged;

  @override
  ConsumerState<RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends ConsumerState<RemindersSection> {
  final _customOffset = TextEditingController();
  bool _invalidOffset = false;

  @override
  void dispose() {
    _customOffset.dispose();
    super.dispose();
  }

  void _addCustomOffset() {
    final value = int.tryParse(_customOffset.text.trim());
    final offsets = widget.defaults.defaultOffsetsMinutes;
    if (value == null ||
        value < 1 ||
        value > 1440 ||
        offsets.contains(value) ||
        offsets.length >= 5) {
      setState(() => _invalidOffset = true);
      return;
    }
    final next = [...offsets, value]..sort();
    widget.onChanged(widget.defaults.copyWith(defaultOffsetsMinutes: next));
    setState(() => _invalidOffset = false);
    _customOffset.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final d = widget.defaults;
    final offsets = d.defaultOffsetsMinutes;
    final customOffsets = offsets.where(
      (offset) => !RemindersSection.quickOffsets.contains(offset),
    );

    final summaryTime = TimeOfDay(
      hour: d.morningSummaryMinutes ~/ 60,
      minute: d.morningSummaryMinutes % 60,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const ValueKey<String>('reminders_chores_enabled'),
          contentPadding: EdgeInsets.zero,
          value: d.chores,
          title: Text(l10n.choresSettingsRemindersEnabled),
          subtitle: Text(l10n.choresSettingsRemindersEnabledSubtitle),
          onChanged: (v) => widget.onChanged(d.copyWith(chores: v)),
        ),
        if (d.chores) ...[
          const SizedBox(height: 12),
          Text(
            l10n.notificationDefaultOffsets,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final offset in [
                ...RemindersSection.quickOffsets,
                ...customOffsets,
              ])
                FilterChip(
                  key: ValueKey<String>('reminder_offset_$offset'),
                  label: Text(
                    l10n.choreReminderBefore(formatters.number(offset)),
                  ),
                  selected: offsets.contains(offset),
                  onSelected: offsets.length >= 5 && !offsets.contains(offset)
                      ? null
                      : (selected) {
                          final next = [...offsets];
                          if (selected) {
                            next.add(offset);
                          } else {
                            next.remove(offset);
                          }
                          next.sort();
                          widget.onChanged(
                            d.copyWith(defaultOffsetsMinutes: next),
                          );
                        },
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey<String>('reminder_custom_offset_field'),
                  controller: _customOffset,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.notificationCustomOffset,
                    errorText: _invalidOffset
                        ? l10n.notificationInvalidOffset
                        : null,
                  ),
                  onSubmitted: (_) => _addCustomOffset(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                key: const ValueKey<String>('reminder_add_offset_button'),
                tooltip: l10n.notificationAddOffset,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: offsets.length >= 5 ? null : _addCustomOffset,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            key: const ValueKey<String>('reminders_overdue_enabled'),
            contentPadding: EdgeInsets.zero,
            value: d.overdueEnabled,
            title: Text(l10n.notificationOverdue),
            onChanged: (v) => widget.onChanged(d.copyWith(overdueEnabled: v)),
          ),
          SwitchListTile(
            key: const ValueKey<String>('reminders_morning_summary_enabled'),
            contentPadding: EdgeInsets.zero,
            value: d.morningSummaryEnabled,
            title: Text(l10n.notificationMorningSummary),
            onChanged: (v) =>
                widget.onChanged(d.copyWith(morningSummaryEnabled: v)),
          ),
          if (d.morningSummaryEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: OutlinedButton.icon(
                key: const ValueKey<String>('reminders_morning_time_button'),
                icon: const Icon(Icons.access_time),
                label: Text(
                  l10n.notificationSummaryTime(summaryTime.format(context)),
                ),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: summaryTime,
                  );
                  if (picked != null) {
                    widget.onChanged(
                      d.copyWith(
                        morningSummaryMinutes: picked.hour * 60 + picked.minute,
                      ),
                    );
                  }
                },
              ),
            ),
        ],
        const SizedBox(height: 16),
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.surfaceSunken,
            borderRadius: BorderRadius.circular(t.radiusMd),
            border: Border.all(color: t.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: t.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.choresSettingsRemindersQuietHint,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: t.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      TextButton(
                        key: const ValueKey<String>(
                          'reminders_open_family_settings',
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(48, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () =>
                            context.push(AppRoutes.notificationSettings),
                        child: Text(l10n.choresSettingsRemindersOpenFamily),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
