import 'dart:async';

import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/date_ranges.dart';
import 'package:family_hub/features/chores/calendar/domain/week_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart';
import 'package:family_hub/features/chores/presentation/widgets/day_part_section.dart';
import 'package:family_hub/features/chores/presentation/widgets/today_row.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// From this width the week is seven columns (B.6).
const double kWeekColumnsMinWidth = 840;

/// The week of the selected day (P3-23).
///
/// Phone: a strip of seven day cells (counts as markers) and the selected
/// day's chores below, by day part. Tablet (>= 840 dp): seven columns, one per
/// day. Both read ONE `WeekModel`, so they never disagree with the month grid.
class WeekView extends ConsumerWidget {
  const WeekView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(selectedDayProvider);
    final weekStart = ref.watch(choreSettingsProvider).weekStartDay;
    // Keyed on the first day of the week, so moving inside the week reuses it.
    final anchor = startOfWeek(selected, weekStart);
    final model = ref.watch(weekModelProvider(anchor));

    if (model.hasValue) {
      return LayoutBuilder(
        builder: (context, box) => box.maxWidth >= kWeekColumnsMinWidth
            ? _WeekColumns(week: model.requireValue)
            : _WeekStrip(week: model.requireValue, selected: selected),
      );
    }
    if (model.hasError) {
      final error = model.error;
      return ErrorView(
        message: l10n.choresFailureMessage(
          error is AppFailure ? error : Unknown(error),
        ),
        onRetry: () =>
            ref.invalidate(monthOccurrencesProvider(selected.monthKey)),
      );
    }
    return const LoadingView();
  }
}

class _WeekStrip extends ConsumerWidget {
  const _WeekStrip({required this.week, required this.selected});

  final WeekModel week;
  final DateKey selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final scope = ref.watch(calendarScopeProvider);
    final style = ref.watch(calendarMarkerStyleProvider);
    final controller = ref.read(calendarFocusProvider.notifier);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final cellHeight = 56 * scale.clamp(1.0, 2.0);
    final day = week.days.firstWhere(
      (d) => d.dateKey == selected,
      orElse: () => week.days.first,
    );
    final date = DateTime.utc(
      day.dateKey.year,
      day.dateKey.month,
      day.dateKey.day,
    );

    return SingleChildScrollView(
      key: const PageStorageKey<String>('calendar_week'),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // P4-23: [DayCell] claims the semantics `cell` role and Flutter only
          // accepts cell -> row -> table, so the strip is a one-row table.
          // Without it TalkBack gets a cell with no table to navigate and the
          // debug assertion fires.
          Semantics(
            role: SemanticsRole.table,
            container: true,
            label: l10n.calendarGridLabel,
            child: Semantics(
              role: SemanticsRole.row,
              container: true,
              child: Row(
                children: [
                  for (final d in week.days)
                    Expanded(
                      child: DayCell(
                        summary: d.summary,
                        selected: d.dateKey == selected,
                        scope: scope,
                        markerStyle: style,
                        formatters: formatters,
                        minHeight: cellHeight,
                        onTap: () => controller.selectDay(d.dateKey),
                        onLongPress: () => controller.selectDay(d.dateKey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                l10n.calendarDayHeader(
                  '${formatters.fullDate(date)}, '
                  '${formatters.weekdayName(day.dateKey.isoWeekday)}',
                  formatters.number(day.items.length),
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (day.items.isEmpty)
            EmptyState(
              icon: Icons.event_available_rounded,
              title: l10n.calendarDayEmptyTitle,
              message: l10n.calendarDayEmptyMessage,
            )
          else
            for (final (part, group) in day.parts) ...[
              DayPartSection(part: part, count: group.length),
              for (final item in group) TodayRow(item: item),
            ],
        ],
      ),
    );
  }
}

/// Seven columns on a tablet: a header per day and its chores as compact tiles.
class _WeekColumns extends ConsumerWidget {
  const _WeekColumns({required this.week});

  final WeekModel week;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final selected = ref.watch(selectedDayProvider);
    final controller = ref.read(calendarFocusProvider.notifier);
    return SingleChildScrollView(
      key: const PageStorageKey<String>('calendar_week_columns'),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
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
