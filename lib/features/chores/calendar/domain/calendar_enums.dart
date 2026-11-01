import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';

/// The three calendar views. The family default is stored in
/// `settings/chores.defaultCalendarView` as [CalendarViewKind]; the calendar
/// uses the same type so the stored value and the live value never need a
/// conversion (P3-20).
typedef CalendarView = CalendarViewKind;

/// "My chores" or "Whole family" (`settings/chores.defaultScope`).
typedef CalendarScope = CalendarScopeKind;

/// Tint behind the day cells (Appendix B.4).
enum HeatMode {
  off('off'),
  workload('workload');

  const HeatMode(this.id);

  /// The id stored in the local preferences (P3-21).
  final String id;

  static HeatMode fromId(Object? id) {
    for (final mode in values) {
      if (mode.id == id) return mode;
    }
    return HeatMode.off;
  }
}

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

/// How a day cell draws its chores.
enum MarkerStyle {
  glyphs('glyphs'),
  dots('dots'),
  count('count');

  const MarkerStyle(this.id);

  final String id;

  static MarkerStyle fromId(Object? id) {
    for (final style in values) {
      if (style.id == id) return style;
    }
    return MarkerStyle.glyphs;
  }
}
