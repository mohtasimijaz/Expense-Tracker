import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/insight_models.dart';
import '../models/statistics_models.dart';
import 'statistics_calculator.dart';

/// Pure logic for insights, streaks, recaps and celebrations.
///
/// [now] is injectable so every result is deterministic in tests.
class InsightsCalculator {
  /// Creates a calculator over [expenses].
  InsightsCalculator(this.expenses, {DateTime? now})
    : now = now ?? DateTime.now(),
      _stats = StatisticsCalculator(expenses, now: now);

  /// Streak lengths that trigger a celebration.
  static const List<int> streakMilestones = [3, 7, 14, 30, 60, 100, 180, 365];

  static const int _percentScale = 100;
  static const int _minCategoryChangePercent = 10;
  static const double _minTopShare = 0.3;
  static const int _minMonthExpenses = 3;
  static const int _minPaceDays = 3;
  static const int _minNoSpendElapsedDays = 5;
  static const int _weekendWindowDays = 56;
  static const int _minWeekendWindowDays = 14;
  static const double _weekendHighRatio = 1.3;
  static const double _weekendLowRatio = 0.77;

  final List<Expense> expenses;
  final DateTime now;
  final StatisticsCalculator _stats;

  DateTime get _today => DateUtils.dateOnly(now);

  Set<DateTime> get _activeDays => {
    for (final e in expenses) DateUtils.dateOnly(e.date),
  };

  /// Consecutive days with expenses ending today (or yesterday, so a streak
  /// is not "lost" before today's first entry).
  Streak streak() {
    final days = _activeDays;
    var cursor = days.contains(_today)
        ? _today
        : DateUtils.addDaysToDate(_today, -1);
    var length = 0;
    while (days.contains(cursor)) {
      length++;
      cursor = DateUtils.addDaysToDate(cursor, -1);
    }
    return length == 0
        ? Streak.none
        : Streak(length, DateUtils.addDaysToDate(cursor, 1));
  }

  /// The milestone to celebrate for [current], or `null` when there is none
  /// or it was already celebrated for this same streak.
  static int? milestoneToCelebrate(
    Streak current, {
    required DateTime? celebratedStart,
    required int celebratedLength,
  }) {
    int? reached;
    for (final m in streakMilestones) {
      if (current.length >= m) reached = m;
    }
    if (reached == null) return null;
    final sameStreak =
        celebratedStart != null &&
        current.start != null &&
        DateUtils.isSameDay(celebratedStart, current.start);
    if (sameStreak && reached <= celebratedLength) return null;
    return reached;
  }

  /// Last month, if it stayed within [budget] and has not been celebrated
  /// ([celebratedMonthKey] is a [monthKey]).
  MonthCelebration? monthToCelebrate({
    required double budget,
    required String? celebratedMonthKey,
  }) {
    if (budget <= 0) return null;
    final previous = DateTime(now.year, now.month - 1);
    if (monthKey(previous) == celebratedMonthKey) return null;
    final total = _stats.totalForMonth(previous);
    final hadExpenses = expenses.any(
      (e) => e.date.year == previous.year && e.date.month == previous.month,
    );
    if (!hadExpenses || total > budget) return null;
    return MonthCelebration(previous, budget - total);
  }

  /// Stable key for a month, e.g. `2026-10`.
  static String monthKey(DateTime month) =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  /// Builds the recap for [month] (defaults to the current month).
  MonthRecap recap([DateTime? month]) {
    final start = DateTime((month ?? now).year, (month ?? now).month);
    final end = DateTime(start.year, start.month + 1);
    final isCurrent = start.year == now.year && start.month == now.month;
    final daysCounted = isCurrent
        ? now.day
        : DateUtils.getDaysInMonth(start.year, start.month);
    final inMonth = [
      for (final e in expenses)
        if (!e.date.isBefore(start) && e.date.isBefore(end)) e,
    ];
    final byDay = <DateTime, double>{};
    Expense? biggest;
    for (final e in inMonth) {
      final day = DateUtils.dateOnly(e.date);
      byDay[day] = (byDay[day] ?? 0) + e.amount;
      if (biggest == null || e.amount > biggest.amount) biggest = e;
    }
    MapEntry<DateTime, double>? topDay;
    for (final entry in byDay.entries) {
      if (topDay == null || entry.value > topDay.value) topDay = entry;
    }
    final categories = StatisticsCalculator(inMonth, now: now).categoryTotals();
    return MonthRecap(
      month: start,
      isCurrentMonth: isCurrent,
      total: inMonth.fold(0, (sum, e) => sum + e.amount),
      count: inMonth.length,
      daysCounted: daysCounted,
      activeDays: byDay.length,
      previousTotal: _stats.totalForMonth(
        DateTime(start.year, start.month - 1),
      ),
      topCategory: categories.isEmpty ? null : categories.first,
      biggestDay: topDay == null ? null : DailyTotal(topDay.key, topDay.value),
      biggestExpense: biggest,
    );
  }

  /// The month the recap card should open: last month during the first week
  /// (when it has data), otherwise the current month.
  DateTime recapMonth() {
    const firstWeek = 7;
    final previous = DateTime(now.year, now.month - 1);
    if (now.day <= firstWeek && recap(previous).hasData) return previous;
    return DateTime(now.year, now.month);
  }

