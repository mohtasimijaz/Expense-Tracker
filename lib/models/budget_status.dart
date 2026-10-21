import 'package:flutter/foundation.dart';

/// How close spending is to the monthly budget.
enum BudgetLevel {
  /// No budget configured.
  none,

  /// Spending is below the warning threshold.
  safe,

  /// Spending reached the warning threshold.
  warning,

  /// Spending is above the budget.
  exceeded,
}

/// Snapshot of this month's spending against the budget.
@immutable
class BudgetStatus {
  /// Creates a status. [thresholdPercent] is the warning point (e.g. 80).
  const BudgetStatus({
    required this.spent,
    required this.limit,
    required this.thresholdPercent,
  });

  static const double _percentScale = 100;

  /// Amount spent this month.
  final double spent;

  /// Budget limit; `0` means none.
  final double limit;

  /// Percentage at which [level] becomes [BudgetLevel.warning].
  final int thresholdPercent;

  /// Whether a budget is configured.
  bool get hasBudget => limit > 0;

  /// Fraction of the budget used (can exceed 1).
  double get ratio => hasBudget ? spent / limit : 0;

  /// [ratio] clamped to 0..1 for progress bars.
  double get progress => ratio.clamp(0, 1).toDouble();

  /// Amount left before the limit (never negative).
  double get remaining => hasBudget ? (limit - spent).clamp(0, limit) : 0;

  /// Amount spent above the limit (never negative).
  double get overspent => hasBudget && spent > limit ? spent - limit : 0;

  /// Whole-number percentage used, for display.
  int get percentUsed => (ratio * _percentScale).round();

  /// Current level.
  BudgetLevel get level {
    if (!hasBudget) return BudgetLevel.none;
    if (spent > limit) return BudgetLevel.exceeded;
    if (ratio * _percentScale >= thresholdPercent) return BudgetLevel.warning;
    return BudgetLevel.safe;
  }

  /// Whether moving from [previous] to this status should trigger an alert:
  /// true only when the level got worse (safe → warning, * → exceeded).
  bool shouldAlertComparedTo(BudgetStatus previous) =>
      hasBudget &&
      (level == BudgetLevel.warning || level == BudgetLevel.exceeded) &&
      level.index > previous.level.index;
}
