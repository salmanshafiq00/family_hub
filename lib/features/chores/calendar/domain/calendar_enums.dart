import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';

// The calendar works in the settings catalog's types directly (P3-20), so the
// original names are in scope wherever these aliases are imported.
export 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart'
    show CalendarViewKind, CalendarScopeKind;

/// The three calendar views. The family default is stored in
/// `settings/chores.defaultCalendarView` as [CalendarViewKind]; the calendar
/// uses the same type so the stored value and the live value never need a
/// conversion (P3-20).
typedef CalendarView = CalendarViewKind;

/// "My chores" or "Whole family" (`settings/chores.defaultScope`).
typedef CalendarScope = CalendarScopeKind;

/// How roomy the tiles and cells are.
enum Density {
  comfortable('comfortable'),
  compact('compact');

  const Density(this.id);

  final String id;

  static Density fromId(Object? id) {
    for (final density in values) {
      if (density.id == id) return density;
    }
    return Density.comfortable;
  }
}
