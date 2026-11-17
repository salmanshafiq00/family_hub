import 'dart:async';

import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/calendar_filter_sheet.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/filter_button.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/member_scope_button.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/view_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Row 2 of the calendar header: the view switcher, the member chip (whose
/// chores) and the filter button with its count. Reads and writes the same
/// providers as the filter sheet, so the controls cannot disagree.
class CalendarToolbar extends ConsumerWidget {
  const CalendarToolbar({
    required this.view,
    required this.enabledViews,
    super.key,
  });

  final CalendarView view;
  final Set<CalendarView> enabledViews;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(calendarFiltersProvider);
    final formatters = ref.watch(appFormattersProvider);
    return Row(
      children: [
        // At large text the pill scales down instead of overflowing.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: ViewSwitcher(
              selected: view,
              enabled: enabledViews,
              onChanged: (next) => unawaited(
                ref.read(calendarPrefsProvider.notifier).setView(next),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        const MemberScopeButton(),
        const Spacer(),
        FilterButton(
          activeCount: filters.activeCount,
          formatters: formatters,
          onPressed: () => unawaited(showCalendarFilterSheet(context)),
        ),
      ],
    );
  }
}
