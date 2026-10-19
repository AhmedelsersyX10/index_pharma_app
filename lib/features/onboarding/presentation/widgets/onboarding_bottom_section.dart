import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/widgets.dart';
import 'package:index_pharma/features/onboarding/presentation/widgets/onboarding_dot_indicator.dart';

class OnboardingBottomSection extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onDone;
  final VoidCallback onSignIn;
  final VoidCallback? onRegister;
  final VoidCallback? onExplore;

  const OnboardingBottomSection({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onPrevious,
    required this.onDone,
    required this.onSignIn,
    this.onRegister,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstPage = currentPage == 0;
    final isLastPage = currentPage == totalPages - 1;
    final isRtl = context.locale.languageCode == 'ar';

    final forwardIcon = Transform.scale(
      scaleX: isRtl ? -1 : 1,
      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
    );

    final backIcon = Transform.scale(
      scaleX: isRtl ? -1 : 1,
      child: const Icon(Icons.arrow_back_rounded, color: AppColors.slate700, size: 20),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.spaceLg,
        AppSpacing.spaceSm,
        AppSpacing.spaceLg,
        AppSpacing.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Expanding Pill Indicators
          OnboardingDotIndicator(itemCount: totalPages, currentIndex: currentPage),

          AppSpacing.vSpaceLg,

          // Dynamic Navigation Action Controls
          if (!isLastPage) ...[
            if (isFirstPage)
              AppButton.primary(
                text: AppLocaleKeys.onboardingGetStarted.tr(),
                icon: forwardIcon,
                height: 54,
                onPressed: onNext,
              )
            else
              Row(
                children: [
                  // Circular Back button
                  Material(
                    color: AppColors.slate100,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onPrevious,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.slate200, width: 1),
                        ),
                        child: backIcon,
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.gutterSm),

                  // Next Action Button
                  Expanded(
                    child: AppButton.primary(
                      text: AppLocaleKeys.onboardingContinue.tr(),
                      icon: forwardIcon,
                      height: 54,
                      onPressed: onNext,
                    ),
                  ),
                ],
              ),
          ] else ...[
            // Last Page: Primary CTA (Register / Create Account)
            AppButton.primary(
              text: onRegister != null
                  ? AppLocaleKeys.authCreateAccountLink.tr()
                  : AppLocaleKeys.onboardingStartExploring.tr(),
              icon: forwardIcon,
              height: 54,
              onPressed: onRegister ?? onDone,
            ),

            const SizedBox(height: AppSpacing.gutterSm),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocaleKeys.onboardingAlreadyHaveAccount.tr(),
                  style: AppTypography.bodyMd(color: AppColors.slate500),
                ),
                GestureDetector(
                  onTap: onSignIn,
                  child: Text(
                    AppLocaleKeys.onboardingSignIn.tr(),
                    style: AppTypography.labelLg(color: AppColors.primaryBrand),
                  ),
                ),
              ],
            ),

            if (onExplore != null) ...[
              const SizedBox(height: AppSpacing.gutterSm),
              GestureDetector(
                onTap: onExplore,
                child: Text(
                  AppLocaleKeys.onboardingStartExploring.tr(),
                  style: AppTypography.labelMd(color: AppColors.slate500),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
