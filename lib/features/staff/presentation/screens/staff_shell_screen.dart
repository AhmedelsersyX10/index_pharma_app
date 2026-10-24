import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/features/staff/presentation/widgets/staff_bottom_nav.dart';

/// The root shell widget for all staff views (`/staff/**`).
///
/// Houses persistent [StaffBottomNav] across tab switches.
class StaffShellScreen extends StatelessWidget {
  const StaffShellScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: StaffBottomNav(
        currentLocation: location,
        onTapRoute: (route) {
          if (location != route) {
            context.go(route);
          }
        },
      ),
    );
  }
}
