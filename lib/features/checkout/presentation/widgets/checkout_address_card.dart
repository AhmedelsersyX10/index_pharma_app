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
    final colors = context.colors;
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: context.shadowsLevel1,
        border: Border.all(
          color: hasError ? colors.error : colors.borderSubtle,
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
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pin_drop_rounded,
                      color: colors.primary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spaceSm),
                  Text(
                    'checkout.delivery_address_title'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
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
                  color: colors.brandMintSurface,
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(
                  'checkout.required_badge'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.brandEmeraldDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            decoration: BoxDecoration(
              color: hasError
                  ? colors.errorContainer.withAlpha(77)
                  : colors.surfaceSubtle,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(
                color: hasError ? colors.error : Colors.transparent,
              ),
            ),
            child: TextField(
              key: const Key('checkout_address_field'),
              controller: controller,
              onChanged: onChanged,
              maxLines: 3,
              style: AppTypography.bodyMd(color: colors.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.all(AppSpacing.spaceSm),
                hintText: 'checkout.delivery_address_hint'.tr(),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: colors.error,
                  size: 15,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colors.error,
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
              Icon(
                Icons.info_outline_rounded,
                color: colors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'checkout.delivery_address_helper'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.secondaryMuted,
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
