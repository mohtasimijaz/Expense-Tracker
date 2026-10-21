import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';

/// "12 expenses · Rs 4,500" line with the active date range and a
/// clear-filters action.
class ExpenseListHeader extends StatelessWidget {
  /// Creates the header.
  const ExpenseListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (count, total, range, hasFilters) = context
        .select<ExpenseProvider, (int, double, DateTimeRange?, bool)>(
          (p) => (
            p.filteredExpenses.length,
            p.filteredTotal,
            p.dateRange,
            p.hasActiveFilters,
          ),
        );
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    final provider = context.read<ExpenseProvider>();
    final noun = count == 1
        ? AppStrings.expenseSingular
        : AppStrings.expensePlural;
    final activeRange = range;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$count $noun · ${formatter.format(total)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: context.palette.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasFilters)
              TextButton.icon(
                onPressed: provider.clearFilters,
                icon: const Icon(
                  Icons.filter_alt_off_rounded,
                  size: AppSizes.iconSm,
                ),
                label: const Text(AppStrings.homeClearFilters),
              ),
          ],
        ),
        if (activeRange != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: InputChip(
              avatar: const Icon(
                Icons.date_range_rounded,
                size: AppSizes.iconSm,
              ),
              label: Text(AppDateFormat.range(activeRange)),
              onDeleted: () => provider.setDateRange(null),
            ),
          ),
      ],
    );
  }
}
