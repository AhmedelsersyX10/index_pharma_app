import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import '../../domain/entities/category.dart';

/// Reusable card component displaying a single clinical category.
///
/// Strictly follows Clinical Clarity design system:
/// - Level 1 ambient shadow
/// - Mint tonal circle with clinical department icon
/// - Clear typography adhering to 8pt spatial grid
/// - Accessible touch target (>= 44px)
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  final Category category;
  final VoidCallback? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = isSelected
        ? colors.primary
        : colors.borderSubtle;
    final backgroundColor = isSelected
        ? colors.brandMintSurface
        : colors.canvasPure;

    return Semantics(
      button: true,
      label: category.name,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.roundedXl,
          child: Container(
            constraints: const BoxConstraints(minHeight: 88, minWidth: 88),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.spaceMd,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: AppRadii.roundedXl,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected ? context.shadowsLevel2 : context.shadowsLevel1,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CategoryIconBadge(
                  name: category.name,
                  isSelected: isSelected,
                ),
                const SizedBox(height: AppSpacing.spaceSm),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMd(
                    color: isSelected ? colors.primary : colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIconBadge extends StatelessWidget {
  const _CategoryIconBadge({
    required this.name,
    required this.isSelected,
  });

  final String name;
  final bool isSelected;

  IconData _resolveCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('skin') ||
        lower.contains('\u0628\u0634\u0631\u0629') ||
        lower.contains('\u062c\u0644\u062f')) {
      return Icons.spa_outlined;
    }
    if (lower.contains('vitamin') ||
        lower.contains('\u0641\u064a\u062a\u0627\u0645\u064a\u0646') ||
        lower.contains('\u0645\u0643\u0645\u0644')) {
      return Icons.health_and_safety_outlined;
    }
    if (lower.contains('cardio') ||
        lower.contains('heart') ||
        lower.contains('\u0642\u0644\u0628')) {
      return Icons.favorite_outline;
    }
    if (lower.contains('pain') ||
        lower.contains('\u0623\u0644\u0645') ||
        lower.contains('\u0645\u0633\u0643\u0646')) {
      return Icons.healing_outlined;
    }
    if (lower.contains('diabetes') ||
        lower.contains('\u0633\u0643\u0631')) {
      return Icons.monitor_heart_outlined;
    }
    if (lower.contains('digest') ||
        lower.contains('\u0645\u0639\u062f\u0629') ||
        lower.contains('\u0647\u0636\u0645')) {
      return Icons.medication_liquid_outlined;
    }
    return Icons.medication_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconData = _resolveCategoryIcon(name);

    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? colors.primary
            : colors.brandMintSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? colors.primary : colors.brandMintBorder,
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        size: 22,
        color: isSelected ? colors.onPrimary : colors.primary,
      ),
    );
  }
}
