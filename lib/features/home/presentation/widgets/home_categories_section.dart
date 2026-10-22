import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_state.dart';
import 'package:index_pharma/features/categories/presentation/widgets/category_card.dart';

/// Clinical Categories section for B2 Home Screen.
///
/// Displays:
/// - Clinical header with indicator bar and "View All" link.
/// - 3-column grid of top clinical categories (up to 6 items).
/// - Independent Loading, Empty, and Error states.
class HomeCategoriesSection extends StatelessWidget {
  const HomeCategoriesSection({
    super.key,
    this.onViewAll,
    this.onCategoryTap,
    this.maxCategories = 6,
  });

  final VoidCallback? onViewAll;
  final ValueChanged<Category>? onCategoryTap;
  final int maxCategories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadii.roundedFull,
                  ),
                ),
                const SizedBox(width: AppSpacing.spaceSm),
                Text(
                  AppLocaleKeys.categoriesTitle.tr(),
                  style: AppTypography.titleMd(
                    color: AppColors.onSurface,
                  ).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onViewAll ?? () => context.go(AppRouter.browsePath()),
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
                    style: AppTypography.labelSm(
                      color: AppColors.primary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space2xs),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),

        // Categories Grid State Switcher
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            return switch (state) {
              CategoriesInitial() || CategoriesLoading() =>
                const _CategoriesSkeletonGrid(),
              CategoriesEmpty() => AppEmptyState(
                  title: AppLocaleKeys.categoriesEmptyTitle.tr(),
                  message: AppLocaleKeys.categoriesEmptyDesc.tr(),
                  icon: const Icon(
                    Icons.category_outlined,
                    size: 32,
                    color: AppColors.slate400,
                  ),
                ),
              CategoriesFailure(:final message) => AppErrorView(
                  title: AppLocaleKeys.categoriesErrorTitle.tr(),
                  message: message,
                  onRetry: () =>
                      context.read<CategoriesCubit>().fetchCategories(),
                ),
              CategoriesLoaded(:final categories) => _CategoriesLoadedGrid(
                  categories: categories.take(maxCategories).toList(),
                  onCategoryTap: onCategoryTap ??
                      (cat) => context.go(AppRouter.browsePath(categoryId: cat.id)),
                ),
            };
          },
        ),
      ],
    );
  }
}

class _CategoriesLoadedGrid extends StatelessWidget {
  const _CategoriesLoadedGrid({
    required this.categories,
    required this.onCategoryTap,
  });

  final List<Category> categories;
  final ValueChanged<Category> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.spaceSm,
        mainAxisSpacing: AppSpacing.spaceSm,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryCard(
          category: category,
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}

class _CategoriesSkeletonGrid extends StatelessWidget {
  const _CategoriesSkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.spaceSm,
        mainAxisSpacing: AppSpacing.spaceSm,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadii.roundedXl,
            border: Border.all(color: AppColors.borderSubtle, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.slate200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: AppSpacing.spaceSm),
              Container(
                width: 50,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.slate200,
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
