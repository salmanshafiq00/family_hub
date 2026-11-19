import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/activity_names.dart';
import 'package:family_hub/core/localization/activity_text.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/activity/domain/activity_entry.dart';
import 'package:family_hub/features/activity/presentation/activity_providers.dart';
import 'package:family_hub/features/activity/presentation/activity_target.dart';
import 'package:family_hub/features/activity/presentation/widgets/activity_filter_bar.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/activity_tile.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:family_hub/shared/widgets/home_fallback_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActivityFeedScreen extends ConsumerWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(activityFilterProvider);
    final firstPage = ref.watch(activityFirstPageProvider(filter.actorId));
    final olderState = ref.watch(activityOlderPagesProvider)[filter.actorId];
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    final familyId = ref.watch(currentFamilyIdProvider);
    final older = olderState ?? const ActivityOlderPagesState();

    return HomeFallbackBack(
      child: Scaffold(
        appBar: AppBar(
          leading: homeFallbackLeading(context),
          title: Text(l10n.activityTitle),
        ),
        // P4-24: the feed keeps a readable measure on a tablet; each row still
        // opens its own target route.
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                ActivityFilterBar(
                  filter: filter,
                  members: members,
                  onModuleChanged: ref
                      .read(activityFilterProvider.notifier)
                      .setModule,
                  onActorChanged: ref
                      .read(activityFilterProvider.notifier)
                      .setActor,
                ),
                Expanded(
                  child: firstPage.when(
                    loading: () => const LoadingView(lines: 5),
                    error: (_, _) => ErrorView(
                      message: l10n.activityLoadError,
                      onRetry: () => ref.invalidate(
                        activityFirstPageProvider(filter.actorId),
                      ),
                    ),
                    data: (page) {
                      final allEntries = _mergeEntries(
                        page.entries,
                        older.entries,
                      );
                      final entries = filter.apply(allEntries);
                      final canLoadMore = older.hasMore ?? page.hasMore;
                      if (entries.isEmpty && !canLoadMore) {
                        return EmptyState(
                          icon: Icons.history_rounded,
                          title: allEntries.isEmpty
                              ? l10n.activityEmpty
                              : l10n.activityNoMatches,
                        );
                      }
                      return ListView.builder(
                        key: const Key('activity_feed'),
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        itemCount:
                            (entries.isEmpty ? 1 : entries.length) +
                            (canLoadMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (entries.isEmpty && index == 0) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.activityNoMatches,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          if (index == (entries.isEmpty ? 1 : entries.length)) {
                            if (older.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (older.failure != null) {
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n.activityLoadError,
                                      textAlign: TextAlign.center,
                                    ),
                                    TextButton.icon(
                                      key: const Key(
                                        'activity_retry_load_more',
                                      ),
                                      onPressed: familyId == null
                                          ? null
                                          : () => _loadMore(
                                              ref,
                                              familyId,
                                              filter.actorId,
                                              page,
                                            ),
                                      icon: const Icon(Icons.refresh_rounded),
                                      label: Text(l10n.actionRetry),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
                              child: TextButton(
                                key: const Key('activity_load_more'),
                                onPressed: familyId == null
                                    ? null
                                    : () => _loadMore(
                                        ref,
                                        familyId,
                                        filter.actorId,
                                        page,
                                      ),
                                child: Text(l10n.activityLoadMore),
                              ),
                            );
                          }
                          final entry = entries[index];
                          return _ActivityRow(
                            entry: entry,
                            members: members,
                            onTap: _targetFor(entry) == null
                                ? null
                                // The feed is a page above the shell: pushing a
                                // tab route would duplicate the shell page key.
                                : () => context.go(_targetFor(entry)!.location),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadMore(
    WidgetRef ref,
    String familyId,
    String? actorId,
    ActivityPage firstPage,
  ) => ref
      .read(activityOlderPagesProvider.notifier)
      .loadMore(familyId: familyId, actorId: actorId, firstPage: firstPage);

  ActivityTarget? _targetFor(ActivityEntry entry) => ActivityTarget.from(entry);

  List<ActivityEntry> _mergeEntries(
    List<ActivityEntry> newest,
    List<ActivityEntry> older,
  ) {
    final seen = <String>{};
    return <ActivityEntry>[
      for (final entry in newest)
        if (seen.add(entry.id)) entry,
      for (final entry in older)
        if (seen.add(entry.id)) entry,
    ];
  }
}

class _ActivityRow extends ConsumerWidget {
  const _ActivityRow({
    required this.entry,
    required this.members,
    required this.onTap,
  });

  final ActivityEntry entry;
  final List<Member> members;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final formatters = ref.watch(appFormattersProvider);
    final familyDates = ref.watch(familyDateKeysProvider);
    final activityDate = familyDates.dateKeyOf(entry.createdAt);
    final activityMinutes = familyDates.minutesOfDayOf(entry.createdAt);
    final params = resolveChoreActivityNames(entry.type, entry.params, (uid) {
      for (final member in members) {
        if (member.uid == uid) return member.displayName;
      }
      return null;
    });
    final actor = _actorName(entry.actorId, members, l10n.activityUnknownActor);
    final target = ActivityTarget.from(entry);
    final title = l10n.activityText(entry.type, params);
    return ActivityTile(
      key: ValueKey<String>(entry.id),
      title: title,
      subtitle: actor,
      timeLabel:
          '${formatters.fullDate(DateTime.utc(activityDate.year, activityDate.month, activityDate.day))} · '
          '${formatters.timeOfDay(activityMinutes)}',
      leading: Icon(
        _iconFor(entry.type),
        color: context.tokens.accentStrong,
        size: 22,
      ),
      onTap: target == null || onTap == null ? null : onTap,
    );
  }

  String _actorName(String uid, List<Member> members, String fallback) {
    for (final member in members) {
      if (member.uid == uid) return member.displayName;
    }
    return fallback;
  }

  IconData _iconFor(String type) {
    if (type.startsWith('bazar.')) return Icons.shopping_basket_outlined;
    if (type.startsWith('chores.')) return Icons.task_alt_rounded;
    if (type.startsWith('engagement.')) return Icons.emoji_events_outlined;
    return Icons.groups_outlined;
  }
}
