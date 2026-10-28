import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/templates/domain/template_enums.dart';

/// The one TOLERANT reader for the stored `rotation` map.
///
/// A template may carry its own rotation and every duty group does, so the
/// shape ([Rotation] / [RotationVersion]) is shared and this parser must be too:
/// two copies would drift the day a version gains a field. `Rotation.toMap` is
/// the writer.
///
/// Reading never throws. An unknown `cycleUnit` falls back to `week`, a version
/// with an unreadable date is dropped, and a list longer than
/// [TemplateLimits.maxRotationVersions] is cut. The rules and the validators
/// reject such documents on write; the reader only has to keep the screen
/// usable and never crash on a document a newer build wrote.
abstract final class RotationMappers {
  /// `null` when [raw] is not a map or no version could be read.
  static Rotation? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final versions = raw['versions'];
    if (versions is! List) return null;
    final parsed = <RotationVersion>[];
    for (final item in versions) {
      if (parsed.length == TemplateLimits.maxRotationVersions) break;
      if (item is! Map) continue;
      final from = _date(item['from']);
      final anchor = _date(item['anchorDate']);
      final members = item['members'];
      if (from == null || anchor == null || members is! List) continue;
      parsed.add(
        RotationVersion(
          from: from,
          anchorDate: anchor,
          members: <String>[
            for (final member in members)
              if (member is String && member.isNotEmpty) member,
          ],
          anchorIndex: _int(item['anchorIndex']),
          cycleUnit: CycleUnit.fromId(item['cycleUnit']),
          weekStartDay: _intIn(item['weekStartDay'], 1, 7) ?? 6,
        ),
      );
    }
    return parsed.isEmpty ? null : Rotation(versions: parsed);
  }

  static int _int(Object? value) => value is num ? value.toInt() : 0;

  static int? _intIn(Object? value, int min, int max) {
    if (value is! num) return null;
    final asInt = value.toInt();
    if (asInt < min || asInt > max) return null;
    return asInt;
  }

  static DateKey? _date(Object? value) {
    if (value is! String) return null;
    return DateKey.parse(value).valueOrNull;
  }
}
