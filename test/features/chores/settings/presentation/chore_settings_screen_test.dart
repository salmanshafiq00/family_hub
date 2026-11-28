import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/generated/app_localizations_en.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/shared/widgets/catalog_editor.dart'
    show CatalogEntry;
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_screen.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_state.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/catalog_mapping.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/slots_editor.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/shared/widgets/weekday_chips.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/in_memory_notification_backend.dart';
import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-17: the chore settings screen against the fake settings repository.
void main() {
  Future<void> openTab(
    WidgetTester tester,
    ChoreSettingsSection section,
  ) async {
    final tab = find.byKey(ValueKey<String>('tab_${section.name}'));
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  Future<void> openAndScrollTo(WidgetTester tester, Finder target) async {
    final vertical = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    if (vertical.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(target, 300, scrollable: vertical.first);
    }
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey<String>('settings_save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('a plain member sees an explanation, not the controls', (
    tester,
  ) async {
    await pumpP3Screen(tester, home: const ChoreSettingsScreen());

    final l10n = AppLocalizationsEn();
    expect(find.text(l10n.choresSettingsNotAllowed), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('settings_save')), findsNothing);
    expect(find.byKey(const ValueKey<String>('policy_skip')), findsNothing);
  });

  testWidgets('the Save button is off until something changes', (tester) async {
    await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      home: const ChoreSettingsScreen(),
    );

    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('settings_save')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('choosing a policy card writes that enum, and only that', (
    tester,
  ) async {
    final fixture = await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      home: const ChoreSettingsScreen(),
    );

    final skip = find.byKey(const ValueKey<String>('policy_skip'));
    await openTab(tester, ChoreSettingsSection.policies);
    await openAndScrollTo(tester, skip);
    await tester.tap(skip);
    await tester.pump();
    await save(tester);

    expect(fixture.settings.policy, AbsencePolicy.skip);
    expect(fixture.settings.policySaves, 1);
    // The settings document itself did not change, so it was not written.
    expect(fixture.settings.saves, 0);
  });

  testWidgets('changing the week start writes weekStartDay', (tester) async {
    final fixture = await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      home: const ChoreSettingsScreen(),
    );

    final monday = find.byKey(const ValueKey<String>('week_start_1'));
    await openAndScrollTo(tester, monday);
    await tester.tap(monday);
    await tester.pump();
    await save(tester);

    expect(fixture.settings.settings.weekStartDay, DateTime.monday);
    expect(fixture.settings.saves, 1);
  });

  testWidgets('the weekday chips follow the week start', (tester) async {
    expect(WeekdayChips.order(DateTime.saturday), <int>[6, 7, 1, 2, 3, 4, 5]);
    expect(WeekdayChips.order(DateTime.monday), <int>[1, 2, 3, 4, 5, 6, 7]);
    expect(WeekdayChips.order(DateTime.sunday), <int>[7, 1, 2, 3, 4, 5, 6]);
  });

  testWidgets('"members can complete for others" is hidden for a moderator', (
    tester,
  ) async {
    await pumpP3Screen(
      tester,
      role: Role.moderator,
      uid: 'bob',
      home: const ChoreSettingsScreen(),
    );

    await openTab(tester, ChoreSettingsSection.policies);
    final swaps = find.byKey(const ValueKey<String>('swaps_enabled'));
    await openAndScrollTo(tester, swaps);
    expect(
      find.byKey(const ValueKey<String>('complete_for_others')),
      findsNothing,
    );
  });

  testWidgets('an offline save keeps the draft and says it needs internet', (
    tester,
  ) async {
    final fixture = await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      home: const ChoreSettingsScreen(),
    );
    fixture.settings.nextFailure = const Network();

    final monday = find.byKey(const ValueKey<String>('week_start_1'));
    await openAndScrollTo(tester, monday);
    await tester.tap(monday);
    await tester.pump();
    await save(tester);

    expect(
      find.text(AppLocalizationsEn().choresSettingsNeedsInternet),
      findsOneWidget,
    );
    // Still unsaved: the button is on, nothing was stored.
    expect(fixture.settings.settings.weekStartDay, isNot(DateTime.monday));
    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('settings_save')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('Reset section asks first, then restores the defaults', (
    tester,
  ) async {
    final fixture = ChoresFixture();
    fixture.settings.settings = ChoreSettings.defaults.copyWith(
      generationHorizonDays: 20,
    );
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      role: Role.admin,
      uid: 'alice',
      home: const ChoreSettingsScreen(),
    );

    final reset = find.byKey(const ValueKey<String>('reset_generation'));
    await openTab(tester, ChoreSettingsSection.generation);
    await openAndScrollTo(tester, reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    // Cancel leaves everything as it was.
    await tester.tap(find.text(AppLocalizationsEn().actionCancel));
    await tester.pumpAndSettle();
    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('settings_save')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);

    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('reset_confirm')));
    await tester.pumpAndSettle();
    await save(tester);

    expect(
      fixture.settings.settings.generationHorizonDays,
      ChoreSettings.defaults.generationHorizonDays,
    );
  });

  testWidgets('leaving with unsaved changes asks first', (tester) async {
    await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ChoreSettingsScreen(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final monday = find.byKey(const ValueKey<String>('week_start_1'));
    await openAndScrollTo(tester, monday);
    await tester.tap(monday);
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.text(AppLocalizationsEn().choresSettingsDiscardTitle),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey<String>('discard_confirm')));
    await tester.pumpAndSettle();
    expect(find.byType(ChoreSettingsScreen), findsNothing);
  });

  group('a deactivated due-time preset', () {
    testWidgets('is hidden from the slots of a new chore', (tester) async {
      final fixture = ChoresFixture();
      final first = ChoreSettings.defaults.dueTimePresets.first.id;
      final second = ChoreSettings.defaults.dueTimePresets.last.id;
      fixture.settings.settings = ChoreSettings.defaults.copyWith(
        dueTimePresets: <DueTimePreset>[
          for (final p in ChoreSettings.defaults.dueTimePresets)
            p.id == first ? p.copyWith(active: false) : p,
        ],
      );
      await pumpP3Screen(
        tester,
        sharedFixture: fixture,
        role: Role.admin,
        uid: 'alice',
        home: Scaffold(
          body: SingleChildScrollView(
            child: SlotsEditor(
              slots: <TemplateSlot>[aSlot(dueMinutes: null)],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.byKey(ValueKey<String>('slot_main_preset_$first')),
        findsNothing,
      );
      expect(
        find.byKey(ValueKey<String>('slot_main_preset_$second')),
        findsOneWidget,
      );
    });
  });

  group('CatalogMapping', () {
    test('nextCustomId takes the smallest unused number', () {
      expect(CatalogMapping.nextCustomId(<String>[]), 'custom_1');
      expect(
        CatalogMapping.nextCustomId(<String>['custom_1', 'custom_3']),
        'custom_2',
      );
    });

    test('a renamed group keeps its colour, icon and built-in flag', () {
      final original = ChoreSettings.defaults.groups.first;
      final rows = <CatalogEntry>[
        CatalogMapping.groupEntry(original).copyWith(labelBn: 'নতুন নাম'),
      ];
      final result = CatalogMapping.groupsFrom(rows, <ChoreGroup>[original]);
      expect(result.single.nameBn, 'নতুন নাম');
      expect(result.single.colorIndex, original.colorIndex);
      expect(result.single.iconKey, original.iconKey);
      expect(result.single.builtIn, isTrue);
    });
  });

  testWidgets(
    'switching tabs shows sections and marks modified tabs with dirty badge',
    (tester) async {
      final fixture = await pumpP3Screen(
        tester,
        role: Role.admin,
        uid: 'alice',
        home: const ChoreSettingsScreen(),
      );

      // Initial state: calendar tab is shown, no badges are active
      expect(find.byKey(const ValueKey<String>('view_agenda')), findsOneWidget);

      // Modify a setting on the calendar tab
      final monday = find.byKey(const ValueKey<String>('week_start_1'));
      await openAndScrollTo(tester, monday);
      await tester.tap(monday);
      await tester.pump();

      // Verify calendar tab badge is now active
      final calendarTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_calendar')),
      );
      final badge = calendarTab.child as Badge;
      expect(badge.isLabelVisible, isTrue);

      // Switch to policies tab
      await openTab(tester, ChoreSettingsSection.policies);
      expect(
        find.byKey(const ValueKey<String>('swaps_enabled')),
        findsOneWidget,
      );

      // Policies tab badge is not active yet
      final policiesTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_policies')),
      );
      final policiesBadge = policiesTab.child as Badge;
      expect(policiesBadge.isLabelVisible, isFalse);

      // Modify policies
      final skip = find.byKey(const ValueKey<String>('policy_skip'));
      await openAndScrollTo(tester, skip);
      await tester.tap(skip);
      await tester.pump();

      final updatedPoliciesTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_policies')),
      );
      expect((updatedPoliciesTab.child as Badge).isLabelVisible, isTrue);

      // Save and verify both tabs are clean again
      await save(tester);
      expect(fixture.settings.settings.weekStartDay, DateTime.monday);
      expect(fixture.settings.policy, AbsencePolicy.skip);

      final cleanCalendarTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_calendar')),
      );
      expect((cleanCalendarTab.child as Badge).isLabelVisible, isFalse);
      final cleanPoliciesTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_policies')),
      );
      expect((cleanPoliciesTab.child as Badge).isLabelVisible, isFalse);
    },
  );

  testWidgets('reminders tab modifies chore notification defaults and saves', (
    tester,
  ) async {
    final notifRepo = InMemoryNotificationDefaultsRepository();
    await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      notificationDefaultsRepository: notifRepo,
      home: const ChoreSettingsScreen(),
    );

    // Open reminders tab
    await openTab(tester, ChoreSettingsSection.reminders);

    // Initial state: reminders tab is clean
    final remindersTab = tester.widget<Tab>(
      find.byKey(const ValueKey<String>('tab_reminders')),
    );
    expect((remindersTab.child as Badge).isLabelVisible, isFalse);

    // Toggle overdue reminders
    final overdue = find.byKey(
      const ValueKey<String>('reminders_overdue_enabled'),
    );
    await openAndScrollTo(tester, overdue);
    await tester.tap(overdue);
    await tester.pump();

    // Reminders tab is now dirty
    final dirtyTab = tester.widget<Tab>(
      find.byKey(const ValueKey<String>('tab_reminders')),
    );
    expect((dirtyTab.child as Badge).isLabelVisible, isTrue);

    // Save
    await save(tester);

    // Verify repo was saved with overdue inverted
    expect(notifRepo.saved, isNotNull);
    expect(
      notifRepo.saved!.overdueEnabled,
      !NotificationDefaults.defaults.overdueEnabled,
    );

    // Tab is clean again
    final cleanTab = tester.widget<Tab>(
      find.byKey(const ValueKey<String>('tab_reminders')),
    );
    expect((cleanTab.child as Badge).isLabelVisible, isFalse);
  });

  testWidgets(
    'resetting reminders section restores default reminder settings',
    (tester) async {
      final notifRepo = InMemoryNotificationDefaultsRepository();
      notifRepo.defaults = NotificationDefaults.defaults.copyWith(
        overdueEnabled: !NotificationDefaults.defaults.overdueEnabled,
        chores: false,
      );
      await pumpP3Screen(
        tester,
        role: Role.admin,
        uid: 'alice',
        notificationDefaultsRepository: notifRepo,
        home: const ChoreSettingsScreen(),
      );

      await openTab(tester, ChoreSettingsSection.reminders);

      final reset = find.byKey(const ValueKey<String>('reset_reminders'));
      await openAndScrollTo(tester, reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();

      // Confirm reset
      await tester.tap(find.byKey(const ValueKey<String>('reset_confirm')));
      await tester.pumpAndSettle();

      // Save the reset state
      await save(tester);

      expect(notifRepo.saved?.chores, NotificationDefaults.defaults.chores);
      expect(
        notifRepo.saved?.overdueEnabled,
        NotificationDefaults.defaults.overdueEnabled,
      );
    },
  );

  testWidgets(
    'changing chore delivery mode marks delivery tab dirty and saves delivery settings',
    (tester) async {
      final deliveryRepo = InMemoryNotificationDeliveryRepository();
      await pumpP3Screen(
        tester,
        role: Role.admin,
        uid: 'alice',
        notificationDeliveryRepository: deliveryRepo,
        home: const ChoreSettingsScreen(),
      );

      await openTab(tester, ChoreSettingsSection.delivery);

      final deliveryTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_delivery')),
      );
      expect((deliveryTab.child as Badge).isLabelVisible, isFalse);

      final l10n = AppLocalizationsEn();
      final swapTile = find.ancestor(
        of: find.text(l10n.notificationTypeSwapRequest),
        matching: find.byType(Card),
      );
      await openAndScrollTo(tester, swapTile);

      final normalSegment = find.descendant(
        of: swapTile,
        matching: find.text(l10n.notificationNormal),
      );
      await tester.tap(normalSegment);
      await tester.pump();

      final dirtyTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_delivery')),
      );
      expect((dirtyTab.child as Badge).isLabelVisible, isTrue);

      await save(tester);

      expect(deliveryRepo.saved, isNotNull);
      expect(deliveryRepo.saved!.modes['swap_request'], DeliveryMode.normal);

      final cleanTab = tester.widget<Tab>(
        find.byKey(const ValueKey<String>('tab_delivery')),
      );
      expect((cleanTab.child as Badge).isLabelVisible, isFalse);
    },
  );

  testWidgets('a moderator sees delivery settings read-only', (tester) async {
    final deliveryRepo = InMemoryNotificationDeliveryRepository();
    await pumpP3Screen(
      tester,
      role: Role.moderator,
      uid: 'bob',
      notificationDeliveryRepository: deliveryRepo,
      home: const ChoreSettingsScreen(),
    );

    await openTab(tester, ChoreSettingsSection.delivery);

    final l10n = AppLocalizationsEn();
    expect(find.text(l10n.choresSettingsDeliveryAdminOnly), findsOneWidget);

    final segmentedButtons = tester.widgetList<SegmentedButton<DeliveryMode>>(
      find.byWidgetPredicate((w) => w is SegmentedButton<DeliveryMode>),
    );
    expect(segmentedButtons, isNotEmpty);
    for (final sb in segmentedButtons) {
      expect(sb.onSelectionChanged, isNull);
    }
  });

  testWidgets(
    'resetting delivery section restores default chore delivery modes',
    (tester) async {
      final deliveryRepo = InMemoryNotificationDeliveryRepository();
      deliveryRepo.settings = NotificationDeliverySettings(
        modes: {'swap_request': DeliveryMode.normal},
      );
      await pumpP3Screen(
        tester,
        role: Role.admin,
        uid: 'alice',
        notificationDeliveryRepository: deliveryRepo,
        home: const ChoreSettingsScreen(),
      );

      await openTab(tester, ChoreSettingsSection.delivery);

      final reset = find.byKey(const ValueKey<String>('reset_delivery'));
      await openAndScrollTo(tester, reset);
      await tester.tap(reset);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('reset_confirm')));
      await tester.pumpAndSettle();

      await save(tester);

      expect(deliveryRepo.saved?.modes['swap_request'], DeliveryMode.push);
    },
  );

  group('layout', () {
    for (final language in <String>['en', 'bn']) {
      for (final scale in <double>[1.0, 2.0]) {
        testWidgets('$language at text scale $scale does not overflow', (
          tester,
        ) async {
          await pumpP3Screen(
            tester,
            role: Role.admin,
            uid: 'alice',
            languageCode: language,
            textScale: scale,
            home: const ChoreSettingsScreen(),
          );
          // Walk every tab so every section is laid out once.
          for (final section in ChoreSettingsSection.values) {
            await openTab(tester, section);
            final vertical = find.byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            );
            if (vertical.evaluate().isNotEmpty) {
              await tester.drag(vertical.first, const Offset(0, -300));
              await tester.pump();
            }
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  });
}
