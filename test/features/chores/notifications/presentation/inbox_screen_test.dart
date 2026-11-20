import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_providers.dart';
import 'package:family_hub/features/chores/swaps/domain/swap_request.dart';
import 'package:family_hub/features/chores/swaps/presentation/swap_providers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:family_hub/features/notifications/presentation/inbox_bell.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/features/notifications/presentation/inbox_screen.dart';
import 'package:family_hub/features/notifications/presentation/inbox_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-27: the inbox screen and the bell.
void main() {
  late ChoresFixture fixture;

  InboxItem row(
    String id, {
    bool read = false,
    DateTime? at,
    Map<String, String>? params,
    String type = InboxType.swapRequest,
  }) => InboxItem(
    id: id,
    toMemberId: 'cara',
    type: type,
    refType: 'swapRequest',
    refId: 'r1',
    createdAt: at ?? fixture.clock.nowUtc(),
    readAt: read ? fixture.clock.nowUtc() : null,
    params:
        params ??
        <String, String>{
          'name': 'Dishes',
          'date': '2026-10-24',
          'from': 'dave',
          'kind': 'swap',
        },
  );

  setUp(() => fixture = ChoresFixture());

  Future<void> open(
    WidgetTester tester, {
    String language = 'en',
    double scale = 1,
    String? focusItemId,
  }) => pumpP3Screen(
    tester,
    home: InboxScreen(focusItemId: focusItemId),
    sharedFixture: fixture,
    languageCode: language,
    textScale: scale,
    overrides: [
      inboxRepositoryProvider.overrideWithValue(fixture.inboxRows),
      swapRepositoryProvider.overrideWithValue(fixture.swaps),
      availabilityRepositoryProvider.overrideWithValue(fixture.availability),
    ],
  ).then((_) => tester.pump(const Duration(milliseconds: 100)));

  testWidgets('groups Today and Earlier, marks unread and explains Spark', (
    tester,
  ) async {
    fixture.inboxRows.items['i1'] = row('i1');
    fixture.inboxRows.items['i2'] = row(
      'i2',
      read: true,
      at: DateTime.utc(2026, 10, 20),
      params: <String, String>{
        'name': 'Bins',
        'date': '2026-10-20',
        'outcome': 'declined',
        'by': 'dave',
      },
      type: InboxType.swapResult,
    );
    await open(tester);

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.textContaining('Dishes'), findsOneWidget);
    expect(find.textContaining('Bins'), findsOneWidget);
    expect(find.byKey(const Key('inbox_unread_dot')), findsOneWidget);
    expect(find.textContaining('when you open the app'), findsOneWidget);
  });

  testWidgets('tapping a row marks it read', (tester) async {
    fixture.inboxRows.items['i1'] = row(
      'i1',
      params: <String, String>{
        'name': 'Dishes',
        'date': '2026-10-24',
        'from': 'dave',
        'kind': 'swap',
      },
    );
    await open(tester);

    await tester.tap(find.textContaining('Dishes'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(fixture.inboxRows.items['i1']!.readAt, isNotNull);
  });

  testWidgets('a notification deep link opens the swap response actions', (
    tester,
  ) async {
    fixture.inboxRows.items['i1'] = row('i1');
    fixture.swapWorld.swapRequests['r1'] = SwapRequest(
      id: 'r1',
      occurrenceId: 'occ-1',
      occurrenceDateKey: DateKey(2026, 10, 24),
      kind: SwapKind.swap,
      fromMemberId: 'dave',
      toMemberId: 'cara',
      reason: 'I cannot do this chore',
      status: SwapStatus.pending,
      expiresAt: fixture.clock.nowUtc().add(const Duration(days: 1)),
      requestedBy: 'dave',
    );
    fixture.occurrences.occurrences[ChoresFixture.familyId] = {
      'occ-1': anOccurrence(id: 'occ-1'),
    };

    await open(tester, focusItemId: 'i1');
    await tester.pumpAndSettle();

    expect(fixture.inboxRows.items['i1']!.readAt, isNotNull);
    expect(find.byKey(const Key('swap_accept')), findsOneWidget);
    expect(find.byKey(const Key('swap_decline')), findsOneWidget);
  });

  testWidgets('tapping a closed request several times shows ONE message', (
    tester,
  ) async {
    // No request r1 exists any more: the row can only say it is not open.
    fixture.inboxRows.items['i1'] = row('i1');
    await open(tester);

    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byType(InboxTile).first);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('This request is no longer open.'), findsOneWidget);
  });

  testWidgets('with nothing under it the inbox still has a back button', (
    tester,
  ) async {
    fixture.inboxRows.items['i1'] = row('i1');
    await open(tester);

    expect(find.byKey(const Key('home_fallback_back')), findsOneWidget);
  });

  testWidgets('mark all read', (tester) async {
    fixture.inboxRows.items['i1'] = row('i1');
    fixture.inboxRows.items['i2'] = row('i2');
    await open(tester);

    await tester.tap(find.byKey(const Key('inbox_mark_all')));
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      fixture.inboxRows.items.values.every((i) => i.readAt != null),
      isTrue,
    );
  });

  testWidgets('clear all notifications dismisses them after confirmation', (tester) async {
    fixture.inboxRows.items['i1'] = row('i1', read: true);
    await open(tester);

    expect(find.byKey(const Key('inbox_clear_all')), findsOneWidget);
    await tester.tap(find.byKey(const Key('inbox_clear_all')));
    await tester.pumpAndSettle();

    // Confirm dialog is shown
    expect(find.text('Clear all notifications'), findsOneWidget);
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(fixture.inboxRows.items['i1']!.isArchived, isTrue);
  });

  testWidgets('an empty inbox says so', (tester) async {
    await open(tester);
    expect(find.text('No notifications yet'), findsOneWidget);
  });

  testWidgets('Bangla at text scale 2.0 does not overflow', (tester) async {
    fixture.inboxRows.items['i1'] = row('i1');
    await open(tester, language: 'bn', scale: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the bell shows the unread count', (tester) async {
    fixture.inboxRows.items['i1'] = row('i1');
    fixture.inboxRows.items['i2'] = row('i2');
    fixture.inboxRows.items['i3'] = row('i3', read: true);
    await pumpP3Screen(
      tester,
      home: const Scaffold(body: Center(child: InboxBell())),
      sharedFixture: fixture,
      overrides: [inboxRepositoryProvider.overrideWithValue(fixture.inboxRows)],
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
