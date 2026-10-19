import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/widgets.dart';
import 'package:index_pharma/features/onboarding/data/models/onboarding_model.dart';

class OnboardingPageItem extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingPageItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
      child: Column(
        children: [
          // Illustration Stage Card with Ambient Glow
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  decoration: BoxDecoration(
                    color: AppColors.canvasPure,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.brandMintBorder, width: 1.2),
                    boxShadow: AppShadows.level1,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.spaceLg),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(model.image, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          ),

          // Content section (Badge, Headline, Description, Perks)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBadge.trust(
                  label: model.badgeLabel,
                  icon: Icon(model.badgeIcon, size: 14, color: AppColors.brandEmeraldDark),
                ),

                AppSpacing.vSpaceSm,

                Text(
                  model.title,
                  textAlign: TextAlign.center,
                  style: AppTypography.displayLgMobile(
                    color: AppColors.secondary,
                  ).copyWith(height: 1.22),
                ),

                AppSpacing.vSpaceSm,

                Text(
                  model.description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd(color: AppColors.slate500).copyWith(height: 1.45),
                ),

                AppSpacing.vSpaceSm,

                Text(
                  model.perkText,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSm(color: AppColors.brandEmeraldDark),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.spaceSm),
        ],
      ),
    );
  }
}
