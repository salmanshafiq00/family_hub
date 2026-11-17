import 'package:family_hub/core/utils/time_zones.dart';

enum PlannedNotificationKind {
  due,
  before,
  overdue,
  nudge,
  summary,
  contributionDue,
  monthEnd,
}

enum NotificationChannelId {
  choresDue('chores_due_v2', legacyId: 'chores_due'),
  choresOverdue('chores_overdue_v2', legacyId: 'chores_overdue'),
  dailySummary('daily_summary_v2', legacyId: 'daily_summary'),
  bazar('bazar_v2', legacyId: 'bazar'),
  family('family_v2', legacyId: 'family'),
  pushEvents('push_events_v2', legacyId: 'push_events');

  const NotificationChannelId(this.id, {required this.legacyId});

  /// The current Android channel id.
  final String id;

  /// The id used before the custom sound; stored metadata may still name it.
  final String legacyId;

  static NotificationChannelId fromStoredId(String id) => values.firstWhere(
    (channel) => channel.id == id || channel.legacyId == id,
    orElse: () => pushEvents,
  );
}

final class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.kind,
    required this.scheduledAt,
    required this.title,
    required this.body,
    required this.payload,
    required this.refId,
    required this.channelId,
    this.familyTimezone = defaultTimezone,
  });

  final int id;
  final PlannedNotificationKind kind;

  /// Always a UTC instant.
  final DateTime scheduledAt;
  final String title;
  final String body;
  final String payload;
  final String refId;
  final NotificationChannelId channelId;
  final String familyTimezone;

  PlannedNotification copyWith({
    int? id,
    PlannedNotificationKind? kind,
    DateTime? scheduledAt,
    String? title,
    String? body,
    String? payload,
    String? refId,
    NotificationChannelId? channelId,
    String? familyTimezone,
  }) => PlannedNotification(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    title: title ?? this.title,
    body: body ?? this.body,
    payload: payload ?? this.payload,
    refId: refId ?? this.refId,
    channelId: channelId ?? this.channelId,
    familyTimezone: familyTimezone ?? this.familyTimezone,
  );

  @override
  bool operator ==(Object other) =>
      other is PlannedNotification &&
      other.id == id &&
      other.kind == kind &&
      other.scheduledAt == scheduledAt &&
      other.title == title &&
      other.body == body &&
      other.payload == payload &&
      other.refId == refId &&
      other.channelId == channelId &&
      other.familyTimezone == familyTimezone;

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    scheduledAt,
    title,
    body,
    payload,
    refId,
    channelId,
    familyTimezone,
  );
}
