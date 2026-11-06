import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/reminder_precedence.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('global and category switches suppress without discarding timings', () {
    final settings = ReminderSettings(
      globalEnabled: false,
      choresEnabled: false,
      defaultOffsetsMinutes: const <int>[15, 45],
      atDue: false,
      overdueEnabled: true,
      overdueAfterMinutes: 90,
    );
    final global = ReminderPrecedence.resolve(
      settings: settings,
      category: NotificationCategory.chores,
    );
    final bazar = ReminderPrecedence.resolve(
      settings: settings,
      category: NotificationCategory.bazar,
    );

    expect(global.fires, isFalse);
    expect(global.reason, ReminderPrecedenceReason.globalOff);
    expect(global.offsetsMinutes, <int>[15, 45]);
    expect(global.atDue, isFalse);
    expect(global.overdue, isTrue);
    expect(global.overdueAfterMinutes, 90);
    expect(bazar.reason, ReminderPrecedenceReason.globalOff);
  });

  test('category off takes precedence over template settings', () {
    final result = ReminderPrecedence.resolve(
      settings: ReminderSettings(choresEnabled: false),
      category: NotificationCategory.chores,
      templateConfig: TemplateReminderConfig(enabled: false),
    );

    expect(result.reason, ReminderPrecedenceReason.categoryOff);
    expect(result.fires, isFalse);
  });

  test('disabled template suppresses only its own saved timings', () {
    final config = TemplateReminderConfig(
      enabled: false,
      atDue: false,
      offsetsMinutes: const <int>[20],
      overdueEnabled: true,
      overdueAfterMinutes: 75,
    );
    final result = ReminderPrecedence.resolve(
      settings: ReminderSettings(defaultOffsetsMinutes: const <int>[30]),
      category: NotificationCategory.chores,
      templateConfig: config,
    );

    expect(result.fires, isFalse);
    expect(result.reason, ReminderPrecedenceReason.templateOff);
    expect(result.offsetsMinutes, <int>[20]);
    expect(result.atDue, isFalse);
    expect(result.overdue, isTrue);
    expect(result.overdueAfterMinutes, 75);
  });

  test('enabled template overrides defaults and reports no timings', () {
    final config = TemplateReminderConfig(
      enabled: true,
      atDue: false,
      offsetsMinutes: const <int>[],
      overdueEnabled: false,
    );
    final result = ReminderPrecedence.resolve(
      settings: ReminderSettings(defaultOffsetsMinutes: const <int>[30]),
      category: NotificationCategory.chores,
      templateConfig: config,
    );

    expect(result.fires, isFalse);
    expect(result.reason, ReminderPrecedenceReason.templateNoTimings);
    expect(result.offsetsMinutes, isEmpty);
    expect(result.atDue, isFalse);
  });

  test('enabled template with any configured timing is active', () {
    final configurations = <TemplateReminderConfig>[
      TemplateReminderConfig(enabled: true, atDue: true),
      TemplateReminderConfig(
        enabled: true,
        atDue: false,
        offsetsMinutes: const <int>[30],
      ),
      TemplateReminderConfig(enabled: true, atDue: false, overdueEnabled: true),
    ];

    for (final config in configurations) {
      final result = ReminderPrecedence.resolve(
        settings: ReminderSettings(),
        category: NotificationCategory.chores,
        templateConfig: config,
      );
      expect(result.fires, isTrue, reason: '$config');
      expect(result.reason, ReminderPrecedenceReason.ok);
    }
  });

  test('family defaults are used only when there is no template override', () {
    final settings = ReminderSettings(
      defaultOffsetsMinutes: const <int>[15],
      atDue: false,
      overdueEnabled: true,
      overdueAfterMinutes: 90,
    );
    final result = ReminderPrecedence.resolve(
      settings: settings,
      category: NotificationCategory.chores,
    );

    expect(result.fires, isTrue);
    expect(result.atDue, isFalse);
    expect(result.offsetsMinutes, <int>[15]);
    expect(result.overdue, isTrue);
    expect(result.overdueAfterMinutes, 90);
  });
}
