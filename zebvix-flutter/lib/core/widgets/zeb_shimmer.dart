import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class ZebShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const ZebShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.borderLight,
      child: Container(
        width: width,
        height: height ?? 16,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ZebShimmerCard extends StatelessWidget {
  final double? height;

  const ZebShimmerCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.borderLight,
      child: Container(
        height: height ?? 80,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 14, width: 120, color: AppColors.surfaceLight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 80, color: AppColors.surfaceLight,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 14, width: 80, color: AppColors.surfaceLight,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 50, color: AppColors.surfaceLight,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ZebShimmerList extends StatelessWidget {
  final int count;
  final double? itemHeight;

  const ZebShimmerList({super.key, this.count = 5, this.itemHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => ZebShimmerCard(height: itemHeight)),
    );
  }
}
