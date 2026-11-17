import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';

/// The ONE sentence a screen reader hears for a day cell (B.7):
/// "25 October, Sunday, today, 3 chores, 1 overdue, 1 yours, needs cover,
/// selected". Empty parts are left out; a day outside the month is only its date.
String dayCellLabel({
  required AppLocalizations l10n,
  required AppFormatters formatters,
  required DaySummary summary,
  required bool selected,
  required Map<String, CalendarMemberStyle> memberStyles,
}) {
  final day = summary.dateKey;
  final parts = <String>[
    '${formatters.number(day.day)} ${formatters.monthName(day.month)}',
    formatters.weekdayName(day.isoWeekday),
    if (summary.isToday) l10n.calendarToday,
  ];
  if (!summary.isOutsideMonth) {
    if (summary.isPast) {
      parts.add(l10n.calendarCellPast);
    } else if (summary.total > 0) {
      parts.add(l10n.calendarCellScheduled);
    }
    final names = <String>[
      for (final load in summary.byMember)
        if (load.memberId != null)
          memberStyles[load.memberId]?.name ?? l10n.calendarUnknownMember,
    ];
    if (names.isNotEmpty) {
      parts.add(l10n.calendarCellMembers(names.join(', ')));
    }
    final done =
        summary.countOf(ChoreStatus.completed) +
        summary.countOf(ChoreStatus.verified);
    if (summary.total > 0) {
      parts.add(l10n.calendarCellChores(formatters.number(summary.total)));
      parts.add(
        l10n.calendarCellProgress(
          formatters.number(done),
          formatters.number(summary.total),
        ),
      );
      final nonSkipped = summary.total - summary.countOf(ChoreStatus.skipped);
      if (nonSkipped > 0 && done == nonSkipped) {
        parts.add(l10n.calendarCellCompleted);
      }
    }
    final overdue = summary.countOf(ChoreStatus.overdue);
    if (overdue > 0) {
      parts.add(l10n.calendarCellOverdue(formatters.number(overdue)));
    }
    if (summary.mineCount > 0) {
      parts.add(l10n.calendarCellMine(formatters.number(summary.mineCount)));
    }
    // Keep planned and away states available to assistive technology even
    // though the compact cell no longer draws their previous hatch marks.
    if (summary.hasProjectedOnly) parts.add(l10n.calendarCellPlanned);
    if (summary.unavailableMemberIds.isNotEmpty) {
      parts.add(l10n.calendarCellAway);
    }
    if (summary.hasNeedsCover) parts.add(l10n.calendarCellNeedsCover);
    if (summary.hasNeedsAttention) parts.add(l10n.calendarCellNeedsAttention);
  }
  if (selected) parts.add(l10n.calendarCellSelected);
  return parts.join(', ');
}
