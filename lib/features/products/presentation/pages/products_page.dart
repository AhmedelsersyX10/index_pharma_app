import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';
import 'package:index_pharma/core/widgets/app_card.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_state.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/products_grid.dart';
import '../widgets/products_loading_skeleton.dart';
import '../widgets/product_search_bar.dart';

/// Full products catalog screen strictly adhering to Stitch Frame B3.
class ProductsPage extends StatelessWidget {
  const ProductsPage({
    super.key,
    this.branchId,
  });

  final String? branchId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductsCubit>(
      create: (context) {
        final cubit = GetIt.instance<ProductsCubit>();
        cubit.loadFirstPage(branchId: branchId);
        return cubit;
      },
      child: _ProductsView(branchId: branchId),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView({this.branchId});

  final String? branchId;

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _ProductsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.branchId != oldWidget.branchId && widget.branchId != null) {
      context.read<ProductsCubit>().reloadForBranch(widget.branchId!);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 250) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<ProductsCubit>().loadFirstPage(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search & Filter Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile,
                    vertical: AppSpacing.spaceSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search Bar
                      ProductSearchBar(
                        onChanged: (keyword) {
                          context
                              .read<ProductsCubit>()
                              .onKeywordChanged(keyword);
                        },
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),

                      // Category Filter Chips
                      _buildCategoryFilters(),
                      const SizedBox(height: AppSpacing.spaceMd),

                      // Section Title
                      _buildSectionHeader(),
                    ],
                  ),
                ),
              ),

              // Products Content (Grid, Skeleton, Empty, or Error)
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildBody(),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space2xl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final productsCubit = context.read<ProductsCubit>();

    return BlocSelector<ProductsCubit, ProductsState, String?>(
      selector: (state) {
        if (state is ProductsLoaded) return state.selectedCategory;
        if (state is ProductsEmpty) return state.selectedCategory;
        if (state is ProductsFailure) return state.selectedCategory;
        return null;
      },
      builder: (context, selectedCategory) {
        // If CategoriesCubit is in the widget tree, consume it, else render empty list
        if (GetIt.instance.isRegistered<CategoriesCubit>()) {
          return BlocBuilder<CategoriesCubit, CategoriesState>(
            bloc: GetIt.instance<CategoriesCubit>()..loadCategories(),
            builder: (context, catState) {
              final categories = catState is CategoriesLoaded
                  ? catState.categories
                  : const [];

              return CategoryFilterChips(
                categories: categories.cast(),
                selectedCategoryId: selectedCategory,
                onSelected: productsCubit.onCategoryChanged,
              );
            },
          );
        }

        return CategoryFilterChips(
          categories: const [],
          selectedCategoryId: selectedCategory,
          onSelected: productsCubit.onCategoryChanged,
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return BlocSelector<ProductsCubit, ProductsState, int?>(
      selector: (state) {
        if (state is ProductsLoaded) return state.total;
        return null;
      },
      builder: (context, totalCount) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocaleKeys.productsTitle.tr(),
              style: AppTypography.titleMd(color: AppColors.onSurface).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (totalCount != null)
              Text(
                '($totalCount)',
                style: AppTypography.labelMd(color: AppColors.primary).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ProductsCubit, ProductsState>(
      buildWhen: (previous, current) {
        // Don't rebuild the entire body when only isLoadingMore changes on ProductsLoaded
        if (previous is ProductsLoaded && current is ProductsLoaded) {
          return previous.products != current.products ||
              previous.isLoadingMore != current.isLoadingMore ||
              previous.loadingMoreError != current.loadingMoreError;
        }
        return true;
      },
      builder: (context, state) {
        return switch (state) {
          ProductsInitial() || ProductsLoading() =>
            const ProductsLoadingSkeleton(),
          ProductsLoaded() => ProductsGrid(
              products: state.products,
              isLoadingMore: state.isLoadingMore,
              loadingMoreError: state.loadingMoreError,
              onRetryMore: () => context.read<ProductsCubit>().loadMore(),
            ),
          ProductsEmpty() => _buildEmptyState(),
          ProductsFailure() => _buildFailureState(state),
        };
      },
    );
  }

  Widget _buildEmptyState() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.slate300,
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            AppLocaleKeys.productsEmptyTitle.tr(),
            style: AppTypography.titleMd(color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            AppLocaleKeys.productsEmptyDesc.tr(),
            style: AppTypography.bodySm(color: AppColors.slate500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          SizedBox(
            width: 160,
            child: AppButton.outlined(
              text: AppLocaleKeys.commonRetry.tr(),
              onPressed: () =>
                  context.read<ProductsCubit>().loadFirstPage(),
              height: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(ProductsFailure state) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            AppLocaleKeys.productsErrorTitle.tr(),
            style: AppTypography.titleMd(color: AppColors.onSurface).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            state.message,
            style: AppTypography.bodySm(color: AppColors.slate500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          SizedBox(
            width: 160,
            child: AppButton.primary(
              text: AppLocaleKeys.commonRetry.tr(),
              onPressed: () => context.read<ProductsCubit>().retry(),
              height: 40,
            ),
          ),
        ],
      ),
    );
  }
}
