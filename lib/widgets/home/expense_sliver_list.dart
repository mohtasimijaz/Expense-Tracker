import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/timeline_builder.dart';
import '../../utils/app_routes.dart';
import '../../utils/formatters.dart';
import '../common/expense_actions.dart';
import '../empty_state_widget.dart';
import '../expense_card.dart';
import 'day_header.dart';

/// The expense list as a sliver.
///
/// When sorted by date it is a timeline: one sticky header per day. Other
/// sorts show a flat list. Only [ExpenseProvider.visibleExpenses] are built;
/// the home screen loads the next page as the user nears the end.
class ExpenseSliverList extends StatelessWidget {
  /// Creates the list. [onAdd] opens quick add from the empty state.
  const ExpenseSliverList({super.key, required this.onAdd});

  final VoidCallback onAdd;

  static const double _slideBegin = 0.15;

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
    final loader = provider.hasMore
        ? const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        : null;
    if (!provider.isTimeline) {
      return SliverMainAxisGroup(
        slivers: [
          SliverList.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => _item(context, items[i], i),
          ),
          ?loader,
        ],
      );
    }
    final groups = provider.timeline;
    final maxTotal = TimelineBuilder.maxTotal(groups);
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    final background = Theme.of(context).scaffoldBackgroundColor;
    return SliverMainAxisGroup(
      slivers: [
        for (final group in groups)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: DayHeaderDelegate(
                  group: group,
                  maxTotal: maxTotal,
                  formatter: formatter,
                  background: background,
                ),
              ),
              SliverList.builder(
                itemCount: group.expenses.length,
                itemBuilder: (context, i) =>
                    _item(context, group.expenses[i], i),
              ),
            ],
          ),
        ?loader,
      ],
    );
  }

  Widget _item(BuildContext context, Expense expense, int index) {
    final animate = AppMotion.enabled(context);
    final delay =
        AppDurations.listItemStagger * (index % AppDurations.maxStaggeredItems);
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
            begin: animate ? _slideBegin : 0,
            end: 0,
            curve: Curves.easeOutCubic,
          ),
    );
  }
}

class _DismissibleExpense extends StatelessWidget {
  const _DismissibleExpense({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final danger = context.palette.danger;
    return Dismissible(
      key: ValueKey('dismiss-${expense.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ExpenseActions.delete(ExpenseActionTargets.of(context), expense),
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
        onTap: () => ExpenseActions.edit(context, expense),
        onLongPress: () => ExpenseActions.showOptions(context, expense),
      ),
    );
  }
}
