import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Trust and quality assurance banner highlighting clinical cold chain logistics.
class ColdChainBanner extends StatelessWidget {
  const ColdChainBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cold chain snowflake icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.brandMintSurface,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: const Icon(
              Icons.ac_unit_rounded,
              color: AppColors.brandEmeraldDark,
              size: 24,
            ),
          ),

          const SizedBox(width: AppSpacing.spaceMd),

          // Content description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'branch_selection.cold_chain_title'.tr(),
                  style: AppTypography.titleMd(
                    color: AppColors.onSurface,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'branch_selection.cold_chain_desc'.tr(),
                  style: AppTypography.bodySm(
                    color: AppColors.onSurfaceVariant,
                  ).copyWith(
                    height: 1.45,
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
