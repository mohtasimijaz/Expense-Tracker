import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../constants/category_data.dart';
import '../../models/insight_models.dart';
import '../../utils/formatters.dart';

/// Text and icon for an [Insight], formatted in the user's currency.
@immutable
class InsightPresentation {
  /// Creates a presentation.
  const InsightPresentation({
    required this.icon,
    required this.title,
    required this.message,
  });

  /// Builds the presentation for [insight].
  factory InsightPresentation.of(Insight insight, CurrencyFormatter formatter) {
    final category = insight.categoryId == null
        ? null
        : CategoryData.byId(insight.categoryId!);
    final percent = insight.percent ?? 0;
    final ratio = (insight.ratio ?? 1).toStringAsFixed(1);
    switch (insight.kind) {
      case InsightKind.budgetPace:
        return InsightPresentation(
          icon: Icons.speed_rounded,
          title: insight.tone == InsightTone.negative
              ? AppStrings.insightPaceBad
              : AppStrings.insightPaceGood,
          message: AppStrings.insightPace(
            formatter.format(insight.amount ?? 0),
            percent,
          ),
        );
      case InsightKind.categoryChange:
        final label = category?.label ?? '';
        return InsightPresentation(
          icon: category?.icon ?? Icons.category_rounded,
          title: AppStrings.insightCategoryTitle(label),
          message: percent < 0
              ? AppStrings.insightCategoryLess(percent.abs(), label)
              : AppStrings.insightCategoryMore(percent, label),
        );
      case InsightKind.weekendSpending:
        return InsightPresentation(
          icon: Icons.weekend_rounded,
          title: AppStrings.insightWeekend,
          message: insight.tone == InsightTone.negative
              ? AppStrings.insightWeekendMore(ratio)
              : AppStrings.insightWeekdayMore(ratio),
        );
      case InsightKind.topCategory:
        return InsightPresentation(
          icon: category?.icon ?? Icons.emoji_events_rounded,
          title: AppStrings.insightTopCategory,
          message: AppStrings.insightTopCategoryMessage(
            category?.label ?? '',
            percent,
          ),
        );
      case InsightKind.noSpendDays:
        return InsightPresentation(
          icon: Icons.savings_rounded,
          title: AppStrings.insightNoSpend,
          message: AppStrings.insightNoSpendMessage(insight.count ?? 0),
        );
      case InsightKind.biggestExpense:
        return InsightPresentation(
          icon: Icons.receipt_long_rounded,
          title: AppStrings.insightBiggest,
          message: AppStrings.insightBiggestMessage(
            insight.title ?? '',
            formatter.format(insight.amount ?? 0),
          ),
        );
      case InsightKind.monthRecap:
        return InsightPresentation(
          icon: Icons.auto_awesome_rounded,
          title: AppStrings.insightRecapTitle(
            AppDateFormat.monthName(insight.month ?? DateTime.now()),
          ),
          message: AppStrings.insightRecapMessage,
        );
    }
  }

  final IconData icon;
  final String title;
  final String message;
}
