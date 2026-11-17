import 'dart:async';

import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/week_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Seven columns on a tablet: a header per day and its chores as compact tiles.
class WeekColumns extends ConsumerWidget {
  const WeekColumns({required this.week, super.key});

  final WeekModel week;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final selected = ref.watch(selectedDayProvider);
    final controller = ref.read(calendarFocusProvider.notifier);
    return SingleChildScrollView(
      key: const PageStorageKey<String>('calendar_week_columns'),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, kCalendarBottomClearance),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final d in week.days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ColumnHeader(
                      day: d,
                      formatters: formatters,
                      selected: d.dateKey == selected,
                      onTap: () => controller.selectDay(d.dateKey),
                    ),
                    for (final item in d.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: ChoreTile(
                          item: item,
                          formatters: formatters,
                          dense: true,
                          onTap: () => unawaited(
                            context.push(AppRoutes.choresOccurrence(item.id)),
                          ),
                        ),
                      ),
                    if (d.items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '—',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: t.textDisabled),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader({
    required this.day,
    required this.formatters,
    required this.selected,
    required this.onTap,
  });

  final WeekDay day;
  final AppFormatters formatters;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final key = day.dateKey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? t.accent : t.surfaceSunken,
        borderRadius: BorderRadius.circular(t.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(t.radiusMd),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              child: Text(
                '${formatters.weekdayShort(key.isoWeekday)} '
                '${formatters.number(key.day)}',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? t.textOnAccent
                      : day.summary.isToday
                      ? t.accentStrong
                      : t.textPrimary,
                  fontWeight: day.summary.isToday || selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
