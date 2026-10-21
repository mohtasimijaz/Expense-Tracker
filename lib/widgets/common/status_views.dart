import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_info.dart';
import '../../constants/app_strings.dart';
import '../../utils/app_routes.dart';

/// Animated loading indicator (spinning coin) with an optional message.
class LoadingView extends StatelessWidget {
  /// Creates a loading view.
  const LoadingView({super.key, this.message = AppStrings.loading});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final text = message;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppSizes.loadingArt,
            child: Lottie.asset(
              AppAssets.lottieLoading,
              animate: AppMotion.enabled(context),
              errorBuilder: (context, error, stackTrace) =>
                  const CircularProgressIndicator(),
            ),
          ),
          if (text != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error message with a retry button.
class ErrorView extends StatelessWidget {
  /// Creates an error view.
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: AppSizes.iconHero,
              color: context.palette.danger,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(AppStrings.errorTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(AppStrings.retry),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppSizes.buttonHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small uppercase heading above a group of content.
class SectionHeader extends StatelessWidget {
  /// Creates a section header with an optional trailing widget.
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ?trailingWidget,
        ],
      ),
    );
  }
}

/// The app logo: a gradient rounded square with a wallet glyph. Wrapped in
/// a [Hero] so it flies between splash and onboarding.
class AppLogo extends StatelessWidget {
  /// Creates the logo at [size].
  const AppLogo({super.key, this.size = AppSizes.logo});

  /// Hero tag shared by every instance.
  static const String heroTag = 'app-logo';

  static const double _iconScale = 0.5;
  static const double _radiusScale = 0.28;

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Hero(
      tag: heroTag,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: palette.brandGradient,
          borderRadius: BorderRadius.circular(size * _radiusScale),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(
                alpha: AppEffects.glassBorderOpacity,
              ),
              blurRadius: AppEffects.shadowBlur,
              offset: const Offset(0, AppEffects.shadowOffsetY),
            ),
          ],
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          color: AppColors.white,
          size: size * _iconScale,
        ),
      ),
    );
  }
}
