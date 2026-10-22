import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/widgets.dart';

class SplashFooter extends StatelessWidget {
  final Animation<double> footerFade;

  const SplashFooter({super.key, required this.footerFade});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: footerFade,
      builder: (context, child) {
        return Opacity(opacity: footerFade.value, child: child);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sleek clinical loading progress capsule
          SizedBox(
            width: 90,
            height: 4,
            child: ClipRRect(
              borderRadius: AppRadii.roundedFull,
              child: LinearProgressIndicator(
                backgroundColor: colors.slate200,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primaryBrand),
              ),
            ),
          ),

          AppSpacing.vSpaceMd,

          // Trust Badge
          AppBadge.trust(
            label: AppLocaleKeys.splashCertifiedPlatform.tr(),
            icon: Icon(
              Icons.verified_user_rounded,
              size: 14,
              color: colors.brandEmeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}
