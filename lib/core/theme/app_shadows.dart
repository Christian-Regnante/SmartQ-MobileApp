import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Neumorphic dual-shadow elevation system
class AppShadows {
  AppShadows._();

  /// Default elevated card shadow (convex state)
  static List<BoxShadow> elevated = const [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-5, -5),
      blurRadius: 10,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(5, 5),
      blurRadius: 10,
      spreadRadius: 0,
    ),
  ];

  /// Subtle elevated shadow for smaller elements like buttons
  static List<BoxShadow> buttonElevated = const [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(-3, -3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: AppColors.shadowDark,
      offset: Offset(3, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// Primary action button shadow (blue tone shadow)
  static List<BoxShadow> primaryButtonElevated = const [
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

  /// Inset recessed shadows (concave state for inputs / trays)
  static List<BoxShadow> insetTray = const [
    BoxShadow(
      color: Color(0x33A3B1C6),
      offset: Offset(2, 2),
      blurRadius: 4,
    ),
  ];
}
