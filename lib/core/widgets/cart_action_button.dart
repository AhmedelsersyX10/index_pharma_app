import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:index_pharma/features/cart/presentation/cubit/cart_state.dart';

/// Shared cart action button with dynamic item count badge for app bars.
///
/// Features:
/// - Directionality-aware badge positioning.
/// - Minimum 48dp touch target per accessibility guidelines.
/// - Dynamic badge count from [CartCubit] with fallback when not in tree.
/// - Localized tooltip and Semantics from [AppLocaleKeys.cartTitle].
class CartActionButton extends StatelessWidget {
  const CartActionButton({
    super.key,
    this.color,
    this.onTap,
    this.cartCubit,
  });

  final Color? color;
  final VoidCallback? onTap;
  final CartCubit? cartCubit;

  @override
  Widget build(BuildContext context) {
    CartCubit? effectiveCubit = cartCubit;
    if (effectiveCubit == null) {
      try {
        effectiveCubit = context.watch<CartCubit>();
      } catch (_) {
        if (getIt.isRegistered<CartCubit>()) {
          effectiveCubit = getIt<CartCubit>();
        }
      }
    }

    if (effectiveCubit == null) {
      return _buildButton(context, 0);
    }

    return BlocBuilder<CartCubit, CartState>(
      bloc: effectiveCubit,
      builder: (context, state) {
        final count = switch (state) {
          CartHasItems(:final totalItemsCount) => totalItemsCount,
          _ => 0,
        };
        return _buildButton(context, count);
      },
    );
  }

  Widget _buildButton(BuildContext context, int count) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.appBarTheme.foregroundColor ?? AppColors.onSurface;

    return Semantics(
      label: AppLocaleKeys.cartTitle.tr(),
      button: true,
      child: IconButton(
        tooltip: AppLocaleKeys.cartTitle.tr(),
        constraints: const BoxConstraints(
          minWidth: AppSpacing.minTouchTarget,
          minHeight: AppSpacing.minTouchTarget,
        ),
        padding: EdgeInsets.zero,
        onPressed: onTap ?? () => context.push(AppRouter.kCartView),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 24,
              color: iconColor,
            ),
            if (count > 0)
              PositionedDirectional(
                top: -4,
                end: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.medicalRed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
