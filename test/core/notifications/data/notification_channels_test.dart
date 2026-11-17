import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/notifications/data/notification_channels.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  test('channels use the custom sound resource', () {
    final channels = notificationChannels(
      lookupAppLocalizations(const Locale('en')),
    );

    expect(
      channels.every((channel) => channel.soundName == kNotificationSound),
      isTrue,
    );
  });

  test('stored pre-v2 channel ids still restore', () {
    expect(
      NotificationChannelId.fromStoredId('chores_due'),
      NotificationChannelId.choresDue,
    );
    expect(
      NotificationChannelId.fromStoredId('push_events_v2'),
      NotificationChannelId.pushEvents,
    );
  });

  test('channel ids and names are localized in Bangla and English', () {
    final bangla = notificationChannels(
      lookupAppLocalizations(const Locale('bn')),
    );
    final english = notificationChannels(
      lookupAppLocalizations(const Locale('en')),
    );

    expect(
      bangla.map((channel) => channel.id.id).toList(),
      english.map((channel) => channel.id.id).toList(),
    );
    expect(
      bangla.map((channel) => channel.name).toList(),
      isNot(english.map((channel) => channel.name).toList()),
    );
    expect(bangla.every((channel) => channel.description.isNotEmpty), isTrue);
    expect(english.every((channel) => channel.description.isNotEmpty), isTrue);
  });
}
