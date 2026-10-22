import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/features/auth/domain/entities/user.dart';

/// Top profile card displaying customer avatar, name, verification badge,
/// email, phone, single address, and an edit button (Stitch D5).
class AccountProfileCard extends StatelessWidget {
  const AccountProfileCard({
    super.key,
    required this.user,
    required this.onEditPressed,
  });

  final UserEntity user;
  final VoidCallback onEditPressed;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'IP';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString();
    }
    return '${parts[0].characters.first}${parts[1].characters.first}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initials = _getInitials(user.name);
    final displayPhone = user.phone?.trim().isNotEmpty == true
        ? user.phone!
        : AppLocaleKeys.accountNotSet.tr();
    final displayAddress = user.address?.trim().isNotEmpty == true
        ? user.address!
        : AppLocaleKeys.accountNotSet.tr();

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.borderSubtle.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B1C30),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar + Name & Verification
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with verification badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.brandMintSurface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: AppTypography.headlineMd(
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.surfaceContainerLowest,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name + Customer status badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppTypography.titleLg(
                        color: colors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brandMintSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.brandMintBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: colors.brandEmeraldDark,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              AppLocaleKeys.accountVerifiedBadge.tr(),
                              style: AppTypography.labelSm(
                                color: colors.brandEmeraldDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: colors.surfaceContainerLow),
          const SizedBox(height: 12),

          // Email Row
          _DetailRow(
            icon: Icons.mail_outline_rounded,
            value: user.email,
            label: AppLocaleKeys.accountEmailLabel.tr(),
            isLtrValue: true,
          ),
          const SizedBox(height: 8),

          // Phone Row
          _DetailRow(
            icon: Icons.call_outlined,
            value: displayPhone,
            label: AppLocaleKeys.accountPhoneLabel.tr(),
            isLtrValue: true,
          ),
          const SizedBox(height: 8),

          // Single Address Row
          _DetailRow(
            icon: Icons.location_on_outlined,
            value: displayAddress,
            label: AppLocaleKeys.accountAddressLabel.tr(),
            isMultiline: true,
          ),

          const SizedBox(height: 16),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              key: const ValueKey('edit_profile_button'),
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: Text(
                AppLocaleKeys.accountEditProfileBtn.tr(),
                style: AppTypography.labelLg(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.value,
    required this.label,
    this.isLtrValue = false,
    this.isMultiline = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isLtrValue;
  final bool isMultiline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSm(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  textDirection: isLtrValue ? TextDirection.ltr : null,
                  style: AppTypography.bodySm(
                    color: colors.onSurface,
                  ).copyWith(fontWeight: FontWeight.w500),
                  maxLines: isMultiline ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
