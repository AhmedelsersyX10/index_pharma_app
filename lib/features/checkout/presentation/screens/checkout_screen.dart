import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/cart/domain/entities/cart_item.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../widgets/checkout_address_card.dart';
import '../widgets/checkout_notes_card.dart';
import '../widgets/checkout_payment_card.dart';
import '../widgets/checkout_phone_card.dart';
import '../widgets/checkout_summary_card.dart';
import '../widgets/stock_conflict_banner.dart';

/// Customer checkout screen conforming to Stitch design `C2_Checkout_عربي`.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    this.checkoutCubit,
    this.cartCubit,
  });

  final CheckoutCubit? checkoutCubit;
  final CartCubit? cartCubit;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutCubit _cubit;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _cubit = widget.checkoutCubit ?? GetIt.instance<CheckoutCubit>();
    _addressController =
        TextEditingController(text: _cubit.state.deliveryAddress);
    _phoneController =
        TextEditingController(text: _cubit.state.customerPhone);
    _notesController = TextEditingController(text: _cubit.state.notes);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    if (widget.checkoutCubit == null) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCartCubit = widget.cartCubit ??
        (GetIt.instance.isRegistered<CartCubit>()
            ? GetIt.instance<CartCubit>()
            : null);

    final providers = [
      BlocProvider<CheckoutCubit>.value(value: _cubit),
      if (effectiveCartCubit != null)
        BlocProvider<CartCubit>.value(value: effectiveCartCubit),
    ];

    return MultiBlocProvider(
      providers: providers,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface.withAlpha(204),
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurface,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(AppRouter.kCartView);
              }
            },
          ),
          title: Text(
            'checkout.title'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ),
        body: BlocConsumer<CheckoutCubit, CheckoutState>(
          listener: (context, state) {
            if (state is CheckoutSuccess) {
              context.go(
                AppRouter.kOrderConfirmationView,
                extra: state.order,
              );
            } else if (state is CheckoutFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return BlocBuilder<CartCubit, CartState>(
              bloc: effectiveCartCubit,
              builder: (context, cartState) {
                final isSubmitting = state is CheckoutSubmitting;
                final cartItems =
                    cartState is CartHasItems ? cartState.items : const <CartItem>[];
                final cartBranchId = cartState is CartHasItems
                    ? cartState.branchId
                    : (cartState is CartEmpty ? cartState.branchId ?? '' : '');
                final totalItems =
                    cartState is CartHasItems ? cartState.totalItemsCount : 0;
                final subtotal =
                    cartState is CartHasItems ? cartState.subtotal : 0.0;
                final currency = 'cart.currency'.tr();

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spaceMd,
                          vertical: AppSpacing.spaceSm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (state is CheckoutConflict)
                              StockConflictBanner(
                                message: state.message,
                                onReturnToCart: () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    context.go(AppRouter.kCartView);
                                  }
                                },
                              ),
                            CheckoutAddressCard(
                              controller: _addressController,
                              onChanged: _cubit.updateAddress,
                              errorMessage: state.addressError,
                            ),
                            const SizedBox(height: AppSpacing.spaceMd),
                            CheckoutPhoneCard(
                              controller: _phoneController,
                              onChanged: _cubit.updatePhone,
                              errorMessage: state.phoneError,
                            ),
                            const SizedBox(height: AppSpacing.spaceMd),
                            CheckoutNotesCard(
                              controller: _notesController,
                              onChanged: _cubit.updateNotes,
                            ),
                            const SizedBox(height: AppSpacing.spaceMd),
                            const CheckoutPaymentCard(),
                            const SizedBox(height: AppSpacing.spaceMd),
                            CheckoutSummaryCard(
                              totalItemsCount: totalItems,
                              subtotal: subtotal,
                            ),
                            const SizedBox(height: AppSpacing.spaceXl),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(
                      context: context,
                      isSubmitting: isSubmitting,
                      subtotal: subtotal,
                      currency: currency,
                      onConfirm: isSubmitting
                          ? null
                          : () {
                              _cubit.submitOrder(
                                branchId: cartBranchId,
                                cartItems: cartItems,
                              );
                            },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBar({
    required BuildContext context,
    required bool isSubmitting,
    required double subtotal,
    required String currency,
    required VoidCallback? onConfirm,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.canvasPure,
        boxShadow: AppShadows.level3,
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              key: const Key('btn_confirm_order'),
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primary.withAlpha(153),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spaceMd,
                  vertical: AppSpacing.spaceSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isSubmitting)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      else
                        const Icon(
                          Icons.lock_outline_rounded,
                          size: 18,
                          color: AppColors.onPrimary,
                        ),
                      const SizedBox(width: AppSpacing.spaceSm),
                      Text(
                        isSubmitting
                            ? 'checkout.submitting_btn'.tr()
                            : 'checkout.confirm_btn'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spaceSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.canvasPure.withAlpha(51),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(
                      '${subtotal.toStringAsFixed(2)} $currency',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  color: AppColors.brandEmeraldDark,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'checkout.disclaimer'.tr(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryMuted,
                    ),
                    textAlign: TextAlign.center,
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
