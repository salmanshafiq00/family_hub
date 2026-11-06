import 'package:family_hub/core/notifications/domain/notification_id_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the roadmap FNV-1a 31-bit hash input shape', () {
    expect(NotificationIdFactory.of('due', 'occ_1', 'due'), 1929342016);
    expect(
      NotificationIdFactory.of('due', 'occ_1', 'due'),
      NotificationIdFactory.of('due', 'occ_1', 'due'),
    );
  });

  test('different components produce independent ids', () {
    final id = NotificationIdFactory.of('due', 'occ_1', 'due');
    expect(NotificationIdFactory.of('before', 'occ_1', 'due'), isNot(id));
    expect(NotificationIdFactory.of('due', 'occ_2', 'due'), isNot(id));
    expect(NotificationIdFactory.of('due', 'occ_1', 'before'), isNot(id));
  });

  test('ids are non-negative 31-bit values', () {
    for (final input in <String>[
      '',
      'due',
      'বাংলা',
      List<String>.filled(1000, 'x').join(),
    ]) {
      final id = NotificationIdFactory.of(input, input, input);
      expect(id, inInclusiveRange(0, 0x7fffffff));
    }
  });

  test('collision probing advances until it reserves an unused id', () {
    final used = <int>{NotificationIdFactory.of('due', 'same', 'same')};
    final result = NotificationIdFactory.unique(
      kind: 'due',
      refId: 'same',
      discriminator: 'same',
      usedIds: used,
    );

    expect(result, NotificationIdFactory.of('due', 'same', 'same') + 1);
    expect(used, contains(result));
  });
}
