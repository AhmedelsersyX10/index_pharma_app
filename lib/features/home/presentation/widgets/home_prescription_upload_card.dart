import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Clinical prescription upload strip for B2 Home Screen.
///
/// Features:
/// - Soft mint container (`AppColors.brandMintSurface`)
/// - Reassurance badge ("آمن وسري" / "Doctor verification")
/// - Prominent CTA button to launch prescription upload flow.
///
/// Deviations per decisions:
/// - "Insurance accepted" is omitted (no insurance API).
class HomePrescriptionUploadCard extends StatelessWidget {
  const HomePrescriptionUploadCard({
    super.key,
    this.onUploadTap,
  });

  final VoidCallback? onUploadTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.brandMintSurface,
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: AppColors.brandMintBorder,
          width: 1,
        ),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon & Titles
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadii.roundedLg,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocaleKeys.homeRxServiceTitle.tr(),
                            style: AppTypography.titleMd(
                              color: AppColors.onSurface,
                            ).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            AppLocaleKeys.homeRxServiceSubtitle.tr(),
                            style: AppTypography.labelSm(
                              color: AppColors.brandEmeraldDark,
                            ).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),

              // Micro Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadii.roundedFull,
                  boxShadow: AppShadows.level1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 12,
                      color: AppColors.brandEmeraldDark,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      AppLocaleKeys.homeRxBadgeSecure.tr(),
                      style: AppTypography.labelSm(
                        color: AppColors.brandEmeraldDark,
                      ).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),

          // Body Text
          Text(
            AppLocaleKeys.homeRxHeading.tr(),
            style: AppTypography.titleMd(
              color: AppColors.onSurface,
            ).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocaleKeys.homeRxDesc.tr(),
            style: AppTypography.bodySm(
              color: AppColors.onSurfaceVariant,
            ).copyWith(
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onUploadTap ?? () => context.go('/prescription'),
              icon: const Icon(
                Icons.add_a_photo_outlined,
                size: 18,
                color: Colors.white,
              ),
              label: Text(
                AppLocaleKeys.homeRxCta.tr(),
                style: AppTypography.labelLg(
                  color: Colors.white,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.roundedLg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
