import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/agenda_model.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar_test_support.dart';

void main() {
  AgendaModel build(
    List<ChoreItem> items, {
    DateKey? from,
    DateKey? to,
    CalendarScope scope = CalendarScope.all,
  }) => AgendaModel.build(
    items: items,
    today: kToday,
    from: from ?? kToday,
    to: to ?? kToday.addDays(6),
    scope: scope,
    viewerId: 'cara',
  );

  test('no chores: today stays, the rest collapses into free days', () {
    final model = build(const []);
    expect(model.overdue, isNull);
    expect(model.entries.length, 2);
    final today = model.entries.first as AgendaDay;
    expect(today.isToday, isTrue);
    expect(today.items, isEmpty);
    final free = model.entries.last as AgendaFreeDays;
    expect(free.from, kToday.addDays(1));
    expect(free.to, kToday.addDays(6));
    expect(free.count, 6);
  });

  test('empty days between busy days collapse into one run', () {
    final model = build([
      aChoreItem('a', kToday.addDays(1)),
      aChoreItem('b', kToday.addDays(4)),
    ]);
    final kinds = model.entries.map((e) => e.runtimeType).toList();
    expect(kinds, [
      AgendaDay, // today
      AgendaDay, // +1
      AgendaFreeDays, // +2, +3
      AgendaDay, // +4
      AgendaFreeDays, // +5, +6
    ]);
    expect((model.entries[2] as AgendaFreeDays).count, 2);
  });

  test('overdue is pinned first, newest first, and never repeated in a day',
      () {
    final model = build(
      [
        aChoreItem('old', kToday.addDays(-3), status: ChoreStatus.overdue),
        aChoreItem('newer', kToday.addDays(-1), status: ChoreStatus.overdue),
        aChoreItem('grace', kToday.addDays(-1)),
        aChoreItem('done', kToday.addDays(-1), status: ChoreStatus.completed),
        aChoreItem('later', kToday.addDays(1)),
      ],
      from: kToday.addDays(-2),
      to: kToday.addDays(1),
    );
    final overdue = model.entries.first as AgendaOverdue;
    expect(overdue.items.map((i) => i.id), ['grace', 'newer', 'old']);
    expect(overdue.total, 3);
    expect(overdue.hasMore, isFalse);

    final yesterday = model.entries.whereType<AgendaDay>().firstWhere(
      (d) => d.dateKey == kToday.addDays(-1),
    );
    expect(yesterday.items.map((i) => i.id), ['done']);
  });

  test('a chore overdue today stays in today, not in the overdue block', () {
    final model = build([
      aChoreItem('now', kToday, status: ChoreStatus.overdue),
    ]);
    expect(model.overdue, isNull);
    expect((model.entries.first as AgendaDay).items.single.id, 'now');
  });

  test('the overdue block is capped with a total for "see all"', () {
    final model = build([
      for (var i = 0; i < 130; i++)
        aChoreItem(
          'o$i',
          kToday.addDays(-1 - i % 20),
          status: ChoreStatus.overdue,
        ),
    ]);
    final overdue = model.overdue!;
    expect(overdue.items.length, AgendaModel.overdueCap);
    expect(overdue.total, 130);
    expect(overdue.hasMore, isTrue);
  });

  test('mine scope drops other people\'s chores and their free days merge', () {
    final model = build([
      aChoreItem('other', kToday.addDays(2), assignee: 'dave'),
    ], scope: CalendarScope.mine);
    expect(model.entries.whereType<AgendaDay>().length, 1);
    expect(model.entries.last, isA<AgendaFreeDays>());
    expect((model.entries.last as AgendaFreeDays).count, 6);
  });

  test('indexOfDay finds a day inside a free run and a missing day', () {
    final model = build([aChoreItem('a', kToday.addDays(1))]);
    expect(model.indexOfDay(kToday), 0);
    expect(model.indexOfDay(kToday.addDays(3)), model.entries.length - 1);
    expect(model.indexOfDay(kToday.addDays(30)), isNull);
  });

  test('a reversed range lists nothing but a pinned overdue block', () {
    final model = build(const [], from: kToday.addDays(3), to: kToday);
    expect(model.entries, isEmpty);
  });

  test('a runaway range is cut at the maximum', () {
    final model = build(const [], to: kToday.addDays(5000));
    final free = model.entries.last as AgendaFreeDays;
    expect(free.count, AgendaModel.maxDays - 1);
  });
}
