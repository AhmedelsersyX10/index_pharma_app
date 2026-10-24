import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/core/widgets/cart_action_button.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/auth/presentation/widgets/login_required_prompt.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/helpers/cart_action_helper.dart';
import 'package:index_pharma/features/categories/domain/entities/category.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_state.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/features/home/presentation/widgets/customer_bottom_nav.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/products_grid.dart';
import '../widgets/products_loading_skeleton.dart';

/// Customer Browse screen conforming to Stitch B3 & B5 designs, Clean Architecture,
/// and project design guidelines.
class ProductsPage extends StatelessWidget {
  const ProductsPage({
    super.key,
    this.initialCategoryId,
    this.initialKeyword,
    this.branchId,
    this.productsCubit,
    this.categoriesCubit,
    this.branchCubit,
    this.cartCubit,
    this.authCubit,
  });

  final String? initialCategoryId;
  final String? initialKeyword;
  final String? branchId;
  final ProductsCubit? productsCubit;
  final CategoriesCubit? categoriesCubit;
  final BranchCubit? branchCubit;
  final CartCubit? cartCubit;
  final AuthCubit? authCubit;

  @override
  Widget build(BuildContext context) {
    if (productsCubit != null ||
        categoriesCubit != null ||
        branchCubit != null ||
        cartCubit != null ||
        authCubit != null) {
      return MultiBlocProvider(
        providers: [
          if (productsCubit != null) BlocProvider.value(value: productsCubit!),
          if (categoriesCubit != null)
            BlocProvider.value(value: categoriesCubit!),
          if (branchCubit != null) BlocProvider.value(value: branchCubit!),
          if (cartCubit != null) BlocProvider.value(value: cartCubit!),
          if (authCubit != null) BlocProvider.value(value: authCubit!),
        ],
        child: _BrowseView(
          initialCategoryId: initialCategoryId,
          initialKeyword: initialKeyword,
          branchId: branchId,
        ),
      );
    }

    return _BrowseView(
      initialCategoryId: initialCategoryId,
      initialKeyword: initialKeyword,
      branchId: branchId,
    );
  }
}

class _BrowseView extends StatefulWidget {
  const _BrowseView({
    this.initialCategoryId,
    this.initialKeyword,
    this.branchId,
  });

  final String? initialCategoryId;
  final String? initialKeyword;
  final String? branchId;

