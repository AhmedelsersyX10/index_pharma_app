import 'package:flutter/material.dart';
import 'package:index_pharma_store/core/theme/theme.dart';
import 'package:index_pharma_store/core/widgets/widgets.dart';

class SplashFooter extends StatelessWidget {
  final Animation<double> footerFade;

  const SplashFooter({
    super.key,
    required this.footerFade,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: footerFade,
      builder: (context, child) {
        return Opacity(
          opacity: footerFade.value,
          child: child,
        );
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
              child: const LinearProgressIndicator(
                backgroundColor: AppColors.slate200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBrand,
                ),
              ),
            ),
          ),

          AppSpacing.vSpaceMd,

          // Trust Badge
          const AppBadge.trust(
            label: 'Certified Healthcare Platform',
            icon: Icon(
              Icons.verified_user_rounded,
              size: 14,
              color: AppColors.brandEmeraldDark,
            ),
          ),
        ],
      ),
    );
  }
}
