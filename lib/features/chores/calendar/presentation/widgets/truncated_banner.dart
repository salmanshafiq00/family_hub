import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:flutter/material.dart';

/// "This month has many chores - not all are shown" (C-2, Appendix B.9-24).
///
/// Shown when the month listener hit `kMaxOccurrencesPerMonth`. It takes plain
/// values (no provider): the screen passes `MonthItems.truncated` and opens the
/// filter sheet from [onOpenFilters], because narrowing the list is the way out.
/// Status is icon + text + colour, never colour alone.
class TruncatedBanner extends StatelessWidget {
  const TruncatedBanner({required this.onOpenFilters, super.key});

  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = context.l10n;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        key: const Key('calendar_truncated_banner'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        decoration: BoxDecoration(
          color: t.surfaceSunken,
          borderRadius: BorderRadius.circular(t.radiusMd),
          border: Border.all(color: t.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, size: 22, color: t.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.calendarTruncatedBanner,
                    style: TextStyle(
                      color: t.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                key: const Key('calendar_truncated_banner_action'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                onPressed: onOpenFilters,
                child: Text(l10n.calendarTruncatedBannerAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