  /// Insights worth showing right now, most useful first.
  List<Insight> insights({double budget = 0}) {
    final month = recap();
    return [
      ?_budgetPace(month, budget),
      ?_categoryChange(),
      ?_weekendSpending(),
      ?_topCategory(month),
      ?_noSpendDays(month),
      ?_biggestExpense(month),
      if (recap(recapMonth()).hasData)
        Insight(
          kind: InsightKind.monthRecap,
          tone: InsightTone.neutral,
          month: recapMonth(),
        ),
    ];
  }

  Insight? _budgetPace(MonthRecap month, double budget) {
    if (budget <= 0 || now.day < _minPaceDays || month.total <= 0) return null;
    final days = DateUtils.getDaysInMonth(now.year, now.month);
    final projected = month.total / now.day * days;
    return Insight(
      kind: InsightKind.budgetPace,
      tone: projected > budget ? InsightTone.negative : InsightTone.positive,
      amount: projected,
      secondaryAmount: budget,
      percent: (projected / budget * _percentScale).round(),
    );
  }

  /// Month-to-date per category vs the same days of last month; reports the
  /// biggest relative change.
  Insight? _categoryChange() {
    final thisStart = DateTime(now.year, now.month);
    final tomorrow = DateUtils.addDaysToDate(_today, 1);
    final lastStart = DateTime(now.year, now.month - 1);
    final lastDays = DateUtils.getDaysInMonth(lastStart.year, lastStart.month);
    final lastEnd = DateUtils.addDaysToDate(
      lastStart,
      now.day < lastDays ? now.day : lastDays,
    );
    final current = _sumByCategory(thisStart, tomorrow);
    final previous = _sumByCategory(lastStart, lastEnd);
    Insight? best;
    var bestAbs = 0;
    for (final entry in previous.entries) {
      if (entry.value <= 0) continue;
      final spent = current[entry.key] ?? 0;
      final pct = ((spent - entry.value) / entry.value * _percentScale).round();
      if (pct.abs() >= _minCategoryChangePercent && pct.abs() > bestAbs) {
        bestAbs = pct.abs();
        best = Insight(
          kind: InsightKind.categoryChange,
          tone: pct < 0 ? InsightTone.positive : InsightTone.negative,
          categoryId: entry.key,
          percent: pct,
        );
      }
    }
    return best;
  }

  Map<String, double> _sumByCategory(DateTime start, DateTime end) {
    final sums = <String, double>{};
    for (final e in expenses) {
      if (!e.date.isBefore(start) && e.date.isBefore(end)) {
        sums[e.category] = (sums[e.category] ?? 0) + e.amount;
      }
    }
    return sums;
  }

  /// Average daily spend on weekends vs weekdays over the last 8 weeks.
  Insight? _weekendSpending() {
    if (expenses.isEmpty) return null;
    final first = expenses
        .map((e) => DateUtils.dateOnly(e.date))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final windowStart = DateUtils.addDaysToDate(
      _today,
      -(_weekendWindowDays - 1),
    );
    final start = first.isAfter(windowStart) ? first : windowStart;
    final span = _today.difference(start).inDays + 1;
    if (span < _minWeekendWindowDays) return null;
    var weekendTotal = 0.0, weekdayTotal = 0.0;
    var weekendDays = 0, weekdayDays = 0;
    for (var i = 0; i < span; i++) {
      final day = DateUtils.addDaysToDate(start, i);
      final isWeekend = day.weekday >= DateTime.saturday;
      isWeekend ? weekendDays++ : weekdayDays++;
    }
    for (final e in expenses) {
      final day = DateUtils.dateOnly(e.date);
      if (day.isBefore(start) || day.isAfter(_today)) continue;
      day.weekday >= DateTime.saturday
          ? weekendTotal += e.amount
          : weekdayTotal += e.amount;
    }
    final weekendAvg = weekendTotal / weekendDays;
    final weekdayAvg = weekdayTotal / weekdayDays;
    if (weekendAvg <= 0 || weekdayAvg <= 0) return null;
    final ratio = weekendAvg / weekdayAvg;
    if (ratio >= _weekendHighRatio) {
      return Insight(
        kind: InsightKind.weekendSpending,
        tone: InsightTone.negative,
        ratio: ratio,
      );
    }
    if (ratio <= _weekendLowRatio) {
      return Insight(
        kind: InsightKind.weekendSpending,
        tone: InsightTone.positive,
        ratio: 1 / ratio,
      );
    }
    return null;
  }

  Insight? _topCategory(MonthRecap month) {
    final top = month.topCategory;
    if (top == null || month.count < _minMonthExpenses) return null;
    if (top.share < _minTopShare) return null;
    return Insight(
      kind: InsightKind.topCategory,
      tone: InsightTone.neutral,
      categoryId: top.categoryId,
      percent: (top.share * _percentScale).round(),
    );
  }

  Insight? _noSpendDays(MonthRecap month) {
    final elapsed = now.day - 1; // today is not over yet
    if (!month.hasData || elapsed < _minNoSpendElapsedDays) return null;
    final start = DateTime(now.year, now.month);
    final active = {
      for (final e in expenses)
        if (!e.date.isBefore(start) && e.date.isBefore(_today))
          DateUtils.dateOnly(e.date),
    };
    final free = elapsed - active.length;
    if (free <= 0) return null;
    return Insight(
      kind: InsightKind.noSpendDays,
      tone: InsightTone.positive,
      count: free,
    );
  }

  Insight? _biggestExpense(MonthRecap month) {
    final biggest = month.biggestExpense;
    if (biggest == null || month.count < 2) return null;
    return Insight(
      kind: InsightKind.biggestExpense,
      tone: InsightTone.neutral,
      title: biggest.title,
      amount: biggest.amount,
      categoryId: biggest.category,
    );
  }
}
