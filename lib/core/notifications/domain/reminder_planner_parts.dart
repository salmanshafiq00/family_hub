part of 'reminder_planner.dart';

bool _eligible(PlannableChore item, String viewerId, DateTime now) =>
    item.assigneeId == viewerId &&
    item.isOpen &&
    !item.isUnavailable &&
    !(item.isProjected && item.dueAt.toUtc().isBefore(now));

void _addSummaries(
  PlanInput input,
  List<PlannableChore> eligibleItems,
  DateTime now,
  DateTime windowEnd,
  tz.Location location,
  List<ReminderCandidate> candidates,
) {
  final settings = input.settings;
  if (!settings.globalEnabled ||
      !settings.choresEnabled ||
      !settings.morningSummary.enabled ||
      !_isNormal(input, 'morning_summary')) {
    return;
  }

  final today = DateKey.fromInstant(now, timezone: input.familyTz);
  for (var day = 0; day <= input.windowDays; day++) {
    final date = today.addDays(day);
    final dueCount = eligibleItems.where((item) {
      return DateKey.fromInstant(item.dueAt, timezone: input.familyTz) == date;
    }).length;
    if (dueCount == 0) continue;
    final at = _atMinutes(date, settings.morningSummary.minutes, location);
    if (at.isAfter(windowEnd)) continue;
    candidates.add(
      ReminderCandidate(
        kind: PlannedNotificationKind.summary,
        at: at,
        refId: date.toString(),
        discriminator: 'summary',
        title: input.texts.summaryTitle(),
        body: input.texts.summaryBody(dueCount),
        payload: '/chores/today',
        channelId: NotificationChannelId.dailySummary,
      ),
    );
  }
}

void _addBazarReminders(
  PlanInput input,
  DateTime now,
  DateTime windowEnd,
  tz.Location location,
  List<ReminderCandidate> candidates,
) {
  if (!input.settings.globalEnabled || !input.settings.bazarEnabled) return;
  final today = DateKey.fromInstant(now, timezone: input.familyTz);
  final end = DateKey.fromInstant(windowEnd, timezone: input.familyTz);
  for (var date = today; date.compareTo(end) <= 0; date = date.addDays(1)) {
    final bazar = input.bazar;
    if (bazar.unpaidThisMonth &&
        date.year == today.year &&
        date.month == today.month &&
        (date.day == bazar.contributionDueDay - 1 ||
            date.day == bazar.contributionDueDay) &&
        _isNormal(input, 'contribution_due')) {
      candidates.add(
        ReminderCandidate(
          kind: PlannedNotificationKind.contributionDue,
          at: _atMinutes(date, 9 * 60, location),
          refId: date.toString(),
          discriminator: 'contribution_due',
          title: input.texts.contributionDueTitle(),
          body: input.texts.contributionDueBody(),
          payload: '/bazar/fund',
          channelId: NotificationChannelId.bazar,
        ),
      );
    }

    if (bazar.canCloseMonth &&
        bazar.monthEndKey == date &&
        _isNormal(input, 'month_end')) {
      candidates.add(
        ReminderCandidate(
          kind: PlannedNotificationKind.monthEnd,
          at: _atMinutes(date, 18 * 60, location),
          refId: date.toString(),
          discriminator: 'month_end',
          title: input.texts.monthEndTitle(),
          body: input.texts.monthEndBody(),
          payload: '/bazar/fund',
          channelId: NotificationChannelId.bazar,
        ),
      );
    }
  }
}

void _addIfNormal(
  PlanInput input,
  List<ReminderCandidate> candidates, {
  required String notificationTypeId,
  required ReminderCandidate candidate,
}) {
  if (_isNormal(input, notificationTypeId)) candidates.add(candidate);
}

bool _isNormal(PlanInput input, String typeId) =>
    input.effectiveModes[typeId] != DeliveryMode.push;

tz.Location _location(String timezone) {
  ensureTimeZonesInitialized();
  return tz.getLocation(timezone);
}

DateTime _atMinutes(DateKey date, int minutes, tz.Location location) =>
    tz.TZDateTime(
      location,
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    ).toUtc();

DateTime _moveOutOfQuietHours(
  DateTime instant,
  QuietHours quiet,
  tz.Location location,
) {
  if (!quiet.enabled || !quiet.isValid) return instant;
  final local = tz.TZDateTime.from(instant.toUtc(), location);
  final minute = local.hour * 60 + local.minute;
  final inQuietHours = quiet.startMinutes < quiet.endMinutes
      ? minute >= quiet.startMinutes && minute < quiet.endMinutes
      : minute >= quiet.startMinutes || minute < quiet.endMinutes;
  if (!inQuietHours) return instant;

  final targetDate =
      quiet.startMinutes > quiet.endMinutes && minute >= quiet.startMinutes
      ? DateKey(local.year, local.month, local.day).addDays(1)
      : DateKey(local.year, local.month, local.day);
  return _atMinutes(targetDate, quiet.endMinutes, location);
}
