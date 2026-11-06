abstract final class NotificationIdFactory {
  static const int _mask32 = 0xffffffff;
  static const int _mask31 = 0x7fffffff;

  static int of(String kind, String refId, String discriminator) {
    final input = '$kind|$refId|$discriminator';
    var hash = 0x811c9dc5;
    for (final codeUnit in input.codeUnits) {
      hash = ((hash ^ codeUnit) * 0x01000193) & _mask32;
    }
    return hash & _mask31;
  }

  static int unique({
    required String kind,
    required String refId,
    required String discriminator,
    required Set<int> usedIds,
  }) {
    var id = of(kind, refId, discriminator);
    while (!usedIds.add(id)) {
      id = (id + 1) & _mask31;
    }
    return id;
  }
}
