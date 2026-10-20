import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

/// Top bar cart icon button with dynamic item count badge.
///
/// Reacts automatically to [CartCubit] state changes when available,
/// and falls back gracefully to a standard cart button if [CartCubit] is not in context.
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({
    super.key,
    this.color,
    this.onTap,
  });

  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    CartCubit? cubit;
    try {
      cubit = context.read<CartCubit>();
    } catch (_) {
      if (getIt.isRegistered<CartCubit>()) {
        cubit = getIt<CartCubit>();
      }
    }

    if (cubit == null) {
      return _buildButton(context, 0);
    }

    return BlocBuilder<CartCubit, CartState>(
      bloc: cubit,
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
    return IconButton(
      tooltip: AppLocaleKeys.cartTitle.tr(),
      onPressed: onTap ?? () => context.push(AppRouter.kCartView),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 24,
            color: color ?? AppColors.onSurface,
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
    );
  }
}
