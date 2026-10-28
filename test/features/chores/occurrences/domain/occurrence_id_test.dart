import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_id.dart';
import 'package:flutter_test/flutter_test.dart';

/// P3-11 / D-P3-3: the occurrence id is rebuilt from its parts and parsed back.
void main() {
  final day = DateKey(2026, 10, 24);

  test('the main slot has no suffix', () {
    expect(OccurrenceId.of('tpl_1', day).value, 'tpl_1_20261024');
    expect(
      OccurrenceId.of('tpl_1', day, slotKey: 'main').value,
      'tpl_1_20261024',
    );
  });

  test('another slot appends its key', () {
    expect(
      OccurrenceId.of('tpl_1', day, slotKey: 'noon').value,
      'tpl_1_20261024_noon',
    );
  });

  test('parse round-trips a template id that contains underscores', () {
    final id = OccurrenceId.of('tpl_dishes', day, slotKey: 'noon');
    final parsed = OccurrenceId.parse(id.value).valueOrNull!;

    expect(parsed.templateId, 'tpl_dishes');
    expect(parsed.dateKey, day);
    expect(parsed.slotKey, 'noon');
    expect(parsed, id);
  });

  test('parse reads a main-slot id', () {
    final parsed = OccurrenceId.parse('tpl_1_20261024').valueOrNull!;
    expect(parsed.slotKey, isNull);
    expect(parsed.dateKey, day);
  });

  test('a "_main" suffix reads as the canonical main id', () {
    final parsed = OccurrenceId.parse('tpl_1_20261024_main').valueOrNull!;
    expect(parsed.slotKey, isNull);
    expect(parsed.value, 'tpl_1_20261024');
  });

  test('parse rejects malformed ids', () {
    const bad = <String>[
      '',
      'tpl_1',
      'tpl_1_20261340',
      'tpl_1_20261024_',
      'tpl_1_20261024_Noon',
      'tpl_1_20261024_way_too_long_slot',
      '_20261024',
    ];
    for (final raw in bad) {
      expect(
        OccurrenceId.parse(raw).failureOrNull,
        isNotNull,
        reason: 'accepted "$raw"',
      );
    }
  });
}
