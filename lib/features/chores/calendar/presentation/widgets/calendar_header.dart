import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_motion.dart';
import 'package:flutter/material.dart';

/// Row 1 of the calendar header: the month title (tap = month and year
/// picker), the previous / next arrows, the jump-to-today button and the
/// legend (B.2).
///
/// The jump-to-today button is an icon (the label is its tooltip and its
/// screen-reader name) and is only there while the person is away from today
/// ([showToday]); a text pill no longer fits next to the arrows on a 360 dp
/// phone. One row, never wraps: the title scales down instead.
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({
    required this.title,
    required this.showToday,
    required this.showArrows,
    required this.previousLabel,
    required this.nextLabel,
    required this.onTitle,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onLegend,
    super.key,
  });

  /// The width of one icon button; the height stays 48 dp (touch target).
  static const double buttonWidth = 40;

  final String title;
  final bool showToday;

  /// The agenda scrolls, so it has no previous / next.
  final bool showArrows;
  final String previousLabel;
  final String nextLabel;
  final VoidCallback onTitle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onLegend;

  static const BoxConstraints _button = BoxConstraints(
    minWidth: buttonWidth,
    minHeight: 48,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: '$title, ${l10n.calendarPickMonth}',
            excludeSemantics: true,
            child: InkWell(
              key: const Key('calendar_title'),
              onTap: onTitle,
              borderRadius: BorderRadius.circular(t.radiusMd),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          title,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down_rounded, color: t.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showArrows) ...[
          IconButton(
            key: const Key('calendar_previous'),
            tooltip: previousLabel,
            constraints: _button,
            padding: EdgeInsets.zero,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            key: const Key('calendar_next'),
            tooltip: nextLabel,
            constraints: _button,
            padding: EdgeInsets.zero,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
        // The button slides in from the side and out again (B.5); with
        // reduced motion the duration is zero and it just appears.
        AnimatedSwitcher(
          duration: calendarMotion(context),
          switchInCurve: kCalendarCurve,
          switchOutCurve: kCalendarCurve,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.4, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: showToday
              ? IconButton(
                  key: const Key('calendar_today_pill'),
                  tooltip: l10n.calendarToday,
                  constraints: _button,
                  padding: EdgeInsets.zero,
                  onPressed: onToday,
                  icon: const Icon(Icons.undo_rounded),
                )
              : const SizedBox.shrink(key: ValueKey<bool>(false)),
        ),
        IconButton(
          key: const Key('calendar_legend_button'),
          tooltip: l10n.calendarLegend,
          constraints: _button,
          padding: EdgeInsets.zero,
          onPressed: onLegend,
          icon: const Icon(Icons.help_outline_rounded),
        ),
      ],
    );
  }
}
