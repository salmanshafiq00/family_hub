import 'dart:async';

import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart'
    show statusLabelOf;
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The filter sheet (P3-23): groups, statuses, people, "needs attention" and
/// a search. It writes `calendarPrefsProvider` (stored filters) and
/// `calendarQueryProvider` (session search), the state ALL three views share.
Future<void> showCalendarFilterSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const CalendarFilterSheet(),
    );

class CalendarFilterSheet extends ConsumerStatefulWidget {
  const CalendarFilterSheet({super.key});

  @override
  ConsumerState<CalendarFilterSheet> createState() =>
      _CalendarFilterSheetState();
}

class _CalendarFilterSheetState extends ConsumerState<CalendarFilterSheet> {
  late final TextEditingController _search = TextEditingController(
    text: ref.read(calendarQueryProvider),
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _write(CalendarFilters next) =>
      unawaited(ref.read(calendarPrefsProvider.notifier).setFilters(next));

  Set<T> _toggled<T>(Set<T> set, T value, {required bool on}) =>
      on ? <T>{...set, value} : (<T>{...set}..remove(value));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bn = l10n.localeName.startsWith('bn');
    final filters = ref.watch(calendarFiltersProvider);
    final followsFamily = ref.watch(calendarUsesFamilyDefaultsProvider);
    final groups = ref
        .watch(choreGroupsProvider)
        .where((group) => group.active)
        .toList();
    final members = ref.watch(membersProvider).value ?? const [];
    final style = Theme.of(context).textTheme.labelLarge;
    final formatters = ref.watch(appFormattersProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('calendar_search_field'),
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: l10n.calendarSearchHint,
              ),
              onChanged: (value) =>
                  ref.read(calendarQueryProvider.notifier).change(value),
            ),
            const SizedBox(height: 16),
            if (groups.isNotEmpty) ...[
              Text(l10n.calendarFilterGroups, style: style),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in groups)
                    FilterChip(
                      key: Key('calendar_filter_group_${group.id}'),
                      label: Text(
                        bn ? group.nameBn : (group.nameEn ?? group.nameBn),
                      ),
                      selected: filters.groupIds.contains(group.id),
                      onSelected: (on) => _write(
                        filters.copyWith(
                          groupIds: _toggled(
                            filters.groupIds,
                            group.id,
                            on: on,
                          ),
                          query: '',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Text(l10n.calendarFilterStatuses, style: style),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final status in ChoreStatus.values)
                  FilterChip(
                    key: Key('calendar_filter_status_${status.id}'),
                    label: Text(statusLabelOf(status, l10n)),
                    selected: filters.statuses.contains(status),
                    onSelected: (on) => _write(
                      filters.copyWith(
                        statuses: _toggled(filters.statuses, status, on: on),
                        query: '',
                      ),
                    ),
                  ),
              ],
            ),
            if (members.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l10n.calendarFilterMembers, style: style),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final member in members)
                    FilterChip(
                      key: Key('calendar_filter_member_${member.uid}'),
                      label: Text(member.displayName),
                      selected: filters.memberIds.contains(member.uid),
                      // The member chip writes the same state: picking someone
                      // here also leaves "my chores" (see selectMembers).
                      onSelected: (on) => unawaited(
                        ref
                            .read(calendarPrefsProvider.notifier)
                            .selectMembers(
                              memberIds: _toggled(
                                filters.memberIds,
                                member.uid,
                                on: on,
                              ),
                            ),
                      ),
                    ),
                ],
              ),
            ],
            SwitchListTile(
              key: const Key('calendar_filter_attention'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.calendarFilterNeedsAttention),
              value: filters.onlyNeedsAttention,
              onChanged: (on) =>
                  _write(filters.copyWith(onlyNeedsAttention: on, query: '')),
            ),
            if (!followsFamily)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  key: const Key('calendar_use_family_defaults'),
                  onPressed: () => unawaited(
                    ref
                        .read(calendarPrefsProvider.notifier)
                        .useFamilyDefaults(),
                  ),
                  child: Text(l10n.calendarUseFamilyDefaults),
                ),
              ),
            if (filters.activeCount > 0)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton.tonal(
                  key: const Key('calendar_clear_filters'),
                  onPressed: () {
                    _search.clear();
                    ref.read(calendarQueryProvider.notifier).clear();
                    unawaited(
                      ref.read(calendarPrefsProvider.notifier).clearFilters(),
                    );
                  },
                  child: Text(
                    '${l10n.calendarClearFilters} '
                    '(${formatters.number(filters.activeCount)})',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
