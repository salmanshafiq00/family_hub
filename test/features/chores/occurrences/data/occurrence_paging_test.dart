import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_paging.dart';
import 'package:flutter_test/flutter_test.dart';

/// A stand-in for one Firestore document, ordered exactly like the query.
final class _Row {
  const _Row(this.dateKey, this.id);

  final DateKey dateKey;
  final String id;
}

int _compare(_Row a, _Row b) {
  final byDay = a.dateKey.toString().compareTo(b.dateKey.toString());
  return byDay != 0 ? byDay : a.id.compareTo(b.id);
}

/// Serves [rows] the way Firestore does: everything strictly after the cursor,
/// in query order, at most [limit] documents.
OccurrencePageReader<String> _readerFor(List<_Row> rows) =>
    (after, limit) async {
      final start = after == null
          ? 0
          : rows.indexWhere(
                  (row) =>
                      row.dateKey.toString() == after.dateKey &&
                      row.id == after.id,
                ) +
                1;
      final window = rows.skip(start).take(limit).toList();
      return OccurrencePage<String>(
        items: <String>[for (final row in window) row.id],
        next: window.length < limit
            ? null
            : OccurrenceCursor(
                dateKey: window.last.dateKey.toString(),
                id: window.last.id,
              ),
      );
    };

/// B-09: a paged query must resume after the whole `(dateKey, id)` position,
/// never after the day alone.
void main() {
  test('B-09: 1,000 documents, three per day, page size 400', () async {
    // Three slots on each day: every page boundary falls INSIDE a day, which is
    // exactly where a day-only cursor used to lose documents.
    final rows = <_Row>[
      for (var day = 0; day < 334; day++)
        for (var slot = 0; slot < 3; slot++)
          _Row(DateKey(2026, 1, 1).addDays(day), 'tpl_${day}_$slot'),
    ].take(1000).toList()..sort(_compare);

    final ids = await readAllOccurrencePages<String>(
      pageSize: 400,
      read: _readerFor(rows),
    );

    expect(ids, hasLength(1000));
    expect(ids.toSet(), hasLength(1000), reason: 'no document is repeated');
    expect(ids, <String>[for (final row in rows) row.id]);
  });

  test('B-09: the read stops on the first short page', () async {
    final rows = <_Row>[
      for (var day = 0; day < 4; day++)
        for (var slot = 0; slot < 2; slot++)
          _Row(DateKey(2026, 1, 1).addDays(day), 'd${day}_$slot'),
    ];
    var calls = 0;

    final ids = await readAllOccurrencePages<String>(
      pageSize: 5,
      read: (after, limit) {
        calls++;
        return _readerFor(rows)(after, limit);
      },
    );

    expect(calls, 2);
    expect(ids, hasLength(8));
  });
}
