import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/money.dart';
import 'package:family_hub/features/bazar/contributions/domain/contribution_status.dart';
import 'package:family_hub/features/bazar/presentation/bazar_reminder_input.dart';
import 'package:family_hub/features/bazar/settings/domain/bazar_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the viewer contribution and only includes a nearby month end', () {
    final input = buildBazarReminderInput(
      now: DateTime.utc(2026, 11, 25),
      familyTimezone: 'Asia/Dhaka',
      viewerId: 'me',
      settings: const BazarSettings(contributionDueDay: 7),
      contributionStatuses: <MemberContributionStatus>[
        _status('me', 1),
        _status('other', 100),
      ],
      canCloseMonth: true,
      enabled: true,
    );

    expect(input.contributionDueDay, 7);
    expect(input.unpaidThisMonth, isTrue);
    expect(input.canCloseMonth, isTrue);
    expect(input.monthEndKey, DateKey(2026, 11, 30));
  });

  test('disables all Bazar reminders when the module is disabled', () {
    final input = buildBazarReminderInput(
      now: DateTime.utc(2026, 11, 25),
      familyTimezone: 'Asia/Dhaka',
      viewerId: 'me',
      settings: BazarSettings.defaults,
      contributionStatuses: <MemberContributionStatus>[_status('me', 1)],
      canCloseMonth: true,
      enabled: false,
    );

    expect(input.unpaidThisMonth, isFalse);
    expect(input.canCloseMonth, isFalse);
    expect(input.monthEndKey, isNull);
  });
}

MemberContributionStatus _status(String memberId, int remainingPaisa) =>
    MemberContributionStatus(
      memberId: memberId,
      expected: Money.paisa(remainingPaisa),
      received: Money.zero,
      remaining: Money.paisa(remainingPaisa),
      credit: Money.zero,
      pendingTotal: Money.zero,
    );
