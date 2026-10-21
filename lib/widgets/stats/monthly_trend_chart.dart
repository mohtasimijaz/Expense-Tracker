import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../models/statistics_models.dart';
import '../../utils/formatters.dart';
import 'chart_card.dart';

/// Smooth line chart of monthly totals with a gradient fill.
class MonthlyTrendChart extends StatelessWidget {
  /// Creates the chart from [months] (oldest first).
  const MonthlyTrendChart({
    super.key,
    required this.months,
    required this.format,
  });

  static const double _fillOpacity = 0.25;
  static const double _dotRadius = 4;

  final List<MonthlyTotal> months;
  final String Function(double value) format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxY = ChartStyle.maxY(months.map((m) => m.total));
    final axisStyle = ChartStyle.axisStyle(context);
    return SizedBox(
      height: AppSizes.chartHeight,
      child: LineChart(
        duration: AppDurations.slow,
        LineChartData(
          minY: 0,
          maxY: maxY,
          minX: 0,
          maxX: (months.length - 1).toDouble(),
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
                interval: 1,
                reservedSize: AppSizes.chartReservedBottom,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= months.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      AppDateFormat.month(months[index].month),
                      style: axisStyle,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    '${AppDateFormat.monthYear(months[spot.x.toInt()].month)}\n'
                    '${format(spot.y)}',
                    theme.textTheme.labelMedium!.copyWith(
                      color: scheme.onInverseSurface,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < months.length; i++)
                  FlSpot(i.toDouble(), months[i].total),
              ],
              isCurved: true,
              preventCurveOverShooting: true,
              color: scheme.primary,
              barWidth: AppSizes.lineWidth,
              isStrokeCapRound: true,
              dotData: FlDotData(
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: _dotRadius,
                      color: scheme.surface,
                      strokeWidth: AppSizes.lineWidth,
                      strokeColor: scheme.primary,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primary.withValues(alpha: _fillOpacity),
                    scheme.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
