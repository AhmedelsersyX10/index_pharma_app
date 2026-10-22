import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

class OnboardingDotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;

  const OnboardingDotIndicator({super.key, required this.itemCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isSelected = currentIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isSelected ? 30 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isSelected ? colors.primaryBrand : colors.slate200,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primaryBrand.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
