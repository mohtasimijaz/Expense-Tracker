import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../constants/category_data.dart';
import '../../models/statistics_models.dart';

/// Donut chart of spending per category. Tapping a slice enlarges it and
/// shows its amount in the centre.
class CategoryPieChart extends StatefulWidget {
  /// Creates the chart from [totals] (largest first).
  const CategoryPieChart({
    super.key,
    required this.totals,
    required this.format,
  });

  final List<CategoryTotal> totals;
  final String Function(double value) format;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  static const int _percentScale = 100;
  static const double _minLabelShare = 0.08;

  final ValueNotifier<int> _touched = ValueNotifier(-1);

  @override
  void dispose() {
    _touched.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = widget.totals;
    if (totals.isEmpty) {
      return SizedBox(
        height: AppSizes.pieChartHeight,
        child: Center(
          child: Text(
            AppStrings.statsNoCategoryData,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ),
      );
    }
    final overall = totals.fold<double>(0, (sum, t) => sum + t.total);
    return SizedBox(
      height: AppSizes.pieChartHeight,
      child: ValueListenableBuilder<int>(
        valueListenable: _touched,
        builder: (context, touched, _) {
          final focus = touched >= 0 && touched < totals.length
              ? totals[touched]
              : null;
          return Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                duration: AppDurations.slow,
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: AppSizes.pieCenterRadius,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      final index =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                      _touched.value = event.isInterestedForInteractions
                          ? index
                          : -1;
                    },
                  ),
                  sections: [
                    for (var i = 0; i < totals.length; i++)
                      _section(context, totals[i], i == touched),
                  ],
                ),
              ),
              IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      focus == null
                          ? AppStrings.homeTotalSpent
                          : CategoryData.byId(focus.categoryId).label,
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      widget.format(focus?.total ?? overall),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PieChartSectionData _section(
    BuildContext context,
    CategoryTotal total,
    bool touched,
  ) {
    final theme = Theme.of(context);
    final color = CategoryData.byId(
      total.categoryId,
    ).colorFor(theme.brightness);
    final percent = (total.share * _percentScale).round();
    return PieChartSectionData(
      value: total.total,
      color: color,
      radius: touched
          ? AppSizes.pieSectionRadiusTouched
          : AppSizes.pieSectionRadius,
      title: total.share >= _minLabelShare ? '$percent%' : '',
      titleStyle: theme.textTheme.labelMedium?.copyWith(
        color: theme.brightness == Brightness.dark
            ? AppColors.backgroundDark
            : AppColors.white,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
