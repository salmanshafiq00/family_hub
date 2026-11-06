import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('recommended defaults match the roadmap', () {
    final settings = ReminderSettings.defaults();

    expect(settings.globalEnabled, isTrue);
    expect(settings.choresEnabled, isTrue);
    expect(settings.bazarEnabled, isTrue);
    expect(settings.familyEnabled, isTrue);
    expect(settings.defaultOffsetsMinutes, <int>[30]);
    expect(settings.atDue, isTrue);
    expect(settings.overdueEnabled, isFalse);
    expect(settings.overdueAfterMinutes, 60);
    expect(
      settings.morningSummary,
      const MorningSummary(enabled: true, minutes: 420),
    );
    expect(
      settings.quiet,
      const QuietHours(enabled: true, startMinutes: 1380, endMinutes: 360),
    );
    expect(ReminderSettings.eveningNudgeMinutes, 1140);
  });

  test('member settings inherit each missing field from family defaults', () {
    final family = ReminderSettings(
      globalEnabled: false,
      choresEnabled: false,
      bazarEnabled: true,
      familyEnabled: false,
      defaultOffsetsMinutes: const <int>[15, 45],
      atDue: false,
      overdueEnabled: true,
      overdueAfterMinutes: 90,
      morningSummaryEnabled: false,
      morningSummaryMinutes: 510,
      quietEnabled: false,
      quietStartMinutes: 1200,
      quietEndMinutes: 300,
    );
    final inherited = ReminderSettings(
      globalEnabled: true,
      bazarEnabled: false,
      defaultOffsetsMinutes: const <int>[10],
      quietEndMinutes: 330,
    ).inheritFrom(family);

    expect(inherited.globalEnabled, isTrue);
    expect(inherited.choresEnabled, isFalse);
    expect(inherited.bazarEnabled, isFalse);
    expect(inherited.familyEnabled, isFalse);
    expect(inherited.defaultOffsetsMinutes, <int>[10]);
    expect(inherited.atDue, isFalse);
    expect(inherited.overdueEnabled, isTrue);
    expect(inherited.overdueAfterMinutes, 90);
    expect(
      inherited.morningSummary,
      const MorningSummary(enabled: false, minutes: 510),
    );
    expect(
      inherited.quiet,
      const QuietHours(enabled: false, startMinutes: 1200, endMinutes: 330),
    );
  });

  test('turning switches off preserves timing values', () {
    final settings = ReminderSettings(
      globalEnabled: false,
      choresEnabled: false,
      defaultOffsetsMinutes: const <int>[20, 40],
      atDue: false,
      overdueEnabled: true,
      overdueAfterMinutes: 75,
    );

    expect(settings.globalEnabled, isFalse);
    expect(settings.choresEnabled, isFalse);
    expect(settings.defaultOffsetsMinutes, <int>[20, 40]);
    expect(settings.atDue, isFalse);
    expect(settings.overdueEnabled, isTrue);
    expect(settings.overdueAfterMinutes, 75);
  });

  test('copies offsets defensively and has value equality', () {
    final offsets = <int>[20, 40];
    final first = ReminderSettings(defaultOffsetsMinutes: offsets);
    offsets.add(60);
    final second = ReminderSettings(defaultOffsetsMinutes: const <int>[20, 40]);

    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first.defaultOffsetsMinutes, <int>[20, 40]);
    expect(first.copyWith(), first);
    expect(first.copyWith(quietEnabled: false), isNot(first));
  });

  test('quiet hours reject equal and out-of-range boundaries', () {
    expect(
      const QuietHours(
        enabled: true,
        startMinutes: 1380,
        endMinutes: 360,
      ).isValid,
      isTrue,
    );
    expect(
      const QuietHours(enabled: true, startMinutes: 60, endMinutes: 60).isValid,
      isFalse,
    );
    expect(
      const QuietHours(
        enabled: true,
        startMinutes: -1,
        endMinutes: 360,
      ).isValid,
      isFalse,
    );
    expect(
      const QuietHours(
        enabled: true,
        startMinutes: 0,
        endMinutes: 1440,
      ).isValid,
      isFalse,
    );
  });
}
