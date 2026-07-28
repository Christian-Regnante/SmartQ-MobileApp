import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography hierarchy matching SmartQ Design specification
class AppTypography {
  AppTypography._();

  static TextStyle displayLarge = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.48,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: AppColors.outline,
  );

  static TextStyle statNumber = GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 40 / 32,
    letterSpacing: -0.96,
    color: AppColors.primary,
  );

  static TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    headlineMedium: headlineMedium,
    bodyLarge: bodyLarge,
    bodySmall: bodySmall,
    labelSmall: labelCaps,
  );
}
