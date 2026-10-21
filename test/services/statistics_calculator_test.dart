import 'package:expense_tracker/services/statistics_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  // Wednesday 21 October 2026, 15:00.
  final now = DateTime(2026, 10, 21, 15);

  test('empty data gives zeros everywhere', () {
    final stats = StatisticsCalculator(const [], now: now);
    final breakdown = stats.periodBreakdown();
    expect(breakdown.today, 0);
    expect(breakdown.thisWeek, 0);
    expect(breakdown.thisMonth, 0);
    expect(breakdown.dailyAverage, 0);
    expect(stats.dailyTotals().every((d) => d.total == 0), isTrue);
    expect(stats.monthlyTotals().every((m) => m.total == 0), isTrue);
    expect(stats.categoryTotals(), isEmpty);
    expect(stats.monthComparison().changePercent, isNull);
  });

  test('period breakdown splits today, week (from Monday) and month', () {
    final stats = StatisticsCalculator([
      makeExpense(id: 'today', amount: 100, date: DateTime(2026, 10, 21, 9)),
      makeExpense(id: 'monday', amount: 50, date: DateTime(2026, 10, 19, 0)),
      makeExpense(id: 'sunday', amount: 20, date: DateTime(2026, 10, 18, 23)),
      makeExpense(id: 'first', amount: 30, date: DateTime(2026, 10, 1)),
      makeExpense(id: 'lastMonth', amount: 999, date: DateTime(2026, 9, 30)),
    ], now: now);
    final b = stats.periodBreakdown();
    expect(b.today, 100);
    expect(b.thisWeek, 150);
    expect(b.thisMonth, 200);
    expect(b.dailyAverage, closeTo(200 / 21, 1e-9));
  });

  test('daily totals cover the last 7 days oldest first', () {
    final stats = StatisticsCalculator([
      makeExpense(id: 'a', amount: 10, date: DateTime(2026, 10, 15, 10)),
      makeExpense(id: 'b', amount: 5, date: DateTime(2026, 10, 21, 1)),
      makeExpense(id: 'c', amount: 5, date: DateTime(2026, 10, 21, 22)),
      makeExpense(id: 'tooOld', amount: 99, date: DateTime(2026, 10, 14, 23)),
    ], now: now);
    final days = stats.dailyTotals();
    expect(days.length, 7);
    expect(days.first.day, DateTime(2026, 10, 15));
    expect(days.first.total, 10);
    expect(days.last.day, DateTime(2026, 10, 21));
    expect(days.last.total, 10);
  });

  test('monthly totals cross a year boundary correctly', () {
    final stats = StatisticsCalculator([
      makeExpense(id: 'sep', amount: 1, date: DateTime(2025, 9, 10)),
      makeExpense(id: 'dec', amount: 2, date: DateTime(2025, 12, 31, 23)),
      makeExpense(id: 'jan', amount: 3, date: DateTime(2026, 1, 1)),
      makeExpense(id: 'feb', amount: 4, date: DateTime(2026, 2, 14)),
    ], now: DateTime(2026, 2, 15));
    final months = stats.monthlyTotals();
    expect(months.map((m) => m.month), [
      DateTime(2025, 9),
      DateTime(2025, 10),
      DateTime(2025, 11),
      DateTime(2025, 12),
      DateTime(2026, 1),
      DateTime(2026, 2),
    ]);
    expect(months.map((m) => m.total), [1, 0, 0, 2, 3, 4]);
  });

  test('category totals are sorted with correct shares', () {
    final stats = StatisticsCalculator([
      makeExpense(id: 'a', amount: 300, category: 'Food'),
      makeExpense(id: 'b', amount: 100, category: 'Transport'),
      makeExpense(id: 'c', amount: 600, category: 'Food'),
    ], now: now);
    final totals = stats.categoryTotals();
    expect(totals.map((t) => t.categoryId), ['Food', 'Transport']);
    expect(totals.first.total, 900);
    expect(totals.first.share, closeTo(0.9, 1e-9));
    expect(totals.last.share, closeTo(0.1, 1e-9));
  });

  test('category totals can be limited to a start date', () {
    final stats = StatisticsCalculator([
      makeExpense(id: 'a', amount: 300, date: DateTime(2026, 9, 1)),
      makeExpense(id: 'b', amount: 100, date: DateTime(2026, 10, 5)),
    ], now: now);
    expect(stats.categoryTotals(from: stats.startOfMonth).single.total, 100);
  });

  test('month comparison computes percentage change', () {
    final stats = StatisticsCalculator([
      makeExpense(id: 'a', amount: 150, date: DateTime(2026, 10, 3)),
      makeExpense(id: 'b', amount: 100, date: DateTime(2026, 9, 3)),
    ], now: now);
    final c = stats.monthComparison();
    expect(c.current, 150);
    expect(c.previous, 100);
    expect(c.changePercent, closeTo(50, 1e-9));
  });

  test('handles very large amounts without overflow', () {
    final stats = StatisticsCalculator([
      for (var i = 0; i < 100; i++)
        makeExpense(id: '$i', amount: 999999999, date: DateTime(2026, 10, 21)),
    ], now: now);
    expect(stats.periodBreakdown().today, 99999999900);
  });
}
