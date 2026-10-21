import 'package:flutter/foundation.dart';

/// Total spent on one calendar day.
@immutable
class DailyTotal {
  /// Creates a daily total.
  const DailyTotal(this.day, this.total);

  /// The day (time set to midnight).
  final DateTime day;
  final double total;
}

/// Total spent in one calendar month.
@immutable
class MonthlyTotal {
  /// Creates a monthly total.
  const MonthlyTotal(this.month, this.total);

  /// First day of the month.
  final DateTime month;
  final double total;
}

/// Total spent in one category.
@immutable
class CategoryTotal {
  /// Creates a category total.
  const CategoryTotal(this.categoryId, this.total, this.share);

  final String categoryId;
  final double total;

  /// Fraction of the overall total (0..1).
  final double share;
}

/// This month compared with the previous month.
@immutable
class MonthComparison {
  /// Creates a comparison.
  const MonthComparison({required this.current, required this.previous});

  static const double _percentScale = 100;

  final double current;
  final double previous;

  /// Whether there is any previous spending to compare with.
  bool get hasPrevious => previous > 0;

  /// Signed percentage change, or `null` when there is nothing to compare.
  double? get changePercent =>
      hasPrevious ? (current - previous) / previous * _percentScale : null;
}

/// Totals for the standard reporting periods.
@immutable
class PeriodBreakdown {
  /// Creates a breakdown.
  const PeriodBreakdown({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
    required this.dailyAverage,
  });

  final double today;

  /// Monday to today.
  final double thisWeek;

  /// First of the month to today.
  final double thisMonth;

  /// [thisMonth] divided by days elapsed this month.
  final double dailyAverage;
}
