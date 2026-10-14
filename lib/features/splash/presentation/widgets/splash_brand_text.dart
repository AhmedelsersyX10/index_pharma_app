import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

class SplashBrandText extends StatelessWidget {
  final Animation<double> textFade;
  final Animation<double> textSlide;

  const SplashBrandText({super.key, required this.textFade, required this.textSlide});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([textFade, textSlide]),
      builder: (context, child) {
        return Opacity(
          opacity: textFade.value,
          child: Transform.translate(offset: Offset(0, textSlide.value), child: child),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocaleKeys.brandNameIndex.tr(),
                style: AppTypography.displayLgMobile(color: AppColors.secondary),
              ),
              const SizedBox(width: 6),
              Text(
                AppLocaleKeys.brandNamePharma.tr(),
                style: AppTypography.displayLgMobile(color: AppColors.primaryBrand),
              ),
              const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 14),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBrand,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          AppSpacing.vSpaceXs,
          Text(
            AppLocaleKeys.brandSlogan.tr(),
            style: AppTypography.bodyMd(color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}
