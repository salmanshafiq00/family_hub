import 'package:flutter/material.dart';

/// Small text that sits on the optical centre of whatever holds it.
///
/// Hind Siliguri (the bundled font) has a tall ascent and descent for the
/// Bangla marks, so a plain `Text` gets more space above or below the glyphs
/// than looks even. This draws the text with a one-em line box (`height: 1`),
/// evenly distributed leading and a forced strut, so Bangla and Latin digits
/// share one centre line. Use it for every small label in a badge, chip or
/// date cell; the ONE place to tune the centring is here.
class CenteredLabel extends StatelessWidget {
  const CenteredLabel(
    this.text, {
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.center,
    super.key,
  });

  final String text;

  /// Null uses the surrounding [DefaultTextStyle] (a `Badge` sets its own).
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    final size = base.fontSize ?? 12;
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      style: base.copyWith(
        height: 1,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      strutStyle: StrutStyle(
        fontSize: size,
        height: 1,
        leading: 0,
        forceStrutHeight: true,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
    );
  }
}
