import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';
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
  const ProductsPage({super.key, this.branchId});

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
                          context.read<ProductsCubit>().onKeywordChanged(keyword);
                        },
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),

                      // Live Stock & Availability Notice (per Stitch B3)
                      _buildLiveStockNotice(),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                sliver: SliverToBoxAdapter(child: _buildBody()),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.space2xl)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStockNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.brandEmeraldDark,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.spaceXs),
              Text(
                AppLocaleKeys.productsLiveStock.tr(),
                style: AppTypography.labelSm(
                  color: AppColors.brandEmeraldDark,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            AppLocaleKeys.productsAvailableOnly.tr(),
            style: AppTypography.labelSm(color: AppColors.slate500),
          ),
        ],
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
              final categories = catState is CategoriesLoaded ? catState.categories : const [];

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
              style: AppTypography.titleMd(
                color: AppColors.onSurface,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            if (totalCount != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: AppSpacing.space2xs,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Text(
                  AppLocaleKeys.productsTotalCount.tr(args: [totalCount.toString()]),
                  style: AppTypography.labelSm(
                    color: AppColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w600),
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
          ProductsInitial() || ProductsLoading() => const ProductsLoadingSkeleton(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.spaceLg,
        horizontal: AppSpacing.spaceXs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            AppLocaleKeys.productsEmptyTitle.tr(),
            style: AppTypography.headlineMd(
              color: AppColors.onSurface,
            ).copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            AppLocaleKeys.productsEmptyDesc.tr(),
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // Prescription Assistance Card (per Stitch B3)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.spaceMd),
            decoration: BoxDecoration(
              color: AppColors.brandMintSurface,
              borderRadius: AppRadii.roundedXl,
              border: Border.all(color: AppColors.brandMintBorder, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppColors.brandEmeraldDark,
                    ),
                    const SizedBox(width: AppSpacing.spaceXs),
                    Text(
                      AppLocaleKeys.productsPrescriptionHelpTitle.tr(),
                      style: AppTypography.titleMd(
                        color: AppColors.brandEmeraldDark,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spaceXs),
                Text(
                  AppLocaleKeys.productsPrescriptionHelpDesc.tr(),
                  style: AppTypography.bodySm(color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          TextButton.icon(
            onPressed: () => context.read<ProductsCubit>().loadFirstPage(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              AppLocaleKeys.commonRetry.tr(),
              style: AppTypography.labelMd(
                color: AppColors.primary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(ProductsFailure state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.spaceLg,
        horizontal: AppSpacing.spaceXs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.cloud_off_rounded, size: 36, color: AppColors.onErrorContainer),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            AppLocaleKeys.productsErrorTitle.tr(),
            style: AppTypography.headlineMd(
              color: AppColors.onSurface,
            ).copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            state.message,
            style: AppTypography.bodyMd(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          SizedBox(
            width: 180,
            child: AppButton.primary(
              text: AppLocaleKeys.commonRetry.tr(),
              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
              onPressed: () => context.read<ProductsCubit>().retry(),
              height: 42,
            ),
          ),
        ],
      ),
    );
  }
}
