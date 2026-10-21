import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/errors/failure_mapper.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../../domain/entities/product.dart';
import 'product_card.dart';

/// Two-column products grid widget strictly matching Stitch Frame B3.
class ProductsGrid extends StatelessWidget {
  const ProductsGrid({
    super.key,
    required this.products,
    this.isLoadingMore = false,
    this.loadingMoreError,
    this.onRetryMore,
    this.onProductTap,
    this.onAddToCart,
  });

  final List<Product> products;
  final bool isLoadingMore;
  final Failure? loadingMoreError;
  final VoidCallback? onRetryMore;
  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.spaceSm,
            mainAxisSpacing: AppSpacing.spaceSm,
            childAspectRatio: 0.58,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: onProductTap != null ? () => onProductTap!(product) : null,
              onAddToCart: onAddToCart != null ? () => onAddToCart!(product) : null,
            );
          },
        ),

        // Pagination loading indicator or retry prompt
        if (isLoadingMore) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceMd,
              vertical: AppSpacing.spaceSm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadii.roundedXl,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.spaceXs),
                Text(
                  AppLocaleKeys.productsLoadingMore.tr(),
                  style: AppTypography.labelMd(
                    color: AppColors.primary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ] else if (loadingMoreError != null) ...[
          const SizedBox(height: AppSpacing.spaceMd),
          Center(
            child: TextButton.icon(
              onPressed: onRetryMore,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                FailureMapper.toMessage(
                  loadingMoreError!,
                  defaultFallback: AppLocaleKeys.commonRetry.tr(),
                ),
                style: AppTypography.bodySm(
                  color: AppColors.error,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
