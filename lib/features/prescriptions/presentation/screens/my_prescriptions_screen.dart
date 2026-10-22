import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';
import 'package:index_pharma/features/home/presentation/widgets/customer_bottom_nav.dart';
import '../cubit/prescription_cubit.dart';
import '../cubit/prescription_state.dart';
import '../widgets/prescription_card.dart';

/// Screen displaying the authenticated customer's prescriptions list (Stitch D3).
class MyPrescriptionsScreen extends StatelessWidget {
  const MyPrescriptionsScreen({super.key, this.cubit});

  final PrescriptionCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<PrescriptionCubit>.value(
        value: cubit!,
        child: const _MyPrescriptionsView(),
      );
    }

    return const _MyPrescriptionsView();
  }
}

class _MyPrescriptionsView extends StatefulWidget {
  const _MyPrescriptionsView();

  @override
  State<_MyPrescriptionsView> createState() => _MyPrescriptionsViewState();
}

class _MyPrescriptionsViewState extends State<_MyPrescriptionsView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<PrescriptionCubit>();
    if (cubit.state.listStep == PrescriptionListStep.initial) {
      cubit.loadMyPrescriptions();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<PrescriptionCubit>().loadMyPrescriptions();
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.kStoreView);
      case 1:
        context.go(AppRouter.kBrowseView);
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.prescriptionsMyPrescriptionsTitle.tr(),
        onBackPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRouter.kStoreView);
          }
        },
      ),
      body: BlocBuilder<PrescriptionCubit, PrescriptionState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: colors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Sub-header Bar: Count & Upload New Action
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                      vertical: AppSpacing.spaceSm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            if (state.prescriptions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.brandMintSurface,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  state.prescriptions.length == 1
                                      ? AppLocaleKeys.prescriptionsSingleCountBadge.tr()
                                      : AppLocaleKeys.prescriptionsCountBadge.tr(
                                          args: [state.prescriptions.length.toString()],
                                        ),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.brandEmeraldDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Content View according to listStep
                if (state.listStep == PrescriptionListStep.loading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator(color: colors.primary)),
                  )
                else if (state.listStep == PrescriptionListStep.failure)
                  SliverFillRemaining(hasScrollBody: false, child: _buildErrorState(colors, state))
                else if (state.listStep == PrescriptionListStep.empty ||
                    state.prescriptions.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState(colors))
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                      vertical: AppSpacing.spaceXs,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = state.prescriptions[index];
                        return PrescriptionCard(
                          prescription: item,
                          onTap: () {
                            context.push(AppRouter.prescriptionDetailsPath(item.id), extra: item);
                          },
                        );
                      }, childCount: state.prescriptions.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.spaceXl)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: CustomerBottomNav(currentIndex: 2, onTap: _onBottomNavTapped),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: colors.surfaceContainerLow, shape: BoxShape.circle),
              child: Icon(Icons.assignment_outlined, size: 44, color: colors.neutral),
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            Text(
              AppLocaleKeys.prescriptionsEmptyTitle.tr(),
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                AppLocaleKeys.prescriptionsEmptyDesc.tr(),
                style: TextStyle(fontSize: 13, color: colors.neutral, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceLg),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PrescriptionCubit>().resetUploadFlow();
                context.push(AppRouter.kPrescriptionUploadView);
              },
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: Text(
                AppLocaleKeys.prescriptionsEmptyAction.tr(),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppColorsExtension colors, PrescriptionState state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.error),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              state.listErrorMessage ?? AppLocaleKeys.prescriptionsErrorLoadingList.tr(),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            ElevatedButton.icon(
              onPressed: () {
                context.read<PrescriptionCubit>().loadMyPrescriptions();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(AppLocaleKeys.commonRetry.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
