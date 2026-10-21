import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';
import 'package:index_pharma/core/widgets/app_card.dart';
import '../../../domain/entities/product.dart';

/// Drug Nomenclature & Clinical Identity Card per Stitch B4.
///
/// Displays:
/// - Commercial Brand Name ([product.name])
/// - Category pill badge
/// - Active Pharmaceutical Ingredient ([product.scientificName])
/// - Scannable Barcode & Registry Box ([product.barcode])
class ProductDetailsIdentityCard extends StatelessWidget {
  const ProductDetailsIdentityCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final hasScientificName =
        product.scientificName != null && product.scientificName!.trim().isNotEmpty;
    final hasBarcode = product.barcode != null && product.barcode!.trim().isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Category pill
          if (product.category != null && product.category!.name.trim().isNotEmpty) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppBadge.tone(label: product.category!.name.trim(), tone: AppBadgeTone.info),
            ),
            const SizedBox(height: AppSpacing.spaceXs),
          ],

          // Commercial Product Name
          Text(
            product.name,
            style: AppTypography.headlineMd(
              color: AppColors.onSurface,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Active Pharmaceutical Ingredient Box
          if (hasScientificName) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.spaceSm),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadii.roundedMd,
                border: Border.all(color: AppColors.slate200.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleKeys.productDetailsActiveIngredientLabel.tr(),
                    style: AppTypography.labelSm(
                      color: AppColors.slate500,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      product.scientificName!.trim(),
                      style: AppTypography.bodyMd(
                        color: AppColors.onSurface,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.spaceSm),
          ],

          // Barcode GTIN Box
          if (hasBarcode)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spaceSm,
                vertical: AppSpacing.spaceXs + 2,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: AppRadii.roundedMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocaleKeys.productDetailsBarcodeGtinLabel.tr(),
                          style: AppTypography.labelSm(color: AppColors.slate500),
                        ),
                        const SizedBox(height: 2),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            product.barcode!.trim(),
                            style: AppTypography.bodySm(color: AppColors.onSurface).copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.qr_code_scanner_rounded, size: 26, color: AppColors.slate500),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
