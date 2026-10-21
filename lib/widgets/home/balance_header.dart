import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/budget_status.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../common/glass_container.dart';
import '../common/rolling_text.dart';
import '../settings/budget_dialog.dart';
import 'budget_line.dart';
import 'budget_ring.dart';
import 'living_gradient.dart';
import 'tilt_card.dart';

/// The "living" balance card at the top of Home.
///
/// - Gradient shifts with the budget: indigo → amber (warning) → red (over),
///   and slowly rotates.
/// - This month's total rolls like an odometer when it changes.
/// - A ring shows how much of the budget is used.
/// - The card tilts with phone motion (or the mouse) with a light reflection.
class BalanceHeader extends StatelessWidget {
  /// Creates the card.
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
    final gradient = switch (status.level) {
      BudgetLevel.exceeded => palette.dangerGradient,
      BudgetLevel.warning => palette.warningGradient,
      _ => palette.brandGradient,
    };
    const onBrand = AppColors.white;
    final muted = onBrand.withValues(alpha: _mutedOpacity);

    return TiltCard(
      radius: AppRadius.xxl,
      child: LivingGradient(
        gradient: gradient,
        radius: AppRadius.xxl,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              color: muted,
                              size: AppSizes.iconSm,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  AppStrings.homeThisMonth,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: muted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: RollingText(
                            formatter.format(spent),
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: onBrand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status.hasBudget) ...[
                    const SizedBox(width: AppSpacing.sm),
                    BudgetRing(
                      progress: status.progress,
                      percent: status.percentUsed,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.sm),
                borderRadius: AppRadius.lg,
                child: status.hasBudget
                    ? BudgetLine(status: status, formatter: formatter)
                    : SetBudgetPrompt(onTap: () => showBudgetDialog(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
