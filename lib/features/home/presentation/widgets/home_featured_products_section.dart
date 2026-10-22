import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/helpers/cart_action_helper.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/features/products/domain/entities/product.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_state.dart';
import 'package:index_pharma/features/products/presentation/widgets/product_card.dart';
import 'package:index_pharma/features/products/presentation/widgets/products_loading_skeleton.dart';

/// Featured Verified Products section for B2 Home Screen.
///
/// Complies with:
/// - Stitch design Section 4 (2-column grid, official pricing header).
/// - Clean Architecture: delegates strictly to [ProductsCubit].
/// - Isolated states: Failure in products section will not blank the rest of the Home screen.
/// - Deviations: Ratings/reviews and fake discount prices are omitted per instructions.
class HomeFeaturedProductsSection extends StatelessWidget {
  const HomeFeaturedProductsSection({
    super.key,
    this.onProductTap,
    this.onAddToCart,
    this.maxItems = 4,
  });

  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onAddToCart;
  final int maxItems;

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
                  AppLocaleKeys.homeFeaturedTitle.tr(),
                  style: AppTypography.titleMd(
                    color: AppColors.onSurface,
                  ).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Flexible(
              child: Text(
                AppLocaleKeys.homeFeaturedSubtitle.tr(),
                style: AppTypography.labelSm(
                  color: AppColors.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spaceSm),

        // Products Grid State Switcher
        BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            return switch (state) {
              ProductsInitial() || ProductsLoading() =>
                const ProductsLoadingSkeleton(itemCount: 4),
              ProductsEmpty() => AppEmptyState(
                  title: AppLocaleKeys.productsEmptyTitle.tr(),
                  message: AppLocaleKeys.productsEmptyDesc.tr(),
                  icon: const Icon(
                    Icons.medication_outlined,
                    size: 32,
                    color: AppColors.slate400,
                  ),
                ),
              ProductsFailure(:final message) => AppErrorView(
                  title: AppLocaleKeys.productsErrorTitle.tr(),
                  message: message,
                  onRetry: () {
                    final branchState = context.read<BranchCubit>().state;
                    final branchId = branchState is BranchLoaded
                        ? branchState.selectedBranchId
                        : null;
                    context
                        .read<ProductsCubit>()
                        .loadFirstPage(branchId: branchId);
                  },
                ),
              ProductsLoaded(:final products) => _FeaturedProductsGrid(
                  products: products.take(maxItems).toList(),
                  onProductTap: onProductTap ??
                      (prod) {
                        context.push(AppRouter.productDetailsPath(prod.id));
                      },
                  onAddToCart: onAddToCart ??
                      (prod) {
                        final cartCubit = context.read<CartCubit>();
                        CartActionHelper.addProductToCart(
                          context: context,
                          cartCubit: cartCubit,
                          product: prod,
                        );
                      },
                ),
            };
          },
        ),
      ],
    );
  }
}

class _FeaturedProductsGrid extends StatelessWidget {
  const _FeaturedProductsGrid({
    required this.products,
    this.onProductTap,
    this.onAddToCart,
  });

  final List<Product> products;
  final ValueChanged<Product>? onProductTap;
  final ValueChanged<Product>? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.spaceSm,
        mainAxisSpacing: AppSpacing.spaceSm,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => onProductTap?.call(product),
          onAddToCart: () => onAddToCart?.call(product),
        );
      },
    );
  }
}
