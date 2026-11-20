import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/member_availability.dart';
import 'package:family_hub/features/chores/availability/presentation/add_availability_sheet.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_providers.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_screen.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-27: the absence screen and its add sheet.
void main() {
  late ChoresFixture fixture;
  final typeId = ChoreSettings.defaults.absenceReasons.first.id;

  void seed(String id, String member, AvailabilityStatus status) {
    fixture.swapWorld.absences[id] = MemberAvailability(
      id: id,
      memberId: member,
      startDate: DateKey(2026, 10, 24),
      endDate: DateKey(2026, 10, 26),
      typeId: typeId,
      reason: 'Fever',
      status: status,
      createdBy: member,
    );
  }

  setUp(() => fixture = ChoresFixture());

  Future<void> open(
    WidgetTester tester, {
    required String uid,
    Role role = Role.member,
    String language = 'en',
    double scale = 1,
  }) async {
    await pumpP3Screen(
      tester,
      home: const AvailabilityScreen(),
      sharedFixture: fixture,
      uid: uid,
      role: role,
      languageCode: language,
      textScale: scale,
      overrides: [
        availabilityRepositoryProvider.overrideWithValue(fixture.availability),
        swapRepositoryProvider.overrideWithValue(fixture.swaps),
      ],
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('a member sees and cancels their own absence only', (
    tester,
  ) async {
    seed('a1', 'cara', AvailabilityStatus.active);
    seed('a2', 'dave', AvailabilityStatus.pending);
    await open(tester, uid: 'cara');

    expect(find.text('Approved'), findsOneWidget);
    expect(
      find.text('Waiting for approval'),
      findsNothing,
      reason: 'dave’s is not mine',
    );
    expect(find.byKey(const Key('availability_scope')), findsNothing);

    await tester.tap(find.byKey(const Key('availability_cancel')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      fixture.swapWorld.absences['a1']!.status,
      AvailabilityStatus.cancelled,
    );
  });

  testWidgets('a manager switches to Everyone and approves a pending absence', (
    tester,
  ) async {
    seed('a2', 'dave', AvailabilityStatus.pending);
    await open(tester, uid: 'bob', role: Role.moderator);

    expect(find.text('Waiting for approval'), findsNothing);
    await tester.tap(find.text('Everyone'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Waiting for approval'), findsOneWidget);

    await tester.tap(find.byKey(const Key('availability_approve')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(fixture.swapWorld.absences['a2']!.status, AvailabilityStatus.active);
  });

  testWidgets('an empty list says so', (tester) async {
    await open(tester, uid: 'cara');
    expect(find.text('No absences'), findsOneWidget);
  });

  testWidgets('Bangla at text scale 2.0 does not overflow', (tester) async {
    seed('a1', 'cara', AvailabilityStatus.active);
    await open(tester, uid: 'cara', language: 'bn', scale: 2);
    expect(tester.takeException(), isNull);
  });

  group('the add sheet', () {
    Future<void> openSheet(WidgetTester tester) async {
      await pumpP3Screen(
        tester,
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () =>
                  ref.addAvailabilityWithSheet(context, memberId: 'cara'),
              child: const Text('open'),
            ),
          ),
        ),
        sharedFixture: fixture,
        uid: 'cara',
        height: 1400,
        overrides: [
          availabilityRepositoryProvider.overrideWithValue(
            fixture.availability,
          ),
          swapRepositoryProvider.overrideWithValue(fixture.swaps),
        ],
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('it explains what the current policy will do', (tester) async {
      fixture.settings.policy = AbsencePolicy.askCover;
      await openSheet(tester);
      expect(find.textContaining('listed as needing a cover'), findsOneWidget);
    });

    testWidgets('the policy line follows the family setting', (tester) async {
      fixture.settings.policy = AbsencePolicy.autoCover;
      await openSheet(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.textContaining('Nothing changes until they accept'),
        findsOneWidget,
      );
    });

    testWidgets('Save stays disabled until type, dates and reason are given', (
      tester,
    ) async {
      await openSheet(tester);
      final save = find.byKey(const Key('availability_save'));
      expect(tester.widget<FilledButton>(save).onPressed, isNull);

      await tester.tap(find.byKey(Key('availability_type_$typeId')));
      await tester.enterText(
        find.byKey(const Key('availability_reason')),
        'Fever',
      );
      await tester.pump();
      expect(
        tester.widget<FilledButton>(save).onPressed,
        isNull,
        reason: 'no dates yet',
      );
    });
  });
}
