import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

enum NeumorphicButtonType { primary, secondary, danger, outline }

class NeumorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final NeumorphicButtonType type;
  final double borderRadius;
  final double height;
  final double? width;

  const NeumorphicButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.type = NeumorphicButtonType.primary,
    this.borderRadius = 16.0,
    this.height = 52.0,
    this.width,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  Color _getBackgroundColor() {
    if (widget.onPressed == null) return AppColors.surfaceContainerHigh;
    switch (widget.type) {
      case NeumorphicButtonType.primary:
        return AppColors.primary;
      case NeumorphicButtonType.secondary:
        return AppColors.surfaceContainerLow;
      case NeumorphicButtonType.danger:
        return AppColors.error;
      case NeumorphicButtonType.outline:
        return AppColors.surface;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null) return AppColors.outline;
    switch (widget.type) {
      case NeumorphicButtonType.primary:
      case NeumorphicButtonType.danger:
        return Colors.white;
      case NeumorphicButtonType.secondary:
        return AppColors.onSurface;
      case NeumorphicButtonType.outline:
        return AppColors.primary;
    }
  }

  List<BoxShadow> _getShadows() {
    if (_isPressed || widget.onPressed == null) return [];
    switch (widget.type) {
      case NeumorphicButtonType.primary:
        return AppShadows.primaryButtonElevated;
      case NeumorphicButtonType.secondary:
      case NeumorphicButtonType.outline:
      case NeumorphicButtonType.danger:
        return AppShadows.buttonElevated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            }
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width ?? double.infinity,
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _getShadows(),
          border: widget.type == NeumorphicButtonType.outline
              ? Border.all(color: AppColors.outlineVariant, width: 1.5)
              : null,
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: _getTextColor()),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
