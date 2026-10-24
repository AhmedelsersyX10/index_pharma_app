import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/storage/storage_service.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/helpers/cart_action_helper.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../widgets/product_details/product_details_bottom_bar.dart';
import '../widgets/product_details/product_details_description_card.dart';
import '../widgets/product_details/product_details_header.dart';
import '../widgets/product_details/product_details_identity_card.dart';
import '../widgets/product_details/product_details_prescription_banner.dart';
import '../widgets/product_details/product_details_quantity_selector.dart';
import '../widgets/product_details/product_details_showcase_card.dart';
import '../widgets/product_details/product_details_skeleton.dart';

/// Clinical Product Details Screen strictly implementing Stitch B4.
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.branchId,
    this.cubit,
    this.branchCubit,
    this.cartCubit,
  });

  final String productId;
  final String? branchId;
  final ProductDetailsCubit? cubit;
  final BranchCubit? branchCubit;
  final CartCubit? cartCubit;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductDetailsCubit _cubit;
  bool _initialized = false;
  int _selectedQuantity = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _cubit = widget.cubit ?? context.read<ProductDetailsCubit>();
      _loadDetails();
    }
  }

  void _loadDetails() {
    final branchCubit = widget.branchCubit;
    if (branchCubit != null) {
      branchCubit.ensureLoaded();
      _loadForBranch(branchCubit.state);
    } else {
      _cubit.loadProductDetails(
        productId: widget.productId,
        branchId:
            widget.branchId ?? context.read<StorageService>().selectedBranchId,
      );
    }
  }

  void _loadForBranch(BranchState state) {
    if (state is BranchLoaded && state.selectedBranch != null) {
      _cubit.loadProductDetails(
        productId: widget.productId,
        branchId: state.selectedBranchId,
      );
    } else {
      _cubit.clearBranchScope();
    }
  }

  CartCubit _resolveCartCubit() {
    return widget.cartCubit ?? context.read<CartCubit>();
  }

  void _handleAddToCart(Product product) {
    final activeCartCubit = _resolveCartCubit();
    CartActionHelper.addProductToCart(
      context: context,
      cartCubit: activeCartCubit,
      product: product,
      quantity: _selectedQuantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget scaffold = Scaffold(
      backgroundColor: colors.background,
      appBar: ProductDetailsHeader(
        onCartTap: () => context.push(AppRouter.kCartView),
      ),
      body: BlocConsumer<ProductDetailsCubit, ProductDetailsState>(
        listener: (context, state) {
          if (state is ProductDetailsLoaded) {
            final stock = state.product.stockQuantity;
            if (_selectedQuantity > stock && stock > 0) {
              setState(() => _selectedQuantity = stock);
            }
          }
        },
        builder: (context, state) {
          return switch (state) {
            ProductDetailsInitial() ||
            ProductDetailsLoading() => const ProductDetailsSkeleton(),
            ProductDetailsFailure(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: AppErrorView(
                  title: AppLocaleKeys.productsErrorTitle.tr(),
                  message: message,
                  onRetry: _loadDetails,
                ),
              ),
            ),
            ProductDetailsLoaded(:final product) => _buildLoadedView(
              product,
              colors,
            ),
          };
        },
      ),
      bottomNavigationBar:
          BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
            builder: (context, state) {
              if (state is! ProductDetailsLoaded) {
                return const SizedBox.shrink();
              }
              final product = state.product;
              final isAvailable = product.stockQuantity > 0;
              return ProductDetailsBottomBar(
                unitPrice: product.sellingPrice,
                quantity: _selectedQuantity,
                isAvailable: isAvailable,
                onAddToCart: () => _handleAddToCart(product),
              );
            },
          ),
    );

    if (widget.branchCubit != null) {
      scaffold = BlocListener<BranchCubit, BranchState>(
        bloc: widget.branchCubit,
        listener: (context, state) => _loadForBranch(state),
        child: scaffold,
      );
    }

    if (widget.cartCubit != null) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ProductDetailsCubit>.value(value: _cubit),
          BlocProvider<CartCubit>.value(value: widget.cartCubit!),
        ],
        child: scaffold,
      );
    }

    return BlocProvider.value(value: _cubit, child: scaffold);
  }

  Widget _buildLoadedView(Product product, AppColorsExtension colors) {
    final unitLabel = (product.unit != null && product.unit!.trim().isNotEmpty)
        ? product.unit!.trim()
        : AppLocaleKeys.productDetailsUnitDefault.tr();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppSpacing.marginMobile,
        right: AppSpacing.marginMobile,
        top: AppSpacing.spaceSm,
        bottom: AppSpacing.space2xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Showcase Card (Image, MOH Stamp, Expiry Date, Branch Stock)
          ProductDetailsShowcaseCard(product: product),
          const SizedBox(height: AppSpacing.spaceMd),

          // 2. Regulatory Prescription Banner (if product requires prescription)
          if (product.requiresPrescription) ...[
            ProductDetailsPrescriptionBanner(
              onUploadPrescriptionTap: () {
                context.push(AppRouter.kPrescriptionView);
              },
            ),
            const SizedBox(height: AppSpacing.spaceMd),
          ],

          // 3. Drug Nomenclature & Clinical Identity
          ProductDetailsIdentityCard(product: product),
          const SizedBox(height: AppSpacing.spaceMd),

          // 4. Clinical Usage & Guidelines Panel
          if (product.description != null &&
              product.description!.trim().isNotEmpty) ...[
            ProductDetailsDescriptionCard(description: product.description!),
            const SizedBox(height: AppSpacing.spaceMd),
          ],

          // 5. Quantity Stepper
          ProductDetailsQuantitySelector(
            quantity: _selectedQuantity,
            maxStock: product.stockQuantity,
            unit: unitLabel,
            onChanged: (newQty) {
              setState(() => _selectedQuantity = newQty);
            },
          ),
          const SizedBox(height: AppSpacing.spaceXl),
        ],
      ),
    );
  }
}
