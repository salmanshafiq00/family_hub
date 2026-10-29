import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';

/// Pure functions between [OccurrenceEvent] and
/// `choreOccurrences/{id}/events/{eventId}`.
///
/// Events are append-only: [toMap] writes the whole document, and the rules
/// allow `create` only. The map is the single source of truth for the closed
/// `occurrenceEventKeys()` list and the contract fixture.
abstract final class OccurrenceEventMappers {
  static Map<String, dynamic> toMap(
    OccurrenceEvent event,
    BaseDocumentMetadata meta,
  ) => <String, dynamic>{
    'type': event.type.id,
    'actorId': event.actorId,
    'fromAssigneeId': event.fromAssigneeId,
    'toAssigneeId': event.toAssigneeId,
    'reason': event.reason,
    'prevCompletedAt': BaseMapper.dateTimeToTimestamp(event.prevCompletedAt),
    'redoSubtaskIds': event.redoSubtaskIds,
    'requestId': event.requestId,
    ...BaseMapper.metadataToMap(meta),
  };

  /// Reads one document; null when it is missing or unreadable.
  ///
  /// An unknown `type` (written by a newer build) is dropped instead of
  /// crashing the timeline.
  static OccurrenceEvent? fromDoc(
    String occurrenceId,
    String id,
    Map<String, dynamic>? map,
  ) {
    if (map == null) return null;
    final type = OccurrenceEventType.fromId(map['type']);
    final actorId = map['actorId'];
    if (type == null || actorId is! String || actorId.isEmpty) return null;
    return OccurrenceEvent(
      id: id,
      occurrenceId: occurrenceId,
      type: type,
      actorId: actorId,
      at:
          BaseMapper.timestampToDateTime(map[BaseMapper.keyCreatedAt]) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      fromAssigneeId: _nullableString(map['fromAssigneeId'], 64),
      toAssigneeId: _nullableString(map['toAssigneeId'], 64),
      reason: _nullableString(map['reason'], 300),
      prevCompletedAt: BaseMapper.timestampToDateTime(map['prevCompletedAt']),
      redoSubtaskIds: _stringList(map['redoSubtaskIds'], 30),
      requestId: _nullableString(map['requestId'], 64),
    );
  }

  /// A bounded list of step ids; a malformed row is dropped, never thrown.
  static List<String> _stringList(Object? raw, int max) {
    if (raw is! List) return const <String>[];
    return <String>[
      for (final item in raw)
        if (item is String && item.isNotEmpty && item.length <= 16) item,
    ].take(max).toList(growable: false);
  }

  static String? _nullableString(Object? value, int max) {
    if (value is! String || value.isEmpty) return null;
    return value.length > max ? value.substring(0, max) : value;
  }
}
