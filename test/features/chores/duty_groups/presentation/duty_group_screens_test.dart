import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_editor_screen.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_list_screen.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

const _familyId = ChoresFixture.familyId;

ChoresFixture _fixture({bool withGroup = true}) {
  final fixture = ChoresFixture();
  if (withGroup) {
    fixture.chores.dutyGroups.groups[_familyId] = <String, DutyGroup>{
      'group_1': aDutyGroup(id: 'group_1'),
    };
  }
  return fixture;
}

Future<ChoresFixture> _pump(
  WidgetTester tester, {
  required ChoresFixture fixture,
  Widget? home,
  GoRouter? router,
  String uid = 'alice',
  Role role = Role.admin,
}) async {
  final result = await pumpP3Screen(
    tester,
    sharedFixture: fixture,
    home: home,
    router: router,
    uid: uid,
    role: role,
    overrides: [
      membersProvider.overrideWith(
        (ref) => Stream.value(fixture.roster),
      ),
    ],
  );
  // Tall enough that a long form never needs scrolling.
  tester.view.physicalSize = const Size(320, 2600);
  await tester.pump(const Duration(milliseconds: 100));
  return result;
}

void main() {
  group('DutyGroupListScreen', () {
    testWidgets('shows the group, who is on duty and the create button', (
      tester,
    ) async {
      await _pump(
        tester,
        fixture: _fixture(),
        home: const DutyGroupListScreen(),
      );

      expect(find.text('Daily kitchen duty'), findsOneWidget);
      // 2026-10-24 is cycle 3 of 3 members: alice.
      expect(find.text('On duty now: Person alice'), findsOneWidget);
      expect(find.text('New duty group'), findsOneWidget);
    });

    testWidgets('a plain member can read but not create', (tester) async {
      await _pump(
        tester,
        fixture: _fixture(),
        home: const DutyGroupListScreen(),
        uid: 'dave',
        role: Role.member,
      );

      expect(find.text('Daily kitchen duty'), findsOneWidget);
      expect(find.text('New duty group'), findsNothing);
    });

    testWidgets('an empty family gets the empty state', (tester) async {
      await _pump(
        tester,
        fixture: _fixture(withGroup: false),
        home: const DutyGroupListScreen(),
      );

      expect(find.text('No duty groups yet'), findsOneWidget);
    });
  });

  group('DutyGroupEditorScreen', () {
    testWidgets('creates a group with two members and a preview', (
      tester,
    ) async {
      final fixture = _fixture(withGroup: false);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DutyGroupEditorScreen(),
          ),
          GoRoute(
            path: AppRoutes.choresDutyGroups,
            builder: (context, state) => const DutyGroupListScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await _pump(tester, fixture: fixture, router: router);

      await tester.enterText(find.byKey(const ValueKey('name_bn')), 'রান্না');
      await tester.tap(find.byKey(const ValueKey('add_alice')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('add_cara')));
      await tester.pump();

      // The preview appears as soon as the rotation is valid.
      expect(find.text('Next turns'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('save_group')));
      await tester.pumpAndSettle();

      final stored = fixture.chores.dutyGroups.groups[_familyId]!.values;
      expect(stored, hasLength(1));
      expect(stored.single.nameBn, 'রান্না');
      expect(stored.single.members, ['alice', 'cara']);
      expect(find.byType(DutyGroupListScreen), findsOneWidget);
    });

    testWidgets('one member is refused with a message', (tester) async {
      final fixture = _fixture(withGroup: false);
      await _pump(
        tester,
        fixture: fixture,
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DutyGroupEditorScreen(),
            ),
          ],
        ),
      );

      await tester.enterText(find.byKey(const ValueKey('name_bn')), 'রান্না');
      await tester.tap(find.byKey(const ValueKey('add_alice')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('save_group')));
      await tester.pumpAndSettle();

      expect(fixture.chores.dutyGroups.groups[_familyId], isNull);
      expect(
        find.text('Add at least two members to rotate.'),
        findsOneWidget,
      );
    });

    testWidgets('a plain member sees the group read-only', (tester) async {
      await _pump(
        tester,
        fixture: _fixture(),
        home: const DutyGroupEditorScreen(groupId: 'group_1'),
        uid: 'dave',
        role: Role.member,
      );

      expect(
        find.text('Only people who manage chores can change duty groups.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('save_group')), findsNothing);
      expect(find.byKey(const ValueKey('change_rotation')), findsNothing);
    });

    testWidgets('adding a member from the next boundary keeps the past', (
      tester,
    ) async {
      final fixture = _fixture();
      await _pump(
        tester,
        fixture: fixture,
        home: const DutyGroupEditorScreen(groupId: 'group_1'),
      );

      await tester.tap(find.byKey(const ValueKey('change_rotation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pick_bob')));
      await tester.pump();

      expect(find.textContaining('Nothing before'), findsOneWidget);
      expect(find.text('After the change'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('change_apply')));
      await tester.pumpAndSettle();

      final group = fixture.chores.dutyGroups.groups[_familyId]!['group_1']!;
      expect(group.rotation.versions, hasLength(2));
      expect(group.rotation.versions.first.members, [
        'alice',
        'cara',
        'dave',
      ]);
      expect(group.rotation.versions.last.members, [
        'alice',
        'cara',
        'dave',
        'bob',
      ]);
      expect(group.rotation.versions.last.from, DateKey(2026, 10, 24));
    });
  });
}
