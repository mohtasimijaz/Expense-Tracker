import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../models/statistics_models.dart';
import '../../utils/formatters.dart';
import 'chart_card.dart';

/// Bar chart of spending for each of the last 7 days.
class WeeklyBarChart extends StatelessWidget {
  /// Creates the chart from [days] (oldest first).
  const WeeklyBarChart({super.key, required this.days, required this.format});

  final List<DailyTotal> days;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = context.palette;
    final maxY = ChartStyle.maxY(days.map((d) => d.total));
    final axisStyle = ChartStyle.axisStyle(context);
    return SizedBox(
      height: AppSizes.chartHeight,
      child: BarChart(
        duration: AppDurations.slow,
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / ChartStyle.gridLines,
            getDrawingHorizontalLine: (_) => FlLine(
              color: scheme.outline,
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: AppSizes.chartReservedLeft,
                interval: maxY / ChartStyle.gridLines,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(ChartStyle.axisLabel(value), style: axisStyle),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: AppSizes.chartReservedBottom,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      AppDateFormat.weekday(days[index].day),
                      style: axisStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                    '${AppDateFormat.dayMonth(days[group.x].day)}\n'
                    '${format(rod.toY)}',
                    theme.textTheme.labelMedium!.copyWith(
                      color: scheme.onInverseSurface,
                    ),
                  ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: days[i].total,
                    width: AppSizes.barWidth,
                    gradient: palette.brandGradient as LinearGradient,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.sm),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY,
                      color: scheme.primary.withValues(
                        alpha: AppEffects.subtleOpacity,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
