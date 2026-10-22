import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';

/// Top app bar for the branch selection screen built on unified [AppPageBar].
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
    return AppPageBar(
      height: preferredSize.height,
      centerTitle: true,
      onBackPressed: onBackPressed,
      title: 'branch_selection.title'.tr(),
    );
  }
}
