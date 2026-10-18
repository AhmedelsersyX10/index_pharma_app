import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Interactive card enabling prospective customers to browse products as guests.
class GuestAccessCard extends StatelessWidget {
  final VoidCallback? onGuestTap;

  const GuestAccessCard({super.key, this.onGuestTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.roundedXl,
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.canvasPure,
              borderRadius: AppRadii.roundedXl,
              boxShadow: AppShadows.level1,
            ),
            child: const Icon(
              Icons.explore_outlined,
              color: AppColors.primaryBrand,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocaleKeys.authGuestTitle.tr(),
                  style: AppTypography.titleMd(color: AppColors.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocaleKeys.authGuestSubtitle.tr(),
                  style: AppTypography.bodySm(color: AppColors.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          ElevatedButton(
            onPressed: onGuestTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryContainer,
              foregroundColor: AppColors.onSecondaryContainer,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: const StadiumBorder(),
            ),
            child: Text(
              AppLocaleKeys.authGuestButton.tr(),
              style: AppTypography.labelMd(color: AppColors.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
