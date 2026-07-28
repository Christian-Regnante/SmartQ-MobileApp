import 'package:flutter/material.dart';

/// App color system with light + Aetheric Depth dark palettes.
/// Call [AppColors.applyBrightness] when [ThemeMode] changes so existing
/// `AppColors.*` call sites resolve the active palette.
class AppColors {
  AppColors._();

  static bool _isDark = false;

  static bool get isDark => _isDark;

  static void applyBrightness(Brightness brightness) {
    _isDark = brightness == Brightness.dark;
  }

  // ── Base Surfaces ──────────────────────────────────────────────
  static Color get background =>
      _isDark ? const Color(0xFF1A063A) : const Color(0xFFF6FAFE);
  static Color get surface =>
      _isDark ? const Color(0xFF1A0B2E) : const Color(0xFFFFFFFF);
  static Color get surfaceDim =>
      _isDark ? const Color(0xFF1A063A) : const Color(0xFFD6DADE);
  static Color get surfaceBright =>
      _isDark ? const Color(0xFF413062) : const Color(0xFFF6FAFE);

  static Color get surfaceContainerLowest =>
      _isDark ? const Color(0xFF150135) : const Color(0xFFFFFFFF);
  static Color get surfaceContainerLow =>
      _isDark ? const Color(0xFF231043) : const Color(0xFFF0F4F8);
  static Color get surfaceContainer =>
      _isDark ? const Color(0xFF271547) : const Color(0xFFEAEFF2);
  static Color get surfaceContainerHigh =>
      _isDark ? const Color(0xFF322052) : const Color(0xFFE4E9ED);
  static Color get surfaceContainerHighest =>
      _isDark ? const Color(0xFF3D2B5E) : const Color(0xFFDFE3E7);

  // ── Text / Content ─────────────────────────────────────────────
  static Color get onSurface =>
      _isDark ? const Color(0xFFEBDCFF) : const Color(0xFF171C1F);
  static Color get onSurfaceVariant =>
      _isDark ? const Color(0xFFCBC4CE) : const Color(0xFF414752);
  static Color get inverseSurface =>
      _isDark ? const Color(0xFFEBDCFF) : const Color(0xFF2C3134);
  static Color get inverseOnSurface =>
      _isDark ? const Color(0xFF382759) : const Color(0xFFEDF1F5);

  // ── Borders & Outlines ─────────────────────────────────────────
  static Color get outline =>
      _isDark ? const Color(0xFF958F98) : const Color(0xFF717783);
  static Color get outlineVariant =>
      _isDark ? const Color(0xFF4A454D) : const Color(0xFFC0C7D4);

  // ── Brand Primary ──────────────────────────────────────────────
  static Color get primary =>
      _isDark ? const Color(0xFFD3BEEB) : const Color(0xFF005DA6);
  static Color get onPrimary =>
      _isDark ? const Color(0xFF38294D) : const Color(0xFFFFFFFF);
  static Color get primaryContainer =>
      _isDark ? const Color(0xFF1A0B2E) : const Color(0xFF0E76CE);
  static Color get onPrimaryContainer =>
      _isDark ? const Color(0xFF88769F) : const Color(0xFFFDFCFF);
  static Color get inversePrimary =>
      _isDark ? const Color(0xFF68577E) : const Color(0xFFA3C9FF);
  static Color get primaryFixed =>
      _isDark ? const Color(0xFFEDDCFF) : const Color(0xFFD3E4FF);

  // ── Secondary / Tertiary (dark accents from design) ────────────
  static Color get secondary =>
      _isDark ? const Color(0xFFE9B3FF) : const Color(0xFF5D5F5F);
  static Color get onSecondary =>
      _isDark ? const Color(0xFF510074) : const Color(0xFFFFFFFF);
  static Color get secondaryContainer =>
      _isDark ? const Color(0xFF7D01B1) : const Color(0xFFDFE0E0);
  static Color get onSecondaryContainer =>
      _isDark ? const Color(0xFFE5A9FF) : const Color(0xFF616363);

  static Color get tertiary =>
      _isDark ? const Color(0xFFD3BBFF) : const Color(0xFF0E76CE);
  static Color get onTertiary =>
      _isDark ? const Color(0xFF3F0689) : const Color(0xFFFFFFFF);

  /// Electric Violet — CTAs, focus rings, active glow (Aetheric Depth)
  static Color get accent =>
      _isDark ? const Color(0xFFBF5AF2) : const Color(0xFF005DA6);

  // ── Status & Feedback ──────────────────────────────────────────
  static Color get error =>
      _isDark ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A);
  static Color get onError =>
      _isDark ? const Color(0xFF690005) : const Color(0xFFFFFFFF);
  static Color get errorContainer =>
      _isDark ? const Color(0xFF93000A) : const Color(0xFFFFDAD6);
  static Color get onErrorContainer =>
      _isDark ? const Color(0xFFFFDAD6) : const Color(0xFF93000A);

  static Color get success =>
      _isDark ? const Color(0xFF81C784) : const Color(0xFF2E7D32);
  static Color get warning =>
      _isDark ? const Color(0xFFFFB74D) : const Color(0xFF8B4C00);

  // ── Neumorphic Shadow Colors ───────────────────────────────────
  static Color get shadowLight =>
      _isDark ? const Color(0xFF2A1645) : const Color(0xFFFFFFFF);
  static Color get shadowDark =>
      _isDark ? const Color(0xFF0D0517) : const Color(0x66A3B1C6);

  // ── Static light/dark ColorSchemes for ThemeData ───────────────
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF005DA6),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF0E76CE),
    onPrimaryContainer: Color(0xFFFDFCFF),
    secondary: Color(0xFF5D5F5F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDFE0E0),
    onSecondaryContainer: Color(0xFF616363),
    tertiary: Color(0xFF0E76CE),
    onTertiary: Color(0xFFFFFFFF),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF171C1F),
    onSurfaceVariant: Color(0xFF414752),
    outline: Color(0xFF717783),
    outlineVariant: Color(0xFFC0C7D4),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFD3BEEB),
    onPrimary: Color(0xFF38294D),
    primaryContainer: Color(0xFF1A0B2E),
    onPrimaryContainer: Color(0xFF88769F),
    secondary: Color(0xFFE9B3FF),
    onSecondary: Color(0xFF510074),
    secondaryContainer: Color(0xFF7D01B1),
    onSecondaryContainer: Color(0xFFE5A9FF),
    tertiary: Color(0xFFD3BBFF),
    onTertiary: Color(0xFF3F0689),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF1A0B2E),
    onSurface: Color(0xFFEBDCFF),
    onSurfaceVariant: Color(0xFFCBC4CE),
    outline: Color(0xFF958F98),
    outlineVariant: Color(0xFF4A454D),
  );
}
