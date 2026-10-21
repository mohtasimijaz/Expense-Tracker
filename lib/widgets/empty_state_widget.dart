import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_info.dart';
import '../utils/app_routes.dart';

/// Friendly illustration + message shown when a list has nothing to show.
class EmptyStateWidget extends StatelessWidget {
  /// Creates an empty state with an optional call-to-action.
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.add_rounded,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animate = AppMotion.enabled(context);
    final action = actionLabel;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: AppSizes.emptyStateArt,
            child: Lottie.asset(
              AppAssets.lottieEmpty,
              animate: animate,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.account_balance_wallet_outlined,
                size: AppSizes.iconHero,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: onAction,
              icon: Icon(icon),
              label: Text(action),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppSizes.buttonHeight),
              ),
            ),
          ],
        ],
      ).animate().fadeIn(duration: animate ? AppDurations.slow : Duration.zero),
    );
  }
}
