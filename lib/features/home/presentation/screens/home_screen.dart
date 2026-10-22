import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:index_pharma/features/categories/presentation/cubit/categories_state.dart';
import 'package:index_pharma/features/products/presentation/cubit/products_cubit.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:index_pharma/features/settings/presentation/cubit/settings_state.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/route_placeholder_screens.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:index_pharma/features/auth/presentation/cubit/auth_state.dart';
import 'package:index_pharma/features/auth/presentation/widgets/login_required_prompt.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/helpers/cart_action_helper.dart';
import '../widgets/customer_bottom_nav.dart';
import '../widgets/home_branch_selector_strip.dart';
import '../widgets/home_categories_section.dart';
import '../widgets/home_featured_products_section.dart';
import '../widgets/home_header_bar.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/home_prescription_upload_card.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_storage_guarantee_footer.dart';

/// Full customer Home screen adhering to Stitch design B2 (Arabic RTL / English LTR).
///
/// Features:
/// 1. Section widgets:
///    - Header (brand IP + branch info + cart badge + profile)
///    - Branch selector strip & live stock pill
///    - Search bar (without barcode scanner per decisions)
///    - Hero banner (dynamic settings from [SettingsCubit] with fallback)
///    - Prescription upload card (without insurance claims per decisions)
///    - Therapeutic categories grid (from [CategoriesCubit])
///    - Featured products grid (from [ProductsCubit] scoped to selected branch)
///    - Storage guarantee footer
///    - Customer bottom navigation (Home, Browse, Prescription, Orders, Account)
/// 2. Independent loading/empty/failure state handling across sections.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.branchCubit,
    this.settingsCubit,
    this.categoriesCubit,
    this.productsCubit,
    this.cartCubit,
  });

  final BranchCubit? branchCubit;
  final SettingsCubit? settingsCubit;
  final CategoriesCubit? categoriesCubit;
  final ProductsCubit? productsCubit;
  final CartCubit? cartCubit;

  @override
  Widget build(BuildContext context) {
    final hasRequiredServices =
        branchCubit != null || getIt.isRegistered<BranchCubit>();

    if (!hasRequiredServices) {
      return const StorePlaceholderScreen();
    }

    return MultiBlocProvider(
      providers: [
        if (branchCubit != null)
          BlocProvider.value(value: branchCubit!)
        else if (getIt.isRegistered<BranchCubit>())
          BlocProvider<BranchCubit>(
            create: (context) => getIt<BranchCubit>()..fetchBranches(),
          ),
        if (settingsCubit != null)
          BlocProvider.value(value: settingsCubit!)
        else if (getIt.isRegistered<SettingsCubit>())
          BlocProvider<SettingsCubit>(
            create: (context) => getIt<SettingsCubit>()..fetchSettings(),
          ),
        if (categoriesCubit != null)
          BlocProvider.value(value: categoriesCubit!)
        else if (getIt.isRegistered<CategoriesCubit>())
          BlocProvider<CategoriesCubit>(
            create: (context) => getIt<CategoriesCubit>()..fetchCategories(),
          ),
        if (productsCubit != null)
          BlocProvider.value(value: productsCubit!)
        else if (getIt.isRegistered<ProductsCubit>())
          BlocProvider<ProductsCubit>(
            create: (context) => getIt<ProductsCubit>(),
          ),
        if (cartCubit != null)
          BlocProvider.value(value: cartCubit!)
        else if (getIt.isRegistered<CartCubit>())
          BlocProvider<CartCubit>.value(
            value: getIt<CartCubit>(),
          ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final ScrollController _scrollController = ScrollController();
  String? _lastLoadedBranchId;

  @override
  void initState() {
    super.initState();
    // Initialize products fetch with current branch if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndFetchProducts();
    });
  }

  void _checkAndFetchProducts() {
    if (!mounted) return;
    try {
      final branchCubit = context.read<BranchCubit>();
      if (branchCubit.state is BranchInitial) {
        branchCubit.fetchBranches();
      }
      final categoriesCubit = context.read<CategoriesCubit>();
      if (categoriesCubit.state is CategoriesInitial) {
        categoriesCubit.fetchCategories();
      }
      final settingsCubit = context.read<SettingsCubit>();
      if (settingsCubit.state is SettingsInitial) {
        settingsCubit.fetchSettings();
      }

      final branchState = branchCubit.state;
      if (branchState is BranchLoaded && branchState.selectedBranchId != null) {
        final currentBranchId = branchState.selectedBranchId;
        if (_lastLoadedBranchId != currentBranchId) {
          _lastLoadedBranchId = currentBranchId;
          context.read<ProductsCubit>().loadFirstPage(branchId: currentBranchId);
        }
      } else {
        context.read<ProductsCubit>().loadFirstPage();
      }
    } catch (_) {
      // In minimal test setups where cubits are not in tree
    }
  }

  Future<void> _onRefresh() async {
    final branchState = context.read<BranchCubit>().state;
    final branchId =
        branchState is BranchLoaded ? branchState.selectedBranchId : null;

    await Future.wait<dynamic>([
      context.read<BranchCubit>().fetchBranches(),
      context.read<SettingsCubit>().fetchSettings(),
      context.read<CategoriesCubit>().fetchCategories(),
      context.read<ProductsCubit>().loadFirstPage(branchId: branchId),
    ]);
  }

  void _handleProtectedNav(String route) {
    try {
      final authCubit = context.read<AuthCubit>();
      if (authCubit.state is! AuthAuthenticated) {
        LoginRequiredBottomSheet.show(context, returnRoute: route);
        return;
      }
    } catch (_) {
      // In minimal test setups where AuthCubit is not in tree
    }
    context.go(route);
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        // Already on Home: scroll to top smoothly
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      case 1:
        context.go(AppRouter.kBrowseView);
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BranchCubit, BranchState>(
      listener: (context, state) {
        if (state is BranchLoaded &&
            state.selectedBranchId != null &&
            state.selectedBranchId != _lastLoadedBranchId) {
          _lastLoadedBranchId = state.selectedBranchId;
          context
              .read<ProductsCubit>()
              .loadFirstPage(branchId: state.selectedBranchId);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: HomeHeaderBar(
          onCartTap: () => context.push('/cart'),
          onAccountTap: () => context.go(AppRouter.kAccountView),
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.spaceSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Branch Selector Strip
                const HomeBranchSelectorStrip(),
                const SizedBox(height: AppSpacing.spaceSm),

                // 2. Search Bar (without barcode icon)
                const HomeSearchBar(),
                const SizedBox(height: AppSpacing.spaceMd),

                // 3. Hero Clinical Banner
                const HomeHeroBanner(),
                const SizedBox(height: AppSpacing.spaceMd),

                // 4. Prescription Upload Card
                HomePrescriptionUploadCard(
                  onUploadTap: () =>
                      _handleProtectedNav(AppRouter.kPrescriptionView),
                ),
                const SizedBox(height: AppSpacing.spaceLg),

                // 5. Therapeutic Categories Grid
                const HomeCategoriesSection(),
                const SizedBox(height: AppSpacing.spaceLg),

                // 6. Featured Products Section
                HomeFeaturedProductsSection(
                  onAddToCart: (product) {
                    CartActionHelper.addProductToCart(
                      context: context,
                      cartCubit: context.read<CartCubit>(),
                      product: product,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.spaceLg),

                // 7. Clinical Quality & Storage Guarantee Footer
                const HomeStorageGuaranteeFooter(),
                const SizedBox(height: AppSpacing.space2xl),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomerBottomNav(
          currentIndex: 0,
          onTap: _onBottomNavTapped,
        ),
      ),
    );
  }
}
