import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class PriceChangeBadge extends StatelessWidget {
  final double change;
  final bool showBg;
  final TextStyle? textStyle;

  const PriceChangeBadge({
    super.key,
    required this.change,
    this.showBg = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final color = isPositive ? AppColors.bullish : AppColors.bearish;

    return Container(
      padding: showBg ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3) : EdgeInsets.zero,
      decoration: showBg
          ? BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: color,
            size: 14,
          ),
          Text(
            Formatters.percent(change.abs(), showSign: false),
            style: (textStyle ?? AppTextStyles.captionSemiBold).copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class PriceText extends StatelessWidget {
  final double price;
  final double? change;
  final String? symbol;
  final TextStyle? style;

  const PriceText({
    super.key,
    required this.price,
    this.change,
    this.symbol,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final color = change == null
        ? AppColors.textPrimary
        : change! >= 0
            ? AppColors.bullish
            : AppColors.bearish;

    return Text(
      Formatters.price(price),
      style: (style ?? AppTextStyles.priceSmall).copyWith(color: color),
    );
  }
}
