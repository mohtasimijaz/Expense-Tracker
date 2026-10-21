import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_theme.dart';
import '../models/expense.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import 'category_badge.dart';
import 'common/pressable_scale.dart';

/// One expense in the list: category icon, title, badge, date and amount.
class ExpenseCard extends StatelessWidget {
  /// Creates a card. [onTap] usually opens the edit screen.
  const ExpenseCard({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  // Largest share of the row the amount may take.
  static const double _amountMaxFraction = 0.45;
  static const double _outlineOpacity = 0.6;

  /// Hero tag linking the card's icon to the edit screen.
  static String heroTagFor(String id) => 'expense-icon-$id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    final hasNote = expense.note != null;
    return PressableScale(
      onTap: onTap,
      semanticLabel: '${expense.title}, ${formatter.format(expense.amount)}',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: _outlineOpacity),
          ),
          boxShadow: [
            BoxShadow(
              color: palette.cardShadow,
              blurRadius: AppEffects.shadowBlur,
              offset: const Offset(0, AppEffects.shadowOffsetY / 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              CategoryIcon(
                categoryId: expense.category,
                heroTag: heroTagFor(expense.id),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CategoryBadge(categoryId: expense.category),
                        Text(
                          AppDateFormat.relative(expense.date),
                          style: theme.textTheme.bodySmall,
                        ),
                        if (hasNote)
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: AppSizes.iconXs,
                            color: palette.textSecondary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Amount takes only the width it needs (up to a cap) so the
              // title gets the rest; very large amounts shrink, never truncate.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * _amountMaxFraction,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatter.format(expense.amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
