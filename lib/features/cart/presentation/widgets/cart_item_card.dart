import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/constants/app_config.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';

/// Single Cart Item Card conforming to Stitch C1 design specifications.
///
/// Features:
/// - Product image with Rx and stock constraint badges.
/// - Product commercial name and active pharmaceutical ingredient.
/// - Package/unit display label.
/// - Unit selling price strictly from server model.
/// - Minimum-1 and maximum-stock clamped quantity stepper.
/// - Delete button with confirmation.
class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final isMaxStock = item.quantity >= product.stockQuantity;
    final isMinQty = item.quantity <= 1;
    final hasImage = product.image != null && product.image!.trim().isNotEmpty;
    final imageUrl = hasImage ? AppConfig.mediaUrl(product.image!.trim()) : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.roundedXl,
        boxShadow: AppShadows.level1,
        border: Border.all(
          color: isMaxStock
              ? AppColors.medicalAmber.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper Row: Image + Names + Delete Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Badge Overlays
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: AppRadii.roundedLg,
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadii.roundedLg,
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => _buildFallbackImage(),
                              )
                            : _buildFallbackImage(),
                      ),
                    ),

                    // Rx badge overlay
                    if (product.requiresPrescription)
                      PositionedDirectional(
                        bottom: 0,
                        end: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: const BoxDecoration(
                            color: AppColors.brandEmeraldDark,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(4)),
                          ),
                          child: const Text(
                            'Rx',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Limited stock warning badge
                    if (product.stockQuantity <= 3 && product.stockQuantity > 0)
                      PositionedDirectional(
                        top: 0,
                        start: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: const BoxDecoration(
                            color: AppColors.medicalAmber,
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(4)),
                          ),
                          child: Text(
                            AppLocaleKeys.cartLimitedStockBadge.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.spaceMd),

              // Title, Active Ingredient, and Unit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTypography.titleMd(
                        color: AppColors.onSurface,
                      ).copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                    if (product.unit != null && product.unit!.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.space2xs),
                      Text(
                        product.unit!,
                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.secondary,
                ),
                tooltip: AppLocaleKeys.cartDeleteItemTooltip.tr(),
                splashRadius: 20,
                onPressed: () => _confirmRemove(context),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.spaceSm),

          // Bottom Row: Unit Price + Quantity Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocaleKeys.cartUnitPriceLabel.tr(),
                    style: AppTypography.labelSm(color: AppColors.secondary),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        product.sellingPrice.toStringAsFixed(2),
                        style: AppTypography.titleMd(
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: AppSpacing.space2xs),
                      Text(
                        AppLocaleKeys.cartCurrency.tr(),
                        style: AppTypography.labelSm(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),

              // Stepper: [-] [qty] [+]
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.roundedLg,
                ),
                padding: const EdgeInsets.all(AppSpacing.space2xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decrement Button
                    _StepperButton(
                      icon: Icons.remove,
                      tooltip: isMinQty ? AppLocaleKeys.cartMinQtyReached.tr() : null,
                      isEnabled: !isMinQty,
                      isPrimary: false,
                      onTap: isMinQty ? null : () => onQuantityChanged(item.quantity - 1),
                    ),

                    // Quantity Display
                    SizedBox(
                      width: 36,
                      child: Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                        style: AppTypography.titleMd(
                          color: AppColors.onSurface,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Increment Button
                    _StepperButton(
                      icon: Icons.add,
                      tooltip: isMaxStock ? AppLocaleKeys.cartMaxStockReached.tr() : null,
                      isEnabled: !isMaxStock,
                      isPrimary: true,
                      onTap: isMaxStock ? null : () => onQuantityChanged(item.quantity + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return const Center(
      child: Icon(Icons.medication_outlined, size: 32, color: AppColors.slate300),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          AppLocaleKeys.cartDeleteDialogTitle.tr(),
          style: AppTypography.titleMd().copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocaleKeys.cartDeleteDialogMessage.tr(args: [item.product.name]),
          style: AppTypography.bodyMd(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocaleKeys.cartCancel.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.medicalRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              onRemove();
            },
            child: Text(AppLocaleKeys.cartDeleteConfirm.tr()),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.isEnabled,
    required this.isPrimary,
    this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final bool isEnabled;
  final bool isPrimary;
  final String? tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: AppRadii.roundedMd,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: !isEnabled
                ? AppColors.surfaceDim.withValues(alpha: 0.4)
                : (isPrimary ? AppColors.primary : AppColors.surfaceContainerLowest),
            borderRadius: AppRadii.roundedMd,
            boxShadow: isEnabled && !isPrimary ? AppShadows.level1 : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: !isEnabled
                ? AppColors.onSurface.withValues(alpha: 0.3)
                : (isPrimary ? Colors.white : AppColors.onSurface),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
