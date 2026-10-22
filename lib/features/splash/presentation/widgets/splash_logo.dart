import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_images.dart';

class SplashLogo extends StatelessWidget {
  final Animation<double> logoFade;
  final Animation<double> logoScale;

  const SplashLogo({super.key, required this.logoFade, required this.logoScale});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: Listenable.merge([logoFade, logoScale]),
      builder: (context, child) {
        return Opacity(
          opacity: logoFade.value,
          child: Transform.scale(scale: logoScale.value, child: child),
        );
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: colors.primaryBrand.withValues(alpha: 0.22),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: colors.secondary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset(AppImages.logo, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
