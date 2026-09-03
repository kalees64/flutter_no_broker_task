import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;
  final double height;
  final double borderRadius;
  final double? width;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.height = 52.0,
    this.borderRadius = 14.0,
    this.width,
    this.backgroundColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bgColor = widget.backgroundColor ?? AppColors.primaryContainer;
        fgColor = AppColors.onPrimary;
        break;
      case AppButtonVariant.secondary:
        bgColor = widget.backgroundColor ?? AppColors.surfaceContainerLow;
        fgColor = AppColors.primary;
        break;
      case AppButtonVariant.outline:
        bgColor = widget.backgroundColor ?? Colors.transparent;
        fgColor = AppColors.onSurface;
        borderSide = const BorderSide(color: AppColors.outlineVariant, width: 1.5);
        break;
    }

    final isClickable = !widget.isLoading && widget.onPressed != null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SizedBox(
        height: widget.height,
        width: widget.width ?? double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            disabledBackgroundColor: bgColor.withValues(alpha: 0.55),
            disabledForegroundColor: fgColor.withValues(alpha: 0.55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              side: borderSide,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: isClickable ? widget.onPressed : null,
          child: widget.isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: fgColor,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.text,
                      style: AppTextStyles.buttonLabel.copyWith(color: fgColor),
                    ),
                    if (widget.icon != null) ...[
                      const SizedBox(width: 8),
                      Icon(widget.icon, size: 18, color: fgColor),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
