import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_empty_state.dart';
import 'package:index_pharma/core/widgets/app_error_view.dart';
import 'package:index_pharma/core/widgets/app_loading_indicator.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/home/presentation/widgets/customer_bottom_nav.dart';
import '../../domain/entities/customer_order.dart';
import '../cubit/my_orders_cubit.dart';
import '../cubit/my_orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_chips.dart';

/// Customer My Orders screen (Stitch C4).
/// Displays paginated orders list with filtering by All, Active, and Past.
class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key, this.cubit});

  /// Optional pre-configured cubit (used for tests or dependency overrides).
  final MyOrdersCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<MyOrdersCubit>.value(value: cubit!, child: const _MyOrdersView());
    }

    return const _MyOrdersView();
  }
}

class _MyOrdersView extends StatefulWidget {
  const _MyOrdersView();

  @override
  State<_MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<_MyOrdersView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      context.read<MyOrdersCubit>().loadMore();
    }
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
        context.go(AppRouter.kPrescriptionView);
      case 3:
        context.go(AppRouter.kOrdersView);
      case 4:
        context.go(AppRouter.kAccountView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppPageBar(
        title: 'orders.title'.tr(),
        onBackPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRouter.kStoreView);
          }
        },
      ),
      body: BlocBuilder<MyOrdersCubit, MyOrdersState>(
        builder: (context, state) {
          return switch (state) {
            MyOrdersInitial() || MyOrdersLoading() => const Center(child: AppLoadingIndicator()),
            MyOrdersFailure(:final message) => AppErrorView(
              message: message ?? 'error.default_message'.tr(),
              onRetry: () => context.read<MyOrdersCubit>().fetchMyOrders(refresh: true),
            ),
            MyOrdersEmpty() => AppEmptyState(
              icon: const Icon(
                Icons.receipt_long_outlined,
                size: 42,
                color: AppColors.brandEmeraldDark,
              ),
              title: 'orders.empty_title'.tr(),
              message: 'orders.empty_desc'.tr(),
              action: ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.kStoreView),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spaceLg,
                    vertical: AppSpacing.spaceSm + 2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                ),
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: Text(
                  'orders.empty_browse_btn'.tr(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            MyOrdersLoaded() => _buildLoadedView(context, state),
          };
        },
      ),

      bottomNavigationBar: CustomerBottomNav(currentIndex: 3, onTap: _onBottomNavTapped),
    );
  }

  Widget _buildLoadedView(BuildContext context, MyOrdersLoaded state) {
    final filteredOrders = state.filteredOrders;

    return Column(
      children: [
        // Filter Chips Row
        Container(
          color: AppColors.canvasPure,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceXs),
          child: OrderFilterChips(
            selectedFilter: state.filter,
            countAll: state.countAll,
            countActive: state.countActive,
            countPast: state.countPast,
            onFilterSelected: (filter) => context.read<MyOrdersCubit>().setFilter(filter),
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),

        // Orders List or Empty Filter View
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<MyOrdersCubit>().fetchMyOrders(refresh: true),
            color: AppColors.primary,
            child: filteredOrders.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: AppEmptyState(
                        icon: const Icon(
                          Icons.filter_list_off_rounded,
                          size: 40,
                          color: AppColors.secondaryMuted,
                        ),
                        title: 'orders.empty_title'.tr(),
                        message: 'orders.empty_desc'.tr(),
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.marginMobile),
                    itemCount:
                        filteredOrders.length +
                        (state.isLoadingMore || state.loadingMoreError != null ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.spaceMd),
                    itemBuilder: (context, index) {
                      if (index >= filteredOrders.length) {
                        return _buildLoadingMoreIndicator(context, state);
                      }

                      final order = filteredOrders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => _navigateToDetails(context, order),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMoreIndicator(BuildContext context, MyOrdersLoaded state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.spaceMd),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
          ),
        ),
      );
    }

    if (state.loadingMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
        child: TextButton.icon(
          onPressed: () => context.read<MyOrdersCubit>().loadMore(),
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: Text('orders.load_more_error'.tr(), style: const TextStyle(fontSize: 12)),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _navigateToDetails(BuildContext context, CustomerOrder order) {
    context.push('${AppRouter.kOrdersView}/${order.id}', extra: order);
  }
}
