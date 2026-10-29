import 'dart:async';

import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';

import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_action_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart';
import 'package:family_hub/features/chores/presentation/widgets/day_part_section.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/choice_wrap.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:family_hub/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What to do with today's chores (P3-15).
///
/// Sections: Overdue (pinned), the day parts of the pending work, then "done
/// today" (collapsed). The "Mine / Whole family" toggle filters the SAME list,
/// so switching it never reads Firestore again (D-P3-8). Swiping right
/// completes with a 5 s undo; swiping left opens the details.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

enum _Scope { mine, family }

class _TodayScreenState extends ConsumerState<TodayScreen> {
  _Scope _scope = _Scope.mine;
  bool _doneExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final today = ref.watch(familyDateKeysProvider).today();
    final month = ref.watch(monthOccurrencesProvider(today.monthKey));
    final all = ref.watch(todayItemsProvider);
    final uid = ref.watch(currentUidProvider);
    final scoped = _scope == _Scope.mine ? mineOnly(all, uid) : all;
    final progress = ref.watch(todayProgressProvider);
    final pending = <ChoreItem>[
      for (final item in scoped)
        if (item.status != ChoreStatus.completed &&
            item.status != ChoreStatus.verified)
          item,
    ];
    final done = <ChoreItem>[
      for (final item in scoped)
        if (item.status == ChoreStatus.completed ||
            item.status == ChoreStatus.verified)
          item,
    ];
    final overdue = <ChoreItem>[
      for (final item in pending)
        if (item.status == ChoreStatus.overdue) item,
    ];
    final upcoming = <ChoreItem>[
      for (final item in pending)
        if (item.status != ChoreStatus.overdue) item,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todayTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.todayProgress(
                      formatters.number(progress.done),
                      formatters.number(progress.total),
                    ),
                    style: TextStyle(color: t.textSecondary),
                  ),
                ),
                ChoiceWrap<_Scope>(
                  selected: _scope,
                  onChanged: (scope) => setState(() => _scope = scope),
                  options: <ChoiceOption<_Scope>>[
                    ChoiceOption(_Scope.mine, l10n.todayScopeMine),
                    ChoiceOption(_Scope.family, l10n.todayScopeFamily),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: month.isLoading
          ? const LoadingView()
          : all.isEmpty
          ? EmptyState(
              icon: Icons.wb_sunny_outlined,
              title: l10n.todayEmptyTitle,
              message: l10n.todayEmptyMessage,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (overdue.isNotEmpty) ...[
                  SectionHeader(title: l10n.todaySectionOverdue),
                  for (final item in overdue) _tile(item),
                  const SizedBox(height: 8),
                ],
                for (final (part, items) in groupByDayPart(upcoming)) ...[
                  DayPartSection(part: part, count: items.length),
                  for (final item in items) _tile(item),
                ],
                if (pending.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: l10n.todayEmptyTitle,
                      message: l10n.todayEmptyMessage,
                    ),
                  ),
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => setState(() => _doneExpanded = !_doneExpanded),
                    child: Row(
                      children: [
                        Expanded(
                          child: SectionHeader(
                            title:
                                '${l10n.todaySectionDone} '
                                '(${formatters.number(done.length)})',
                          ),
                        ),
                        Icon(
                          _doneExpanded ? Icons.expand_less : Icons.expand_more,
                          color: t.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  if (_doneExpanded)
                    for (final item in done) _tile(item),
                ],
              ],
            ),
    );
  }

  Widget _tile(ChoreItem item) {
    final formatters = ref.watch(appFormattersProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('today_${item.id}'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            await _complete(item);
            return false;
          }
          if (mounted) {
            unawaited(context.push(AppRoutes.choresOccurrence(item.id)));
          }
          return false;
        },
        background: _swipeBackground(
          context,
          alignment: Alignment.centerLeft,
          icon: Icons.check_circle_outline_rounded,
          label: context.l10n.occurrenceActionComplete,
        ),
        secondaryBackground: _swipeBackground(
          context,
          alignment: Alignment.centerRight,
          icon: Icons.open_in_new_rounded,
          label: context.l10n.occurrenceDetailTitle,
        ),
        child: ChoreTile(
          item: item,
          formatters: formatters,
          onTap: () => context.push(AppRoutes.choresOccurrence(item.id)),
        ),
      ),
    );
  }

  Widget _swipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required IconData icon,
    required String label,
  }) {
    final t = context.tokens;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: t.accentSoft,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: t.accentStrong),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: t.accentStrong)),
        ],
      ),
    );
  }

  /// Completes from a swipe and offers an undo for five seconds.
  Future<void> _complete(ChoreItem item) async {
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    final result = await ref.read(completeOccurrenceProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: item.id,
    );
    final failure = result.failureOrNull;
    if (!mounted) return;
    if (failure != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.choresFailureMessage(failure))),
      );
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.statusCompleted),
        action: SnackBarAction(
          label: l10n.todayUndo,
          onPressed: () async {
            final undone = await ref.read(uncompleteOccurrenceProvider)(
              familyId: familyId,
              actorUid: uid,
              occurrenceId: item.id,
            );
            final error = undone.failureOrNull;
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  error == null
                      ? l10n.occurrenceUndone
                      : l10n.choresFailureMessage(error),
                ),
              ),
            );
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
