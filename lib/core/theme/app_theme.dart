import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const scheme = AppColors.lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6FAFE),
      primaryColor: scheme.primary,
      colorScheme: scheme,
      textTheme: AppTypography.textThemeFor(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF6FAFE),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF171C1F)),
        titleTextStyle: GoogleFonts.sora(
          color: const Color(0xFF171C1F),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: const Color(0xFFC0C7D4),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return null;
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    const scheme = AppColors.darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A063A),
      primaryColor: scheme.primary,
      colorScheme: scheme,
      textTheme: AppTypography.textThemeFor(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1A063A),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFEBDCFF)),
        titleTextStyle: GoogleFonts.sora(
          color: const Color(0xFFEBDCFF),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerColor: const Color(0xFF4A454D),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFBF5AF2);
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFFBF5AF2).withValues(alpha: 0.35);
          }
          return null;
        }),
      ),
    );
  }
}
