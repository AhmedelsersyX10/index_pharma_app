import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// Mandatory Prescription Alert Banner (Regulatory UI) per Stitch B4.
///
/// Displayed when [requiresPrescription] is true.
/// Allows the user to navigate directly to the prescription upload flow.
class ProductDetailsPrescriptionBanner extends StatelessWidget {
  const ProductDetailsPrescriptionBanner({
    super.key,
    this.onUploadPrescriptionTap,
  });

  final VoidCallback? onUploadPrescriptionTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.35),
        borderRadius: AppRadii.roundedXl,
        border: Border.all(
          color: colors.medicalRed.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.medicalRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colors.medicalRed,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocaleKeys.productDetailsRxRequiredTitle.tr(),
                      style: AppTypography.titleMd(
                        color: colors.onSurface,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.space2xs),
                    Text(
                      AppLocaleKeys.productDetailsRxRequiredDesc.tr(),
                      style: AppTypography.bodySm(
                        color: colors.onSurfaceVariant,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onUploadPrescriptionTap ??
                  () {
                    context.push(AppRouter.kPrescriptionView);
                  },
              icon: Icon(
                Icons.add_a_photo_outlined,
                size: 18,
                color: colors.onError,
              ),
              label: Text(
                AppLocaleKeys.productDetailsUploadPrescriptionBtn.tr(),
                style: AppTypography.labelMd(color: colors.onError).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.medicalRed,
                foregroundColor: colors.onError,
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
