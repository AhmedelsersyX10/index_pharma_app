import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/widgets.dart';

class OnboardingTopBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;

  const OnboardingTopBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceLg,
        vertical: AppSpacing.spaceSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step Counter Badge
          AppBadge.neutral(
            label: AppLocaleKeys.onboardingStepCounter.tr(args: ['${currentPage + 1}', '$totalPages']),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),

          // Smooth animated Skip button
          AnimatedOpacity(
            opacity: isLastPage ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: isLastPage,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.slate500,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppLocaleKeys.onboardingSkip.tr(),
                  style: AppTypography.labelLg(color: AppColors.slate500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
