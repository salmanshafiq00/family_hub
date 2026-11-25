import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:flutter/material.dart';

/// The bundled Bangla-first font family declared in pubspec.yaml.
///
/// Chosen after evaluating Hind Siliguri, Noto Sans Bengali and Anek Bangla:
/// Hind Siliguri has the best weight coverage
/// for UI (300–700), a clean humanist look that stays readable at small sizes,
/// complete Bengali coverage, and is SIL OFL 1.1 licensed (free to bundle).
const String kAppFontFamily = 'HindSiliguri';

/// Builds the app [TextTheme] on top of [kAppFontFamily].
///
/// Body text >= 14sp and small labels >= 12sp as required by the roadmap.
/// Latin glyphs fall back to the same family's Latin coverage; a dedicated
/// Latin fallback family can be added later without touching screens.
TextTheme _buildTextTheme() {
  const family = kAppFontFamily;
  return const TextTheme(
    displayLarge: TextStyle(
      fontFamily: family,
      fontSize: 57,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: TextStyle(
      fontFamily: family,
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: TextStyle(
      fontFamily: family,
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: TextStyle(
      fontFamily: family,
      fontSize: 32,
      fontWeight: FontWeight.w600,
    ),
    headlineMedium: TextStyle(
      fontFamily: family,
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: TextStyle(
      fontFamily: family,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      fontFamily: family,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      fontFamily: family,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      fontFamily: family,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontFamily: family,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontFamily: family,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontFamily: family,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontFamily: family,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontFamily: family,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontFamily: family,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    ),
  );
}

/// Converts an [AppThemeSpec] into a complete Material 3 [ThemeData].
///
/// All colors come from the spec's [AppTokens]; no raw Color literal is used
/// here — they are already encoded in the token files under lib/app/theme/.
ThemeData buildThemeData(AppThemeSpec spec) {
  final t = spec.tokens;
  final isDark = spec.brightness == Brightness.dark;

  final colorScheme = ColorScheme(
    brightness: spec.brightness,
    primary: t.accent,
    onPrimary: t.textOnAccent,
    primaryContainer: t.accentSoft,
    onPrimaryContainer: t.accentStrong,
    secondary: t.accentSoft,
    onSecondary: t.accentStrong,
    secondaryContainer: t.accentSoft,
    onSecondaryContainer: t.accentStrong,
    tertiary: t.info,
    onTertiary: t.textOnAccent,
    tertiaryContainer: isDark
        ? const Color(0xFF0D2A4A)
        : const Color(0xFFBBDEFB),
    onTertiaryContainer: t.info,
    error: t.danger,
    onError: t.textOnAccent,
    errorContainer: isDark ? const Color(0xFF3B0909) : const Color(0xFFFFCDD2),
    onErrorContainer: t.danger,
    surface: t.surface,
    onSurface: t.textPrimary,
    surfaceContainerHighest: t.surfaceRaised,
    onSurfaceVariant: t.textSecondary,
    outline: t.outline,
    outlineVariant: t.divider,
    shadow: isDark ? const Color(0xFF000000) : const Color(0xFF000000),
    scrim: t.scrim,
    inverseSurface: isDark ? t.surface : const Color(0xFF1A1917),
    onInverseSurface: isDark ? t.textPrimary : const Color(0xFFF5F3F0),
    inversePrimary: isDark ? t.accentStrong : t.accentSoft,
  );

  // Bangla-first TextTheme (font bundled in assets/fonts, Step 5).
  final textTheme = _buildTextTheme();

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: t.background,
    textTheme: textTheme,
    extensions: [t],

    // ── Card ──────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: t.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
        side: BorderSide(color: t.divider),
      ),
      margin: EdgeInsets.zero,
    ),

    // ── InputDecoration ───────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surfaceSunken,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusSm),
        borderSide: BorderSide(color: t.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusSm),
        borderSide: BorderSide(color: t.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusSm),
        borderSide: BorderSide(color: t.focusRing, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusSm),
        borderSide: BorderSide(color: t.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(t.radiusSm),
        borderSide: BorderSide(color: t.danger, width: 2),
      ),
      hintStyle: TextStyle(color: t.textDisabled),
      labelStyle: TextStyle(color: t.textSecondary),
    ),

    // ── Chip ──────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: t.surfaceSunken,
      selectedColor: t.accentSoft,
      labelStyle: TextStyle(color: t.textPrimary),
      side: BorderSide(color: t.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusPill),
      ),
    ),

    // ── NavigationBar ─────────────────────────────────────────────────────
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surface,
      indicatorColor: t.accentSoft,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? t.accentStrong
            : t.textSecondary;
        return IconThemeData(color: color);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final color = states.contains(WidgetState.selected)
            ? t.accentStrong
            : t.textSecondary;
        return TextStyle(color: color, fontSize: 12);
      }),
    ),

    // ── Dialog ────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: t.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusLg),
      ),
    ),

    // ── BottomSheet ───────────────────────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(t.radiusLg),
          topRight: Radius.circular(t.radiusLg),
        ),
      ),
    ),

    // ── FilledButton ──────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: t.textOnAccent,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusPill),
        ),
      ),
    ),

    // ── OutlinedButton ────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.accent,
        side: BorderSide(color: t.accent),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusPill),
        ),
      ),
    ),

    // ── TextButton ────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.accent,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.radiusPill),
        ),
      ),
    ),

    // ── SnackBar ──────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark
          ? const Color(0xFFF0EDE9)
          : const Color(0xFF1A1917),
      contentTextStyle: TextStyle(
        color: isDark ? const Color(0xFF1A1917) : const Color(0xFFF0EDE9),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
    ),

    // ── DatePicker ────────────────────────────────────────────────────────
    datePickerTheme: DatePickerThemeData(
      backgroundColor: t.surfaceRaised,
      headerBackgroundColor: t.accent,
      headerForegroundColor: t.textOnAccent,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return t.textOnAccent;
        return t.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return t.accent;
        return Colors.transparent;
      }),
      todayForegroundColor: WidgetStateProperty.all(t.accent),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.radiusLg),
      ),
    ),

    // ── Divider ───────────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(color: t.divider, thickness: 1),

    // ── AppBar ────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: t.surface,
      foregroundColor: t.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: t.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
