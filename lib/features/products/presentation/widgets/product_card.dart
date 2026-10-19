import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';
import 'package:index_pharma/core/widgets/app_card.dart';
import '../../domain/entities/product.dart';

/// Clinical product card widget designed strictly according to Stitch design B3.
///
/// Displays:
/// - Prescription requirement pill badge (Rx in red or OTC in mint/emerald)
/// - Medication image (network with graceful clinical fallback)
/// - Commercial brand name and scientific name
/// - Branch stock count
/// - Server-provided selling price (strictly uncomputed)
/// - Add-to-cart clinical CTA button
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final hasImage = product.image != null && product.image!.trim().isNotEmpty;
    final resolvedImageUrl =
        hasImage ? AppConfig.mediaUrl(product.image!.trim()) : '';

    return AppCard(
      isInteractive: true,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.spaceSm),
      borderRadius: AppRadii.roundedXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rx / OTC Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: product.requiresPrescription
                    ? AppBadge.urgent(
                        label: AppLocaleKeys.productsRequiresPrescription.tr(),
                        icon: const Icon(
                          Icons.receipt_long_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : AppBadge.trust(
                        label: AppLocaleKeys.productsOtc.tr(),
                        icon: const Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: AppColors.brandEmeraldDark,
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceXs),

          // Product Image Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadii.roundedLg,
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: resolvedImageUrl.isNotEmpty
                    ? Image.network(
                        resolvedImageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackImage(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildFallbackImage(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Product Commercial Name
          Text(
            product.name,
            style: AppTypography.titleMd(color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Scientific / Active Ingredient Name
          if (product.scientificName != null &&
              product.scientificName!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              product.scientificName!,
              style: AppTypography.bodySm(color: AppColors.slate500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.spaceXs),

          // Available Stock Indicator
          Row(
            children: [
              const Icon(
                Icons.store_mall_directory_outlined,
                size: 15,
                color: AppColors.brandEmeraldDark,
              ),
              const SizedBox(width: AppSpacing.space2xs),
              Expanded(
                child: Text(
                  AppLocaleKeys.productsInStock.tr(
                    args: [product.stockQuantity.toString()],
                  ),
                  style: AppTypography.bodySm(
                    color: AppColors.brandEmeraldDark,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Price & Add to Cart Action
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Server-provided Price (Never calculated by client)
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: product.sellingPrice.toStringAsFixed(2),
                        style: AppTypography.titleLg(
                          color: AppColors.onSurface,
                        ).copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: AppLocaleKeys.productsCurrency.tr(),
                        style: AppTypography.labelSm(
                          color: AppColors.slate600,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceXs),

          // Add to Cart Capsule Button
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: onAddToCart ?? () {},
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                AppLocaleKeys.productsAddToCart.tr(),
                style: AppTypography.labelMd(color: Colors.white).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.roundedFull,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return const Icon(
      Icons.medication_outlined,
      size: 48,
      color: AppColors.slate300,
    );
  }
}
