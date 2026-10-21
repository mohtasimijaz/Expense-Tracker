import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../models/statistics_models.dart';
import '../summary_card.dart';

/// 2×2 grid: today, this week, this month and daily average.
class PeriodBreakdownGrid extends StatelessWidget {
  /// Creates the grid.
  const PeriodBreakdownGrid({
    super.key,
    required this.breakdown,
    required this.format,
  });

  final PeriodBreakdown breakdown;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = context.palette;
    final tiles = [
      (
        AppStrings.statsToday,
        breakdown.today,
        Icons.today_rounded,
        scheme.primary,
      ),
      (
        AppStrings.statsThisWeek,
        breakdown.thisWeek,
        Icons.view_week_rounded,
        scheme.tertiary,
      ),
      (
        AppStrings.statsThisMonth,
        breakdown.thisMonth,
        Icons.calendar_month_rounded,
        scheme.secondary,
      ),
      (
        AppStrings.statsDailyAverage,
        breakdown.dailyAverage,
        Icons.speed_rounded,
        palette.warning,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppSizes.wideBreakpoint ? 4 : 2;
        final width =
            (constraints.maxWidth - AppSpacing.xs * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final (label, value, icon, color) in tiles)
              SizedBox(
                width: width,
                child: SummaryCard(
                  label: label,
                  value: value,
                  format: format,
                  icon: icon,
                  color: color,
                ),
              ),
          ],
        );
      },
    );
  }
}
