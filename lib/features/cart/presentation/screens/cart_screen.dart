import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_header.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_order_summary_card.dart';
import '../widgets/cart_rx_reminder_card.dart';
import '../widgets/cart_stock_alert_banner.dart';

/// Customer shopping cart screen adhering strictly to Stitch C1 design.
///
/// Features:
/// - Reactive sealed state rendering ([CartEmpty] vs [CartHasItems]).
/// - Branch-scoped cart with context badge and single-branch validation.
/// - Minimum 1 and maximum stock-clamped quantity controls.
/// - Item deletion with confirmation dialog.
/// - Stock adjustment alert banner.
/// - Prescription (Rx) compliance reminder card.
/// - Estimated invoice summary card (strictly based on server prices).
/// - Sticky bottom checkout bar with navigation to `/checkout`.
class CartScreen extends StatelessWidget {
  const CartScreen({
    super.key,
    this.cartCubit,
  });

  final CartCubit? cartCubit;

  @override
  Widget build(BuildContext context) {
    if (cartCubit != null) {
      return BlocProvider.value(
        value: cartCubit!,
        child: const _CartScreenContent(),
      );
    }

    return const _CartScreenContent();
  }
}

class _CartScreenContent extends StatefulWidget {
  const _CartScreenContent();

  @override
  State<_CartScreenContent> createState() => _CartScreenContentState();
}

class _CartScreenContentState extends State<_CartScreenContent> {
  @override
  void initState() {
    super.initState();
    // Load cart on entry if not yet loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<CartCubit>();
      if (cubit.state is CartEmpty) {
        cubit.loadCart();
      }
    });
  }

  String? _resolveBranchName(BuildContext context, String? branchId) {
    if (branchId == null) return null;
    final branchState = context.read<BranchCubit>().state;
    if (branchState is BranchLoaded) {
      final match = branchState.branches
          .where((b) => b.id == branchId)
          .firstOrNull;
      return match?.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cubit = context.read<CartCubit>();

        return switch (state) {
          CartEmpty(:final branchId) => Scaffold(
              backgroundColor: colors.background,
              appBar: CartHeader(
                branchName: _resolveBranchName(context, branchId),
                itemsCount: 0,
              ),
              body: const SafeArea(
                child: CartEmptyView(),
              ),
            ),
          CartHasItems(
            :final branchId,
            :final items,
            :final subtotal,
            :final totalItemsCount,
            :final totalUniqueProducts,
            :final hasRxItems,
            :final stockAlertMessage,
          ) =>
            Scaffold(
              backgroundColor: colors.background,
              appBar: CartHeader(
                branchName: _resolveBranchName(context, branchId),
                itemsCount: totalUniqueProducts,
              ),
              body: SafeArea(
                bottom: false,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile,
                    vertical: AppSpacing.spaceSm,
                  ),
                  children: [
                    // Branch Context Strip with Location Icon and items count
                    _buildBranchContextStrip(
                      context,
                      branchName: _resolveBranchName(context, branchId),
                      itemsCount: totalUniqueProducts,
                    ),

                    const SizedBox(height: AppSpacing.spaceSm),

                    // Stock adjustment alert banner (if any item was capped)
                    if (stockAlertMessage != null) ...[
                      CartStockAlertBanner(
                        productName: stockAlertMessage,
                        onDismiss: () => cubit.dismissStockAlert(),
                      ),
                      const SizedBox(height: AppSpacing.spaceSm),
                    ],

                    // Rx prescription reminder pill (if any item is Rx)
                    if (hasRxItems) ...[
                      const CartRxReminderCard(),
                      const SizedBox(height: AppSpacing.spaceSm),
                    ],

                    // Cart Items List
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.spaceSm),
                        child: CartItemCard(
                          item: item,
                          onQuantityChanged: (newQty) {
                            cubit.changeQuantity(item.product.id, newQty);
                          },
                          onRemove: () {
                            cubit.removeFromCart(item.product.id);
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: AppSpacing.spaceXs),

                    // Order Summary Card
                    CartOrderSummaryCard(
                      subtotal: subtotal,
                      totalUnitsCount: totalItemsCount,
                    ),

                    // Padding for bottom checkout bar
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              bottomNavigationBar: CartBottomBar(
                totalAmount: subtotal,
                onCheckout: () => context.push(AppRouter.kCheckoutView),
              ),
            ),
        };
      },
    );
  }

  Widget _buildBranchContextStrip(
    BuildContext context, {
    required String? branchName,
    required int itemsCount,
  }) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (branchName != null && branchName.trim().isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spaceSm,
              vertical: AppSpacing.space2xs,
            ),
            decoration: BoxDecoration(
              color: colors.brandMintSurface,
              borderRadius: AppRadii.roundedFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: colors.brandEmeraldDark,
                ),
                const SizedBox(width: AppSpacing.space2xs),
                Text(
                  branchName,
                  style: AppTypography.labelSm(
                    color: colors.brandEmeraldDark,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
        Text(
          AppLocaleKeys.cartItemsCount.tr(args: [itemsCount.toString()]),
          style: AppTypography.labelSm(color: colors.secondary),
        ),
      ],
    );
  }
}
