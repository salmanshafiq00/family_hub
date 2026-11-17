import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/member_load.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

/// The OTHER members who have a chore on a date: up to two avatars, then
/// `+n`. The viewer is never in this row (the cell shows them with the person
/// icon instead) and nobody is ranked: the order is by member id.
class DayCellMembers extends StatelessWidget {
  const DayCellMembers({
    required this.loads,
    required this.styles,
    required this.viewerId,
    super.key,
  });

  final List<MemberLoad> loads;
  final Map<String, CalendarMemberStyle> styles;
  final String? viewerId;

  /// The avatar diameter.
  static const double size = 16;

  @override
  Widget build(BuildContext context) {
    final others = <String>[
      for (final load in loads)
        if (load.memberId != null && load.memberId != viewerId) load.memberId!,
    ]..sort();
    if (others.isEmpty) return const SizedBox.shrink();

    final visible = others.take(2).toList();
    final hidden = others.length - visible.length;
    return ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < visible.length; index++)
              Padding(
                padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : 2),
                child: _MemberAvatar(
                  memberId: visible[index],
                  style: styles[visible[index]],
                ),
              ),
            if (hidden > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 2),
                child: Text(
                  context.l10n.avatarStackMoreShort(hidden),
                  maxLines: 1,
                  style: TextStyle(
                    color: context.tokens.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.memberId, required this.style});

  final String memberId;
  final CalendarMemberStyle? style;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SizedBox.square(
      key: ValueKey<String>('calendar_member_$memberId'),
      dimension: DayCellMembers.size,
      child: style == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                shape: BoxShape.circle,
                border: Border.all(color: t.outline),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: t.textSecondary,
                size: 10,
              ),
            )
          : AppAvatar(
              id: memberId,
              name: style!.name,
              avatarKey: style!.avatarKey,
              size: DayCellMembers.size,
            ),
    );
  }
}
