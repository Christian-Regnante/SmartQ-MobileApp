import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'neumorphic_card.dart';
import 'neumorphic_button.dart';

class AppLoadingWidget extends StatelessWidget {
  final String? message;

  const AppLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeumorphicCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: NeumorphicCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                NeumorphicButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                  type: NeumorphicButtonType.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const AppEmptyWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: NeumorphicCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: AppColors.outline),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (onAction != null && actionText != null) ...[
                const SizedBox(height: 20),
                NeumorphicButton(
                  text: actionText!,
                  onPressed: onAction,
                  type: NeumorphicButtonType.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
