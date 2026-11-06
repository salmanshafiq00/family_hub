import 'package:family_hub/core/notifications/domain/reminder_plan_input.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/bazar/contributions/domain/contribution_status.dart';
import 'package:family_hub/features/bazar/settings/domain/bazar_settings.dart';

BazarReminderInput buildBazarReminderInput({
  required DateTime now,
  required String familyTimezone,
  required String viewerId,
  required BazarSettings settings,
  required List<MemberContributionStatus> contributionStatuses,
  required bool canCloseMonth,
  required bool enabled,
}) {
  final today = DateKey.fromInstant(now, timezone: familyTimezone);
  final monthEnd = today.monthKey.endOfMonth;
  final daysUntilMonthEnd = today.daysUntil(monthEnd);
  return BazarReminderInput(
    contributionDueDay: settings.contributionDueDay,
    unpaidThisMonth:
        enabled &&
        contributionStatuses.any(
          (status) => status.memberId == viewerId && status.remaining.paisa > 0,
        ),
    canCloseMonth: enabled && canCloseMonth,
    monthEndKey: enabled && daysUntilMonthEnd <= 7 ? monthEnd : null,
  );
}
