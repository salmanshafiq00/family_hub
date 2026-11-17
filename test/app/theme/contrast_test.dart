// ignore_for_file: avoid_print

import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 contrast ratio between foreground and background.
double _contrast(Color fg, Color bg) {
  final l1 = fg.computeLuminance();
  final l2 = bg.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

void _assertContrast(String label, Color fg, Color bg, double minRatio) {
  final ratio = _contrast(fg, bg);
  if (ratio < minRatio) {
    fail(
      '$label: contrast ratio ${ratio.toStringAsFixed(2)} '
      'is below minimum $minRatio\n'
      '  fg  = ${fg.toARGB32().toRadixString(16)}\n'
      '  bg  = ${bg.toARGB32().toRadixString(16)}',
    );
  }
}

void main() {
  group('WCAG contrast — all themes', () {
    for (final spec in appThemes) {
      group(spec.labelEn, () {
        late AppTokens t;
        setUpAll(() => t = spec.tokens);

        // ── Text on backgrounds ───────────────────────────────────────────

        test('textPrimary on background >= 4.5', () {
          _assertContrast(
            'textPrimary/background',
            t.textPrimary,
            t.background,
            4.5,
          );
        });

        test('textPrimary on surface >= 4.5', () {
          _assertContrast('textPrimary/surface', t.textPrimary, t.surface, 4.5);
        });

        test('textPrimary on surfaceRaised >= 4.5', () {
          _assertContrast(
            'textPrimary/surfaceRaised',
            t.textPrimary,
            t.surfaceRaised,
            4.5,
          );
        });

        test('textSecondary on background >= 4.5', () {
          _assertContrast(
            'textSecondary/background',
            t.textSecondary,
            t.background,
            4.5,
          );
        });

        test('textSecondary on surface >= 4.5', () {
          _assertContrast(
            'textSecondary/surface',
            t.textSecondary,
            t.surface,
            4.5,
          );
        });

        test('textSecondary on surfaceRaised >= 4.5', () {
          _assertContrast(
            'textSecondary/surfaceRaised',
            t.textSecondary,
            t.surfaceRaised,
            4.5,
          );
        });

        // ── textOnAccent on accent ────────────────────────────────────────

        test('textOnAccent on accent >= 4.5', () {
          _assertContrast('textOnAccent/accent', t.textOnAccent, t.accent, 4.5);
        });

        // ── Status onColor on container ───────────────────────────────────

        // The calendar's date cells: today is a soft accent (the selected date,
        // solid accent + textOnAccent, is covered above).
        test('accentStrong on accentSoft >= 4.5', () {
          _assertContrast(
            'accentStrong/accentSoft',
            t.accentStrong,
            t.accentSoft,
            4.5,
          );
        });

        test('statusScheduledOn on statusScheduledContainer >= 4.5', () {
          _assertContrast(
            'statusScheduledOn/statusScheduledContainer',
            t.statusScheduledOn,
            t.statusScheduledContainer,
            4.5,
          );
        });

        test('statusInProgressOn on statusInProgressContainer >= 4.5', () {
          _assertContrast(
            'statusInProgressOn/statusInProgressContainer',
            t.statusInProgressOn,
            t.statusInProgressContainer,
            4.5,
          );
        });

        test('statusCompletedOn on statusCompletedContainer >= 4.5', () {
          _assertContrast(
            'statusCompletedOn/statusCompletedContainer',
            t.statusCompletedOn,
            t.statusCompletedContainer,
            4.5,
          );
        });

        test('statusVerifiedOn on statusVerifiedContainer >= 4.5', () {
          _assertContrast(
            'statusVerifiedOn/statusVerifiedContainer',
            t.statusVerifiedOn,
            t.statusVerifiedContainer,
            4.5,
          );
        });

        test('statusOverdueOn on statusOverdueContainer >= 4.5', () {
          _assertContrast(
            'statusOverdueOn/statusOverdueContainer',
            t.statusOverdueOn,
            t.statusOverdueContainer,
            4.5,
          );
        });

        test('statusSkippedOn on statusSkippedContainer >= 4.5 (P3-04)', () {
          _assertContrast(
            'statusSkippedOn/statusSkippedContainer',
            t.statusSkippedOn,
            t.statusSkippedContainer,
            4.5,
          );
        });

        // ── Icon/status colors on surface >= 3 (large UI icons) ──────────

        test('statusScheduled on surface >= 3', () {
          _assertContrast(
            'statusScheduled/surface',
            t.statusScheduled,
            t.surface,
            3,
          );
        });

        test('statusInProgress on surface >= 3', () {
          _assertContrast(
            'statusInProgress/surface',
            t.statusInProgress,
            t.surface,
            3,
          );
        });

        test('statusCompleted on surface >= 3', () {
          _assertContrast(
            'statusCompleted/surface',
            t.statusCompleted,
            t.surface,
            3,
          );
        });

        test('statusVerified on surface >= 3', () {
          _assertContrast(
            'statusVerified/surface',
            t.statusVerified,
            t.surface,
            3,
          );
        });

        test('statusOverdue on surface >= 3', () {
          _assertContrast(
            'statusOverdue/surface',
            t.statusOverdue,
            t.surface,
            3,
          );
        });

        test('statusSkipped on surface >= 3 (P3-04)', () {
          _assertContrast(
            'statusSkipped/surface',
            t.statusSkipped,
            t.surface,
            3,
          );
        });

        // ── Placeholder initials (H11) ─────────────────────────────────────
        // Mirrors AppAvatar.foregroundFor: dark ink on light backgrounds,
        // light ink on dark ones.  EVERY palette entry must reach 4.5:1.
        test('placeholder foreground on every palette entry >= 4.5', () {
          for (var i = 0; i < t.placeholderPalette.length; i++) {
            final bg = t.placeholderPalette[i];
            final fg =
                ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
                ? t.placeholderOnDark
                : t.placeholderOnLight;
            _assertContrast('placeholder[$i]', fg, bg, 4.5);
          }
        });

        test('accent on surface >= 3', () {
          _assertContrast('accent/surface', t.accent, t.surface, 3);
        });
      });
    }
  });
}
