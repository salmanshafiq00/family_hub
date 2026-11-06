import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/utils/bangla_numerals.dart';
import 'package:family_hub/core/utils/time_zones.dart';
import 'package:family_hub/core/notifications/domain/reminder_plan_input.dart';
import 'package:intl/intl.dart' as intl;
import 'package:timezone/timezone.dart' as tz;

final class LocalizedReminderTexts implements ReminderTexts {
  const LocalizedReminderTexts({
    required this.localizations,
    required this.useBanglaDigits,
  });

  final AppLocalizations localizations;
  final bool useBanglaDigits;

  @override
  String choreName(String nameBn, String? nameEn) =>
      localizations.localeName == 'bn' || nameEn == null || nameEn.isEmpty
      ? nameBn
      : nameEn;

  @override
  String formatTime(DateTime instant, String familyTimezone) {
    ensureTimeZonesInitialized();
    final local = tz.TZDateTime.from(
      instant.toUtc(),
      tz.getLocation(familyTimezone),
    );
    return _digits(intl.DateFormat.jm(localizations.localeName).format(local));
  }

  @override
  String dueTitle(String choreName) =>
      localizations.reminderDueTitle(choreName);

  @override
  String dueBody(String choreName, String time) =>
      localizations.reminderDueBody(choreName, time);

  @override
  String beforeTitle(String choreName) =>
      localizations.reminderBeforeTitle(choreName);

  @override
  String beforeBody(String choreName, int offsetMinutes, String time) =>
      localizations.reminderBeforeBody(
        choreName,
        _digits(offsetMinutes.toString()),
        time,
      );

  @override
  String overdueTitle(String choreName) =>
      localizations.reminderOverdueTitle(choreName);

  @override
  String overdueBody(String choreName) =>
      localizations.reminderOverdueBody(choreName);

  @override
  String nudgeTitle() => localizations.reminderNudgeTitle;

  @override
  String nudgeBody(int remainingCount) =>
      localizations.reminderNudgeBody(_digits(remainingCount.toString()));

  @override
  String summaryTitle() => localizations.reminderSummaryTitle;

  @override
  String summaryBody(int choreCount) =>
      localizations.reminderSummaryBody(_digits(choreCount.toString()));

  @override
  String contributionDueTitle() => localizations.reminderContributionDueTitle;

  @override
  String contributionDueBody() => localizations.reminderContributionDueBody;

  @override
  String monthEndTitle() => localizations.reminderMonthEndTitle;

  @override
  String monthEndBody() => localizations.reminderMonthEndBody;

  String _digits(String value) =>
      useBanglaDigits ? toBanglaDigits(value) : value;
}
