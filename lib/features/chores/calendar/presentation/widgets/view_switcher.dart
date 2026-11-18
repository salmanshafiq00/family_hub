import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/shared/widgets/centered_label.dart';
import 'package:flutter/material.dart';

/// Agenda / Month / Week (B.2) as a compact three-segment pill.
///
/// The pill is [kCalendarControlHeight] high (the same height as the "whose
/// chores" chip, from the same constant);
/// every segment's touch area is 48 dp high. The order is the enum's, the labels
/// come from ARB. [enabled] lists the views that can be chosen: the others are
/// shown but dimmed. The selected segment is marked by its surface AND its bold
/// text, and announced as selected.
class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({
    required this.selected,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  /// The visible height of the pill.
  static const double pillHeight = kCalendarControlHeight;

  final CalendarView selected;
  final Set<CalendarView> enabled;
  final ValueChanged<CalendarView> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    String label(CalendarView view) => switch (view) {
      CalendarViewKind.agenda => l10n.choresCalendarViewAgenda,
      CalendarViewKind.month => l10n.choresCalendarViewMonth,
      CalendarViewKind.week => l10n.choresCalendarViewWeek,
    };
    return Semantics(
      key: const Key('calendar_view_switcher'),
      container: true,
      child: Stack(
        children: [
          // The tray is [pillHeight] high and centred in the 48 dp touch row.
          Positioned.fill(
            top: (kMinInteractiveDimension - pillHeight) / 2,
            bottom: (kMinInteractiveDimension - pillHeight) / 2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.surfaceSunken,
                borderRadius: BorderRadius.circular(t.radiusPill),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final view in CalendarViewKind.values)
                Flexible(
                  child: _Segment(
                    label: label(view),
                    selected: view == selected,
                    enabled: enabled.contains(view),
                    onTap: () => onChanged(view),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = !enabled
        ? t.textDisabled
        : selected
        ? t.accentStrong
        : t.textSecondary;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          height: kMinInteractiveDimension,
          // widthFactor: 1 keeps the segment as wide as its text (it sits in a
          // Flexible, so a plain Center or an aligned Container would stretch).
          child: Center(
            widthFactor: 1,
            child: Container(
              height: ViewSwitcher.pillHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: selected ? t.accentSoft : null,
                borderRadius: BorderRadius.circular(t.radiusPill),
              ),
              child: Center(
                widthFactor: 1,
                child: CenteredLabel(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
