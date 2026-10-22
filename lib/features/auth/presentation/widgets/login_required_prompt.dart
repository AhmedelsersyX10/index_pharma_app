import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:index_pharma/core/localization/app_locale_keys.dart';
import 'package:index_pharma/core/theme/theme.dart';
import 'package:index_pharma/core/utils/app_router.dart';
import 'package:index_pharma/core/widgets/app_buttons.dart';

/// Modal bottom sheet utility for displaying the clinical login required prompt.
class LoginRequiredBottomSheet {
  const LoginRequiredBottomSheet._();

  /// Displays the [LoginRequiredPrompt] as a modal bottom sheet adhering to Stitch A4.
  static Future<T?> show<T>(BuildContext context, {required String returnRoute}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: context.colors.inverseSurface.withValues(alpha: 0.5),
      builder: (sheetContext) => LoginRequiredPrompt(
        returnRoute: returnRoute,
        isBottomSheet: true,
        onDismiss: () => Navigator.of(sheetContext).pop(),
      ),
    );
  }
}

/// Clinical Login-Required Prompt adhering to Stitch Design specification (A4_Login_Required_Prompt).
///
/// Can be rendered as a bottom sheet modal or as a standalone card/screen widget.
class LoginRequiredPrompt extends StatelessWidget {
  const LoginRequiredPrompt({
    super.key,
    required this.returnRoute,
    this.isBottomSheet = true,
    this.onDismiss,
    this.onLoginTap,
    this.onRegisterTap,
  });

  /// The route to return the user to after completing authentication.
  final String returnRoute;

  /// Whether this prompt is displayed inside a modal bottom sheet.
  final bool isBottomSheet;

  /// Optional callback invoked when the user dismisses the prompt or taps "Continue as Guest".
  final VoidCallback? onDismiss;

  /// Optional override for the login action (used primarily for testability).
  final VoidCallback? onLoginTap;

  /// Optional override for the register action (used primarily for testability).
  final VoidCallback? onRegisterTap;

  void _handleLogin(BuildContext context) {
    if (onLoginTap != null) {
      onLoginTap!();
      return;
    }
    if (isBottomSheet && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    final targetUri = Uri(
      path: AppRouter.kLoginView,
      queryParameters: {'from': returnRoute},
    ).toString();
    context.go(targetUri);
  }

  void _handleRegister(BuildContext context) {
    if (onRegisterTap != null) {
      onRegisterTap!();
      return;
    }
    if (isBottomSheet && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    final targetUri = Uri(
      path: AppRouter.kRegisterView,
      queryParameters: {'from': returnRoute},
    ).toString();
    context.go(targetUri);
  }

  void _handleDismiss(BuildContext context) {
    if (onDismiss != null) {
      onDismiss!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go(AppRouter.kStoreView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final content = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isBottomSheet) ...[
            const _TactileDragHandle(),
            const SizedBox(height: AppSpacing.spaceXs),
          ],
          _TopHeaderArea(onDismiss: () => _handleDismiss(context)),
          const SizedBox(height: AppSpacing.spaceSm),
          const _HealthcareContextBadge(),
          const SizedBox(height: AppSpacing.spaceSm),
          Text(
            AppLocaleKeys.authLoginRequiredTitle.tr(),
            textAlign: TextAlign.center,
            style: AppTypography.headlineLgMobile(color: colors.onSurface),
          ),
          const SizedBox(height: AppSpacing.spaceXs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spaceSm),
            child: Text(
              AppLocaleKeys.authLoginRequiredDesc.tr(),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd(color: colors.secondaryMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.spaceLg),
          const _ValuePropsGrid(),
          const SizedBox(height: AppSpacing.spaceLg),
          _ActionButtonsStack(
            onLogin: () => _handleLogin(context),
            onRegister: () => _handleRegister(context),
            onContinueAsGuest: () => _handleDismiss(context),
          ),
          const SizedBox(height: AppSpacing.spaceMd),
          const _PrivacyAndSecurityPill(),
        ],
      ),
    );

    if (isBottomSheet) {
      return Container(
        decoration: BoxDecoration(
          color: colors.canvasPure,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28.0),
            topRight: Radius.circular(28.0),
          ),
          boxShadow: context.shadowsLevel3,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spaceLg,
          AppSpacing.spaceSm,
          AppSpacing.spaceLg,
          AppSpacing.spaceLg,
        ),
        child: SafeArea(top: false, child: content),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.canvasPure,
        borderRadius: AppRadii.roundedXl,
        boxShadow: context.shadowsLevel1,
        border: Border.all(color: colors.slate200),
      ),
      padding: const EdgeInsets.all(AppSpacing.spaceLg),
      child: content,
    );
  }
}

/// Tactile drag handle pill indicator at top of bottom sheet.
class _TactileDragHandle extends StatelessWidget {
  const _TactileDragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: context.colors.outlineVariant.withValues(alpha: 0.6),
          borderRadius: AppRadii.roundedFull,
        ),
      ),
    );
  }
}

