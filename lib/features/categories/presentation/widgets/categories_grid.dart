import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import '../../domain/entities/category.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/categories_state.dart';
import 'category_card.dart';

/// Reusable grid widget displaying clinical categories from [CategoriesCubit].
///
/// Implements Clinical Clarity requirements:
/// - Explicit handling for Loading, Empty, Failure, and Loaded states.
/// - Localized texts via `easy_localization`.
/// - Clean architecture: strictly delegates events to [CategoriesCubit].
class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({
    super.key,
    this.showHeader = true,
    this.onViewAll,
    this.onCategorySelected,
    this.selectedCategoryId,
    this.crossAxisCount = 3,
    this.physics = const NeverScrollableScrollPhysics(),
    this.shrinkWrap = true,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.spaceLg),
  });

  final bool showHeader;
  final VoidCallback? onViewAll;
  final ValueChanged<Category>? onCategorySelected;
  final String? selectedCategoryId;
  final int crossAxisCount;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        return Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) ...[
                _CategoriesSectionHeader(onViewAll: onViewAll),
                const SizedBox(height: AppSpacing.spaceMd),
              ],
              switch (state) {
                CategoriesInitial() || CategoriesLoading() => _CategoriesSkeletonGrid(
                  crossAxisCount: crossAxisCount,
                  physics: physics,
                  shrinkWrap: shrinkWrap,
                ),
                CategoriesEmpty() => AppEmptyState(
                  title: AppLocaleKeys.categoriesEmptyTitle.tr(),
                  message: AppLocaleKeys.categoriesEmptyDesc.tr(),
                  icon: Icon(Icons.category_outlined, size: 36, color: context.colors.slate400),
                ),
                CategoriesFailure(:final message) => AppErrorView(
                  title: AppLocaleKeys.categoriesErrorTitle.tr(),
                  message: message,
                  onRetry: () => context.read<CategoriesCubit>().fetchCategories(),
                ),
                CategoriesLoaded(:final categories) => _CategoriesGridView(
                  categories: categories,
                  crossAxisCount: crossAxisCount,
                  selectedCategoryId: selectedCategoryId,
                  onCategorySelected: onCategorySelected,
                  physics: physics,
                  shrinkWrap: shrinkWrap,
                ),
              },
            ],
          ),
        );
      },
    );
  }
}

class _CategoriesSectionHeader extends StatelessWidget {
  const _CategoriesSectionHeader({this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: AppRadii.roundedFull,
              ),
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Text(
              AppLocaleKeys.categoriesTitle.tr(),
              style: AppTypography.titleMd(color: colors.onSurface),
            ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(44, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocaleKeys.categoriesViewAll.tr(),
                  style: AppTypography.labelMd(color: colors.primary),
                ),
                const SizedBox(width: AppSpacing.space2xs),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: colors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

class _CategoriesGridView extends StatelessWidget {
  const _CategoriesGridView({
    required this.categories,
    required this.crossAxisCount,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.physics,
    required this.shrinkWrap,
  });

  final List<Category> categories;
  final int crossAxisCount;
  final String? selectedCategoryId;
  final ValueChanged<Category>? onCategorySelected;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.spaceSm,
        mainAxisSpacing: AppSpacing.spaceSm,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;
        return CategoryCard(
          category: category,
          isSelected: isSelected,
          onTap: () => onCategorySelected?.call(category),
        );
      },
    );
  }
}

class _CategoriesSkeletonGrid extends StatelessWidget {
  const _CategoriesSkeletonGrid({
    required this.crossAxisCount,
    required this.physics,
    required this.shrinkWrap,
  });

  final int crossAxisCount;
  final ScrollPhysics physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.builder(
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.spaceSm,
        mainAxisSpacing: AppSpacing.spaceSm,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: AppRadii.roundedXl,
            border: Border.all(color: colors.borderSubtle, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: colors.slate200, shape: BoxShape.circle),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: colors.slate200,
                  borderRadius: AppRadii.roundedSm,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
