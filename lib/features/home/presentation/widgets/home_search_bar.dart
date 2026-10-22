import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';

/// Clinical Search Bar for B2 Home Screen.
///
/// Complies with design constraints:
/// - Barcode scanner icon is REMOVED (deferred).
/// - Clean, accessible search field with search icon.
/// - Submitting with query navigates to `/browse?q={query}`.
/// - Tapping without query navigates to `/browse`.
class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    this.onSubmitted,
    this.onTap,
  });

  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit(String query) {
    if (widget.onSubmitted != null) {
      widget.onSubmitted!(query);
    } else {
      context.go(AppRouter.browsePath(q: query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: AppRadii.roundedLg,
        boxShadow: AppShadows.level1,
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _handleSubmit(_controller.text),
          ),
          const SizedBox(width: AppSpacing.spaceSm),
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: _handleSubmit,
              onTap: widget.onTap,
              textInputAction: TextInputAction.search,
              style: AppTypography.bodyMd(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: AppLocaleKeys.homeSearchHint.tr(),
                hintStyle: AppTypography.bodyMd(
                  color: AppColors.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.slate400,
                ),
                onPressed: () => _controller.clear(),
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            },
          ),
        ],
      ),
    );
  }
}
