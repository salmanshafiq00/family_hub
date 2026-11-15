import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Modern Dark theme tokens — hand-tuned dark neutral (not pure black, not an
/// inverted light theme); raised surfaces get lighter as they elevate;
/// slightly desaturated teal accent.
final AppTokens modernDarkTokens = AppTokens(
  // ── Surfaces ────────────────────────────────────────────────────────────
  // Elevation stack: background < surface < surfaceRaised
  background: const Color(0xFF131210), // very dark warm brown-black
  surface: const Color(0xFF1E1C1A), // card / sheet base
  surfaceRaised: const Color(0xFF2A2825), // dialogs, drawers — lighter
  surfaceSunken: const Color(0xFF0E0D0C), // inset fields
  scrim: const Color(0x99000000),

  // ── Text ────────────────────────────────────────────────────────────────
  textPrimary: const Color(0xFFF0EDE9),
  textSecondary: const Color(0xFFABA8A4),
  textDisabled: const Color(0xFF6B6866),
  // Teal 300 is light, so we use dark text on accent buttons in dark mode.
  textOnAccent: const Color(0xFF00201C), // very dark teal — ~11:1 on #4DB6AC
  // ── Brand (slightly desaturated teal) ─────────────────────────────────────
  accent: const Color(0xFF4DB6AC), // teal 300 — desaturated for dark
  accentSoft: const Color(0xFF1A3330), // very dark teal tint
  accentStrong: const Color(0xFF80CBC4), // teal 200
  // ── Status ───────────────────────────────────────────────────────────────
  // scheduled — blue, dark-adapted
  statusScheduled: const Color(0xFF90CAF9),
  statusScheduledContainer: const Color(0xFF0D2A4A),
  statusScheduledOn: const Color(0xFF90CAF9),
  // inProgress — orange, dark-adapted
  statusInProgress: const Color(0xFFFFCC80),
  statusInProgressContainer: const Color(0xFF3E2000),
  statusInProgressOn: const Color(0xFFFFCC80),
  // completed — teal, dark-adapted
  statusCompleted: const Color(0xFF80CBC4),
  statusCompletedContainer: const Color(0xFF002924),
  statusCompletedOn: const Color(0xFF80CBC4),
  // verified — green, dark-adapted
  statusVerified: const Color(0xFFA5D6A7),
  statusVerifiedContainer: const Color(0xFF0D2E0E),
  statusVerifiedOn: const Color(0xFFA5D6A7),
  // overdue — red, dark-adapted
  statusOverdue: const Color(0xFFEF9A9A),
  statusOverdueContainer: const Color(0xFF3B0909),
  statusOverdueOn: const Color(0xFFEF9A9A),
  // skipped — neutral grey-blue, dark-adapted.
  // #B0BEC5 on #263238: lum 0.475 vs 0.045 → ≈6.6:1 (WCAG AA ✓)
  statusSkipped: const Color(0xFF90A4AE),
  statusSkippedContainer: const Color(0xFF263238),
  statusSkippedOn: const Color(0xFFB0BEC5),

  // ── Feedback ─────────────────────────────────────────────────────────────
  success: const Color(0xFFA5D6A7),
  warning: const Color(0xFFFFD54F),
  danger: const Color(0xFFEF9A9A),
  info: const Color(0xFF90CAF9),

  // ── Lines ─────────────────────────────────────────────────────────────────
  divider: const Color(0xFF2E2C29),
  outline: const Color(0xFF4A4845),
  focusRing: const Color(0xFF4DB6AC),

  // ── Data viz ──────────────────────────────────────────────────────────────
  chart: const [
    Color(0xFF4DB6AC),
    Color(0xFF90CAF9),
    Color(0xFFFFCC80),
    Color(0xFFCE93D8),
    Color(0xFFEF9A9A),
    Color(0xFFA5D6A7),
    Color(0xFFFFD54F),
    Color(0xFF80DEEA),
    Color(0xFFB39DDB),
    Color(0xFFAED581),
  ],
  chartGrid: const Color(0xFF2E2C29),

  // ── Placeholder palette ───────────────────────────────────────────────────
  placeholderPalette: const [
    Color(0xFF1A3330),
    Color(0xFF0D2A4A),
    Color(0xFF3E2000),
    Color(0xFF0D2E0E),
    Color(0xFF3B0909),
    Color(0xFF2A1230),
    Color(0xFF2E2500),
    Color(0xFF08263A),
    Color(0xFF1B2E10),
    Color(0xFF3A0A20),
    Color(0xFF1A2428),
    Color(0xFF2E1F00),
    Color(0xFF151A33),
    Color(0xFF221030),
    Color(0xFF222600),
    Color(0xFF2A1F1A),
    Color(0xFF1F1F1F),
    Color(0xFF3A1400),
    Color(0xFF00363A),
    Color(0xFF331A00),
    Color(0xFF1B1F45),
    Color(0xFF2A1B45),
    Color(0xFF1D3300),
    Color(0xFF0A2A45),
  ],

  placeholderOnLight: const Color(0xFF1A1A1A),
  placeholderOnDark: const Color(0xFFF5F5F5),

  // ── Shape ─────────────────────────────────────────────────────────────────
  radiusSm: 8,
  radiusMd: 16,
  radiusLg: 24,
  radiusPill: 999,
  elevation1: const [
    BoxShadow(color: Color(0x28000000), blurRadius: 4, offset: Offset(0, 1)),
  ],
  elevation2: const [
    BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2)),
  ],
  elevation3: const [
    BoxShadow(color: Color(0x40000000), blurRadius: 16, offset: Offset(0, 4)),
  ],

  // ── Motion ────────────────────────────────────────────────────────────────
  durationFast: const Duration(milliseconds: 120),
  durationMedium: const Duration(milliseconds: 240),
  durationSlow: const Duration(milliseconds: 400),
  curveStandard: Curves.easeInOut,
);
