import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/week_model.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/day_part.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar_test_support.dart';

void main() {
  WeekModel build(
    List<ChoreItem> items, {
    DateKey? anchor,
    int weekStart = 6,
    CalendarScope scope = CalendarScope.all,
    CalendarFilters filters = CalendarFilters.none,
  }) => WeekModel.build(
    anchor: anchor ?? kToday,
    weekStartDay: weekStart,
    items: items,
    today: kToday,
    scope: scope,
    viewerId: 'cara',
    filters: filters,
  );

  test('a Saturday-start week runs Saturday to Friday', () {
    final model = build(const [], anchor: DateKey(2026, 10, 28));
    expect(model.range.start, DateKey(2026, 10, 24));
    expect(model.range.end, DateKey(2026, 10, 30));
    expect(model.days.length, 7);
    expect(model.days.first.summary.isToday, isTrue);
  });

  test('Sunday and Monday starts move the range', () {
    expect(
      build(const [], anchor: DateKey(2026, 10, 28), weekStart: 7).range.start,
      DateKey(2026, 10, 25),
    );
    expect(
      build(const [], anchor: DateKey(2026, 10, 28), weekStart: 1).range.start,
      DateKey(2026, 10, 26),
    );
  });

  test('a week across a month border keeps every day real', () {
    final model = build(
      [
        aChoreItem('a', DateKey(2026, 10, 31)),
        aChoreItem('b', DateKey(2026, 11, 1)),
      ],
      anchor: DateKey(2026, 10, 31),
    );
    expect(model.dayOf(DateKey(2026, 10, 31))!.summary.total, 1);
    expect(model.dayOf(DateKey(2026, 11, 1))!.summary.total, 1);
    expect(model.days.any((d) => d.summary.isOutsideMonth), isFalse);
  });

  test('items are in deadline order and grouped by day part', () {
    final day = DateKey(2026, 10, 25);
    final model = build([
      aChoreItem('late', day, dueMinutes: 1200).copyWith(
        dueAt: DateTime.utc(2026, 10, 25, 14),
      ),
      aChoreItem('early', day, dueMinutes: 540).copyWith(
        dueAt: DateTime.utc(2026, 10, 25, 3),
      ),
      aChoreItem('none', day, dueMinutes: null).copyWith(
        dueAt: DateTime.utc(2026, 10, 25, 17, 59),
      ),
    ]);
    final entry = model.dayOf(day)!;
    expect(entry.items.map((i) => i.id), ['early', 'late', 'none']);
    expect(entry.parts.map((p) => p.$1), [
      ChoreDayPart.morning,
      ChoreDayPart.night,
    ]);
    expect(entry.parts.last.$2.map((i) => i.id), ['late', 'none']);
  });

  test('items outside the week are ignored', () {
    final model = build([aChoreItem('a', DateKey(2026, 11, 20))]);
    expect(model.days.every((d) => d.summary.total == 0), isTrue);
  });

  test('scope and filters apply like in the month model', () {
    final day = DateKey(2026, 10, 26);
    final items = [
      aChoreItem('mine', day),
      aChoreItem('other', day, assignee: 'dave'),
    ];
    expect(build(items, scope: CalendarScope.mine).dayOf(day)!.items.length, 1);
    expect(
      build(
        items,
        filters: const CalendarFilters(memberIds: {'dave'}),
      ).dayOf(day)!.items.single.id,
      'other',
    );
  });

  test('dayOf is null outside the week', () {
    expect(build(const []).dayOf(DateKey(2026, 12, 1)), isNull);
  });
}
