import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/shared/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

/// The palette colours of the theme as tappable circles.  The stored value
/// is the index (0-23), never a hex, so a category looks right in both themes.
/// Selection is a ring *and* a check mark.
class ColorSwatchGrid extends StatelessWidget {
  const ColorSwatchGrid({
    required this.selected,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
  });

  final int selected;
  final ValueChanged<int> onChanged;

  /// Localized name of one swatch, e.g. "Colour 3".
  final String Function(int number) semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final palette = t.placeholderPalette;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i = 0; i < palette.length; i++)
          Semantics(
            button: true,
            selected: i == selected,
            label: semanticLabel(i + 1),
            excludeSemantics: true,
            child: InkResponse(
              key: ValueKey('swatch-$i'),
              onTap: () => onChanged(i),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: palette[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == selected ? t.textPrimary : t.outline,
                        width: i == selected ? 3 : 1,
                      ),
                    ),
                    child: i == selected
                        ? Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: AppAvatar.foregroundFor(palette[i], t),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
