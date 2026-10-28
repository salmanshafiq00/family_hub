import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// The parts of a day a chore can be due in (road map P3-15).
///
/// They are a closed domain set (not a configurable list like the due-time
/// presets, D-P3-4): the labels come from the ARB, the boundaries are fixed so
/// two screens never group the same chore differently.
enum ChoreDayPart { earlyMorning, morning, noon, afternoon, evening, night }

/// The part of the day a due time falls in.
///
/// 00:00–05:59 early morning, 06:00–09:59 morning, 10:00–13:59 noon,
/// 14:00–16:59 afternoon, 17:00–19:59 evening, 20:00–23:59 night. A chore
/// without a time belongs to `night` (its deadline is the end of the day).
ChoreDayPart dayPartOf(int? dueMinutes) {
  if (dueMinutes == null) return ChoreDayPart.night;
  if (dueMinutes < 6 * 60) return ChoreDayPart.earlyMorning;
  if (dueMinutes < 10 * 60) return ChoreDayPart.morning;
  if (dueMinutes < 14 * 60) return ChoreDayPart.noon;
  if (dueMinutes < 17 * 60) return ChoreDayPart.afternoon;
  if (dueMinutes < 20 * 60) return ChoreDayPart.evening;
  return ChoreDayPart.night;
}

/// Localized label of [part].
String dayPartLabel(BuildContext context, ChoreDayPart part) {
  final l10n = context.l10n;
  return switch (part) {
    ChoreDayPart.earlyMorning => l10n.choreDayPartEarlyMorning,
    ChoreDayPart.morning => l10n.choreDayPartMorning,
    ChoreDayPart.noon => l10n.choreDayPartNoon,
    ChoreDayPart.afternoon => l10n.choreDayPartAfternoon,
    ChoreDayPart.evening => l10n.choreDayPartEvening,
    ChoreDayPart.night => l10n.choreDayPartNight,
  };
}

/// The items of one day grouped by [ChoreDayPart], in clock order.
List<(ChoreDayPart, List<ChoreItem>)> groupByDayPart(List<ChoreItem> items) {
  final groups = <ChoreDayPart, List<ChoreItem>>{};
  for (final item in items) {
    (groups[dayPartOf(item.dueMinutes)] ??= <ChoreItem>[]).add(item);
  }
  return <(ChoreDayPart, List<ChoreItem>)>[
    for (final part in ChoreDayPart.values)
      if (groups[part] != null) (part, groups[part]!),
  ];
}

/// One day-part heading with a count, above the chores of that part.
class DayPartSection extends StatelessWidget {
  const DayPartSection({required this.part, required this.count, super.key});

  final ChoreDayPart part;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: t.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: SectionHeader(title: dayPartLabel(context, part))),
          Text(
            '$count',
            style: TextStyle(color: t.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (part) {
    ChoreDayPart.earlyMorning => Icons.nights_stay_outlined,
    ChoreDayPart.morning => Icons.wb_sunny_outlined,
    ChoreDayPart.noon => Icons.light_mode_outlined,
    ChoreDayPart.afternoon => Icons.wb_twilight_outlined,
    ChoreDayPart.evening => Icons.nights_stay_outlined,
    ChoreDayPart.night => Icons.dark_mode_outlined,
  };
}
