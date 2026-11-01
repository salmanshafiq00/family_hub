import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which month the calendar shows and which day is selected (P3-21).
///
/// The two always agree: the selected day is inside the focused month unless
/// the person is browsing months (see [CalendarFocusController.showMonth]).
/// They are ONE value so that "selecting a day in another month moves the
/// focused month" cannot be forgotten by a screen.
final class CalendarFocus {
  const CalendarFocus({required this.month, required this.day});

  final MonthKey month;
  final DateKey day;

  @override
  bool operator ==(Object other) =>
      other is CalendarFocus && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(month, day);

  @override
  String toString() => 'CalendarFocus($month, $day)';
}

/// Session state (not stored): a new app start opens on today.
final calendarFocusProvider =
    NotifierProvider<CalendarFocusController, CalendarFocus>(
      CalendarFocusController.new,
    );

/// The month the Month, Week and Agenda views are aimed at.
final focusedMonthProvider = Provider<MonthKey>(
  (ref) => ref.watch(calendarFocusProvider.select((focus) => focus.month)),
);

/// The selected day (the day panel and the Week strip follow it).
final selectedDayProvider = Provider<DateKey>(
  (ref) => ref.watch(calendarFocusProvider.select((focus) => focus.day)),
);

class CalendarFocusController extends Notifier<CalendarFocus> {
  @override
  CalendarFocus build() {
    // A different family starts again on today.
    ref.watch(currentFamilyIdProvider);
    final today = ref.read(familyDateKeysProvider).today();
    return CalendarFocus(month: today.monthKey, day: today);
  }

  /// Selects [day]; the focused month follows it.
  void selectDay(DateKey day) {
    final next = CalendarFocus(month: day.monthKey, day: day);
    if (next != state) state = next;
  }

  /// Aims the views at [month] (a swipe or the month picker).
  ///
  /// The selected day stays when it is inside [month]; otherwise it moves to
  /// today when today is inside, else to the first of the month, so the day
  /// panel never shows a day the grid is not on.
  void showMonth(MonthKey month) {
    if (month == state.month) return;
    final today = ref.read(familyDateKeysProvider).today();
    final DateKey day;
    if (state.day.monthKey == month) {
      day = state.day;
    } else if (today.monthKey == month) {
      day = today;
    } else {
      day = month.startOfMonth;
    }
    state = CalendarFocus(month: month, day: day);
  }

  /// The previous (-1) or next (+1) month.
  void shiftMonth(int months) => showMonth(state.month.addMonths(months));

  /// The Today pill.
  void goToToday() => selectDay(ref.read(familyDateKeysProvider).today());
}
