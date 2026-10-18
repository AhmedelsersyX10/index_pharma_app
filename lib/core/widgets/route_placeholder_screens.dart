import 'package:flutter/material.dart';
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
