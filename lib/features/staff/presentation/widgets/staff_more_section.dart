import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/widgets/app_card.dart';

/// Card-wrapped section container for the Staff More screen.
class StaffMoreSection extends StatelessWidget {
  const StaffMoreSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceXs, vertical: AppSpacing.spaceXs),
            child: Text(
              title,
              style: AppTypography.labelLg(color: colors.primary).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