/// Header area containing close button and centered verified shield badge.
class _TopHeaderArea extends StatelessWidget {
  const _TopHeaderArea({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Symmetrical close button
        Material(
          color: colors.surfaceContainerHigh,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            color: colors.onSurfaceVariant,
            onPressed: onDismiss,
            tooltip: AppLocaleKeys.commonSkip.tr(),
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            padding: EdgeInsets.zero,
          ),
        ),
        const Spacer(),
        // Center verified badge with miniature lock badge
        const _ClinicalShieldBadge(),
        const Spacer(),
        // Invisible spacer matching close button width for symmetric centering
        const SizedBox(width: 36, height: 36),
      ],
    );
  }
}

/// Clinical verified emblem with secondary lock badge overlay.
class _ClinicalShieldBadge extends StatelessWidget {
  const _ClinicalShieldBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 68,
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.brandMintSurface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.primaryBrand.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.verified_user_rounded, color: colors.primaryBrand, size: 34),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.canvasPure,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Color(0x1A0F172A), blurRadius: 4, offset: Offset(0, 1)),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(color: colors.primaryBrand, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(Icons.lock_rounded, color: colors.onPrimary, size: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Regulatory accredited pharmacy platform pill badge.
class _HealthcareContextBadge extends StatelessWidget {
  const _HealthcareContextBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: colors.brandMintSurface,
          borderRadius: AppRadii.roundedFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 14, color: colors.brandEmeraldDark),
            const SizedBox(width: AppSpacing.space2xs),
            Text(
              AppLocaleKeys.authLoginRequiredBadge.tr(),
              style: AppTypography.labelSm(color: colors.brandEmeraldDark),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delight & reassurance 3-item value proposition grid.
///
/// NOTE: Free of any insurance wording per project rules.
class _ValuePropsGrid extends StatelessWidget {
  const _ValuePropsGrid();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.roundedLg,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spaceSm,
        vertical: AppSpacing.spaceMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ValuePropItem(
              icon: Icons.receipt_long_rounded,
              title: AppLocaleKeys.authLoginRequiredSaveRx.tr(),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: _ValuePropItem(
              icon: Icons.history_toggle_off_rounded,
              title: AppLocaleKeys.authLoginRequiredTrackOrders.tr(),
            ),
          ),
          const SizedBox(width: AppSpacing.spaceXs),
          Expanded(
            child: _ValuePropItem(
              icon: Icons.verified_outlined,
              title: AppLocaleKeys.authLoginRequiredGenuineMeds.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValuePropItem extends StatelessWidget {
  const _ValuePropItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: colors.surfaceContainerLowest, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, color: colors.primaryBrand, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelSm(color: colors.onSurface),
        ),
      ],
    );
  }
}

/// Action stack: Primary Sign In, Secondary Create Account, Tertiary Continue as Guest.
class _ActionButtonsStack extends StatelessWidget {
  const _ActionButtonsStack({
    required this.onLogin,
    required this.onRegister,
    required this.onContinueAsGuest,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onContinueAsGuest;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Primary Action: Sign In
        AppButton.primary(
          text: AppLocaleKeys.authLoginRequiredBtnLogin.tr(),
          icon: Icon(Icons.login_rounded, size: 20, color: colors.onPrimary),
          onPressed: onLogin,
          height: 48,
        ),
        const SizedBox(height: AppSpacing.spaceSm),
        // 2. Secondary Action: Create New Account
        ElevatedButton(
          onPressed: onRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.secondaryContainer,
            foregroundColor: colors.onSecondaryFixed,
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            shape: const StadiumBorder(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_outlined, size: 20, color: colors.onSecondaryFixed),
              const SizedBox(width: AppSpacing.spaceSm),
              Text(
                AppLocaleKeys.authLoginRequiredBtnRegister.tr(),
                style: AppTypography.labelLg(color: colors.onSecondaryFixed),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space2xs),
        // 3. Tertiary Action: Continue as Guest
        TextButton(
          onPressed: onContinueAsGuest,
          style: TextButton.styleFrom(
            foregroundColor: colors.secondaryMuted,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spaceSm),
            shape: const StadiumBorder(),
          ),
          child: Text(
            AppLocaleKeys.authLoginRequiredBtnContinueGuest.tr(),
            style: AppTypography.labelMd(color: colors.secondaryMuted),
          ),
        ),
      ],
    );
  }
}

/// Medical data confidentiality and encryption reassurance pill.
///
/// NOTE: Free of any English acronyms in Arabic mode per project rules.
class _PrivacyAndSecurityPill extends StatelessWidget {
  const _PrivacyAndSecurityPill();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: AppRadii.roundedFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 13, color: colors.brandEmeraldDark),
            const SizedBox(width: AppSpacing.space2xs),
            Flexible(
              child: Text(
                AppLocaleKeys.authLoginRequiredPrivacyPill.tr(),
                textAlign: TextAlign.center,
                style: AppTypography.labelSm(color: colors.secondaryMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
