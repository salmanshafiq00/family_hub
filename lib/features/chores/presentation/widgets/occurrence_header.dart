import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart'
    as domain;
import 'package:family_hub/features/chores/presentation/chore_icons.dart';
import 'package:family_hub/features/chores/presentation/date_of_key.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/presentation/widgets/chore_tile.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:family_hub/shared/widgets/flag_chip.dart' as chips;
import 'package:family_hub/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The top of the chore detail screen (P3-15).
///
/// The group icon, the name, the status chip, the flags, the due line and the
/// assignee row ("covering for X" when somebody else covers it). A projected
/// item shows "planned" and a note instead of pretending it is stored (D-P3-6).
class OccurrenceHeader extends ConsumerWidget {
  const OccurrenceHeader({
    required this.item,
    required this.formatters,
    required this.today,
    super.key,
  });

  final domain.ChoreItem item;
  final AppFormatters formatters;

  /// The family's today (a `DateKey`), so the due line can say "Today, by 9:00".
  final DateKey today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l10n = context.l10n;
    final members = ref.watch(membersProvider).value ?? const [];
    final assignee = item.assigneeId == null
        ? null
        : members.where((m) => m.uid == item.assigneeId).firstOrNull;
    final planned = item.plannedAssigneeId == null
        ? null
        : members.where((m) => m.uid == item.plannedAssigneeId).firstOrNull;
    final isToday = today == item.dateKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: t.accentSoft,
                borderRadius: BorderRadius.circular(t.radiusMd),
              ),
              child: Icon(choreIconFor(item), color: t.accentStrong),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameOf(item, l10n),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      StatusChip(status: widgetStatusOf(item.status)),
                      if (item.isProjected)
                        const chips.FlagChip(flag: chips.ChoreFlag.planned),
                      for (final flag in item.flags)
                        if (flag != domain.ChoreFlag.isProjected)
                          chips.FlagChip(flag: sharedFlag(flag)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Line(icon: Icons.schedule_rounded, text: _dueText(l10n, isToday)),
        const SizedBox(height: 10),
        if (assignee == null)
          _Line(
            icon: Icons.person_search_rounded,
            text: l10n.occurrenceUnassigned,
            tone: t.warning,
          )
        else
          Row(
            children: [
              AppAvatar(
                id: assignee.uid,
                name: assignee.displayName,
                avatarKey: assignee.avatarKey,
                size: 28,
                semanticLabel: assignee.displayName,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  assignee.displayName,
                  style: TextStyle(color: t.textPrimary),
                ),
              ),
              if (item.has(domain.ChoreFlag.isCover) && planned != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.occurrenceCoveringFor(planned.displayName),
                    style: TextStyle(color: t.info, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        if (item.isProjected) ...[
          const SizedBox(height: 12),
          Text(
            l10n.occurrencePlannedReadOnly,
            style: TextStyle(color: t.textSecondary, fontSize: 12),
          ),
        ],
        if (item.estimatedMinutes != null ||
            item.difficulty != Difficulty.normal) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (item.estimatedMinutes != null)
                _Line(
                  icon: Icons.timer_outlined,
                  text: l10n.occurrenceEstimated(
                    formatters.number(item.estimatedMinutes!),
                  ),
                ),
              _Line(
                icon: Icons.speed_rounded,
                text: switch (item.difficulty) {
                  Difficulty.easy => l10n.occurrenceDifficultyEasy,
                  Difficulty.normal => l10n.occurrenceDifficultyNormal,
                  Difficulty.hard => l10n.occurrenceDifficultyHard,
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _dueText(AppLocalizations l10n, bool isToday) {
    final minutes = item.dueMinutes;
    if (minutes == null) return l10n.occurrenceDueNoTime;
    final time = formatters.timeOfDay(minutes);
    return isToday
        ? l10n.occurrenceDueToday(time)
        : l10n.occurrenceDueDay(
            formatters.fullDate(dateOfKey(item.dateKey)),
            time,
          );
  }
}

/// The chore's name in the active language (English falls back to Bangla).
String nameOf(domain.ChoreItem item, AppLocalizations l10n) =>
    l10n.localeName.startsWith('bn')
    ? item.nameBn
    : (item.nameEn ?? item.nameBn);

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text, this.tone});

  final IconData icon;
  final String text;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final colour = tone ?? t.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colour),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text, style: TextStyle(color: colour, fontSize: 13)),
        ),
      ],
    );
  }
}
