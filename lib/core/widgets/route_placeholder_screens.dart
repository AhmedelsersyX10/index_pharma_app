import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';

/// Minimal placeholder screen for the public customer store.
///
/// Used until the full Store feature is implemented.
class StorePlaceholderScreen extends StatelessWidget {
  const StorePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Index Pharma Store'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Store Screen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Staff Dashboard Screen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Branch Management'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Branch Management Screen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocaleKeys.navBrowse.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Browse Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocaleKeys.navPrescription.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Prescription Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocaleKeys.navOrders.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'My Orders Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocaleKeys.navAccount.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Account Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocaleKeys.cartTitle.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Cart Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocaleKeys.checkoutTitle.tr()),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Checkout Screen (Placeholder)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
