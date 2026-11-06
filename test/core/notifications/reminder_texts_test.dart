import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/features/notifications/presentation/reminder_texts.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminder text follows locale and the independent digit preference', () {
    final bangla = LocalizedReminderTexts(
      localizations: lookupAppLocalizations(const Locale('bn')),
      useBanglaDigits: true,
    );
    final english = LocalizedReminderTexts(
      localizations: lookupAppLocalizations(const Locale('en')),
      useBanglaDigits: false,
    );

    expect(bangla.choreName('বাসন', 'Dishes'), 'বাসন');
    expect(bangla.nudgeBody(2), contains('২'));
    expect(english.choreName('বাসন', 'Dishes'), 'Dishes');
    expect(english.nudgeBody(2), contains('2'));
  });
}
