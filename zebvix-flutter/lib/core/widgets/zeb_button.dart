import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ZebButtonVariant { primary, secondary, outline, ghost, danger }

class ZebButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ZebButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;

  const ZebButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZebButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 12.0;
    final h = height ?? 52.0;

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: _foregroundColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: (textStyle ?? AppTextStyles.button).copyWith(color: _foregroundColor),
              ),
            ],
          );

    final button = switch (variant) {
      ZebButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textDark,
            minimumSize: Size(isFullWidth ? double.infinity : 0, h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            elevation: 0,
          ),
          child: child,
        ),
      ZebButtonVariant.secondary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceLight,
            foregroundColor: AppColors.textPrimary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            elevation: 0,
          ),
          child: child,
        ),
      ZebButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            side: const BorderSide(color: AppColors.primary),
          ),
          child: child,
        ),
      ZebButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            minimumSize: Size(isFullWidth ? double.infinity : 0, h),
          ),
          child: child,
        ),
      ZebButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: Size(isFullWidth ? double.infinity : 0, h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            elevation: 0,
          ),
          child: child,
        ),
    };

    return button;
  }

  Color get _foregroundColor => switch (variant) {
    ZebButtonVariant.primary => AppColors.textDark,
    ZebButtonVariant.secondary => AppColors.textPrimary,
    ZebButtonVariant.outline => AppColors.primary,
    ZebButtonVariant.ghost => AppColors.textPrimary,
    ZebButtonVariant.danger => Colors.white,
  };
}
