import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

class SplashBackground extends StatelessWidget {
  final Animation<double> pulseGlow;

  const SplashBackground({super.key, required this.pulseGlow});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ambient clinical background illumination
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.brandMintSurface, AppColors.background, AppColors.surfaceSubtle],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // Soft glowing pulse behind logo
        Center(
          child: AnimatedBuilder(
            animation: pulseGlow,
            builder: (context, child) {
              return Container(
                width: 250 * pulseGlow.value,
                height: 250 * pulseGlow.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandMintBorder.withValues(alpha: 0.5),
                      AppColors.brandMintSurface.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
