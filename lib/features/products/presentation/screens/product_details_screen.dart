import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_badges.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
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
  });

  final String productId;
  final String? branchId;
  final ProductDetailsCubit? cubit;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final ProductDetailsCubit _cubit;
  bool _isLocalCubit = false;
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
    } else if (GetIt.instance.isRegistered<ProductDetailsCubit>()) {
      _cubit = GetIt.instance<ProductDetailsCubit>();
      _isLocalCubit = true;
    } else {
      throw StateError(
        'ProductDetailsCubit is not registered in GetIt and was not passed to ProductDetailsScreen.',
      );
    }

    _loadDetails();
  }

  void _loadDetails() {
    String? effectiveBranchId = widget.branchId;
    if (effectiveBranchId == null || effectiveBranchId.trim().isEmpty) {
      try {
        final branchState = context.read<BranchCubit>().state;
        if (branchState is BranchLoaded) {
          effectiveBranchId = branchState.selectedBranchId;
        }
      } catch (_) {
        // In isolated test environments where BranchCubit is not in context
      }
    }

    _cubit.loadProductDetails(
      productId: widget.productId,
      branchId: effectiveBranchId,
    );
  }

  @override
  void dispose() {
    if (_isLocalCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  void _handleAddToCart(Product product) {
    final unitLabel = (product.unit != null && product.unit!.trim().isNotEmpty)
        ? product.unit!.trim()
        : AppLocaleKeys.productDetailsUnitDefault.tr();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primaryFixed,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.spaceSm),
            Expanded(
              child: Text(
                AppLocaleKeys.productDetailsAddedToCartSuccess.tr(
                  args: [_selectedQuantity.toString(), unitLabel],
                ),
                style: AppTypography.bodyMd(color: AppColors.inverseOnSurface),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: AppLocaleKeys.productDetailsViewCart.tr(),
          textColor: AppColors.primaryFixed,
          onPressed: () => context.push(AppRouter.kCartView),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
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
              ProductDetailsInitial() || ProductDetailsLoading() =>
                const ProductDetailsSkeleton(),
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
              ProductDetailsLoaded(:final product) => _buildLoadedView(product),
            };
          },
        ),
        bottomNavigationBar: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
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
      ),
    );
  }

  Widget _buildLoadedView(Product product) {
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
          // Top Utility Ribbon: Certified Pharmacy Badge
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: AppBadge.tone(
              label: AppLocaleKeys.productDetailsCertifiedPharmacyBadge.tr(),
              tone: AppBadgeTone.trust,
              icon: const Icon(
                Icons.verified_user_rounded,
                size: 15,
                color: AppColors.brandEmeraldDark,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceSm),

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
          if (product.description != null && product.description!.trim().isNotEmpty) ...[
            ProductDetailsDescriptionCard(
              description: product.description!,
            ),
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
