import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/budget_status.dart';
import '../../utils/formatters.dart';

/// "Rs 38,749 left · of Rs 40,000" (or "over budget").
class BudgetLine extends StatelessWidget {
  /// Creates the line.
  const BudgetLine({super.key, required this.status, required this.formatter});

  final BudgetStatus status;
  final CurrencyFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.white);
    final exceeded = status.level == BudgetLevel.exceeded;
    final headline = exceeded
        ? '${formatter.format(status.overspent)} ${AppStrings.budgetOver}'
        : '${formatter.format(status.remaining)} ${AppStrings.budgetLeft}';
    return Row(
      children: [
        Icon(
          switch (status.level) {
            BudgetLevel.exceeded => Icons.error_rounded,
            BudgetLevel.warning => Icons.warning_amber_rounded,
            _ => Icons.savings_rounded,
          },
          size: AppSizes.iconMd,
          color: AppColors.white,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              headline,
              style: text?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${AppStrings.budgetOf} ${formatter.format(status.limit)}',
              style: text,
            ),
          ),
        ),
      ],
    );
  }
}

/// Prompt with a button to set a monthly budget.
class SetBudgetPrompt extends StatelessWidget {
  /// Creates the prompt.
  const SetBudgetPrompt({super.key, required this.onTap});

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
