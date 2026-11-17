/// The snap points of the day panel, as a fraction of the calendar body (B.5).
///
/// The grid reads the FIRST snap too ([dayPanelRestingHeight]), so the grid and
/// the collapsed panel can never disagree about how tall the body is.
const List<double> kDayPanelSnaps = <double>[0.28, 0.55, 0.92];

/// The height the day panel takes when it rests at its lowest snap.
double dayPanelRestingHeight(double bodyHeight) =>
    bodyHeight * kDayPanelSnaps.first;

/// Space around the month / week grid, on each side.
const double kCalendarGridSidePadding = 8;

/// The visual gap between two date cells. It lives INSIDE the cell, so the
/// whole column stays tappable (no dead strip between cells).
const double kCalendarCellInset = 2;

/// A month cell is never shorter than this, never taller than [Max].
const double kCalendarCellMinHeight = 44;
const double kCalendarCellMaxHeight = 68;

/// The week strip has a list under it, so its cell height is fixed.
const double kCalendarWeekCellHeight = 64;

/// Room kept under every list for the floating action button (the small FAB is
/// 40 dp, its margin 16 dp, plus 16 dp of air). The bottom navigation bar is
/// the Scaffold's own `bottomNavigationBar`, so the body already ends above it.
const double kCalendarBottomClearance = 40 + 16 + 16;

/// The height of one month row: the space left divided by the rows, kept
/// between [kCalendarCellMinHeight] and [kCalendarCellMaxHeight].
double calendarCellHeightFor({
  required double availableHeight,
  required int rows,
}) {
  if (rows <= 0 || !availableHeight.isFinite) return kCalendarCellMinHeight;
  return (availableHeight / rows)
      .clamp(kCalendarCellMinHeight, kCalendarCellMaxHeight)
      .toDouble();
}
