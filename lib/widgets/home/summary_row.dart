import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../summary_card.dart';

/// Three stat tiles (total, count, highest) for the currently filtered
/// expenses. Rebuilds only when those three numbers change.
class SummaryRow extends StatelessWidget {
  /// Creates the row.
  const SummaryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final (total, count, highest) = context
        .select<ExpenseProvider, (double, int, double)>(
          (p) =>
              (p.filteredTotal, p.filteredExpenses.length, p.filteredHighest),
        );
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: SummaryCard(
            label: AppStrings.homeTotalSpent,
            value: total,
            format: formatter.compact,
            icon: Icons.account_balance_wallet_rounded,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: SummaryCard(
            label: AppStrings.homeTransactions,
            value: count.toDouble(),
            format: (v) => v.round().toString(),
            icon: Icons.receipt_long_rounded,
            color: scheme.tertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: SummaryCard(
            label: AppStrings.homeHighest,
            value: highest,
            format: formatter.compact,
            icon: Icons.trending_up_rounded,
            color: palette.danger,
          ),
        ),
      ],
    );
  }
}
