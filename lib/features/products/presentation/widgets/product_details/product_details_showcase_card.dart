import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';
import 'package:index_pharma/core/widgets/app_card.dart';
import '../../../domain/entities/product.dart';

/// Medical product showcase card matching Stitch B4 design.
///
/// Features:
/// - Official MOH registration trust badge and category badge.
/// - 4:3 product image with clinical placeholder fallback.
/// - 2-column clinical indicators bar: Expiry Date and Branch Available Stock.
class ProductDetailsShowcaseCard extends StatelessWidget {
  const ProductDetailsShowcaseCard({super.key, required this.product});

  final Product product;

  String _formatExpiryDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '-';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed != null) {
      return DateFormat('MM / yyyy').format(parsed);
    }
    return rawDate;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = product.image != null && product.image!.trim().isNotEmpty;
    final resolvedImageUrl = hasImage ? AppConfig.mediaUrl(product.image!.trim()) : '';

    final unitLabel = (product.unit != null && product.unit!.trim().isNotEmpty)
        ? product.unit!.trim()
        : AppLocaleKeys.productDetailsUnitDefault.tr();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Ribbon: MOH Stamp & Optional Category Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AppBadge.tone(
                  label: AppLocaleKeys.productDetailsMohRegisteredPill.tr(),
                  tone: AppBadgeTone.trust,
                  icon: const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: AppColors.brandEmeraldDark,
                  ),
                ),
              ),
              if (product.category != null && product.category!.name.trim().isNotEmpty) ...[
                const SizedBox(width: AppSpacing.spaceXs),
                AppBadge.tone(label: product.category!.name.trim(), tone: AppBadgeTone.neutral),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Main Visual Container (4:3 aspect ratio per Stitch B4)
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.roundedLg,
                border: Border.all(color: AppColors.slate200.withValues(alpha: 0.5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: resolvedImageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildFallback(),
                    )
                  : _buildFallback(),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Clinical Quick Indicators Bar (2 columns)
          Row(
            children: [
              // 1. Expiry Date Indicator
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceSm,
                    vertical: AppSpacing.spaceXs + 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppRadii.roundedMd,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.spaceXs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocaleKeys.productDetailsExpiryDateLabel.tr(),
                              style: AppTypography.labelSm(color: AppColors.slate500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatExpiryDate(product.expiryDate),
                              style: AppTypography.labelMd(
                                color: AppColors.onSurface,
                              ).copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),

              // 2. Branch Stock Indicator
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceSm,
                    vertical: AppSpacing.spaceXs + 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: AppRadii.roundedMd,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.spaceXs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocaleKeys.productDetailsDispensingBranch.tr(),
                              style: AppTypography.labelSm(color: AppColors.slate500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.stockQuantity > 0
                                  ? AppLocaleKeys.productDetailsAvailableUnits.tr(
                                      args: [product.stockQuantity.toString(), unitLabel],
                                    )
                                  : AppLocaleKeys.productDetailsOutOfStock.tr(),
                              style: AppTypography.labelMd(
                                color: product.stockQuantity > 0
                                    ? AppColors.brandEmeraldDark
                                    : AppColors.medicalRed,
                              ).copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            AppLocaleKeys.productDetailsMohRegisteredPill.tr(),
            style: AppTypography.labelSm(color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}
