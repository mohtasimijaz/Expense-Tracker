import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_theme.dart';
import '../../models/expense.dart';
import '../../providers/settings_provider.dart';
import '../../utils/formatters.dart';
import '../category_badge.dart';

/// Choices in the press-and-hold menu.
enum ExpenseOption { edit, delete }

/// Bottom sheet showing the expense with Edit and Delete actions. Pops
/// with the chosen [ExpenseOption].
class ExpenseOptionsSheet extends StatelessWidget {
  /// Creates the sheet.
  const ExpenseOptionsSheet({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final danger = context.palette.danger;
    final formatter = context.read<SettingsProvider>().formatter;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CategoryIcon(categoryId: expense.category),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        AppDateFormat.full(expense.date),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  formatter.format(expense.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text(AppStrings.optionsEdit),
              onTap: () => Navigator.of(context).pop(ExpenseOption.edit),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: danger),
              title: Text(
                AppStrings.optionsDelete,
                style: TextStyle(color: danger),
              ),
              onTap: () => Navigator.of(context).pop(ExpenseOption.delete),
            ),
          ],
        ),
      ),
    );
  }
}
