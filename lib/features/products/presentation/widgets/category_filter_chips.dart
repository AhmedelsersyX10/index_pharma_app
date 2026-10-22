import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';

/// Horizontal category filter chips adhering to Stitch Frame B3.
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAllSelected = selectedCategoryId == null;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (context, _) =>
            const SizedBox(width: AppSpacing.spaceXs),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildChip(
              context: context,
              colors: colors,
              label: AppLocaleKeys.productsAll.tr(),
              isSelected: isAllSelected,
              onTap: () => onSelected(null),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;

          return _buildChip(
            context: context,
            colors: colors,
            label: category.name,
            isSelected: isSelected,
            onTap: () => onSelected(category.id),
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required AppColorsExtension colors,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.roundedFull,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surfaceContainerLowest,
          borderRadius: AppRadii.roundedFull,
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.borderSubtle,
            width: 1,
          ),
          boxShadow: isSelected ? null : context.shadowsLevel1,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelMd(
            color: isSelected ? Colors.white : colors.onSurface,
          ).copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
