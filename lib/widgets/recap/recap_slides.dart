import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../constants/category_data.dart';
import '../../models/insight_models.dart';
import '../../utils/formatters.dart';
import 'recap_slide_view.dart';

/// Builds the recap story slides for [recap].
abstract final class RecapSlides {
  static const int _percentScale = 100;

  // One gradient per slide so the story feels lively.
  static const List<List<Color>> _gradients = [
    [Color(0xFF4338CA), Color(0xFF7C3AED)],
    [Color(0xFF0F766E), Color(0xFF0E7490)],
    [Color(0xFFB45309), Color(0xFFC2410C)],
    [Color(0xFFBE185D), Color(0xFF7C3AED)],
    [Color(0xFF1E1B4B), Color(0xFF4338CA)],
    [Color(0xFF4F46E5), Color(0xFF0D9488)],
  ];

  static LinearGradient _gradient(int i) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _gradients[i % _gradients.length],
  );

  /// The slides, or a single "nothing yet" slide for an empty month.
  static List<RecapSlide> build(MonthRecap recap, CurrencyFormatter f) {
    final month = AppDateFormat.monthName(recap.month);
    final title = AppStrings.recapTitle(month, current: recap.isCurrentMonth);
    if (!recap.hasData) {
      return [
        RecapSlide(
          gradient: _gradient(0),
          emoji: '🗓️',
          kicker: title,
          headline: AppStrings.recapEmpty,
        ),
      ];
    }
    final top = recap.topCategory;
    final day = recap.biggestDay;
    final change = recap.changePercent;
    final previous = AppDateFormat.monthName(
      DateTime(recap.month.year, recap.month.month - 1),
    );
    return [
      RecapSlide(
        gradient: _gradient(0),
        emoji: '💸',
        kicker: '$title\n${AppStrings.recapYouSpent}',
        headline: f.format(recap.total),
        caption: AppStrings.recapCount(recap.count),
      ),
      RecapSlide(
        gradient: _gradient(1),
        emoji: '📅',
        kicker: AppStrings.recapAverage(f.format(recap.dailyAverage)),
        headline: '${recap.noSpendDays}',
        caption:
            '${AppStrings.recapNoSpendDays}\n'
            '${AppStrings.recapNoSpendMessage(recap.noSpendDays, recap.daysCounted)}',
      ),
      if (top != null)
        RecapSlide(
          gradient: _gradient(2),
          icon: CategoryData.byId(top.categoryId).icon,
          kicker: AppStrings.recapTopCategory,
          headline: CategoryData.byId(top.categoryId).label,
          caption:
              '${f.format(top.total)} · '
              '${AppStrings.recapShareOf((top.share * _percentScale).round())}',
        ),
      if (day != null)
        RecapSlide(
          gradient: _gradient(3),
          emoji: '🔥',
          kicker: AppStrings.recapBiggestDay,
          headline: AppDateFormat.dayMonth(day.day),
          caption: f.format(day.total),
        ),
      if (change != null)
        RecapSlide(
          gradient: _gradient(4),
          emoji: change <= 0 ? '📉' : '📈',
          kicker: AppStrings.recapCompared(previous),
          headline: change <= 0
              ? AppStrings.recapLess(change.abs())
              : AppStrings.recapMore(change),
          caption:
              '${f.format(recap.previousTotal)} → ${f.format(recap.total)}',
        ),
      RecapSlide(
        gradient: _gradient(5),
        emoji: '✨',
        kicker: title,
        headline: f.format(recap.total),
        caption: [
          AppStrings.recapCount(recap.count),
          if (top != null) CategoryData.byId(top.categoryId).label,
          AppStrings.recapAverage(f.format(recap.dailyAverage)),
        ].join(' · '),
        footer: AppStrings.recapFooter,
      ),
    ];
  }
}
