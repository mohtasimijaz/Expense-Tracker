import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/budget_status.dart';
import '../../utils/formatters.dart';

/// Budget usage bar for use on the brand gradient: white text, a bar that
/// turns amber at the warning threshold and red when exceeded.
class BudgetProgress extends StatelessWidget {
  /// Creates the progress row for [status].
  const BudgetProgress({
    super.key,
    required this.status,
    required this.formatter,
  });

  final BudgetStatus status;
  final CurrencyFormatter formatter;

  // Bright semantic colors that stay readable on the indigo gradient.
  static const Color _safe = Color(0xFF86EFAC);
  static const Color _warning = Color(0xFFFCD34D);
  static const Color _danger = Color(0xFFFCA5A5);

  Color get _barColor => switch (status.level) {
    BudgetLevel.exceeded => _danger,
    BudgetLevel.warning => _warning,
    _ => _safe,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme.bodySmall?.copyWith(color: AppColors.white);
    final exceeded = status.level == BudgetLevel.exceeded;
    final trailing = exceeded
        ? '${formatter.format(status.overspent)} ${AppStrings.budgetOver}'
        : '${formatter.format(status.remaining)} ${AppStrings.budgetLeft}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line 1: what matters most — amount left (or over) and percent.
        Row(
          children: [
            if (status.level != BudgetLevel.safe)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxs),
                child: Icon(
                  exceeded ? Icons.error_rounded : Icons.warning_amber_rounded,
                  size: AppSizes.iconSm,
                  color: _barColor,
                ),
              ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  trailing,
                  style: text?.copyWith(
                    color: _barColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${status.percentUsed}% ${AppStrings.budgetUsed}',
              style: text,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: status.progress),
            duration: AppDurations.slow,
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: AppSizes.progressBarHeight,
              color: _barColor,
              backgroundColor: AppColors.white.withValues(
                alpha: AppEffects.glassBorderOpacity,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        // Line 2: spent of budget.
        Text(
          '${formatter.format(status.spent)} ${AppStrings.budgetOf} '
          '${formatter.format(status.limit)}',
          style: text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
