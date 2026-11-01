import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/day_part.dart';
import 'package:family_hub/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';

// The pure bucketing lives in the domain (P3-20); screens keep importing it
// from here.
export 'package:family_hub/features/chores/occurrences/domain/day_part.dart';

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
