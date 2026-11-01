import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_month_model.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/templates/domain/template_enums.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar_test_support.dart';

void main() {
  final october = MonthKey(2026, 10);

  CalendarMonthModel build(
    List<ChoreItem> items, {
    MonthKey? month,
    int weekStart = 6,
    CalendarScope scope = CalendarScope.all,
    String? viewer = 'cara',
    CalendarFilters filters = CalendarFilters.none,
    AvailabilityIndex availability = AvailabilityIndex.empty,
    HeatMode heat = HeatMode.off,
    DateKey? today,
    bool truncated = false,
  }) => CalendarMonthModel.build(
    month: month ?? october,
    weekStartDay: weekStart,
    items: items,
    today: today ?? kToday,
    scope: scope,
    viewerId: viewer,
    filters: filters,
    availability: availability,
    heatMode: heat,
    truncated: truncated,
  );

  group('grid shape', () {
    test('Saturday start: October 2026 has 6 rows starting Saturday 26 Sep',
        () {
      final model = build(const []);
      expect(model.weeks.length, 6);
      expect(model.weeks.first.first.dateKey, DateKey(2026, 9, 26));
      expect(model.weeks.last.last.dateKey, DateKey(2026, 11, 6));
      expect(model.weeks.every((week) => week.length == 7), isTrue);
    });

    test('Sunday and Monday starts give 5 rows', () {
      expect(build(const [], weekStart: 7).weeks.length, 5);
      expect(build(const [], weekStart: 1).weeks.length, 5);
      expect(
        build(const [], weekStart: 7).weeks.first.first.dateKey,
        DateKey(2026, 9, 27),
      );
    });

    test('every first cell falls on the configured weekday', () {
      for (var start = 1; start <= 7; start++) {
        final first = build(const [], weekStart: start).weeks.first.first;
        expect(first.dateKey.isoWeekday, start, reason: 'start $start');
      }
    });

    test('February 2028 has 29 days inside the month', () {
      final model = build(const [], month: MonthKey(2028, 2), weekStart: 1);
      final inside = model.days.where((d) => !d.isOutsideMonth).toList();
      expect(inside.length, 29);
      expect(inside.last.dateKey, DateKey(2028, 2, 29));
    });

    test('cells are contiguous with no gaps', () {
      final days = build(const []).days;
      for (var i = 1; i < days.length; i++) {
        expect(days[i - 1].dateKey.daysUntil(days[i].dateKey), 1);
      }
    });
  });

  group('empty and today', () {
    test('an empty month has empty cells and no truncation', () {
      final model = build(const []);
      expect(model.days.every((d) => d.isEmpty && d.markers.extra == 0), true);
      expect(model.truncated, isFalse);
      expect(model.totalInMonth, 0);
    });

    test('today is marked, also when it lies outside the month', () {
      final model = build(const [], today: DateKey(2026, 10, 24));
      expect(model.summaryOf(DateKey(2026, 10, 24))!.isToday, isTrue);
      expect(model.days.where((d) => d.isToday).length, 1);

      final november = build(
        const [],
        month: MonthKey(2026, 11),
        today: DateKey(2026, 10, 31),
      );
      final outside = november.summaryOf(DateKey(2026, 10, 31))!;
      expect(outside.isOutsideMonth, isTrue);
      expect(outside.isToday, isTrue);
    });

    test('truncated is passed through', () {
      expect(build(const [], truncated: true).truncated, isTrue);
    });
  });

  group('items', () {
    test('counts, markers and flags of one day', () {
      final day = DateKey(2026, 10, 25);
      final model = build([
        aChoreItem('a', day),
        aChoreItem('b', day, status: ChoreStatus.overdue, needsCover: true),
        aChoreItem('c', day, status: ChoreStatus.completed, needsAttention: true),
      ]);
      final summary = model.summaryOf(day)!;
      expect(summary.total, 3);
      expect(summary.countOf(ChoreStatus.overdue), 1);
      expect(summary.countOf(ChoreStatus.verified), 0);
      expect(summary.markers.markers.first, ChoreStatus.overdue);
      expect(summary.hasNeedsCover, isTrue);
      expect(summary.hasNeedsAttention, isTrue);
      expect(summary.hasProjectedOnly, isFalse);
      expect(model.totalInMonth, 3);
    });

    test('items on the first and last day of the month are shown', () {
      final model = build([
        aChoreItem('a', DateKey(2026, 10, 1)),
        aChoreItem('b', DateKey(2026, 10, 31)),
      ]);
      expect(model.summaryOf(DateKey(2026, 10, 1))!.total, 1);
      expect(model.summaryOf(DateKey(2026, 10, 31))!.total, 1);
    });

    test('items of another month leave the outside days empty (D-P3-8)', () {
      final model = build([
        aChoreItem('sep', DateKey(2026, 9, 28)),
        aChoreItem('nov', DateKey(2026, 11, 2)),
        aChoreItem('in', DateKey(2026, 10, 3)),
      ]);
      expect(model.summaryOf(DateKey(2026, 9, 28))!.total, 0);
      expect(model.summaryOf(DateKey(2026, 9, 28))!.isOutsideMonth, isTrue);
      expect(model.summaryOf(DateKey(2026, 11, 2))!.total, 0);
      expect(model.totalInMonth, 1);
    });

    test('a day of only planned chores is projected-only', () {
      final day = DateKey(2026, 10, 28);
      final model = build([
        aChoreItem('a', day, projected: true),
        aChoreItem('b', day, projected: true),
      ]);
      expect(model.summaryOf(day)!.hasProjectedOnly, isTrue);

      final mixed = build([
        aChoreItem('a', day, projected: true),
        aChoreItem('b', day),
      ]);
      expect(mixed.summaryOf(day)!.hasProjectedOnly, isFalse);
    });

    test('summaryOf is null for a day the grid does not show', () {
      expect(build(const []).summaryOf(DateKey(2027, 1, 1)), isNull);
    });
  });

  group('scope and filters', () {
    final day = DateKey(2026, 10, 25);
    final items = [
      aChoreItem('mine', day),
      aChoreItem('dave1', day, assignee: 'dave'),
      aChoreItem('dave2', DateKey(2026, 10, 26), assignee: 'dave'),
    ];

    test('mine counts only the viewer; family counts everyone', () {
      expect(
        build(items, scope: CalendarScope.mine).summaryOf(day)!.total,
        1,
      );
      expect(build(items).summaryOf(day)!.total, 2);
    });

    test('a viewer with no chores gets an empty month in mine', () {
      final model = build(items, scope: CalendarScope.mine, viewer: 'erin');
      expect(model.totalInMonth, 0);
    });

    test('mineCount marks the viewer days even in family scope', () {
      final model = build(items);
      expect(model.summaryOf(day)!.mineCount, 1);
      expect(model.summaryOf(DateKey(2026, 10, 26))!.mineCount, 0);
    });

    test('a filter narrows both the counts and the mine ring', () {
      final model = build(
        items,
        filters: const CalendarFilters(memberIds: {'dave'}),
      );
      expect(model.summaryOf(day)!.total, 1);
      expect(model.summaryOf(day)!.mineCount, 0);
    });

    test('filters never change an outside day', () {
      final model = build(
        [aChoreItem('sep', DateKey(2026, 9, 28))],
        filters: const CalendarFilters(groupIds: {'kitchen'}),
      );
      expect(model.summaryOf(DateKey(2026, 9, 28))!.total, 0);
    });
  });

  group('heat and availability', () {
    test('heat is 0 everywhere when off', () {
      final model = build([aChoreItem('a', DateKey(2026, 10, 25))]);
      expect(model.days.every((d) => d.heatLevel == 0), isTrue);
    });

    test('heat ranks a hard day above an easy day', () {
      final light = DateKey(2026, 10, 25);
      final heavy = DateKey(2026, 10, 26);
      final model = build([
        aChoreItem('a', light, difficulty: Difficulty.easy),
        aChoreItem('b', heavy, difficulty: Difficulty.hard),
        aChoreItem('c', heavy, difficulty: Difficulty.hard),
      ], heat: HeatMode.workload);
      expect(model.summaryOf(heavy)!.heatLevel, 4);
      expect(
        model.summaryOf(light)!.heatLevel < model.summaryOf(heavy)!.heatLevel,
        isTrue,
      );
      expect(model.summaryOf(DateKey(2026, 10, 27))!.heatLevel, 0);
    });

    test('an absence shows on its days, never on outside days', () {
      final model = build(
        const [],
        availability: AvailabilityIndex(<AvailabilitySpan>[
          AvailabilitySpan(
            memberId: 'dave',
            startDate: DateKey(2026, 9, 28),
            endDate: DateKey(2026, 10, 2),
          ),
        ]),
      );
      expect(model.summaryOf(DateKey(2026, 10, 1))!.unavailableMemberIds, {
        'dave',
      });
      expect(
        model.summaryOf(DateKey(2026, 9, 28))!.unavailableMemberIds,
        isEmpty,
      );
    });
  });

  group('size', () {
    test('900 items build well inside the frame budget', () {
      final items = <ChoreItem>[
        for (var i = 0; i < 900; i++)
          aChoreItem(
            'item_$i',
            DateKey(2026, 10, 1 + i % 31),
            assignee: i.isEven ? 'cara' : 'dave',
            status: ChoreStatus.values[i % ChoreStatus.values.length],
          ),
      ];
      var best = const Duration(days: 1);
      for (var run = 0; run < 10; run++) {
        final clock = Stopwatch()..start();
        final model = build(items, heat: HeatMode.workload);
        clock.stop();
        expect(model.totalInMonth, 900);
        if (clock.elapsed < best) best = clock.elapsed;
      }
      expect(best, lessThan(const Duration(milliseconds: 30)));
    });
  });
}
