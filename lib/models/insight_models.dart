import 'package:flutter/foundation.dart';

import 'expense.dart';
import 'statistics_models.dart';

/// The kinds of automatic insight shown on the Home screen.
enum InsightKind {
  budgetPace,
  categoryChange,
  weekendSpending,
  topCategory,
  noSpendDays,
  biggestExpense,
  monthRecap,
}

/// Whether an insight is good news, a warning, or neutral.
enum InsightTone { positive, negative, neutral }

/// One automatically generated observation about the user's spending.
///
/// Holds raw values only; turning them into text (with the user's currency)
/// is done by the UI, so this stays easy to test.
@immutable
class Insight {
  /// Creates an insight.
  const Insight({
    required this.kind,
    required this.tone,
    this.categoryId,
    this.percent,
    this.ratio,
    this.amount,
    this.secondaryAmount,
    this.count,
    this.title,
    this.month,
  });

  final InsightKind kind;
  final InsightTone tone;
  final String? categoryId;

  /// Whole-number percentage (may be negative for decreases).
  final int? percent;

  /// A multiplier such as "2.1× more".
  final double? ratio;
  final double? amount;
  final double? secondaryAmount;
  final int? count;

  /// Expense title (for [InsightKind.biggestExpense]).
  final String? title;

  /// First day of the month an insight or recap refers to.
  final DateTime? month;
}

/// A run of consecutive days with at least one logged expense.
@immutable
class Streak {
  /// Creates a streak of [length] days starting on [start].
  const Streak(this.length, this.start);

  /// No streak.
  static const Streak none = Streak(0, null);

  final int length;

  /// First day of the streak, or `null` when [length] is 0.
  final DateTime? start;
}

/// Expenses that happened on one calendar day (for the timeline list).
@immutable
class DayGroup {
  /// Creates a group.
  const DayGroup({
    required this.day,
    required this.expenses,
    required this.total,
  });

  /// The day (midnight).
  final DateTime day;

  /// Expenses in this group that are currently visible.
  final List<Expense> expenses;

  /// Total of all matching expenses that day (not only visible ones).
  final double total;
}

/// Everything shown in the monthly recap ("Wrapped") story.
@immutable
class MonthRecap {
  /// Creates a recap.
  const MonthRecap({
    required this.month,
    required this.isCurrentMonth,
    required this.total,
    required this.count,
    required this.daysCounted,
    required this.activeDays,
    required this.previousTotal,
    this.topCategory,
    this.biggestDay,
    this.biggestExpense,
  });

  static const double _percentScale = 100;

  /// First day of the month.
  final DateTime month;

  /// Whether this is the month in progress ("so far").
  final bool isCurrentMonth;
  final double total;
  final int count;

  /// Days of the month included (all of them, or up to today).
  final int daysCounted;

  /// Days with at least one expense.
  final int activeDays;

  /// Total of the month before.
  final double previousTotal;
  final CategoryTotal? topCategory;
  final DailyTotal? biggestDay;
  final Expense? biggestExpense;

  /// Whether there is anything to show.
  bool get hasData => count > 0;

  /// Average spent per counted day.
  double get dailyAverage => daysCounted == 0 ? 0 : total / daysCounted;

  /// Days without any spending.
  int get noSpendDays => daysCounted - activeDays;

  /// Signed change from the previous month in percent, or `null`.
  int? get changePercent => previousTotal > 0
      ? ((total - previousTotal) / previousTotal * _percentScale).round()
      : null;
}

/// A finished month that stayed within budget and has not been celebrated.
@immutable
class MonthCelebration {
  /// Creates a celebration for [month] with [saved] left over.
  const MonthCelebration(this.month, this.saved);

  final DateTime month;
  final double saved;
}
