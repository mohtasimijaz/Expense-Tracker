import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../screens/add_expense_screen.dart';
import '../../utils/app_routes.dart';
import '../common/app_feedback.dart';
import '../empty_state_widget.dart';
import '../expense_card.dart';

/// The lazily built, swipe-to-delete expense list (as a sliver).
///
/// Only [ExpenseProvider.visibleExpenses] are built; the home screen asks
/// for the next page as the user nears the end.
class ExpenseSliverList extends StatelessWidget {
  /// Creates the list. [onAdd] opens the add screen from the empty state.
  const ExpenseSliverList({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final items = provider.visibleExpenses;
    if (items.isEmpty) {
      final noData = provider.isEmpty;
      return SliverToBoxAdapter(
        child: EmptyStateWidget(
          title: noData ? AppStrings.emptyTitle : AppStrings.noResultsTitle,
          message: noData
              ? AppStrings.emptyMessage
              : AppStrings.noResultsMessage,
          actionLabel: noData
              ? AppStrings.addFirstExpense
              : AppStrings.homeClearFilters,
          icon: noData ? Icons.add_rounded : Icons.filter_alt_off_rounded,
          onAction: noData ? onAdd : provider.clearFilters,
        ),
      );
    }
    final animate = AppMotion.enabled(context);
    return SliverList.builder(
      itemCount: items.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final expense = items[index];
        final delay =
            AppDurations.listItemStagger *
            (index % AppDurations.maxStaggeredItems);
        return Padding(
          key: ValueKey(expense.id),
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: _DismissibleExpense(expense: expense)
              .animate()
              .fadeIn(
                duration: animate ? AppDurations.medium : Duration.zero,
                delay: animate ? delay : Duration.zero,
              )
              .slideY(
                begin: animate ? 0.15 : 0,
                end: 0,
                curve: Curves.easeOutCubic,
              ),
        );
      },
    );
  }
}

class _DismissibleExpense extends StatelessWidget {
  const _DismissibleExpense({required this.expense});

  final Expense expense;

  Future<void> _delete(BuildContext context) async {
    // This item leaves the tree as soon as it is removed from the list, so
    // grab everything needed after the await up front.
    final provider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final danger = context.palette.danger;
    final ok = await provider.deleteExpense(expense.id);
    if (!ok) {
      AppFeedback.showSnackOn(
        messenger,
        provider.errorMessage ?? AppStrings.errorDelete,
        errorColor: danger,
      );
      return;
    }
    AppFeedback.showSnackOn(
      messenger,
      '"${expense.title}" ${AppStrings.expenseDeleted}',
      actionLabel: AppStrings.undo,
      onAction: () async {
        final restored = await provider.undoDelete();
        if (!restored) {
          AppFeedback.showSnackOn(
            messenger,
            AppStrings.errorRestore,
            errorColor: danger,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final danger = context.palette.danger;
    return Dismissible(
      key: ValueKey('dismiss-${expense.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: danger.withValues(alpha: AppEffects.tintOpacity * 1.5),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.swipeToDelete,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: danger),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.delete_rounded, color: danger),
          ],
        ),
      ),
      child: ExpenseCard(
        expense: expense,
        onTap: () => Navigator.of(
          context,
        ).push(AppRoutes.fadeSlide<void>(AddExpenseScreen(expense: expense))),
      ),
    );
  }
}
