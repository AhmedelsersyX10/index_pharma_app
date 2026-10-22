import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_page_bar.dart';

/// Minimal placeholder screen for the public customer store.
///
/// Used until the full Store feature is implemented.
class StorePlaceholderScreen extends StatelessWidget {
  const StorePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppPageBar(
        title: 'Index Pharma Store',
      ),
      body: Center(
        child: Text(
          'Store Screen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for staff operations (pharmacists & admins).
///
/// Used until the Staff feature screens are implemented.
class StaffDashboardPlaceholderScreen extends StatelessWidget {
  const StaffDashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppPageBar(
        title: 'Staff Dashboard',
      ),
      body: Center(
        child: Text(
          'Staff Dashboard Screen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for superadmin branch management operations.
///
/// Used until Branch Management is implemented.
class BranchManagementPlaceholderScreen extends StatelessWidget {
  const BranchManagementPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppPageBar(
        title: 'Branch Management',
      ),
      body: Center(
        child: Text(
          'Branch Management Screen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for customer Browse tab (Decision 0.6).
class BrowsePlaceholderScreen extends StatelessWidget {
  const BrowsePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.navBrowse.tr(),
      ),
      body: Center(
        child: Text(
          'Browse Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for customer Prescription tab (Decision 0.6).
class PrescriptionPlaceholderScreen extends StatelessWidget {
  const PrescriptionPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.navPrescription.tr(),
      ),
      body: Center(
        child: Text(
          'Prescription Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for customer My Orders tab (Decision 0.6).
class MyOrdersPlaceholderScreen extends StatelessWidget {
  const MyOrdersPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.navOrders.tr(),
      ),
      body: Center(
        child: Text(
          'My Orders Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for customer Account tab (Decision 0.6).
class AccountPlaceholderScreen extends StatelessWidget {
  const AccountPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.navAccount.tr(),
      ),
      body: Center(
        child: Text(
          'Account Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for customer Cart.
class CartPlaceholderScreen extends StatelessWidget {
  const CartPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.cartTitle.tr(),
      ),
      body: Center(
        child: Text(
          'Cart Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Minimal placeholder screen for customer Checkout.
class CheckoutPlaceholderScreen extends StatelessWidget {
  const CheckoutPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppPageBar(
        title: AppLocaleKeys.checkoutTitle.tr(),
      ),
      body: Center(
        child: Text(
          'Checkout Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ),
    );
  }
}
