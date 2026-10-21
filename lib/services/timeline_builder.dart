import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/insight_models.dart';

/// Groups expenses into calendar days for the timeline list.
abstract final class TimelineBuilder {
  /// Groups [visible] (already sorted by date) into consecutive days,
  /// keeping their order. Each group's total is computed from [all] so a
  /// day's header shows the full total even when only part of that day is
  /// loaded yet.
  static List<DayGroup> group(List<Expense> visible, List<Expense> all) {
    final totals = <DateTime, double>{};
    for (final e in all) {
      final day = DateUtils.dateOnly(e.date);
      totals[day] = (totals[day] ?? 0) + e.amount;
    }
    final groups = <DayGroup>[];
    DateTime? currentDay;
    var current = <Expense>[];
    void flush() {
      final day = currentDay;
      if (day == null || current.isEmpty) return;
      groups.add(
        DayGroup(day: day, expenses: current, total: totals[day] ?? 0),
      );
    }

    for (final e in visible) {
      final day = DateUtils.dateOnly(e.date);
      if (currentDay == null || !DateUtils.isSameDay(day, currentDay)) {
        flush();
        currentDay = day;
        current = <Expense>[];
      }
      current.add(e);
    }
    flush();
    return groups;
  }

  /// The largest day total in [groups], used to scale the mini bars.
  static double maxTotal(List<DayGroup> groups) =>
      groups.fold(0, (max, g) => g.total > max ? g.total : max);
}
