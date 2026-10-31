import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rota_preview.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_labels.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The next turns of a rotation: date range, avatar and name per turn
/// (P3-18). A turn whose planned person is no longer active says "Needs a
/// cover" with an icon and words.
///
/// All dates and names come from [RotaPreview] / [RotationEngine], the same
/// maths the generator uses, so the preview cannot disagree with Today.
class RotaPreviewView extends ConsumerWidget {
  const RotaPreviewView({
    required this.rotation,
    this.title,
    this.from,
    this.recurrence,
    super.key,
  });

  final Rotation rotation;

  /// Heading; defaults to "Next turns".
  final String? title;

  /// First day to show; defaults to the family's today.
  final DateKey? from;

  /// The schedule an `occurrence` rotation counts (the first chore's).
  final Recurrence? recurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final formatters = ref.watch(appFormattersProvider);
    final index = ref.watch(dutyMemberIndexProvider);
    final roster = ref.watch(dutyRosterProvider);
    final start = from ?? ref.watch(familyDateKeysProvider).today();
    // Without a member list yet nobody can be called "gone".
    final active = index.isEmpty
        ? null
        : <String>{for (final member in roster) member.uid};

    final needsSchedule = RotaPreview.needsSchedule(
      rotation,
      start,
      recurrence: recurrence,
    );
    final cells = RotaPreview.build(
      rotation,
      from: start,
      recurrence: recurrence,
      activeMemberIds: active,
    );

    String range(RotaCell cell) {
      final first = formatters.fullDate(dateOfKey(cell.start));
      if (cell.start == cell.end) return first;
      return l10n.dutyRotaRange(
        first,
        formatters.fullDate(dateOfKey(cell.end)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? l10n.dutyRotaTitle,
          style: textTheme.titleSmall?.copyWith(color: t.textPrimary),
        ),
        const SizedBox(height: 8),
        if (needsSchedule)
          Text(
            l10n.dutyRotaNeedsSchedule,
            style: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
        for (final cell in cells)
          _Cell(
            key: ValueKey<String>('rota_${cell.start}'),
            range: range(cell),
            memberId: cell.memberId,
            name: cell.memberId == null
                ? l10n.dutyRotaNobody
                : memberName(index, cell.memberId!),
            avatarKey: index[cell.memberId]?.avatarKey,
            needsCover: cell.needsCover,
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.range,
    required this.memberId,
    required this.name,
    required this.needsCover,
    this.avatarKey,
    super.key,
  });

  final String range;
  final String? memberId;
  final String name;
  final String? avatarKey;
  final bool needsCover;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final label = needsCover
        ? l10n.dutyRotaCellLabelCover(range, name)
        : l10n.dutyRotaCellLabel(range, name);

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              AppAvatar(id: memberId ?? '-', name: name, avatarKey: avatarKey, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                    Text(
                      range,
                      style: textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (needsCover) ...[
                const SizedBox(width: 8),
                Icon(Icons.warning_amber_rounded, size: 18, color: t.danger),
                const SizedBox(width: 4),
                Text(
                  l10n.dutyNeedsCover,
                  style: textTheme.labelMedium?.copyWith(color: t.danger),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
