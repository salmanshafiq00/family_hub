import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The composition root must override every provider that is declared as
/// throwing [UnimplementedError] until overridden — Riverpod only fails when
/// the missed provider is first read, which is how a missing
/// `choreSettingsRepositoryProvider` override broke saving a chore.
void main() {
  test('bootstrap overrides every provider that must be overridden', () {
    final bootstrap = File('lib/app/bootstrap.dart').readAsStringSync();
    final declaration = RegExp(
      r'final\s+(\w+Provider)\s*=\s*Provider\s*<[^;]*?UnimplementedError',
      multiLine: true,
    );

    final missing = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      for (final match in declaration.allMatches(entity.readAsStringSync())) {
        final name = match.group(1)!;
        if (!bootstrap.contains('$name.overrideWithValue')) {
          missing.add('$name (${entity.path})');
        }
      }
    }

    expect(
      missing,
      isEmpty,
      reason:
          'Providers that throw UnimplementedError must be overridden in '
          'lib/app/bootstrap.dart:\n${missing.join('\n')}',
    );
  });
}
