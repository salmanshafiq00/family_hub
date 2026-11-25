part of 'agenda_view.dart';

extension _AgendaViewStateList on _AgendaViewState {
  Widget _list(
    BuildContext context,
    AgendaModel model, {
    required bool filtering,
    required AgendaWindow window,
  }) {
    final l10n = context.l10n;
    final formatters = ref.watch(appFormattersProvider);
    final today = ref.watch(todayKeyProvider);
    final selected = ref.watch(selectedDayProvider);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final headerExtent = 48 * scale.clamp(1.0, 2.0);

    final hasDayItems = model.entries.any(
      (entry) => entry is AgendaDay && entry.items.isNotEmpty,
    );
    if (filtering && !hasDayItems && model.overdue == null) {
      return EmptyState(
        key: const Key('calendar_agenda_no_match'),
        icon: Icons.filter_alt_off_outlined,
        title: l10n.calendarAgendaNoMatch,
        actionLabel: l10n.calendarClearFilters,
        onAction: () {
          ref.read(calendarQueryProvider.notifier).clear();
          unawaited(ref.read(calendarPrefsProvider.notifier).clearFilters());
        },
      );
    }

    final past = <AgendaEntry>[];
    final future = <AgendaEntry>[];
    for (final entry in model.entries) {
      switch (entry) {
        case AgendaOverdue():
          break;
        case AgendaDay(:final dateKey):
          (dateKey.isBefore(today) ? past : future).add(entry);
        case AgendaFreeDays(:final to):
          (to.isBefore(today) ? past : future).add(entry);
      }
    }

    // The reversed sliver lays its first child NEAREST the centre, so the past
    // is built newest-first and its last child ("earlier weeks") is the top.
    final reversedRows = <Widget>[
      for (final entry in past.reversed)
        ..._rowsOf(
          entry,
          formatters,
          selected,
          today,
          filtering: filtering,
        ).reversed,
      if (window.canGoEarlier)
        _MoreButton(
          key: const Key('calendar_load_earlier'),
          label: l10n.calendarLoadEarlier,
          onPressed: () => _setWindow(window.earlier()),
        ),
    ];

    final overdue = model.overdue;
    return CustomScrollView(
      key: const PageStorageKey<String>('calendar_agenda'),
      controller: _scroll,
      center: _centerKey,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => reversedRows[index],
            childCount: reversedRows.length,
          ),
        ),
        SliverToBoxAdapter(
          key: _centerKey,
          child: overdue == null
              ? const SizedBox.shrink()
              : _OverdueBlock(overdue: overdue, formatters: formatters),
        ),
        for (final entry in future)
          switch (entry) {
            final AgendaDay day => SliverMainAxisGroup(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DayHeaderDelegate(
                    extent: headerExtent,
                    child: _headerOf(
                      day,
                      formatters,
                      selected,
                      today,
                      filtering: filtering,
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: TodayRow(item: day.items[index]),
                    ),
                    childCount:
                        _isOpen(day.dateKey, today, filtering: filtering)
                        ? day.items.length
                        : 0,
                  ),
                ),
              ],
            ),
            final AgendaFreeDays free => SliverToBoxAdapter(
              child: _FreeDaysChip(count: free.count),
            ),
            AgendaOverdue() => const SliverToBoxAdapter(),
          },
        SliverToBoxAdapter(
          child: window.canGoLater
              ? _MoreButton(
                  key: const Key('calendar_load_later'),
                  label: l10n.calendarLoadLater,
                  onPressed: () => _setWindow(window.later()),
                )
              : const SizedBox(height: 24),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: kCalendarBottomClearance),
        ),
      ],
    );
  }

  _DayHeader _headerOf(
    AgendaDay day,
    AppFormatters formatters,
    DateKey selected,
    DateKey today, {
    required bool filtering,
  }) => _DayHeader(
    day: day,
    formatters: formatters,
    selected: day.dateKey == selected,
    expanded: _isOpen(day.dateKey, today, filtering: filtering),
    onToggle: () => _toggleDay(day.dateKey),
    showToggle: !filtering,
  );

  /// The rows of one past entry in reading order (header first).
  List<Widget> _rowsOf(
    AgendaEntry entry,
    AppFormatters formatters,
    DateKey selected,
    DateKey today, {
    required bool filtering,
  }) => switch (entry) {
    final AgendaDay day => <Widget>[
      _headerOf(day, formatters, selected, today, filtering: filtering),
      if (_isOpen(day.dateKey, today, filtering: filtering))
        for (final item in day.items)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: TodayRow(item: item),
          ),
    ],
    final AgendaFreeDays free => <Widget>[_FreeDaysChip(count: free.count)],
    AgendaOverdue() => const <Widget>[],
  };
}
