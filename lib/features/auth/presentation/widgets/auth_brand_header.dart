import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_images.dart';

/// Brand Header for Authentication screens displaying logo, titles, and clinical badge.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        const SizedBox(height: AppSpacing.spaceSm),
        // App Logo with glowing badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(AppSpacing.spaceSm),
              decoration: BoxDecoration(
                color: colors.canvasPure,
                borderRadius: AppRadii.roundedXl,
                boxShadow: context.shadowsLevel1,
              ),
              child: Image.asset(AppImages.logo, fit: BoxFit.contain),
            ),
            PositionedDirectional(
              top: -2,
              end: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: colors.primaryBrand,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.canvasPure, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        Text(
          AppLocaleKeys.authLoginTitle.tr(),
          style: AppTypography.headlineLg(color: colors.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space2xs),
        Text(
          AppLocaleKeys.authLoginSubtitle.tr(),
          style: AppTypography.bodyMd(color: colors.secondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.spaceMd),
        // Clinical Trust Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.brandMintSurface,
            borderRadius: AppRadii.roundedFull,
            border: Border.all(color: colors.brandMintBorder, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 16, color: colors.brandEmeraldDark),
              const SizedBox(width: AppSpacing.space2xs),
              Text(
                AppLocaleKeys.authClinicalBadge.tr(),
                style: AppTypography.labelSm(color: colors.brandEmeraldDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spaceLg),
      ],
    );
  }
}
