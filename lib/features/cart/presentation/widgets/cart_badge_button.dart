import 'package:flutter/material.dart';
import 'package:index_pharma/core/widgets/cart_action_button.dart';
import '../cubit/cart_cubit.dart';

export 'package:index_pharma/core/widgets/cart_action_button.dart';

/// Backward-compatible wrapper delegating to shared [CartActionButton].
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({
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
    return CartActionButton(
      color: color,
      onTap: onTap,
      cartCubit: cartCubit,
    );
  }
}
