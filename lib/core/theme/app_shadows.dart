import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Neumorphic dual-shadow elevation system (light + Aetheric Depth dark).
class AppShadows {
  AppShadows._();

  /// Extruded / raised card shadow
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.shadowLight,
          offset: const Offset(-4, -4),
          blurRadius: AppColors.isDark ? 12 : 10,
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(4, 4),
          blurRadius: AppColors.isDark ? 12 : 10,
        ),
      ];

  /// Extruded shadow for smaller elements (buttons, chips)
  static List<BoxShadow> get buttonElevated => [
        BoxShadow(
          color: AppColors.shadowLight,
          offset: const Offset(-3, -3),
          blurRadius: 6,
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(3, 3),
          blurRadius: 6,
        ),
      ];

  /// Primary / accent action button extruded shadow
  static List<BoxShadow> get primaryButtonElevated {
    if (AppColors.isDark) {
      return [
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.35),
          offset: const Offset(-3, -3),
          blurRadius: 10,
        ),
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(3, 3),
          blurRadius: 10,
        ),
      ];
    }
    return const [
      BoxShadow(
        color: Color(0xFF338BE6),
        offset: Offset(-3, -3),
        blurRadius: 6,
      ),
      BoxShadow(
        color: Color(0xFF003E73),
        offset: Offset(3, 3),
        blurRadius: 6,
      ),
    ];
  }

  /// Inset / sunken shadows (inputs, pressed buttons, progress tracks)
  static List<BoxShadow> get inset => [
        BoxShadow(
          color: AppColors.shadowDark,
          offset: const Offset(4, 4),
          blurRadius: 8,
          blurStyle: BlurStyle.inner,
        ),
        BoxShadow(
          color: AppColors.shadowLight.withValues(alpha: AppColors.isDark ? 0.5 : 0.8),
          offset: const Offset(-4, -4),
          blurRadius: 8,
          blurStyle: BlurStyle.inner,
        ),
      ];

  /// Legacy alias used by inputs
  static List<BoxShadow> get insetTray => inset;

  /// Soft accent glow for selected chips / active states (dark)
  static List<BoxShadow> get accentGlow => [
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.45),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];
}
