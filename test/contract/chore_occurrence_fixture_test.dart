import 'dart:convert';
import 'dart:io';

import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_event_mappers.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_mappers.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/chores/chores_test_helpers.dart';

/// P3-13: the JS fixtures in `firebase/rules_test/support.mjs` and the Dart
/// mappers must describe the SAME documents.
///
/// The rules tests use the readable JS fixtures; the contract fixture uses the
/// real mapper.  If one gains a field the other does not, this test fails — the
/// rules could otherwise pass in Node while the app writes a key they reject.
void main() {
  final meta = BaseMapper.createMetadata(
    uid: 'alice',
    clock: FakeClock(DateTime.utc(2026, 10, 24, 9)),
  );

  /// Everything after `export const [symbol] =` up to that definition's own
  /// closing line `});`.
  String bodyOf(String source, String symbol) {
    final start = source.indexOf('export const $symbol');
    expect(start, greaterThan(-1), reason: '$symbol not found');
    final close = RegExp(
      r'^\s*\}\);\s*$',
      multiLine: true,
    ).firstMatch(source.substring(start));
    expect(close, isNotNull, reason: '$symbol never closes');
    return source.substring(start, start + close!.end);
  }

  /// The TOP-LEVEL keys of the fixture's `baseDoc(uid, { … })` map: the lines
  /// indented by exactly four spaces.  The metadata spread and the nested
  /// `subtasks` rows sit deeper (six spaces and more) and are name-checked by
  /// the mapper map itself.
  Set<String> keysOf(String body) => RegExp(
    r'^ {4}([A-Za-z][A-Za-z0-9]*):',
    multiLine: true,
  ).allMatches(body).map((match) => match.group(1)!).toSet();

  /// `BaseMapper.metadataToMap` writes these; the spread inside `baseDoc`
  /// covers them.
  const metadataKeys = <String>{
    BaseMapper.keyCreatedAt,
    BaseMapper.keyCreatedBy,
    BaseMapper.keyUpdatedAt,
    BaseMapper.keyUpdatedBy,
    BaseMapper.keySchemaVersion,
    BaseMapper.keyDeletedAt,
    BaseMapper.keyDeletedBy,
  };

  test('the JS occurrence fixture keys == OccurrenceMappers.toMap keys', () {
    final body = bodyOf(
      File('firebase/rules_test/support.mjs').readAsStringSync(),
      'occurrenceDoc',
    );
    final jsKeys = <String>{...keysOf(body), ...metadataKeys};
    final dartKeys = OccurrenceMappers.toMap(anOccurrence(), meta).keys.toSet();

    expect(jsKeys, isNotEmpty, reason: 'the parser found no keys');
    expect(
      jsKeys.difference(dartKeys),
      isEmpty,
      reason: 'the JS fixture has keys the mapper never writes',
    );
    expect(
      dartKeys.difference(jsKeys),
      isEmpty,
      reason: 'the mapper writes keys the JS fixture lacks',
    );
  });

  test('the JS event fixture keys == OccurrenceEventMappers.toMap keys', () {
    final body = bodyOf(
      File('firebase/rules_test/support.mjs').readAsStringSync(),
      'occurrenceEventDoc',
    );
    final jsKeys = <String>{...keysOf(body), ...metadataKeys};
    final dartKeys = OccurrenceEventMappers.toMap(
      OccurrenceEvent(
        id: 'completed_0',
        occurrenceId: 'tpl_1_20261024',
        type: OccurrenceEventType.completed,
        actorId: 'cara',
        at: DateTime.utc(2026, 10, 24, 4),
      ),
      meta,
    ).keys.toSet();

    expect(jsKeys, isNotEmpty, reason: 'the parser found no keys');
    expect(
      jsKeys.difference(dartKeys),
      isEmpty,
      reason: 'the JS fixture has keys the mapper never writes',
    );
    expect(
      dartKeys.difference(jsKeys),
      isEmpty,
      reason: 'the mapper writes keys the JS fixture lacks',
    );
  });

  test('the generated occurrence fixture is the real mapper output', () {
    final file = File('firebase/rules_test/fixtures/chore_occurrence.json');
    expect(file.existsSync(), isTrue);
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final writes = (json['writes'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final occurrence = writes.firstWhere(
      (w) => '${w['path']}'.contains('/choreOccurrences/'),
    );
    final data = occurrence['data'] as Map<String, dynamic>;
    final path = '${occurrence['path']}';
    expect(path, 'families/fixFam/choreOccurrences/tpl_fixDishes_20261018');
    expect(data['dateKey'], '2026-10-18');
    expect(data['monthKey'], '2026-10');
    // The id's date and the dateKey agree (the rules re-derive one from the
    // other).
    expect(path.endsWith('${data['dateKey']}'.replaceAll('-', '')), isTrue);
    expect(data['status'], 'completed');
    expect(data['subtaskDone'], hasLength(2));
    expect(data['assignmentSource'], 'cover');
  });
}
