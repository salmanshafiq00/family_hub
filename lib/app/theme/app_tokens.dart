import 'package:flutter/material.dart';

/// Immutable design-token bag registered as a [ThemeExtension].
/// Access via `context.tokens` (see extension below).
///
/// Groups:
/// - surfaces · text · brand · status · feedback · lines · dataViz · shape · motion
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    // ── Surfaces ────────────────────────────────────────────────────────────
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.scrim,
    // ── Text ────────────────────────────────────────────────────────────────
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnAccent,
    // ── Brand ───────────────────────────────────────────────────────────────
    required this.accent,
    required this.accentSoft,
    required this.accentStrong,
    // ── Status ──────────────────────────────────────────────────────────────
    required this.statusScheduled,
    required this.statusScheduledContainer,
    required this.statusScheduledOn,
    required this.statusInProgress,
    required this.statusInProgressContainer,
    required this.statusInProgressOn,
    required this.statusCompleted,
    required this.statusCompletedContainer,
    required this.statusCompletedOn,
    required this.statusVerified,
    required this.statusVerifiedContainer,
    required this.statusVerifiedOn,
    required this.statusOverdue,
    required this.statusOverdueContainer,
    required this.statusOverdueOn,
    required this.statusSkipped,
    required this.statusSkippedContainer,
    required this.statusSkippedOn,
    // ── Feedback ────────────────────────────────────────────────────────────
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    // ── Lines ───────────────────────────────────────────────────────────────
    required this.divider,
    required this.outline,
    required this.focusRing,
    // ── Data viz ────────────────────────────────────────────────────────────
    required this.chart,
    required this.chartGrid,
    // ── Placeholder palette ─────────────────────────────────────────────────
    required this.placeholderPalette,
    required this.placeholderOnLight,
    required this.placeholderOnDark,
    // ── Shape ───────────────────────────────────────────────────────────────
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusPill,
    required this.elevation1,
    required this.elevation2,
    required this.elevation3,
    // ── Motion ──────────────────────────────────────────────────────────────
    required this.durationFast,
    required this.durationMedium,
    required this.durationSlow,
    required this.curveStandard,
    // ── Optional ────────────────────────────────────────────────────────────
    this.backgroundGradient,
  }) : assert(chart.length == 10, 'chart must have exactly 10 colors'),
       assert(
         placeholderPalette.length == 24,
         'placeholderPalette must have exactly 24 colors',
       );

  // ── Surfaces ──────────────────────────────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color scrim;

  // ── Text ──────────────────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color textOnAccent;

  // ── Brand ─────────────────────────────────────────────────────────────────
  final Color accent;
  final Color accentSoft;
  final Color accentStrong;

  // ── Status ────────────────────────────────────────────────────────────────
  final Color statusScheduled;
  final Color statusScheduledContainer;
  final Color statusScheduledOn;
  final Color statusInProgress;
  final Color statusInProgressContainer;
  final Color statusInProgressOn;
  final Color statusCompleted;
  final Color statusCompletedContainer;
  final Color statusCompletedOn;
  final Color statusVerified;
  final Color statusVerifiedContainer;
  final Color statusVerifiedOn;
  final Color statusOverdue;
  final Color statusOverdueContainer;
  final Color statusOverdueOn;

  /// Skipped (absence policy C / a manager skip, P3-04). Deliberately NEUTRAL:
  /// a skipped chore is neither a failure nor a success.
  final Color statusSkipped;
  final Color statusSkippedContainer;
  final Color statusSkippedOn;

  // ── Feedback ──────────────────────────────────────────────────────────────
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  // ── Lines ─────────────────────────────────────────────────────────────────
  final Color divider;
  final Color outline;
  final Color focusRing;

  // ── Data viz ──────────────────────────────────────────────────────────────
  final List<Color> chart; // exactly 10
  final Color chartGrid;

  // ── Placeholder palette ───────────────────────────────────────────────────
  final List<Color> placeholderPalette; // exactly 24

  /// Initial/foreground on a LIGHT placeholder background (dark ink), and on a
  /// DARK one (light ink).  Both reach >= 4.5:1 on every palette entry of the
  /// theme that defines them (contrast_test.dart).
  final Color placeholderOnLight;
  final Color placeholderOnDark;

  // ── Shape ─────────────────────────────────────────────────────────────────
  final double radiusSm; // 8
  final double radiusMd; // 16
  final double radiusLg; // 24
  final double radiusPill; // 999
  final List<BoxShadow> elevation1;
  final List<BoxShadow> elevation2;
  final List<BoxShadow> elevation3;

  // ── Motion ────────────────────────────────────────────────────────────────
  final Duration durationFast; // 120 ms
  final Duration durationMedium; // 240 ms
  final Duration durationSlow; // 400 ms
  final Curve curveStandard;

  // ── Optional ──────────────────────────────────────────────────────────────
  final Gradient? backgroundGradient;

  // ── ThemeExtension ────────────────────────────────────────────────────────

  @override
  AppTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? scrim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? textOnAccent,
    Color? accent,
    Color? accentSoft,
    Color? accentStrong,
    Color? statusScheduled,
    Color? statusScheduledContainer,
    Color? statusScheduledOn,
    Color? statusInProgress,
    Color? statusInProgressContainer,
    Color? statusInProgressOn,
    Color? statusCompleted,
    Color? statusCompletedContainer,
    Color? statusCompletedOn,
    Color? statusVerified,
    Color? statusVerifiedContainer,
    Color? statusVerifiedOn,
    Color? statusOverdue,
    Color? statusOverdueContainer,
    Color? statusOverdueOn,
    Color? statusSkipped,
    Color? statusSkippedContainer,
    Color? statusSkippedOn,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? divider,
    Color? outline,
    Color? focusRing,
    List<Color>? chart,
    Color? chartGrid,
    List<Color>? placeholderPalette,
    Color? placeholderOnLight,
    Color? placeholderOnDark,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    List<BoxShadow>? elevation1,
    List<BoxShadow>? elevation2,
    List<BoxShadow>? elevation3,
    Duration? durationFast,
    Duration? durationMedium,
    Duration? durationSlow,
    Curve? curveStandard,
    Gradient? backgroundGradient,
  }) {
    return AppTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      scrim: scrim ?? this.scrim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnAccent: textOnAccent ?? this.textOnAccent,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentStrong: accentStrong ?? this.accentStrong,
      statusScheduled: statusScheduled ?? this.statusScheduled,
      statusScheduledContainer:
          statusScheduledContainer ?? this.statusScheduledContainer,
      statusScheduledOn: statusScheduledOn ?? this.statusScheduledOn,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusInProgressContainer:
          statusInProgressContainer ?? this.statusInProgressContainer,
      statusInProgressOn: statusInProgressOn ?? this.statusInProgressOn,
      statusCompleted: statusCompleted ?? this.statusCompleted,
      statusCompletedContainer:
          statusCompletedContainer ?? this.statusCompletedContainer,
      statusCompletedOn: statusCompletedOn ?? this.statusCompletedOn,
      statusVerified: statusVerified ?? this.statusVerified,
      statusVerifiedContainer:
          statusVerifiedContainer ?? this.statusVerifiedContainer,
      statusVerifiedOn: statusVerifiedOn ?? this.statusVerifiedOn,
      statusOverdue: statusOverdue ?? this.statusOverdue,
      statusOverdueContainer:
          statusOverdueContainer ?? this.statusOverdueContainer,
      statusOverdueOn: statusOverdueOn ?? this.statusOverdueOn,
      statusSkipped: statusSkipped ?? this.statusSkipped,
      statusSkippedContainer:
          statusSkippedContainer ?? this.statusSkippedContainer,
      statusSkippedOn: statusSkippedOn ?? this.statusSkippedOn,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      divider: divider ?? this.divider,
      outline: outline ?? this.outline,
      focusRing: focusRing ?? this.focusRing,
      chart: chart ?? this.chart,
      chartGrid: chartGrid ?? this.chartGrid,
      placeholderPalette: placeholderPalette ?? this.placeholderPalette,
      placeholderOnLight: placeholderOnLight ?? this.placeholderOnLight,
      placeholderOnDark: placeholderOnDark ?? this.placeholderOnDark,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusPill: radiusPill ?? this.radiusPill,
      elevation1: elevation1 ?? this.elevation1,
      elevation2: elevation2 ?? this.elevation2,
      elevation3: elevation3 ?? this.elevation3,
      durationFast: durationFast ?? this.durationFast,
      durationMedium: durationMedium ?? this.durationMedium,
      durationSlow: durationSlow ?? this.durationSlow,
      curveStandard: curveStandard ?? this.curveStandard,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
    );
  }

  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnAccent: Color.lerp(textOnAccent, other.textOnAccent, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      statusScheduled: Color.lerp(statusScheduled, other.statusScheduled, t)!,
      statusScheduledContainer: Color.lerp(
        statusScheduledContainer,
        other.statusScheduledContainer,
        t,
      )!,
      statusScheduledOn: Color.lerp(
        statusScheduledOn,
        other.statusScheduledOn,
        t,
      )!,
      statusInProgress: Color.lerp(
        statusInProgress,
        other.statusInProgress,
        t,
      )!,
      statusInProgressContainer: Color.lerp(
        statusInProgressContainer,
        other.statusInProgressContainer,
        t,
      )!,
      statusInProgressOn: Color.lerp(
        statusInProgressOn,
        other.statusInProgressOn,
        t,
      )!,
      statusCompleted: Color.lerp(statusCompleted, other.statusCompleted, t)!,
      statusCompletedContainer: Color.lerp(
        statusCompletedContainer,
        other.statusCompletedContainer,
        t,
      )!,
      statusCompletedOn: Color.lerp(
        statusCompletedOn,
        other.statusCompletedOn,
        t,
      )!,
      statusVerified: Color.lerp(statusVerified, other.statusVerified, t)!,
      statusVerifiedContainer: Color.lerp(
        statusVerifiedContainer,
        other.statusVerifiedContainer,
        t,
      )!,
      statusVerifiedOn: Color.lerp(
        statusVerifiedOn,
        other.statusVerifiedOn,
        t,
      )!,
      statusOverdue: Color.lerp(statusOverdue, other.statusOverdue, t)!,
      statusOverdueContainer: Color.lerp(
        statusOverdueContainer,
        other.statusOverdueContainer,
        t,
      )!,
      statusOverdueOn: Color.lerp(statusOverdueOn, other.statusOverdueOn, t)!,
      statusSkipped: Color.lerp(statusSkipped, other.statusSkipped, t)!,
      statusSkippedContainer: Color.lerp(
        statusSkippedContainer,
        other.statusSkippedContainer,
        t,
      )!,
      statusSkippedOn: Color.lerp(statusSkippedOn, other.statusSkippedOn, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      chart: List<Color>.generate(
        10,
        (i) => Color.lerp(chart[i], other.chart[i], t)!,
      ),
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      placeholderPalette: List<Color>.generate(
        24,
        (i) =>
            Color.lerp(placeholderPalette[i], other.placeholderPalette[i], t)!,
      ),
      placeholderOnLight: Color.lerp(
        placeholderOnLight,
        other.placeholderOnLight,
        t,
      )!,
      placeholderOnDark: Color.lerp(
        placeholderOnDark,
        other.placeholderOnDark,
        t,
      )!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t),
      radiusPill: lerpDouble(radiusPill, other.radiusPill, t),
      elevation1: t < 0.5 ? elevation1 : other.elevation1,
      elevation2: t < 0.5 ? elevation2 : other.elevation2,
      elevation3: t < 0.5 ? elevation3 : other.elevation3,
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationMedium: t < 0.5 ? durationMedium : other.durationMedium,
      durationSlow: t < 0.5 ? durationSlow : other.durationSlow,
      curveStandard: t < 0.5 ? curveStandard : other.curveStandard,
      backgroundGradient: t < 0.5
          ? backgroundGradient
          : other.backgroundGradient,
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

/// Convenience getter: `context.tokens` — throws if AppTokens is not found.
extension AppTokensContext on BuildContext {
  AppTokens get tokens {
    final tokens = Theme.of(this).extension<AppTokens>();
    assert(tokens != null, 'AppTokens ThemeExtension not found in theme.');
    return tokens!;
  }
}