  @override
  State<_BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<_BrowseView> {
  final ScrollController _scrollController = ScrollController();
  String? _lastLoadedBranchId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _lastLoadedBranchId = widget.branchId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialFetch();
    });
  }

  void _checkInitialFetch() {
    if (!mounted) return;
    final branchCubit = context.read<BranchCubit>();
    if (branchCubit.state is BranchInitial) {
      branchCubit.fetchBranches();
    }
    final categoriesCubit = context.read<CategoriesCubit>();
    if (categoriesCubit.state is CategoriesInitial) {
      categoriesCubit.fetchCategories();
    }

    final productsCubit = context.read<ProductsCubit>();
    if (productsCubit.state is ProductsInitial) {
      final currentBranchId =
          widget.branchId ??
          (branchCubit.state is BranchLoaded
              ? (branchCubit.state as BranchLoaded).selectedBranchId
              : null);

      productsCubit.setInitialFilters(
        categoryId: widget.initialCategoryId,
        keyword: widget.initialKeyword,
      );
      if (currentBranchId != null) {
        _lastLoadedBranchId = currentBranchId;
        productsCubit.loadFirstPage(branchId: currentBranchId);
      } else {
        productsCubit.clearBranchScope();
      }
    }
  }

  @override
  void didUpdateWidget(covariant _BrowseView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final categoryChanged =
        widget.initialCategoryId != oldWidget.initialCategoryId;
    final keywordChanged = widget.initialKeyword != oldWidget.initialKeyword;
    final branchChanged =
        widget.branchId != oldWidget.branchId && widget.branchId != null;

    if (categoryChanged || keywordChanged || branchChanged) {
      if (branchChanged) {
        _lastLoadedBranchId = widget.branchId;
      }
      context.read<ProductsCubit>().loadFirstPage(
        branchId: widget.branchId,
        categoryId: widget.initialCategoryId,
        keyword: widget.initialKeyword,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll > 0 && currentScroll >= maxScroll - 250) {
      context.read<ProductsCubit>().loadMore();
    }
  }

  void _handleProtectedNav(String route) {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is! AuthAuthenticated) {
      LoginRequiredBottomSheet.show(context, returnRoute: route);
      return;
    }
    context.go(route);
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.kStoreView);
      case 1:
        // Already on Browse: smoothly scroll to top
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      case 2:
        _handleProtectedNav(AppRouter.kPrescriptionView);
      case 3:
        _handleProtectedNav(AppRouter.kOrdersView);
      case 4:
        context.go(AppRouter.kAccountView);
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
    final colors = context.colors;
    Widget view = Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar.noBack(
        title: AppLocaleKeys.navBrowse.tr(),
        actions: [
          CartActionButton(onTap: () => context.push(AppRouter.kCartView)),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: colors.primary,
          onRefresh: () async {
            await context.read<ProductsCubit>().loadFirstPage();
          },
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
                        initialValue: widget.initialKeyword,
                        onChanged: (keyword) {
                          context.read<ProductsCubit>().onKeywordChanged(
                            keyword,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),

                      // Live Stock & Availability Notice (Stitch Frame B3)
                      _buildLiveStockNotice(colors),
                      const SizedBox(height: AppSpacing.spaceSm),

                      // Category Filter Chips
                      _buildCategoryFilters(),
                      const SizedBox(height: AppSpacing.spaceMd),

                      // Section Title & Total Count Header
                      _buildSectionHeader(colors),
                    ],
                  ),
                ),
              ),

              // Products Content Grid, Skeleton, Empty, or Error
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.marginMobile,
                ),
                sliver: SliverToBoxAdapter(child: _buildBody(colors)),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.space2xl),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomerBottomNav(
        currentIndex: 1,
        onTap: _onBottomNavTapped,
      ),
    );

    view = BlocListener<BranchCubit, BranchState>(
      listener: (context, state) {
        if (state is BranchLoaded &&
            state.selectedBranchId != null &&
            state.selectedBranchId != _lastLoadedBranchId) {
          _lastLoadedBranchId = state.selectedBranchId;
          context.read<ProductsCubit>().reloadForBranch(
            state.selectedBranchId!,
          );
        } else if (state is! BranchLoaded || state.selectedBranch == null) {
          _lastLoadedBranchId = null;
          context.read<ProductsCubit>().clearBranchScope();
        }
      },
      child: view,
    );

    return view;
  }

  Widget _buildLiveStockNotice(AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2xs),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colors.brandEmeraldDark,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: Text(
              AppLocaleKeys.productsLiveStock.tr(),
              style: AppTypography.labelSm(
                color: colors.brandEmeraldDark,
              ).copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Text(
            AppLocaleKeys.productsAvailableOnly.tr(),
            style: AppTypography.labelSm(color: colors.neutral),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return BlocSelector<ProductsCubit, ProductsState, String?>(
      selector: (state) {
        if (state is ProductsLoaded) return state.selectedCategory;
        if (state is ProductsEmpty) return state.selectedCategory;
        if (state is ProductsFailure) return state.selectedCategory;
        return null;
      },
      builder: (context, selectedCategory) {
        return BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, catState) {
            final categories = catState is CategoriesLoaded
                ? catState.categories
                : const <Category>[];

            return CategoryFilterChips(
              categories: categories,
              selectedCategoryId: selectedCategory,
              onSelected: (categoryId) {
                context.read<ProductsCubit>().onCategoryChanged(categoryId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(AppColorsExtension colors) {
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
                color: colors.onSurface,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            if (totalCount != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceSm,
                  vertical: AppSpacing.space2xs,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Text(
                  AppLocaleKeys.productsTotalCount.tr(
                    args: [totalCount.toString()],
                  ),
                  style: AppTypography.labelSm(
                    color: colors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBody(AppColorsExtension colors) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      buildWhen: (previous, current) {
        if (previous is ProductsLoaded && current is ProductsLoaded) {
          return previous.products != current.products ||
              previous.isLoadingMore != current.isLoadingMore ||
              previous.loadingMoreError != current.loadingMoreError;
        }
        return true;
      },
      builder: (context, state) {
        return switch (state) {
          ProductsInitial() ||
          ProductsLoading() => const ProductsLoadingSkeleton(),
          ProductsLoaded() => ProductsGrid(
            products: state.products,
            isLoadingMore: state.isLoadingMore,
            loadingMoreError: state.loadingMoreError,
            onRetryMore: () => context.read<ProductsCubit>().loadMore(),
            onProductTap: (product) =>
                context.push(AppRouter.productDetailsPath(product.id)),
            onAddToCart: (product) {
              final cartCubit = context.read<CartCubit>();
              CartActionHelper.addProductToCart(
                context: context,
                cartCubit: cartCubit,
                product: product,
              );
            },
          ),
          ProductsEmpty() => _buildEmptyState(colors),
          ProductsFailure() => _buildFailureState(state),
        };
      },
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
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
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          Text(
            AppLocaleKeys.productsEmptyTitle.tr(),
            style: AppTypography.headlineMd(
              color: colors.onSurface,
            ).copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Text(
            AppLocaleKeys.productsEmptyDesc.tr(),
            style: AppTypography.bodyMd(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spaceLg),

          // Prescription Assistance Card (Stitch Frame B3)
          InkWell(
            onTap: () => _handleProtectedNav(AppRouter.kPrescriptionView),
            borderRadius: AppRadii.roundedXl,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.spaceMd),
              decoration: BoxDecoration(
                color: colors.brandMintSurface,
                borderRadius: AppRadii.roundedXl,
                border: Border.all(color: colors.brandMintBorder, width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 20,
                        color: colors.brandEmeraldDark,
                      ),
                      const SizedBox(width: AppSpacing.spaceXs),
                      Text(
                        AppLocaleKeys.productsPrescriptionHelpTitle.tr(),
                        style: AppTypography.titleMd(
                          color: colors.brandEmeraldDark,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spaceXs),
                  Text(
                    AppLocaleKeys.productsPrescriptionHelpDesc.tr(),
                    style: AppTypography.bodySm(color: colors.onSurface),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          TextButton.icon(
            onPressed: () => context.read<ProductsCubit>().loadFirstPage(),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              AppLocaleKeys.commonRetry.tr(),
              style: AppTypography.labelMd(
                color: colors.primary,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(ProductsFailure state) {
    return AppErrorView(
      title: AppLocaleKeys.productsErrorTitle.tr(),
      message: state.message,
      onRetry: () => context.read<ProductsCubit>().retry(),
    );
  }
}
