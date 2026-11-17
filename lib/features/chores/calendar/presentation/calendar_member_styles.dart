import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CalendarMemberStyle {
  const CalendarMemberStyle({required this.name, this.avatarKey});

  final String name;
  final String? avatarKey;
}

final calendarMemberStylesProvider = Provider<Map<String, CalendarMemberStyle>>(
  (ref) {
    final members = ref.watch(membersProvider).value ?? const <Member>[];
    return Map<String, CalendarMemberStyle>.unmodifiable({
      for (final member in members)
        if (member.isActive)
          member.uid: CalendarMemberStyle(
            name: member.displayName,
            avatarKey: member.avatarKey,
          ),
    });
  },
);
