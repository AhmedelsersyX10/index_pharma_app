import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import 'package:index_pharma/core/theme/app_spacing.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import '../cubit/prescription_cubit.dart';
import '../cubit/prescription_state.dart';
import '../widgets/prescription_card.dart';

/// Screen displaying the authenticated customer's prescriptions list (Stitch D3).
class MyPrescriptionsScreen extends StatelessWidget {
  const MyPrescriptionsScreen({
    super.key,
    this.cubit,
  });

  final PrescriptionCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<PrescriptionCubit>.value(
        value: cubit!,
        child: const _MyPrescriptionsView(),
      );
    }

    return BlocProvider<PrescriptionCubit>(
      create: (_) => getIt<PrescriptionCubit>(),
      child: const _MyPrescriptionsView(),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRouter.kStoreView);
            }
          },
        ),
        title: Text(
          AppLocaleKeys.prescriptionsMyPrescriptionsTitle.tr(),
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<PrescriptionCubit, PrescriptionState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
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
                            Text(
                              AppLocaleKeys.prescriptionsMyPrescriptionsTitle.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (state.prescriptions.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.brandMintSurface,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  state.prescriptions.length == 1
                                      ? AppLocaleKeys.prescriptionsSingleCountBadge.tr()
                                      : AppLocaleKeys.prescriptionsCountBadge
                                          .tr(args: [state.prescriptions.length.toString()]),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandEmeraldDark,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<PrescriptionCubit>().resetUploadFlow();
                            context.push(AppRouter.kPrescriptionUploadView);
                          },
                          icon: const Icon(Icons.add_photo_alternate, size: 16),
                          label: Text(
                            AppLocaleKeys.prescriptionsUploadNewBtn.tr(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content View according to listStep
                if (state.listStep == PrescriptionListStep.loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (state.listStep == PrescriptionListStep.failure)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(state),
                  )
                else if (state.listStep == PrescriptionListStep.empty ||
                    state.prescriptions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                      vertical: AppSpacing.spaceXs,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = state.prescriptions[index];
                          return PrescriptionCard(
                            prescription: item,
                            onTap: () {
                              context.push(
                                AppRouter.prescriptionDetailsPath(item.id),
                                extra: item,
                              );
                            },
                          );
                        },
                        childCount: state.prescriptions.length,
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.spaceXl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 44,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: AppSpacing.spaceMd),
            Text(
              AppLocaleKeys.prescriptionsEmptyTitle.tr(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                AppLocaleKeys.prescriptionsEmptyDesc.tr(),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.neutral,
                  height: 1.4,
                ),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(PrescriptionState state) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.spaceSm),
            Text(
              state.listErrorMessage ?? 'حدث خطأ في تحميل الروشتات',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
