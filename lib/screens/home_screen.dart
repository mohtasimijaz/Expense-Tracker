import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../providers/expense_provider.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import '../widgets/common/status_views.dart';
import '../widgets/home/balance_header.dart';
import '../widgets/home/category_filter_bar.dart';
import '../widgets/home/expense_list_header.dart';
import '../widgets/home/expense_sliver_list.dart';
import '../widgets/home/gesture_hint.dart';
import '../widgets/home/search_sort_bar.dart';
import '../widgets/home/streak_chip.dart';
import '../widgets/home/summary_row.dart';
import '../widgets/insights/insight_carousel.dart';

/// Main screen: monthly balance, budget, summary, filters and the list.
class HomeScreen extends StatelessWidget {
  /// Creates the screen. [onAdd] opens the add-expense screen.
  const HomeScreen({super.key, required this.onAdd});

  final VoidCallback onAdd;

  bool _onScroll(ScrollNotification notification, ExpenseProvider provider) {
    if (notification.metrics.extentAfter < AppSizes.loadMoreTriggerExtent &&
        provider.hasMore) {
      provider.loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final status = context.select<ExpenseProvider, LoadStatus>((p) => p.status);
    final provider = context.read<ExpenseProvider>();
    final Widget body = switch (status) {
      LoadStatus.initial || LoadStatus.loading => const LoadingView(),
      LoadStatus.error => ErrorView(
        message: provider.errorMessage ?? AppStrings.errorLoad,
        onRetry: provider.loadExpenses,
      ),
      LoadStatus.ready => _HomeContent(
        onAdd: onAdd,
        onScroll: (n) => _onScroll(n, provider),
        onRefresh: provider.refresh,
      ),
    };
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(duration: AppDurations.medium, child: body),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.onAdd,
    required this.onScroll,
    required this.onRefresh,
  });

  final VoidCallback onAdd;
  final bool Function(ScrollNotification) onScroll;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animate = AppMotion.enabled(context);
    final header = <Widget>[
      const SizedBox(height: AppSpacing.md),
      Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.homeGreeting,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const StreakChip(),
        ],
      ),
      Text(
        AppDateFormat.full(DateTime.now()),
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: AppSpacing.md),
      const BalanceHeader(),
      const SizedBox(height: AppSpacing.md),
      const SummaryRow(),
      const SizedBox(height: AppSpacing.lg),
      const InsightCarousel(),
      const SizedBox(height: AppSpacing.lg),
      const SearchSortBar(),
      const SizedBox(height: AppSpacing.sm),
      const CategoryFilterBar(),
      const SizedBox(height: AppSpacing.sm),
      const ExpenseListHeader(),
      const SizedBox(height: AppSpacing.xs),
      const GestureHint(),
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: onScroll,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverList.list(
                    children: header
                        .animate(
                          interval: animate
                              ? AppDurations.listItemStagger
                              : Duration.zero,
                        )
                        .fadeIn(
                          duration: animate ? AppDurations.slow : Duration.zero,
                        ),
                  ),
                ),
                SliverPadding(
                  // Room for the glass nav bar (in the bottom padding because
                  // the shell extends its body behind it) plus the + button.
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    MediaQuery.paddingOf(context).bottom +
                        AppSizes.fabClearance,
                  ),
                  sliver: ExpenseSliverList(onAdd: onAdd),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
