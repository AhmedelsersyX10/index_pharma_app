import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Card showing the cash-on-delivery payment method (only supported payment method).
class CheckoutPaymentCard extends StatelessWidget {
  const CheckoutPaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: AppShadows.level1,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.payments_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Text(
                'checkout.payment_title'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.brandMintSurface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.brandMintBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.canvasPure,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'checkout.payment_cod_title'.tr(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.spaceSm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadii.full),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  color: AppColors.onPrimary,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'checkout.payment_cod_badge'.tr(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'checkout.payment_cod_desc'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
