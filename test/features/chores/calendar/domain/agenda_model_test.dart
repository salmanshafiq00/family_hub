import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/agenda_model.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_month_model.dart';
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
    CalendarFilters filters = CalendarFilters.none,
  }) => AgendaModel.build(
    items: items,
    today: kToday,
    from: from ?? kToday,
    to: to ?? kToday.addDays(6),
    scope: scope,
    filters: filters,
    viewerId: 'cara',
  );

  AgendaDay dayOf(AgendaModel model, DateKey day) => model.entries
      .whereType<AgendaDay>()
      .firstWhere((entry) => entry.dateKey == day);

  List<String> idsOn(AgendaModel model, int offset) => dayOf(
    model,
    kToday.addDays(offset),
  ).items.map((item) => item.id).toList();

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

  test('only TODAY\'s overdue is pinned; older ones stay under their date', () {
    final model = build(
      [
        aChoreItem('old', kToday.addDays(-3), status: ChoreStatus.overdue),
        aChoreItem('newer', kToday.addDays(-1), status: ChoreStatus.overdue),
        aChoreItem('grace', kToday.addDays(-1)),
        aChoreItem('done', kToday.addDays(-1), status: ChoreStatus.completed),
        aChoreItem('now', kToday, status: ChoreStatus.overdue),
        aChoreItem('later', kToday.addDays(1)),
      ],
      from: kToday.addDays(-3),
      to: kToday.addDays(1),
    );
    final overdue = model.entries.first as AgendaOverdue;
    expect(overdue.items.map((i) => i.id), ['now']);

    expect(idsOn(model, -3), ['old']);
    expect(idsOn(model, -1), ['done', 'grace', 'newer']);
    expect(idsOn(model, 1), ['later']);
  });

  test('today\'s overdue is in the block, not repeated in today\'s list', () {
    final model = build([
      aChoreItem('now', kToday, status: ChoreStatus.overdue),
    ]);
    expect(model.overdue!.items.single.id, 'now');
    expect(dayOf(model, kToday).items, isEmpty);
  });

  test('no overdue today: no block even with overdue chores on past days', () {
    final model = build(
      [aChoreItem('old', kToday.addDays(-2), status: ChoreStatus.overdue)],
      from: kToday.addDays(-2),
      to: kToday,
    );
    expect(model.overdue, isNull);
    expect(idsOn(model, -2), ['old']);
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

  group('filters keep the date-wise layout (FIX-5)', () {
    List<ChoreItem> mixed() => [
      aChoreItem(
        'd5',
        kToday.addDays(-5),
        status: ChoreStatus.overdue,
        assignee: 'cara',
      ),
      aChoreItem(
        'd2',
        kToday.addDays(-2),
        status: ChoreStatus.overdue,
        assignee: 'cara',
      ),
      aChoreItem(
        'done',
        kToday.addDays(-2),
        status: ChoreStatus.completed,
        assignee: 'dave',
        groupId: 'bathroom',
      ),
      aChoreItem('now', kToday, status: ChoreStatus.overdue, assignee: 'cara'),
    ];

    void expectOverdueUnderTheirDates(AgendaModel model) {
      expect(model.overdue, isNull, reason: 'a status filter hides the block');
      expect(idsOn(model, -5), ['d5']);
      expect(idsOn(model, -2), ['d2']);
      expect(idsOn(model, 0), ['now']);
      expect(
        model.entries.whereType<AgendaFreeDays>(),
        isNotEmpty,
        reason: 'a day without a match collapses to a free-day chip',
      );
    }

    test('a status filter lists matching chores under their own dates', () {
      final model = build(
        mixed(),
        from: kToday.addDays(-5),
        to: kToday,
        filters: const CalendarFilters(
          statuses: <ChoreStatus>{ChoreStatus.overdue},
        ),
      );
      expectOverdueUnderTheirDates(model);
    });

    test('a group filter and a member filter give the same shape', () {
      for (final filters in <CalendarFilters>[
        const CalendarFilters(groupIds: <String>{'kitchen'}),
        const CalendarFilters(memberIds: <String>{'cara'}),
      ]) {
        final model = build(
          mixed(),
          from: kToday.addDays(-5),
          to: kToday,
          filters: filters,
        );
        expect(model.overdue, isNull);
        expect(idsOn(model, -5), ['d5']);
        expect(idsOn(model, -2), ['d2']);
        expect(idsOn(model, 0), ['now']);
      }
    });

    test('mine scope and a status filter combine with AND', () {
      final model = build(
        <ChoreItem>[
          ...mixed(),
          aChoreItem(
            'dave_overdue',
            kToday.addDays(-2),
            status: ChoreStatus.overdue,
            assignee: 'dave',
          ),
        ],
        from: kToday.addDays(-5),
        to: kToday,
        scope: CalendarScope.mine,
        filters: const CalendarFilters(
          statuses: <ChoreStatus>{ChoreStatus.overdue},
        ),
      );
      expect(idsOn(model, -2), ['d2']);
      expect(model.overdue, isNull);
    });

    test('the agenda and the month grid agree on a filtered October', () {
      const filters = CalendarFilters(
        statuses: <ChoreStatus>{ChoreStatus.overdue},
      );
      final items = <ChoreItem>[
        for (var day = 1; day <= 31; day++)
          aChoreItem(
            'o$day',
            DateKey(2026, 10, day),
            status: day.isEven ? ChoreStatus.completed : ChoreStatus.overdue,
          ),
      ];
      final agenda = AgendaModel.build(
        items: items,
        today: kToday,
        from: DateKey(2026, 10, 1),
        to: DateKey(2026, 10, 31),
        filters: filters,
        viewerId: 'cara',
      );
      final month = CalendarMonthModel.build(
        month: MonthKey(2026, 10),
        weekStartDay: DateTime.saturday,
        items: items,
        today: kToday,
        filters: filters,
        viewerId: 'cara',
      );

      final agendaTotal = agenda.entries.whereType<AgendaDay>().fold<int>(
        0,
        (sum, day) => sum + day.items.length,
      );
      final monthTotal = month.days
          .where((day) => !day.isOutsideMonth)
          .fold<int>(0, (sum, day) => sum + day.total);

      expect(agendaTotal, 16);
      expect(monthTotal, agendaTotal);
    });
  });
}
