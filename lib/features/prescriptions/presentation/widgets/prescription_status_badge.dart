import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:index_pharma/core/theme/app_colors.dart';
import '../../domain/entities/prescription_status.dart';

/// Renders a clinical status badge for a prescription based on [PrescriptionStatus].
///
/// Follows Stitch C6 / D3 / D4 status colors:
/// - [PrescriptionStatus.pending]: Amber / warning background & dot.
/// - [PrescriptionStatus.preparing]: Sky / cyan background & dot.
/// - [PrescriptionStatus.completed]: Mint / emerald background with check icon.
/// - [PrescriptionStatus.rejected]: Rose / error background with cancel icon.
/// - [PrescriptionStatus.unknown]: Subtle slate background.
class PrescriptionStatusBadge extends StatelessWidget {
  const PrescriptionStatusBadge({
    super.key,
    required this.status,
    this.rawStatus,
  });

  final PrescriptionStatus status;
  final String? rawStatus;

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor, dotColor, icon) = _getBadgeStyle();
    final label = (status == PrescriptionStatus.unknown &&
            rawStatus != null &&
            rawStatus!.trim().isNotEmpty)
        ? rawStatus!
        : status.translationKey.tr();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color text, Color dot, IconData? icon) _getBadgeStyle() {
    switch (status) {
      case PrescriptionStatus.pending:
        return (
          const Color(0xFFFEF3C7), // Amber 100
          const Color(0xFF92400E), // Amber 800
          const Color(0xFFF59E0B), // Amber 500
          null,
        );
      case PrescriptionStatus.preparing:
        return (
          const Color(0xFFE0F2FE), // Sky 100
          const Color(0xFF0369A1), // Sky 700
          const Color(0xFF0EA5E9), // Sky 500
          null,
        );
      case PrescriptionStatus.completed:
        return (
          AppColors.brandMintSurface,
          AppColors.brandEmeraldDark,
          AppColors.brandEmeraldDark,
          Icons.check_circle,
        );
      case PrescriptionStatus.rejected:
        return (
          const Color(0xFFFFE4E6), // Rose 100
          const Color(0xFFBE123C), // Rose 700
          const Color(0xFFF43F5E), // Rose 500
          Icons.cancel,
        );
      case PrescriptionStatus.unknown:
        return (
          const Color(0xFFF1F5F9), // Slate 100
          const Color(0xFF475569), // Slate 600
          const Color(0xFF94A3B8), // Slate 400
          null,
        );
    }
  }
}
