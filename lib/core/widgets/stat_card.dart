import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'neumorphic_card.dart';

/// Stat metric card for 2x2 grids (24px corner radius, stat number + label caps)
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      borderRadius: 20.0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: valueColor),
            const SizedBox(height: 4),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: valueColor,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.outline,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
