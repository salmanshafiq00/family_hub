import 'dart:convert';

import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

const String _metadataPrefix = 'local_reminder_metadata_';

final class NotificationChannelDefinition {
  const NotificationChannelDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.highImportance,
    this.soundName,
  });

  final NotificationChannelId id;
  final String name;
  final String description;
  final bool highImportance;

  /// A `res/raw` resource name, or null for the system default sound.
  final String? soundName;
}

final class LocalNotificationRequest {
  const LocalNotificationRequest({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

final class NotificationLaunchDetails {
  const NotificationLaunchDetails({required this.didLaunch, this.payload});

  final bool didLaunch;
  final String? payload;
}

abstract interface class LocalNotificationsDriver {
  Future<bool?> initialize(void Function(String? payload) onTap);

  Future<NotificationLaunchDetails?> launchDetails();

  Future<void> createChannels(List<NotificationChannelDefinition> channels);

  Future<List<LocalNotificationRequest>> pending();

  Future<void> schedule({
    required PlannedNotification notification,
    required NotificationChannelDefinition channel,
    required tz.TZDateTime scheduledAt,
    required bool exact,
  });

  Future<void> show({
    required PlannedNotification notification,
    required NotificationChannelDefinition channel,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<bool> notificationsEnabled();

  Future<bool> exactAlarmsAllowed();

  Future<bool> requestNotifications();

  Future<bool> requestExactAlarms();

  Future<int?> androidSdkVersion();
}

abstract interface class AndroidSettingsIntents {
  Future<void> openBatterySettings();

  Future<void> openExactAlarmSettings();
}

final class LocalReminderMetadataStore {
  const LocalReminderMetadataStore(this._preferences);

  final SharedPreferences _preferences;

  Future<void> save(PlannedNotification notification) async {
    final metadata = jsonEncode(<String, Object>{
      'kind': notification.kind.name,
      'scheduledAt': notification.scheduledAt.toUtc().toIso8601String(),
      'refId': notification.refId,
      'channelId': notification.channelId.id,
      'familyTimezone': notification.familyTimezone,
    });
    final saved = await _preferences.setString(
      _metadataKey(notification.id),
      metadata,
    );
    if (!saved) {
      throw StateError('Failed to store reminder ${notification.id} metadata.');
    }
  }

  Future<void> remove(int id) async {
    await _preferences.remove(_metadataKey(id));
  }

  Future<void> clearAll() async {
    for (final key in _preferences.getKeys().where(
      (key) => key.startsWith(_metadataPrefix),
    )) {
      await _preferences.remove(key);
    }
  }

  PlannedNotification restore(LocalNotificationRequest request) {
    final raw = _preferences.getString(_metadataKey(request.id));
    if (raw == null) {
      throw StateError(
        'Scheduled notification ${request.id} has no saved metadata.',
      );
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid metadata for notification ${request.id}.');
    }
    return PlannedNotification(
      id: request.id,
      kind: PlannedNotificationKind.values.byName(decoded['kind'] as String),
      scheduledAt: DateTime.parse(decoded['scheduledAt'] as String).toUtc(),
      title: request.title ?? '',
      body: request.body ?? '',
      payload: request.payload ?? '',
      refId: decoded['refId'] as String,
      channelId: NotificationChannelId.fromStoredId(
        decoded['channelId'] as String,
      ),
      familyTimezone: decoded['familyTimezone'] as String,
    );
  }

  static String _metadataKey(int id) => '$_metadataPrefix$id';
}
