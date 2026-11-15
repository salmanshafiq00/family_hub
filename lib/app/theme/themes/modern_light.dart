import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Modern Light theme tokens — warm neutral background, white cards, soft
/// shadows, teal accent.
final AppTokens modernLightTokens = AppTokens(
  // ── Surfaces ────────────────────────────────────────────────────────────
  background: const Color(0xFFF5F3F0), // warm off-white
  surface: const Color(0xFFFFFFFF),
  surfaceRaised: const Color(0xFFFFFFFF),
  surfaceSunken: const Color(0xFFEFEDEA),
  scrim: const Color(0x80000000),

  // ── Text ────────────────────────────────────────────────────────────────
  textPrimary: const Color(0xFF1A1917),
  textSecondary: const Color(0xFF5A5754),
  textDisabled: const Color(0xFF9E9B98),
  textOnAccent: const Color(0xFFFFFFFF),

  // ── Brand (teal) ─────────────────────────────────────────────────────────
  // Teal 800 (#00574B): white on this gives ~5.6:1 contrast (WCAG AA ✓)
  accent: const Color(0xFF00574B), // teal 800
  accentSoft: const Color(0xFFB2DFDB), // teal 100
  accentStrong: const Color(0xFF00352B), // teal 950-ish
  // ── Status ───────────────────────────────────────────────────────────────
  // scheduled — blue family
  statusScheduled: const Color(0xFF1565C0),
  statusScheduledContainer: const Color(0xFFBBDEFB),
  statusScheduledOn: const Color(0xFF0D47A1),
  // inProgress — deep-orange family. Container is peach, so onColor must be very dark
  statusInProgress: const Color(0xFFBF360C), // deep orange 800
  statusInProgressContainer: const Color(0xFFFFE0B2),
  // #6A1900 on #FFE0B2: 6A1900 lum≈0.03, FFE0B2 lum≈0.74, ratio≈(0.79/0.08)≈9.9:1 ✓
  statusInProgressOn: const Color(0xFF6A1900),
  // completed — teal family
  statusCompleted: const Color(0xFF00796B),
  statusCompletedContainer: const Color(0xFFB2DFDB),
  statusCompletedOn: const Color(0xFF004D40),
  // verified — green family
  statusVerified: const Color(0xFF2E7D32),
  statusVerifiedContainer: const Color(0xFFC8E6C9),
  statusVerifiedOn: const Color(0xFF1B5E20),
  // overdue — red family
  statusOverdue: const Color(0xFFC62828),
  statusOverdueContainer: const Color(0xFFFFCDD2),
  statusOverdueOn: const Color(0xFFB71C1C),
  // skipped — neutral grey-blue (neither success nor failure).
  // #37474F on #ECEFF1: lum 0.061 vs 0.854 → ≈10.2:1 (WCAG AA ✓)
  statusSkipped: const Color(0xFF546E7A),
  statusSkippedContainer: const Color(0xFFECEFF1),
  statusSkippedOn: const Color(0xFF37474F),

  // ── Feedback ─────────────────────────────────────────────────────────────
  success: const Color(0xFF2E7D32),
  warning: const Color(0xFFF57F17),
  danger: const Color(0xFFC62828),
  info: const Color(0xFF1565C0),

  // ── Lines ─────────────────────────────────────────────────────────────────
  divider: const Color(0xFFE0DEDA),
  outline: const Color(0xFFBBB9B6),
  focusRing: const Color(0xFF00897B),

  // ── Data viz ──────────────────────────────────────────────────────────────
  chart: const [
    Color(0xFF00897B), // teal
    Color(0xFF1565C0), // blue
    Color(0xFFE65100), // orange
    Color(0xFF6A1B9A), // purple
    Color(0xFFC62828), // red
    Color(0xFF2E7D32), // green
    Color(0xFFF57F17), // amber
    Color(0xFF00838F), // cyan
    Color(0xFF4527A0), // deep purple
    Color(0xFF558B2F), // light green
  ],
  chartGrid: const Color(0xFFE0DEDA),

  // ── Placeholder palette ───────────────────────────────────────────────────
  placeholderPalette: const [
    Color(0xFFB2DFDB),
    Color(0xFFBBDEFB),
    Color(0xFFFFE0B2),
    Color(0xFFC8E6C9),
    Color(0xFFFFCDD2),
    Color(0xFFE1BEE7),
    Color(0xFFFFF9C4),
    Color(0xFFB3E5FC),
    Color(0xFFDCEDC8),
    Color(0xFFF8BBD9),
    Color(0xFFCFD8DC),
    Color(0xFFFFE082),
    Color(0xFFC5CAE9),
    Color(0xFFD1C4E9),
    Color(0xFFF0F4C3),
    Color(0xFFD7CCC8),
    Color(0xFFBDBDBD),
    Color(0xFFFFCCBC),
    Color(0xFFB2EBF2),
    Color(0xFFFFAB91),
    Color(0xFF9FA8DA),
    Color(0xFFB39DDB),
    Color(0xFFAED581),
    Color(0xFF90CAF9),
  ],

  placeholderOnLight: const Color(0xFF1A1A1A),
  placeholderOnDark: const Color(0xFFF5F5F5),

  // ── Shape ─────────────────────────────────────────────────────────────────
  radiusSm: 8,
  radiusMd: 16,
  radiusLg: 24,
  radiusPill: 999,
  elevation1: const [
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ],
  elevation2: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 2)),
  ],
  elevation3: const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
  ],

  // ── Motion ────────────────────────────────────────────────────────────────
  durationFast: const Duration(milliseconds: 120),
  durationMedium: const Duration(milliseconds: 240),
  durationSlow: const Duration(milliseconds: 400),
  curveStandard: Curves.easeInOut,
);
