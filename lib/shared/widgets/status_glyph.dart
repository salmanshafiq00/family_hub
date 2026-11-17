import 'dart:async';
import 'dart:math' as math;

import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';

/// The status of a chore as a SHAPE (road map 3.7, P3-04).
///
/// Colour is never the only cue (CLAUDE.md rule 13), and in a dense calendar
/// cell there is no room for a label, so each status gets its own outline:
///
/// | status | shape |
/// | --- | --- |
/// | scheduled | hollow ring |
/// | in progress | half-filled ring |
/// | completed | filled disc + check |
/// | verified | filled disc + check inside a ring |
/// | overdue | rounded triangle + `!` |
/// | skipped | ring with a dash |
///
/// The shapes stay distinguishable at 10 dp and in greyscale. A screen that
/// shows only glyphs must also label them (for example in the day panel); the
/// [semanticsLabel] here is the fallback for assistive technology.
class StatusGlyph extends StatelessWidget {
  const StatusGlyph({
    required this.status,
    this.size = 14,
    this.semanticLabel,
    this.checkProgress = 1,
    this.colourOverride,
    super.key,
  });

  /// Diameter in logical pixels. The calendar uses 10, lists 14, detail 18.
  static const List<double> allowedSizes = <double>[10, 14, 18];

  final WidgetStatus status;
  final double size;

  /// Overrides the localized status name announced to screen readers.
  final String? semanticLabel;

  /// How much of the check mark is drawn, 0 … 1 (P3-24 "tick draws a check").
  /// Always 1 except while [AnimatedStatusGlyph] animates a completion.
  final double checkProgress;

  /// Draws the shape in this colour instead of the status's own `*On` token,
  /// for a glyph that sits on a surface the status colours do not belong to
  /// (a selected calendar date, for example). The caller picks a pair that is
  /// contrast-tested.
  final Color? colourOverride;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colours = colourOverride ?? statusColours(status, tokens);
    final label = semanticLabel ?? _label(context.l10n);

    return Semantics(
      label: label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _GlyphPainter(
            status: status,
            colour: colours,
            contextTokens: tokens,
            checkProgress: checkProgress,
          ),
          // The painter needs no child, but a non-empty semantic node keeps
          // the tap region stable when the glyph sits inside a bigger target.
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n) => switch (status) {
    WidgetStatus.scheduled => l10n.statusScheduled,
    WidgetStatus.inProgress => l10n.statusInProgress,
    WidgetStatus.completed => l10n.statusCompleted,
    WidgetStatus.verified => l10n.statusVerified,
    WidgetStatus.overdue => l10n.statusOverdue,
    WidgetStatus.skipped => l10n.choreStatusSkipped,
  };

