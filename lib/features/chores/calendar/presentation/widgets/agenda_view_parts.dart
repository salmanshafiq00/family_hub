part of 'agenda_view.dart';

class _DayHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DayHeaderDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => child;

  @override
  bool shouldRebuild(_DayHeaderDelegate oldDelegate) =>
      oldDelegate.extent != extent || oldDelegate.child != child;
}

/// "Sunday, 25 October 2026 · Today · 3 chores". Tapping selects the day and
/// opens or closes its chores.
class _DayHeader extends ConsumerWidget {
  const _DayHeader({
    required this.day,
    required this.formatters,
    required this.selected,
    required this.expanded,
    required this.onToggle,
  });

  final AgendaDay day;
  final AppFormatters formatters;
  final bool selected;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final key = day.dateKey;
    final date = DateTime.utc(key.year, key.month, key.day);
    final text = StringBuffer(
      '${formatters.weekdayName(key.isoWeekday)}, ${formatters.fullDate(date)}',
    );
    if (day.isToday) text.write(' · ${l10n.calendarToday}');
    if (day.items.isNotEmpty) {
      text.write(
        ' · ${l10n.calendarCellChores(formatters.number(day.items.length))}',
      );
    }
    return Material(
      color: t.background,
      child: InkWell(
        key: ValueKey<String>('calendar_agenda_day_$key'),
        onTap: () {
          ref.read(calendarFocusProvider.notifier).selectDay(key);
          onToggle();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Semantics(
              header: true,
              selected: selected,
              button: day.items.isNotEmpty,
              expanded: day.items.isEmpty ? null : expanded,
              child: Row(
                children: [
                  if (selected)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: t.accentStrong,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      text.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: day.isToday ? t.accentStrong : t.textPrimary,
                        fontSize: 14,
                        fontWeight: day.isToday || selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (day.items.isNotEmpty)
                    ExcludeSemantics(
                      child: Icon(
                        expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: t.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverdueBlock extends StatelessWidget {
  const _OverdueBlock({required this.overdue, required this.formatters});

  final AgendaOverdue overdue;
  final AppFormatters formatters;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Container(
      key: const Key('calendar_agenda_overdue'),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: t.statusOverdueContainer,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Semantics(
              header: true,
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: t.statusOverdueOn,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.todaySectionOverdue} · '
                      '${formatters.number(overdue.total)}',
                      style: TextStyle(
                        color: t.statusOverdueOn,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final item in overdue.items)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: TodayRow(item: item),
            ),
        ],
      ),
    );
  }
}

class _FreeDaysChip extends StatelessWidget {
  const _FreeDaysChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Consumer(
      builder: (context, ref, _) {
        final formatters = ref.watch(appFormattersProvider);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Chip(
              key: const Key('calendar_free_days'),
              avatar: Icon(
                Icons.event_available_rounded,
                size: 18,
                color: t.textSecondary,
              ),
              label: Text(
                context.l10n.calendarFreeDays(formatters.number(count)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Center(
      child: TextButton(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        onPressed: onPressed,
        child: Text(label),
      ),
    ),
  );
}
