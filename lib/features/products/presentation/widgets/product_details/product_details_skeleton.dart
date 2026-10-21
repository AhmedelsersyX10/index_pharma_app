import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_card.dart';

/// Loading skeleton placeholder for Product Details screen.
class ProductDetailsSkeleton extends StatelessWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
        vertical: AppSpacing.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trust strip skeleton
          _SkeletonBox(height: 32, width: 180, borderRadius: AppRadii.roundedFull),
          SizedBox(height: AppSpacing.spaceSm),

          // Showcase Card skeleton
          AppCard(
            padding: EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SkeletonBox(height: 24, width: 140),
                    _SkeletonBox(height: 24, width: 80),
                  ],
                ),
                SizedBox(height: AppSpacing.spaceSm),
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _SkeletonBox(height: double.infinity, borderRadius: AppRadii.roundedLg),
                ),
                SizedBox(height: AppSpacing.spaceSm),
                Row(
                  children: [
                    Expanded(child: _SkeletonBox(height: 48)),
                    SizedBox(width: AppSpacing.spaceXs),
                    Expanded(child: _SkeletonBox(height: 48)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.spaceMd),

          // Identity Card skeleton
          AppCard(
            padding: EdgeInsets.all(AppSpacing.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(height: 20, width: 100),
                SizedBox(height: AppSpacing.spaceSm),
                _SkeletonBox(height: 28, width: 220),
                SizedBox(height: AppSpacing.spaceSm),
                _SkeletonBox(height: 44, width: double.infinity),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.spaceMd),

          // Quantity Stepper skeleton
          AppCard(
            padding: EdgeInsets.all(AppSpacing.spaceMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SkeletonBox(height: 24, width: 120),
                _SkeletonBox(height: 44, width: 110),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width, this.borderRadius = AppRadii.roundedMd});

  final double height;
  final double? width;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: borderRadius),
    );
  }
}
