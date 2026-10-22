import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

class SplashBackground extends StatelessWidget {
  final Animation<double> pulseGlow;

  const SplashBackground({super.key, required this.pulseGlow});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        // Ambient clinical background illumination
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colors.brandMintSurface, colors.background, colors.surfaceSubtle],
                stops: const [0.0, 0.55, 1.0],
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
                      colors.brandMintBorder.withValues(alpha: 0.5),
                      colors.brandMintSurface.withValues(alpha: 0.15),
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
