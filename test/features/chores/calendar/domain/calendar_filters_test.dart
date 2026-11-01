import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/search_text.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:flutter_test/flutter_test.dart';

import '../calendar_test_support.dart';

void main() {
  final cleaning = aChoreItem(
    'a',
    kToday,
    groupId: 'cleaning',
    nameBn: 'ঘর ঝাড়ু',
    nameEn: 'Sweep the house',
  );
  final dishes = aChoreItem(
    'b',
    kToday,
    status: ChoreStatus.overdue,
    assignee: 'dave',
  );
  final orphan = aChoreItem('c', kToday, assignee: null, needsAttention: true);
  final all = [cleaning, dishes, orphan];

  group('CalendarFilters', () {
    test('none keeps everything and reports no active filter', () {
      expect(CalendarFilters.none.isEmpty, isTrue);
      expect(CalendarFilters.none.activeCount, 0);
      expect(CalendarFilters.none.apply(all), all);
    });

    test('group, status and member narrow independently', () {
      expect(
        const CalendarFilters(groupIds: {'cleaning'}).apply(all),
        [cleaning],
      );
      expect(
        const CalendarFilters(statuses: {ChoreStatus.overdue}).apply(all),
        [dishes],
      );
      expect(const CalendarFilters(memberIds: {'dave'}).apply(all), [dishes]);
    });

    test('a member filter never matches an unassigned chore', () {
      expect(const CalendarFilters(memberIds: {'cara', 'dave'}).apply([orphan]),
          isEmpty);
    });

    test('only-needs-attention keeps flagged chores', () {
      expect(
        const CalendarFilters(onlyNeedsAttention: true).apply(all),
        [orphan],
      );
    });

    test('filters combine with AND', () {
      const filters = CalendarFilters(
        groupIds: {'kitchen'},
        statuses: {ChoreStatus.overdue},
      );
      expect(filters.apply(all), [dishes]);
      expect(filters.activeCount, 2);
    });

    test('the query matches Bangla and English names, ignoring case', () {
      expect(const CalendarFilters(query: 'sweep').apply(all), [cleaning]);
      expect(const CalendarFilters(query: 'SWEEP').apply(all), [cleaning]);
      expect(const CalendarFilters(query: 'ঝাড়ু').apply(all), [cleaning]);
      expect(const CalendarFilters(query: 'xyz').apply(all), isEmpty);
    });

    test('a blank query is no filter', () {
      const filters = CalendarFilters(query: '   ');
      expect(filters.isEmpty, isTrue);
      expect(filters.activeCount, 0);
      expect(filters.apply(all), all);
    });

    test('apply keeps the input order', () {
      expect(
        const CalendarFilters(groupIds: {'kitchen'}).apply([orphan, dishes]),
        [orphan, dishes],
      );
    });

    test('equal filters are equal whatever the set order', () {
      expect(
        const CalendarFilters(groupIds: {'a', 'b'}),
        const CalendarFilters(groupIds: {'b', 'a'}),
      );
      expect(
        const CalendarFilters(groupIds: {'a'}).hashCode,
        const CalendarFilters(groupIds: {'a'}).hashCode,
      );
      expect(const CalendarFilters(groupIds: {'a'}) == CalendarFilters.none,
          isFalse);
    });
  });

  group('inScope', () {
    test('mine is the current assignee, family is everything', () {
      expect(inScope(CalendarScope.mine, 'cara', cleaning), isTrue);
      expect(inScope(CalendarScope.mine, 'cara', dishes), isFalse);
      expect(inScope(CalendarScope.mine, 'cara', orphan), isFalse);
      expect(inScope(CalendarScope.mine, null, cleaning), isFalse);
      expect(inScope(CalendarScope.all, null, orphan), isTrue);
    });
  });

  group('normalizeBn', () {
    test('lower-cases and collapses whitespace', () {
      expect(normalizeBn('  Wash   The\tDishes '), 'wash the dishes');
    });

    test('drops zero-width joiners so two spellings compare equal', () {
      expect(normalizeBn('র‍্যাক'), normalizeBn('র্যাক'));
      expect(normalizeBn('ক‌খ'), 'কখ');
    });

    test('empty stays empty', () {
      expect(normalizeBn(''), '');
      expect(normalizeBn('‍'), '');
    });
  });
}
