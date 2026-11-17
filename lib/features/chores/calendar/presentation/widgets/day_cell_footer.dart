import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/features/chores/calendar/domain/day_summary.dart';
import 'package:flutter/material.dart';

class DayCellFooter extends StatelessWidget {
  const DayCellFooter({
    required this.summary,
    required this.formatters,
    required this.color,
    super.key,
  });

  final DaySummary summary;
  final AppFormatters formatters;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final total = summary.total > 99
        ? '${formatters.number(99)}+'
        : formatters.number(summary.total);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        '${formatters.number(summary.doneCount)}/$total',
        maxLines: 1,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
