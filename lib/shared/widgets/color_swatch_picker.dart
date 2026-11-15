import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

/// Picks one of the theme's twenty-four placeholder colours by index (P3-04).
///
/// Colour is never the only cue: the selected swatch carries a check mark and
/// every swatch is announced as "Colour N of 24". Indices wrap at the palette
/// length, so a stored `colorIndex` can never point past the theme.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    required this.selectedIndex,
    required this.onChanged,
    this.count = 24,
    this.enabled = true,
    super.key,
  });

  static const double swatchSize = 48;

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// How many palette entries to offer (default: the whole palette).
  final int count;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final palette = tokens.placeholderPalette;
    final total = count.clamp(1, palette.length);
    final selected = selectedIndex % total;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < total; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: context.l10n.colorSwatchLabel(i + 1, total),
            excludeSemantics: true,
            child: InkResponse(
              key: ValueKey<int>(i),
              onTap: enabled ? () => onChanged(i) : null,
              radius: swatchSize * 0.6,
              child: Container(
                width: swatchSize,
                height: swatchSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette[i],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i == selected ? tokens.textPrimary : tokens.divider,
                    width: i == selected ? 3 : 1,
                  ),
                ),
                child: i == selected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: AppAvatar.foregroundFor(palette[i], tokens),
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
