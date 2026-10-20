import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Card component for entering the detailed delivery address per Stitch C2.
class CheckoutAddressCard extends StatelessWidget {
  const CheckoutAddressCard({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorMessage,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.level1,
        border: Border.all(
          color: hasError ? AppColors.error : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pin_drop_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Text(
                    'checkout.delivery_address_title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: AppSpacing.space2xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandMintSurface,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  'checkout.required_badge'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandEmeraldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            decoration: BoxDecoration(
              color: hasError
                  ? AppColors.errorContainer.withAlpha(77)
                  : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: hasError ? AppColors.error : Colors.transparent,
              ),
            ),
            child: TextField(
              key: const Key('checkout_address_field'),
              controller: controller,
              onChanged: onChanged,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
                border: InputBorder.none,
                hintText: 'checkout.delivery_address_hint'.tr(),
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant.withAlpha(128),
                ),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.spaceSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'checkout.delivery_address_helper'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
