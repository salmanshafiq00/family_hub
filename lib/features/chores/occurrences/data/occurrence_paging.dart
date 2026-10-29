/// One `(dateKey, documentId)` position in a keyset-paginated occurrence query.
///
/// The day alone is NOT a position: a template with slots writes several
/// documents per day, so a cursor of only `dateKey` can skip the rest of a day
/// when a page ends in the middle of it (B-09).
final class OccurrenceCursor {
  const OccurrenceCursor({required this.dateKey, required this.id});

  final String dateKey;
  final String id;

  @override
  bool operator ==(Object other) =>
      other is OccurrenceCursor && other.dateKey == dateKey && other.id == id;

  @override
  int get hashCode => Object.hash(dateKey, id);

  @override
  String toString() => '$dateKey/$id';
}

/// One page of a query ordered by `dateKey`, then by document id.
///
/// [next] is the cursor of the last RAW document on the page and is null on the
/// last (short) page. A document that cannot be mapped still advances the
/// cursor, so one unreadable row never stalls the read.
final class OccurrencePage<T> {
  const OccurrencePage({required this.items, required this.next});

  final List<T> items;
  final OccurrenceCursor? next;
}

/// Reads one page strictly after [after], at most [limit] documents.
///
/// The reader must apply the SAME [limit] it is given: the loop decides "this
/// was the last page" from a short page, so two different page sizes would
/// disagree (B-09).
typedef OccurrencePageReader<T> = Future<OccurrencePage<T>> Function(
  OccurrenceCursor? after,
  int limit,
);

/// Reads every page of a `dateKey` + document-id keyset query.
///
/// Resuming after the whole `(dateKey, id)` pair (not the day alone) keeps every
/// document that shares a day with a page boundary exactly once (B-09).
Future<List<T>> readAllOccurrencePages<T>({
  required int pageSize,
  required OccurrencePageReader<T> read,
}) async {
  final all = <T>[];
  OccurrenceCursor? after;
  while (true) {
    final page = await read(after, pageSize);
    all.addAll(page.items);
    final next = page.next;
    if (next == null) return all;
    if (next == after) {
      throw StateError('paging did not advance past $after');
    }
    after = next;
  }
}

/// Documents per one-shot page (generation, regeneration, replan).
const int kOccurrencePageSize = 400;
