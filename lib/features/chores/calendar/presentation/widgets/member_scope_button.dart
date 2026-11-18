import 'dart:async';

import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Whose chores": one chip that replaces the old My / Whole family toggle.
///
/// | selection | the chip shows |
/// | --- | --- |
/// | my chores | the person icon |
/// | whole family | the family (groups) icon |
/// | one other member | that member's avatar |
/// | several members | the family icon and a count |
///
/// A tap opens a small menu. Everything is stored through
/// `CalendarPrefsController.selectMembers`, in the same `calendarFiltersProvider`
/// the filter sheet's "Members" section uses, so the two never disagree.
class MemberScopeButton extends ConsumerWidget {
  const MemberScopeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final scope = ref.watch(calendarScopeProvider);
    final memberIds = ref.watch(
      calendarFiltersProvider.select((f) => f.memberIds),
    );
    final styles = ref.watch(calendarMemberStylesProvider);
    final viewerId = ref.watch(currentUidProvider);
    final formatters = ref.watch(appFormattersProvider);
    final prefs = ref.read(calendarPrefsProvider.notifier);

    final others = <MapEntry<String, CalendarMemberStyle>>[
      for (final entry in styles.entries)
        if (entry.key != viewerId) entry,
    ]..sort((a, b) => a.value.name.compareTo(b.value.name));

    final mine = scope == CalendarScope.mine;
    final picked = <String>[
      for (final id in memberIds)
        if (styles.containsKey(id)) id,
    ]..sort();
    final String name;
    final Widget face;
    if (mine) {
      name = l10n.choresCalendarScopeMine;
      face = Icon(Icons.person_rounded, color: t.accentStrong, size: 20);
    } else if (picked.length == 1) {
      final style = styles[picked.single]!;
      name = style.name;
      face = AppAvatar(
        id: picked.single,
        name: style.name,
        avatarKey: style.avatarKey,
        size: 24,
      );
    } else if (picked.length > 1) {
      name = picked.map((id) => styles[id]!.name).join(', ');
      face = Badge(
        label: Text(formatters.number(picked.length)),
        child: Icon(Icons.groups_rounded, color: t.accentStrong, size: 22),
      );
    } else {
      name = l10n.choresCalendarScopeAll;
      face = Icon(Icons.groups_rounded, color: t.accentStrong, size: 22);
    }
    final label = l10n.calendarShowingMember(name);

    return PopupMenuButton<_Pick>(
      key: const Key('calendar_member_button'),
      tooltip: label,
      position: PopupMenuPosition.under,
      onSelected: (pick) => unawaited(switch (pick) {
        _Mine() => prefs.selectMembers(
          memberIds: const <String>{},
          scope: CalendarScope.mine,
        ),
        _Family() => prefs.selectMembers(
          memberIds: const <String>{},
          scope: CalendarScope.all,
        ),
        _Member(:final id) => prefs.selectMembers(
          memberIds: <String>{id},
          scope: CalendarScope.all,
        ),
      }),
      itemBuilder: (context) => [
        PopupMenuItem<_Pick>(
          key: const Key('calendar_member_menu_mine'),
          value: const _Mine(),
          child: _MenuRow(
            leading: const Icon(Icons.person_rounded),
            text: l10n.choresCalendarScopeMine,
            checked: mine,
          ),
        ),
        PopupMenuItem<_Pick>(
          key: const Key('calendar_member_menu_family'),
          value: const _Family(),
          child: _MenuRow(
            leading: const Icon(Icons.groups_rounded),
            text: l10n.choresCalendarScopeAll,
            checked: !mine && picked.isEmpty,
          ),
        ),
        if (others.isNotEmpty) const PopupMenuDivider(),
        for (final entry in others)
          PopupMenuItem<_Pick>(
            key: Key('calendar_member_menu_${entry.key}'),
            value: _Member(entry.key),
            child: _MenuRow(
              leading: AppAvatar(
                id: entry.key,
                name: entry.value.name,
                avatarKey: entry.value.avatarKey,
                size: 24,
              ),
              text: entry.value.name,
              checked:
                  !mine && picked.length == 1 && picked.single == entry.key,
            ),
          ),
      ],
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: ConstrainedBox(
          // kCalendarControlHeight to look at, 48 dp to touch.
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Center(
            child: Container(
              height: kCalendarControlHeight,
              padding: const EdgeInsetsDirectional.only(start: 8, end: 2),
              decoration: BoxDecoration(
                color: t.accentSoft,
                borderRadius: BorderRadius.circular(t.radiusPill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  face,
                  Icon(Icons.arrow_drop_down, color: t.accentStrong),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

sealed class _Pick {
  const _Pick();
}

final class _Mine extends _Pick {
  const _Mine();
}

final class _Family extends _Pick {
  const _Family();
}

final class _Member extends _Pick {
  const _Member(this.id);

  final String id;
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.leading,
    required this.text,
    required this.checked,
  });

  final Widget leading;
  final String text;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const SizedBox(width: 12),
        Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
        if (checked) const Icon(Icons.check_rounded, size: 20),
      ],
    );
  }
}
