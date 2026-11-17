import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// One destination of a [PillBottomBar].
class PillNavItem {
  const PillNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.key,
  });

  final IconData icon;
  final IconData? selectedIcon;

  /// Already-localized label: shown next to the icon when selected and always
  /// used as the screen-reader label.
  final String label;

  /// Optional key (tests, stable identity).
  final Key? key;
}

/// A floating pill navigation bar.
///
/// The active destination expands to show its label; inactive ones show only an
/// icon.  Everything comes from [AppTokens]; every target is at least 48dp; each
/// item is a button for assistive technology with its selected state announced.
///
/// The label sits in a [Flexible] with ellipsis, so a long Bangla label at 200%
/// text scale shrinks instead of overflowing.
class PillBottomBar extends StatelessWidget {
  const PillBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  }) : assert(items.length >= 2, 'A navigation bar needs at least 2 items');

  final List<PillNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Minimum touch target (accessibility rule 13).
  static const double minTarget = 48;

  static const double layoutHeight = minTarget + 8 + 4 + 12;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final duration = reduceMotion ? Duration.zero : t.durationMedium;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Center(
          heightFactor: 1,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: t.surfaceRaised,
              borderRadius: BorderRadius.circular(t.radiusPill),
              border: Border.all(color: t.outline),
              boxShadow: t.elevation2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < items.length; i++)
                  _PillItem(
                    item: items[i],
                    selected: i == selectedIndex,
                    duration: duration,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillItem extends StatelessWidget {
  const _PillItem({
    required this.item,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final PillNavItem item;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final iconData = selected ? (item.selectedIcon ?? item.icon) : item.icon;

    final child = AnimatedContainer(
      duration: duration,
      curve: t.curveStandard,
      constraints: const BoxConstraints(
        minHeight: PillBottomBar.minTarget,
        minWidth: PillBottomBar.minTarget,
      ),
      padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 12),
      decoration: BoxDecoration(
        color: selected ? t.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(t.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 24,
            color: selected ? t.accentStrong : t.textSecondary,
          ),
          if (selected)
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: t.accentStrong,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    // Only the selected item may shrink; icon-only items keep their 48dp.
    final tappable = Semantics(
      container: true,
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        key: item.key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );

    return selected ? Flexible(child: tappable) : tappable;
  }
}
