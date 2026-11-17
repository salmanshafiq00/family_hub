import 'package:family_hub/app/gallery/gallery_sections.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/domain/member_load.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/calendar/presentation/widgets/day_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Calendar date states used by the month and week grids.
GallerySection calendarPolishSection = GallerySection(
  id: 'calendar_polish',
  label: (l10n) => l10n.galleryCalendarPolish,
  build: (context) {
    final f = AppFormatters(
      languageCode: Localizations.localeOf(context).languageCode,
      useBanglaDigits: Localizations.localeOf(context).languageCode == 'bn',
    );
    // One cell per state: none, scheduled (with my chore and two others),
    // in progress, all done, overdue, skipped, today.
    final cells = <DaySummary>[
      DaySummary(dateKey: DateKey(2026, 10, 1)),
      DaySummary(
        dateKey: DateKey(2026, 10, 2),
        total: 3,
        counts: const <ChoreStatus, int>{ChoreStatus.scheduled: 3},
        mineCount: 1,
        byMember: const <MemberLoad>[
          MemberLoad(memberId: 'me', count: 1),
          MemberLoad(memberId: 'amy', count: 1),
          MemberLoad(memberId: 'bob', count: 1),
        ],
      ),
      DaySummary(
        dateKey: DateKey(2026, 10, 3),
        total: 2,
        counts: const <ChoreStatus, int>{
          ChoreStatus.completed: 1,
          ChoreStatus.scheduled: 1,
        },
      ),
      DaySummary(
        dateKey: DateKey(2026, 10, 4),
        isPast: true,
        total: 2,
        counts: const <ChoreStatus, int>{ChoreStatus.completed: 2},
      ),
      DaySummary(
        dateKey: DateKey(2026, 10, 5),
        isPast: true,
        total: 2,
        counts: const <ChoreStatus, int>{ChoreStatus.overdue: 1},
      ),
      DaySummary(
        dateKey: DateKey(2026, 10, 6),
        isPast: true,
        total: 1,
        counts: const <ChoreStatus, int>{ChoreStatus.skipped: 1},
      ),
      DaySummary(dateKey: DateKey(2026, 10, 7), isToday: true),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // P4-23: a `cell` is only legal under a `row`, and a `row` only under a
        // `table` - the same nesting `MonthBody` builds, or the demo trips the
        // semantics assertion instead of showing what a screen reader gets.
        Semantics(
          role: SemanticsRole.table,
          container: true,
          label: context.l10n.calendarGridLabel,
          child: Semantics(
            role: SemanticsRole.row,
            container: true,
            child: Row(
              children: [
                for (final summary in cells)
                  Expanded(
                    child: DayCell(
                      summary: summary,
                      selected: summary.dateKey.day == 3,
                      viewerId: 'me',
                      formatters: f,
                      minHeight: 64,
                      onTap: () {},
                      onLongPress: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  },
);
