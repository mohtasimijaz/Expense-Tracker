import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/statistics_models.dart';

/// Pure, side-effect-free statistics over a list of expenses.
///
/// [now] is injectable so results are deterministic in tests.
class StatisticsCalculator {
  /// Creates a calculator for [expenses] relative to [now].
  StatisticsCalculator(this.expenses, {DateTime? now})
    : now = now ?? DateTime.now();

  /// Days shown in the weekly chart.
  static const int weekDays = 7;

  /// Months shown in the trend chart.
  static const int trendMonths = 6;

  final List<Expense> expenses;
  final DateTime now;

  DateTime get _today => DateUtils.dateOnly(now);

  /// Monday of the current week.
  DateTime get startOfWeek =>
      _today.subtract(Duration(days: _today.weekday - DateTime.monday));

  /// First day of the current month.
  DateTime get startOfMonth => DateTime(now.year, now.month);

  /// Sum of expenses with `start <= date < end`.
  double totalBetween(DateTime start, DateTime end) {
    var total = 0.0;
    for (final e in expenses) {
      if (!e.date.isBefore(start) && e.date.isBefore(end)) total += e.amount;
    }
    return total;
  }

  /// Sum spent in the calendar month containing [month].
  double totalForMonth(DateTime month) => totalBetween(
    DateTime(month.year, month.month),
    DateTime(month.year, month.month + 1),
  );

  /// Today / week / month totals and the daily average for this month.
  PeriodBreakdown periodBreakdown() {
    final tomorrow = DateUtils.addDaysToDate(_today, 1);
    final thisMonth = totalBetween(startOfMonth, tomorrow);
    return PeriodBreakdown(
      today: totalBetween(_today, tomorrow),
      thisWeek: totalBetween(startOfWeek, tomorrow),
      thisMonth: thisMonth,
      dailyAverage: thisMonth / now.day,
    );
  }

  /// Daily totals for the last [days] days, oldest first, including today.
  List<DailyTotal> dailyTotals({int days = weekDays}) {
    final start = DateUtils.addDaysToDate(_today, -(days - 1));
    final totals = List<double>.filled(days, 0);
    for (final e in expenses) {
      final index = DateUtils.dateOnly(e.date).difference(start).inDays;
      if (index >= 0 && index < days) totals[index] += e.amount;
    }
    return [
      for (var i = 0; i < days; i++)
        DailyTotal(DateUtils.addDaysToDate(start, i), totals[i]),
    ];
  }

  /// Monthly totals for the last [months] months, oldest first.
  List<MonthlyTotal> monthlyTotals({int months = trendMonths}) {
    return [
      for (var i = months - 1; i >= 0; i--)
        () {
          final month = DateTime(now.year, now.month - i);
          return MonthlyTotal(month, totalForMonth(month));
        }(),
    ];
  }

  /// Totals per category, largest first. When [from] is given only expenses
  /// on or after it are counted.
  List<CategoryTotal> categoryTotals({DateTime? from}) {
    final sums = <String, double>{};
    var overall = 0.0;
    for (final e in expenses) {
      if (from != null && e.date.isBefore(from)) continue;
      sums[e.category] = (sums[e.category] ?? 0) + e.amount;
      overall += e.amount;
    }
    final result = [
      for (final entry in sums.entries)
        CategoryTotal(
          entry.key,
          entry.value,
          overall == 0 ? 0 : entry.value / overall,
        ),
    ]..sort((a, b) => b.total.compareTo(a.total));
    return result;
  }

  /// This month versus last month.
  MonthComparison monthComparison() => MonthComparison(
    current: totalForMonth(now),
    previous: totalForMonth(DateTime(now.year, now.month - 1)),
  );
}
