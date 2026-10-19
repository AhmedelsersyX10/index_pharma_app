import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_cubit.dart';
import 'package:index_pharma/features/choose_branches/presentation/cubit/branch_state.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_bottom_bar.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_card.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_header.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_intro_section.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/branch_state_views.dart';
import 'package:index_pharma/features/choose_branches/presentation/widgets/cold_chain_banner.dart';

/// Full screen branch selection experience conforming to Stitch design specifications.
///
/// Features:
/// - Fetches active pharmacy branches on initialization.
/// - Automatically selects and persists branch if only one is returned.
/// - Highlights current selection with clinical clarity design tokens.
/// - Persists selection to local storage via [BranchCubit].
class BranchSelectionScreen extends StatelessWidget {
  const BranchSelectionScreen({
    super.key,
    this.branchCubit,
    this.onBranchConfirmed,
  });

  final BranchCubit? branchCubit;
  final VoidCallback? onBranchConfirmed;

  @override
  Widget build(BuildContext context) {
    if (branchCubit != null) {
      return BlocProvider.value(
        value: branchCubit!,
        child: _BranchSelectionView(
          onBranchConfirmed: onBranchConfirmed,
        ),
      );
    }

    return BlocProvider<BranchCubit>(
      create: (context) => getIt<BranchCubit>()..fetchBranches(),
      child: _BranchSelectionView(
        onBranchConfirmed: onBranchConfirmed,
      ),
    );
  }
}

class _BranchSelectionView extends StatefulWidget {
  const _BranchSelectionView({
    this.onBranchConfirmed,
  });

  final VoidCallback? onBranchConfirmed;

  @override
  State<_BranchSelectionView> createState() => _BranchSelectionViewState();
}

class _BranchSelectionViewState extends State<_BranchSelectionView> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<BranchCubit>();
    if (cubit.state is BranchInitial) {
      cubit.fetchBranches();
    }
  }

  void _onConfirm(BranchState state) {
    if (widget.onBranchConfirmed != null) {
      widget.onBranchConfirmed!();
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRouter.kStoreView);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BranchHeader(),
      body: BlocBuilder<BranchCubit, BranchState>(
        builder: (context, state) {
          return switch (state) {
            BranchInitial() || BranchLoading() => const SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.spaceLg),
                  child: BranchLoadingView(),
                ),
              ),
            BranchEmpty() => SafeArea(
                child: BranchEmptyView(
                  onRetry: () => context.read<BranchCubit>().fetchBranches(),
                ),
              ),
            BranchFailure(:final failure) => SafeArea(
                child: BranchErrorView(
                  failure: failure,
                  onRetry: () => context.read<BranchCubit>().fetchBranches(),
                ),
              ),
            BranchLoaded(:final branches, :final selectedBranchId) =>
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: AppSpacing.spaceMd,
                  bottom: AppSpacing.space2xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Intro section with location pills and headline
                    BranchIntroSection(
                      branchesCount: branches.length,
                      onAutoLocatePressed: branches.isNotEmpty
                          ? () {
                              context
                                  .read<BranchCubit>()
                                  .selectBranch(branches.first.id);
                            }
                          : null,
                    ),

                    AppSpacing.vSpaceLg,

                    // Branch cards list
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spaceLg,
                      ),
                      itemCount: branches.length,
                      separatorBuilder: (_, _) => AppSpacing.vSpaceMd,
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        final isSelected = branch.id == selectedBranchId;

                        return BranchCard(
                          branch: branch,
                          isSelected: isSelected,
                          onTap: () {
                            context
                                .read<BranchCubit>()
                                .selectBranch(branch.id);
                          },
                        );
                      },
                    ),

                    AppSpacing.vSpaceXl,

                    // Cold Chain Quality Assurance Banner
                    const ColdChainBanner(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
          };
        },
      ),
      bottomNavigationBar: BlocBuilder<BranchCubit, BranchState>(
        builder: (context, state) {
          if (state is BranchLoaded) {
            return BranchBottomBar(
              selectedBranch: state.selectedBranch,
              onConfirm: () => _onConfirm(state),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
