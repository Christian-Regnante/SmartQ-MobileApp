import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography hierarchy — Sora / Hanken Grotesk / JetBrains Mono (Aetheric Depth).
class AppTypography {
  AppTypography._();

  static TextStyle displayLarge({Color? color}) => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.64,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle displayLargeDesktop({Color? color}) => GoogleFonts.sora(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.96,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: color ?? AppColors.onSurfaceVariant,
      );

  static TextStyle labelCaps({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        letterSpacing: 0.6,
        color: color ?? AppColors.outline,
      );

  static TextStyle statNumber({Color? color}) => GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 40 / 32,
        letterSpacing: -0.96,
        color: color ?? AppColors.primary,
      );

  static TextTheme textThemeFor(ColorScheme scheme) => TextTheme(
        displayLarge: displayLarge(color: scheme.onSurface),
        headlineMedium: headlineMedium(color: scheme.onSurface),
        bodyLarge: bodyLarge(color: scheme.onSurface),
        bodyMedium: bodyMedium(color: scheme.onSurface),
        bodySmall: bodySmall(color: scheme.onSurfaceVariant),
        labelSmall: labelCaps(color: scheme.outline),
      );

  static TextTheme get textTheme => textThemeFor(
        AppColors.isDark
            ? AppColors.darkColorScheme
            : AppColors.lightColorScheme,
      );
}
