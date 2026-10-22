import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

class SplashBrandText extends StatelessWidget {
  final Animation<double> textFade;
  final Animation<double> textSlide;

  const SplashBrandText({super.key, required this.textFade, required this.textSlide});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppLocaleKeys.splashBrandIndex.tr(),
                  style: AppTypography.displayLgMobile(color: colors.secondary),
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocaleKeys.splashBrandPharma.tr(),
                  style: AppTypography.displayLgMobile(color: colors.primaryBrand),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: colors.primaryBrand,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vSpaceXs,
          Text(
            AppLocaleKeys.splashSlogan.tr(),
            style: AppTypography.bodyMd(color: colors.slate500),
          ),
        ],
      ),
    );
  }
}
