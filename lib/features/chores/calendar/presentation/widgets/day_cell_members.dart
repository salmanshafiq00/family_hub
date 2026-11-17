import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/member_load.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final members = <MemberLoad>[
      for (final load in loads)
        if (load.memberId != null) load,
    ];
    if (members.isEmpty) return const SizedBox(height: 18);

    final visible = members.take(2).toList();
    final hidden = members.length - visible.length;
    const size = 18.0;
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
                  memberId: visible[index].memberId!,
                  style: styles[visible[index].memberId],
                  viewer: visible[index].memberId == viewerId,
                  size: size,
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
  const _MemberAvatar({
    required this.memberId,
    required this.style,
    required this.viewer,
    required this.size,
  });

  final String memberId;
  final CalendarMemberStyle? style;
  final bool viewer;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      key: ValueKey<String>('calendar_member_$memberId'),
      width: size,
      height: size,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.surface,
        border: Border.all(
          color: viewer ? t.accent : t.surface,
          width: viewer ? 2 : 1,
        ),
      ),
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
              size: 14,
            ),
    );
  }
}
