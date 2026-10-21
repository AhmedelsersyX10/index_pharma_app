import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Interactive card component representing a language choice (Stitch A3).
///
/// Features distinct selected/unselected visual states with custom radio checkmarks,
/// clinical typography, and layout orientation metadata chips.
class LanguageSelectionCard extends StatelessWidget {
  const LanguageSelectionCard({
    super.key,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
    required this.iconText,
    required this.title,
    required this.badge,
  });

  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;
  final String iconText;
  final String title;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('language_card_$languageCode'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderSubtle.withValues(alpha: 0.6),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? const [BoxShadow(color: Color(0x1400966B), blurRadius: 14, offset: Offset(0, 4))]
              : const [BoxShadow(color: Color(0x060B1C30), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.brandMintSurface : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      iconText,
                      style: AppTypography.titleLg(
                        color: isSelected ? AppColors.primary : AppColors.secondary,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Text Content
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AppTypography.titleLg(
                                color: AppColors.onSurface,
                              ).copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.brandMintSurface
                                  : AppColors.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: AppTypography.labelSm(
                                color: isSelected
                                    ? AppColors.brandEmeraldDark
                                    : AppColors.onSecondaryContainer,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Custom Radio Visual
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
