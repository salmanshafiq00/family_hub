import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/calendar/domain/unavailability_overlay.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final index = AvailabilityIndex(<AvailabilitySpan>[
    AvailabilitySpan(
      memberId: 'cara',
      startDate: DateKey(2026, 10, 24),
      endDate: DateKey(2026, 10, 26),
    ),
    AvailabilitySpan(
      memberId: 'dave',
      startDate: DateKey(2026, 10, 25),
      endDate: DateKey(2026, 10, 25),
    ),
  ]);

  Set<String> away(
    DateKey day, {
    CalendarScope scope = CalendarScope.all,
    String? viewer,
    CalendarFilters filters = CalendarFilters.none,
    AvailabilityIndex? availability,
  }) => UnavailabilityOverlay.forDay(
    index: availability ?? index,
    day: day,
    scope: scope,
    viewerId: viewer,
    filters: filters,
  );

  test('an empty index gives no overlay', () {
    expect(
      away(DateKey(2026, 10, 25), availability: AvailabilityIndex.empty),
      isEmpty,
    );
  });

  test('family scope lists everybody away that day', () {
    expect(away(DateKey(2026, 10, 25)), {'cara', 'dave'});
    expect(away(DateKey(2026, 10, 24)), {'cara'});
    expect(away(DateKey(2026, 10, 27)), isEmpty);
  });

  test('mine shows only the viewer', () {
    expect(
      away(DateKey(2026, 10, 25), scope: CalendarScope.mine, viewer: 'dave'),
      {'dave'},
    );
    expect(
      away(DateKey(2026, 10, 24), scope: CalendarScope.mine, viewer: 'dave'),
      isEmpty,
    );
  });

  test('a member filter hides the others', () {
    expect(
      away(
        DateKey(2026, 10, 25),
        filters: const CalendarFilters(memberIds: {'dave'}),
      ),
      {'dave'},
    );
  });
}
