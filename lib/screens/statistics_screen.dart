import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_routes.dart';
import '../utils/formatters.dart';
import 'recap_screen.dart';
import '../widgets/category_breakdown_tile.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stats/category_pie_chart.dart';
import '../widgets/stats/chart_card.dart';
import '../widgets/stats/month_comparison_card.dart';
import '../widgets/stats/monthly_trend_chart.dart';
import '../widgets/stats/stat_cards.dart';
import '../widgets/stats/weekly_bar_chart.dart';

/// Charts and breakdowns of spending.
class StatisticsScreen extends StatefulWidget {
  /// Creates the screen.
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  /// `true` = this month only, `false` = all time (pie chart period).
  final ValueNotifier<bool> _monthOnly = ValueNotifier(true);

  @override
  void dispose() {
    _monthOnly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final formatter = context.select<SettingsProvider, CurrencyFormatter>(
      (s) => s.formatter,
    );
    final stats = provider.statistics;
    final animate = AppMotion.enabled(context);

    final Widget body;
    if (provider.isEmpty) {
      body = const Center(
        child: SingleChildScrollView(
          child: EmptyStateWidget(
            title: AppStrings.statsNoDataTitle,
            message: AppStrings.statsNoDataMessage,
          ),
        ),
      );
    } else {
      final cards = <Widget>[
        PeriodBreakdownGrid(
          breakdown: stats.periodBreakdown(),
          format: formatter.compact,
        ),
        ChartCard(
          title: AppStrings.statsComparison,
          child: MonthComparisonCard(
            comparison: stats.monthComparison(),
            format: formatter.format,
          ),
        ),
        ChartCard(
          title: AppStrings.statsWeekly,
          child: WeeklyBarChart(
            days: stats.dailyTotals(),
            format: formatter.format,
          ),
        ),
        ChartCard(
          title: AppStrings.statsMonthlyTrend,
          child: MonthlyTrendChart(
            months: stats.monthlyTotals(),
            format: formatter.format,
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _monthOnly,
          builder: (context, monthOnly, _) {
            final totals = stats.categoryTotals(
              from: monthOnly ? stats.startOfMonth : null,
            );
            return ChartCard(
              title: AppStrings.statsCategories,
              trailing: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: true,
                    label: Text(AppStrings.statsPeriodMonth),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(AppStrings.statsPeriodAll),
                  ),
                ],
                selected: {monthOnly},
                onSelectionChanged: (s) => _monthOnly.value = s.first,
              ),
              child: Column(
                children: [
                  CategoryPieChart(totals: totals, format: formatter.format),
                  const SizedBox(height: AppSpacing.md),
                  for (final total in totals)
                    CategoryBreakdownTile(
                      total: total,
                      format: formatter.format,
                    ),
                ],
              ),
            );
          },
        ),
      ];
      body = LayoutBuilder(
        builder: (context, constraints) => ListView.separated(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSizes.fabClearance,
          ),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, i) => cards[i]
              .animate()
              .fadeIn(
                duration: animate ? AppDurations.slow : Duration.zero,
                delay: animate
                    ? AppDurations.listItemStagger * i
                    : Duration.zero,
              )
              .slideY(begin: animate ? 0.08 : 0, end: 0),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.transparent,
      appBar: AppBar(
        title: const Text(AppStrings.statsTitle),
        actions: [
          if (!provider.isEmpty)
            IconButton(
              tooltip: AppStrings.recapTooltip,
              icon: const Icon(Icons.auto_awesome_rounded),
              onPressed: () => Navigator.of(context).push(
                AppRoutes.fadeSlide<void>(
                  RecapScreen(month: provider.insights.recapMonth()),
                  fullscreenDialog: true,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: body,
          ),
        ),
      ),
    );
  }
}
