import 'dart:async';

import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/calendar/domain/agenda_model.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_layout.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/widgets/today_row.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'agenda_view_parts.dart';
part 'agenda_view_list.dart';

const double _kJumpTodayThreshold = 240;

/// Days either side of today whose chores start open; every other day starts
/// closed behind its header (the person taps the header to open or close it).
const int _kOpenDaysAroundToday = 2;

/// The Agenda (P3-23): a list that grows in both directions from today.
///
/// * the Overdue block comes first, then today and the days after it, each day
///   under a sticky header;
/// * days before today scroll upwards (`center` = today), without sticky
///   headers (a reversed sliver has none);
/// * the chores of today ± [_kOpenDaysAroundToday] days start open, every
///   other day starts closed to its header and opens on tap;
/// * runs of days without chores collapse into one "N free days" chip;
/// * the ends carry "Show earlier / later weeks" (the window grows by whole
///   weeks up to the model's limit);
/// * a button jumps back to today.
class AgendaView extends ConsumerStatefulWidget {
  const AgendaView({super.key});

  @override
  ConsumerState<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState<AgendaView> {
  final GlobalKey _centerKey = GlobalKey(debugLabel: 'agenda_center');
  final ScrollController _scroll = ScrollController();
  final Set<DateKey> _toggledDays = <DateKey>{};
  AgendaWindow _window = const AgendaWindow();
  bool _away = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final offset = _scroll.offset;
    // P4-23: far enough from today, OR already at the top of the past. A short
    // window cannot be scrolled 240 px at all, so with the distance rule alone
    // the pill never appeared even though the person was at "show earlier
    // weeks" and wanted to get back to today.
    final atTopOfPast =
        position.minScrollExtent < 0 && offset <= position.minScrollExtent + 1;
    final away = offset.abs() > _kJumpTodayThreshold || atTopOfPast;
    if (away != _away) setState(() => _away = away);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Open near today, closed further away, unless the person tapped the header.
  /// While a filter (or "Mine") is on, every day with a match opens: a folded
  /// result would look like "nothing found".
  bool _isOpen(DateKey day, DateKey today, {required bool filtering}) =>
      filtering ||
      (today.daysUntil(day).abs() <= _kOpenDaysAroundToday) !=
          _toggledDays.contains(day);

  void _toggleDay(DateKey day) => setState(() {
    if (!_toggledDays.remove(day)) _toggledDays.add(day);
  });

  void _setWindow(AgendaWindow window) => setState(() => _window = window);

  void _jumpToToday() {
    if (!_scroll.hasClients) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(0);
    } else {
      unawaited(
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // A filter keeps the same date-wise list, but every matching day is
    // open, the window reaches further back, and an empty result says so.
    final filtering = !ref.watch(calendarFiltersProvider).isEmpty;
    final window = filtering
        ? _window.atLeastBack(AgendaWindow.filteringWeeksBack)
        : _window;
    final model = ref.watch(agendaWindowModelProvider(window));
    final Widget body;
    if (model.hasValue) {
      body = _list(
        context,
        model.requireValue,
        filtering: filtering,
        window: window,
      );
    } else if (model.hasError) {
      final error = model.error;
      body = ErrorView(
        message: l10n.choresFailureMessage(
          error is AppFailure ? error : Unknown(error),
        ),
        onRetry: () => ref.invalidate(agendaWindowModelProvider(window)),
      );
    } else {
      body = const LoadingView();
    }
    return Stack(
      children: [
        Positioned.fill(child: body),
        if (_away)
          PositionedDirectional(
            end: 16,
            bottom: 88,
            child: FloatingActionButton.small(
              key: const Key('calendar_jump_today'),
              tooltip: l10n.calendarJumpToToday,
              onPressed: _jumpToToday,
              child: const Icon(Icons.vertical_align_center_rounded),
            ),
          ),
      ],
    );
  }
}
