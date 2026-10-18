import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Top app bar for the branch selection screen.
class BranchHeader extends StatelessWidget implements PreferredSizeWidget {
  const BranchHeader({
    super.key,
    this.onBackPressed,
  });

  final VoidCallback? onBackPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      leading: (canPop || onBackPressed != null)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.onSurface,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        'branch_selection.title'.tr(),
        style: AppTypography.titleLg(
          color: AppColors.onSurface,
        ).copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
