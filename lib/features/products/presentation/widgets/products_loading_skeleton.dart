import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_card.dart';

/// Shimmering/pulsing placeholder skeleton for products grid.
class ProductsLoadingSkeleton extends StatefulWidget {
  const ProductsLoadingSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  State<ProductsLoadingSkeleton> createState() =>
      _ProductsLoadingSkeletonState();
}

class _ProductsLoadingSkeletonState extends State<ProductsLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacityAnim = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.itemCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.spaceSm,
              mainAxisSpacing: AppSpacing.spaceSm,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      borderRadius: AppRadii.roundedXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 70,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: AppRadii.roundedFull,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: AppRadii.roundedLg,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: AppRadii.roundedSm,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: AppRadii.roundedSm,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            height: 20,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: AppRadii.roundedSm,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.slate200,
              borderRadius: AppRadii.roundedFull,
            ),
          ),
        ],
      ),
    );
  }
}
