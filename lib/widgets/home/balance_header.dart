import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_theme.dart';
import '../../models/budget_status.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../animated_counter.dart';
import '../common/glass_container.dart';
import '../settings/budget_dialog.dart';
import 'budget_progress.dart';

/// Gradient hero card at the top of Home: this month's spending with an
/// animated counter and the budget progress on a glass panel.
class BalanceHeader extends StatelessWidget {
  /// Creates the header.
  const BalanceHeader({super.key});

  static const double _mutedOpacity = 0.85;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final spent = context.select<ExpenseProvider, double>(
      (p) => p.currentMonthSpent,
    );
    final (limit, threshold) = context.select<SettingsProvider, (double, int)>(
      (s) => (s.settings.monthlyBudget, s.settings.alertThresholdPercent),
    );
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    final status = BudgetStatus(
      spent: spent,
      limit: limit,
      thresholdPercent: threshold,
    );
    const onBrand = AppColors.white;
    final onBrandMuted = onBrand.withValues(alpha: _mutedOpacity);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: palette.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(
              alpha: AppEffects.glassBorderOpacity,
            ),
            blurRadius: AppEffects.shadowBlur,
            offset: const Offset(0, AppEffects.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: onBrandMuted,
                size: AppSizes.iconSm,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  AppStrings.homeThisMonth,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: onBrandMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedCounter(
              value: spent,
              format: formatter.format,
              style: theme.textTheme.displaySmall?.copyWith(
                color: onBrand,
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.sm),
            borderRadius: AppRadius.lg,
            child: status.hasBudget
                ? BudgetProgress(status: status, formatter: formatter)
                : _SetBudgetPrompt(onTap: () => showBudgetDialog(context)),
          ),
        ],
      ),
    );
  }
}

class _SetBudgetPrompt extends StatelessWidget {
  const _SetBudgetPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Icon(Icons.flag_rounded, color: AppColors.white),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            AppStrings.homeSetBudgetPrompt,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.white),
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.white,
            backgroundColor: AppColors.white.withValues(
              alpha: AppEffects.glassBorderOpacity,
            ),
          ),
          child: const Text(AppStrings.homeSetBudgetAction),
        ),
      ],
    );
  }
}
