import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';

/// One-time tip explaining swipe-to-delete and press-and-hold options.
/// Hidden once closed (remembered) and while the list is empty.
class GestureHint extends StatelessWidget {
  /// Creates the tip.
  const GestureHint({super.key});

  @override
  Widget build(BuildContext context) {
    final dismissed = context.select<SettingsProvider, bool>(
      (s) => s.settings.gestureHintDismissed,
    );
    final empty = context.select<ExpenseProvider, bool>((p) => p.isEmpty);
    final theme = Theme.of(context);
    return AnimatedSize(
      duration: AppDurations.medium,
      child: dismissed || empty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Container(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(
                    alpha: AppEffects.subtleOpacity,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swipe_left_rounded,
                      size: AppSizes.iconMd,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        AppStrings.gestureHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: context.palette.textSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: AppStrings.dismiss,
                      icon: const Icon(Icons.close_rounded),
                      iconSize: AppSizes.iconMd,
                      onPressed: () =>
                          context.read<SettingsProvider>().dismissGestureHint(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
