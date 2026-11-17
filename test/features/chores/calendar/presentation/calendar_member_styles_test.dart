import 'dart:async';

import 'package:family_hub/features/chores/calendar/presentation/calendar_member_styles.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/member_role.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'styles include only active members and preserve display identity',
    () async {
      final container = ProviderContainer(
        overrides: [
          membersProvider.overrideWith(
            (ref) => Stream.value([
              const Member(
                uid: 'cara',
                role: MemberRole.member,
                status: MembershipStatus.active,
                fullName: 'Cara',
                nickname: 'C',
                relationship: 'other',
                avatarKey: 'p3',
              ),
              const Member(
                uid: 'pending',
                role: MemberRole.member,
                status: MembershipStatus.pending,
                fullName: 'Pending',
                relationship: 'other',
              ),
              Member(
                uid: 'removed',
                role: MemberRole.member,
                status: MembershipStatus.active,
                fullName: 'Removed',
                relationship: 'other',
                removedAt: DateTime.utc(2026, 1, 1),
              ),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final loaded = Completer<Map<String, CalendarMemberStyle>>();
      final subscription = container.listen(calendarMemberStylesProvider, (
        _,
        styles,
      ) {
        if (styles.containsKey('cara') && !loaded.isCompleted) {
          loaded.complete(styles);
        }
      }, fireImmediately: true);
      final styles = await loaded.future;
      subscription.close();

      expect(styles.keys, {'cara'});
      expect(styles['cara']!.name, 'C');
      expect(styles['cara']!.avatarKey, 'p3');
    },
  );
}
