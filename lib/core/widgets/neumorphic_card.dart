import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Elevated Neumorphic Card container (16px default border radius)
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color backgroundColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 16.0,
    this.backgroundColor = AppColors.surface,
    this.shadows,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppShadows.elevated,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
