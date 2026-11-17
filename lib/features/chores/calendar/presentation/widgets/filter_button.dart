import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/shared/widgets/centered_label.dart';
import 'package:flutter/material.dart';

/// The filter button with the number of filters that are on (B.2).
class FilterButton extends StatelessWidget {
  const FilterButton({
    required this.activeCount,
    required this.formatters,
    required this.onPressed,
    super.key,
  });

  final int activeCount;
  final AppFormatters formatters;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = activeCount > 0
        ? l10n.calendarFiltersActive(formatters.number(activeCount))
        : l10n.calendarFilters;
    return IconButton(
      key: const Key('calendar_filter_button'),
      tooltip: label,
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: activeCount > 0,
        label: CenteredLabel(formatters.number(activeCount)),
        child: const Icon(Icons.filter_list_rounded),
      ),
    );
  }
}