  /// The colour a glyph of [status] is drawn with (the `*On` token, so it is
  /// readable on a status container of the same theme).
  static Color statusColours(WidgetStatus status, AppTokens t) =>
      switch (status) {
        WidgetStatus.scheduled => t.statusScheduledOn,
        WidgetStatus.inProgress => t.statusInProgressOn,
        WidgetStatus.completed => t.statusCompletedOn,
        WidgetStatus.verified => t.statusVerifiedOn,
        WidgetStatus.overdue => t.statusOverdueOn,
        WidgetStatus.skipped => t.statusSkippedOn,
      };
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.status,
    required this.colour,
    required this.contextTokens,
    required this.checkProgress,
  });

  final WidgetStatus status;
  final Color colour;
  final AppTokens contextTokens;
  final double checkProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    final centre = Offset(size.width / 2, size.height / 2);
    final stroke = math.max(1.2, side * 0.12);
    final ring = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = colour
      ..style = PaintingStyle.fill;
    // The stroke inside a filled disc: the theme's own light/dark inks, so no
    // colour literal is needed here and the result is contrast-tested.
    final discInk =
        ThemeData.estimateBrightnessForColor(colour) == Brightness.dark
        ? contextTokens.placeholderOnDark
        : contextTokens.placeholderOnLight;
    final radius = side / 2 - stroke / 2;

    switch (status) {
      case WidgetStatus.scheduled:
        canvas.drawCircle(centre, radius, ring);

      case WidgetStatus.inProgress:
        canvas.drawCircle(centre, radius, ring);
        // Right half filled: "started, not done".
        canvas.drawArc(
          Rect.fromCircle(center: centre, radius: radius),
          -math.pi / 2,
          math.pi,
          true,
          fill,
        );
        canvas.drawCircle(centre, radius, ring);

      case WidgetStatus.completed:
        canvas.drawCircle(centre, radius, fill);
        _check(canvas, centre, side, discInk, checkProgress);

      case WidgetStatus.verified:
        canvas.drawCircle(centre, radius, ring);
        canvas.drawCircle(centre, radius * 0.72, fill);
        _check(canvas, centre, side * 0.8, discInk, checkProgress);

      case WidgetStatus.overdue:
        _triangle(canvas, size, side, ring);
        _bang(canvas, centre, side, fill);

      case WidgetStatus.skipped:
        canvas.drawCircle(centre, radius, ring);
        canvas.drawLine(
          Offset(centre.dx - radius * 0.5, centre.dy),
          Offset(centre.dx + radius * 0.5, centre.dy),
          ring,
        );
    }
  }

  static void _check(
    Canvas canvas,
    Offset centre,
    double side,
    Color colour,
    double progress,
  ) {
    final paint = Paint()
      ..color = colour
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(centre.dx - side * 0.20, centre.dy + side * 0.01)
      ..lineTo(centre.dx - side * 0.05, centre.dy + side * 0.16)
      ..lineTo(centre.dx + side * 0.21, centre.dy - side * 0.15);
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    if (progress <= 0) return;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  static void _triangle(Canvas canvas, Size size, double side, Paint paint) {
    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.08)
      ..lineTo(size.width * 0.96, size.height * 0.90)
      ..lineTo(size.width * 0.04, size.height * 0.90)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void _bang(Canvas canvas, Offset centre, double side, Paint paint) {
    final barWidth = math.max(1.2, side * 0.11);
    canvas.drawLine(
      Offset(centre.dx, centre.dy - side * 0.10),
      Offset(centre.dx, centre.dy + side * 0.14),
      Paint()
        ..color = paint.color
        ..strokeWidth = barWidth
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(centre.dx, centre.dy + side * 0.29),
      barWidth / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.status != status ||
      old.colour != colour ||
      old.contextTokens != contextTokens ||
      old.checkProgress != checkProgress;
}

/// A [StatusGlyph] that DRAWS its check mark when the status changes to
/// completed or verified (B.5, P3-24). Under reduced motion
/// (`MediaQuery.disableAnimations`) the check simply appears. At rest no
/// animation runs.
class AnimatedStatusGlyph extends StatefulWidget {
  const AnimatedStatusGlyph({required this.status, this.size = 14, super.key});

  final WidgetStatus status;
  final double size;

  @override
  State<AnimatedStatusGlyph> createState() => _AnimatedStatusGlyphState();
}

class _AnimatedStatusGlyphState extends State<AnimatedStatusGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  static bool _done(WidgetStatus s) =>
      s == WidgetStatus.completed || s == WidgetStatus.verified;

  @override
  void didUpdateWidget(AnimatedStatusGlyph old) {
    super.didUpdateWidget(old);
    if (old.status == widget.status) return;
    if (_done(widget.status) &&
        !_done(old.status) &&
        !MediaQuery.disableAnimationsOf(context)) {
      unawaited(_controller.forward(from: 0));
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => StatusGlyph(
        status: widget.status,
        size: widget.size,
        checkProgress: Curves.easeOutCubic.transform(_controller.value),
      ),
    );
  }
}
