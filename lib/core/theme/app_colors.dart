import 'package:flutter/material.dart';

/// App color system derived from SmartQ Light Mode Design specification
class AppColors {
  AppColors._();

  // Base Surfaces
  static const Color background = Color(0xFFF6FAFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFD6DADE);
  static const Color surfaceBright = Color(0xFFF6FAFE);

  // Recessed and Container Surfaces
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F4F8);
  static const Color surfaceContainer = Color(0xFFEAEFF2);
  static const Color surfaceContainerHigh = Color(0xFFE4E9ED);
  static const Color surfaceContainerHighest = Color(0xFFDFE3E7);

  // Text / Content
  static const Color onSurface = Color(0xFF171C1F);
  static const Color onSurfaceVariant = Color(0xFF414752);
  static const Color inverseSurface = Color(0xFF2C3134);
  static const Color inverseOnSurface = Color(0xFFEDF1F5);

  // Borders & Outlines
  static const Color outline = Color(0xFF717783);
  static const Color outlineVariant = Color(0xFFC0C7D4);

  // Brand Primary (Professional Blue)
  static const Color primary = Color(0xFF005DA6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF0E76CE);
  static const Color onPrimaryContainer = Color(0xFFFDFCFF);
  static const Color inversePrimary = Color(0xFFA3C9FF);
  static const Color primaryFixed = Color(0xFFD3E4FF);

  // Secondary
  static const Color secondary = Color(0xFF5D5F5F);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDFE0E0);
  static const Color onSecondaryContainer = Color(0xFF616363);

  // Status & Feedback Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000a);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFF8B4C00);

  // Neumorphic Shadow Colors
  static const Color shadowLight = Color(0xFFFFFFFF);
  static const Color shadowDark = Color(0x66A3B1C6); // rgba(163, 177, 198, 0.4)
}
