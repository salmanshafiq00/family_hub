import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The lifecycle history of one chore (P3-15): who completed, verified, moved
/// or reopened it, and why.
///
/// It reads the append-only `events` subcollection through
/// [occurrenceEventsProvider]; an event type this build does not know is
/// already dropped by the mapper, so the list never shows a raw code. Names are
/// resolved from the family roster (the events store uids, never display text).
class OccurrenceTimeline extends ConsumerWidget {
  const OccurrenceTimeline({
    required this.events,
    required this.formatters,
    super.key,
  });

  final List<OccurrenceEvent> events;
  final AppFormatters formatters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) return const SizedBox.shrink();
    final t = context.tokens;
    final members = ref.watch(membersProvider).value ?? const [];
    String name(String? uid) {
      if (uid == null) return '';
      for (final member in members) {
        if (member.uid == uid) return member.displayName;
      }
      return uid;
    }

    final ordered = <OccurrenceEvent>[...events]
      ..sort((a, b) => b.at.compareTo(a.at));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.occurrenceTimelineTitle,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: t.textPrimary),
        ),
        const SizedBox(height: 8),
        for (final event in ordered)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon(event.type), size: 16, color: t.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    describeEvent(context, event, name),
                    style: TextStyle(color: t.textPrimary, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatters.timeOfDay(
                    event.at.toLocal().hour * 60 + event.at.toLocal().minute,
                  ),
                  style: TextStyle(color: t.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// The localized sentence of one event (never a raw code).
  static String describeEvent(
    BuildContext context,
    OccurrenceEvent event,
    String Function(String?) name,
  ) {
    final l10n = context.l10n;
    final actor = name(event.actorId);
    final reason = event.reason ?? '';
    return switch (event.type) {
      OccurrenceEventType.completed => l10n.occurrenceEventCompleted(actor),
      OccurrenceEventType.uncompleted => l10n.occurrenceEventUncompleted(actor),
      OccurrenceEventType.verified => l10n.occurrenceEventVerified(actor),
      OccurrenceEventType.reopened => l10n.occurrenceEventReopened(
        actor,
        reason,
      ),
      OccurrenceEventType.reassigned => l10n.occurrenceEventReassigned(
        actor,
        name(event.toAssigneeId),
        reason,
      ),
      OccurrenceEventType.skipped => l10n.occurrenceEventSkipped(actor, reason),
      OccurrenceEventType.unskipped => l10n.occurrenceEventUnskipped(actor),
      OccurrenceEventType.exception => l10n.occurrenceEventException(
        actor,
        reason,
      ),
      OccurrenceEventType.swapped => l10n.occurrenceEventSwapped(
        actor,
        name(event.toAssigneeId),
      ),
      OccurrenceEventType.covered => l10n.occurrenceEventCovered(
        actor,
        name(event.fromAssigneeId),
      ),
    };
  }

  static IconData _icon(OccurrenceEventType type) => switch (type) {
    OccurrenceEventType.completed => Icons.check_circle_outline_rounded,
    OccurrenceEventType.uncompleted => Icons.undo_rounded,
    OccurrenceEventType.verified => Icons.verified_outlined,
    OccurrenceEventType.reopened => Icons.refresh_rounded,
    OccurrenceEventType.reassigned => Icons.swap_horiz_rounded,
    OccurrenceEventType.skipped => Icons.remove_circle_outline_rounded,
    OccurrenceEventType.unskipped => Icons.restore_rounded,
    OccurrenceEventType.exception => Icons.info_outline_rounded,
    OccurrenceEventType.swapped => Icons.swap_horiz_rounded,
    OccurrenceEventType.covered => Icons.person_outline_rounded,
  };
}
