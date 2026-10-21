import 'package:expense_tracker/models/insight_models.dart';
import 'package:expense_tracker/services/insights_calculator.dart';
import 'package:expense_tracker/services/timeline_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  // Wednesday 21 October 2026, 15:00.
  final now = DateTime(2026, 10, 21, 15);

  InsightsCalculator calc(List<dynamic> items, {DateTime? at}) =>
      InsightsCalculator(items.cast(), now: at ?? now);

  group('streak', () {
    test('no expenses means no streak', () {
      expect(calc([]).streak().length, 0);
    });

    test('counts consecutive days ending today', () {
      final s = calc([
        makeExpense(id: 'a', date: DateTime(2026, 10, 21, 9)),
        makeExpense(id: 'b', date: DateTime(2026, 10, 20, 23)),
        makeExpense(id: 'c', date: DateTime(2026, 10, 19, 1)),
        makeExpense(id: 'old', date: DateTime(2026, 10, 10)),
      ]).streak();
      expect(s.length, 3);
      expect(s.start, DateTime(2026, 10, 19));
    });

    test('is kept alive until today ends', () {
      final s = calc([
        makeExpense(id: 'a', date: DateTime(2026, 10, 20)),
        makeExpense(id: 'b', date: DateTime(2026, 10, 19)),
      ]).streak();
      expect(s.length, 2);
    });

    test('a gap breaks the streak', () {
      expect(
        calc([
          makeExpense(id: 'a', date: DateTime(2026, 10, 21)),
          makeExpense(id: 'b', date: DateTime(2026, 10, 19)),
        ]).streak().length,
        1,
      );
      expect(
        calc([
          makeExpense(id: 'a', date: DateTime(2026, 10, 18)),
        ]).streak().length,
        0,
      );
    });

    test('milestones are celebrated once per streak', () {
      final start = DateTime(2026, 10, 19);
      int? milestone(int length, {DateTime? celebrated, int done = 0}) =>
          InsightsCalculator.milestoneToCelebrate(
            Streak(length, start),
            celebratedStart: celebrated,
            celebratedLength: done,
          );
      expect(milestone(2), isNull);
      expect(milestone(3), 3);
      expect(milestone(5), 3);
      expect(milestone(3, celebrated: start, done: 3), isNull);
      expect(milestone(7, celebrated: start, done: 3), 7);
      expect(milestone(3, celebrated: DateTime(2026, 9, 1), done: 7), 3);
    });
  });

  group('month celebration', () {
    List<dynamic> september(double amount) => [
      makeExpense(id: 's', amount: amount, date: DateTime(2026, 9, 12)),
    ];

    test('celebrates last month under budget once', () {
      final c = calc(
        september(800),
      ).monthToCelebrate(budget: 1000, celebratedMonthKey: null);
      expect(c, isNotNull);
      expect(c!.month, DateTime(2026, 9));
      expect(c.saved, 200);
      expect(
        calc(
          september(800),
        ).monthToCelebrate(budget: 1000, celebratedMonthKey: '2026-09'),
        isNull,
      );
    });

    test('no celebration when over budget, no budget or no data', () {
      expect(
        calc(
          september(1200),
        ).monthToCelebrate(budget: 1000, celebratedMonthKey: null),
        isNull,
      );
      expect(
        calc(
          september(100),
        ).monthToCelebrate(budget: 0, celebratedMonthKey: null),
        isNull,
      );
      expect(
        calc([]).monthToCelebrate(budget: 1000, celebratedMonthKey: null),
        isNull,
      );
    });

    test('month key format', () {
      expect(InsightsCalculator.monthKey(DateTime(2026, 1, 31)), '2026-01');
    });
  });

  group('recap', () {
    final items = [
      makeExpense(
        id: '1',
        amount: 100,
        category: 'Food',
        date: DateTime(2026, 10, 2, 9),
      ),
      makeExpense(
        id: '2',
        amount: 50,
        category: 'Transport',
        date: DateTime(2026, 10, 2, 18),
      ),
      makeExpense(
        id: '3',
        title: 'Party',
        amount: 400,
        category: 'Food',
        date: DateTime(2026, 10, 10),
      ),
      makeExpense(id: '4', amount: 300, date: DateTime(2026, 9, 5)),
    ];

    test('current month so far', () {
      final r = calc(items).recap();
      expect(r.isCurrentMonth, isTrue);
      expect(r.total, 550);
      expect(r.count, 3);
      expect(r.daysCounted, 21);
      expect(r.activeDays, 2);
      expect(r.noSpendDays, 19);
      expect(r.previousTotal, 300);
      expect(r.changePercent, 83);
      expect(r.topCategory!.categoryId, 'Food');
      expect(r.biggestDay!.day, DateTime(2026, 10, 10));
      expect(r.biggestDay!.total, 400);
      expect(r.biggestExpense!.title, 'Party');
      expect(r.dailyAverage, closeTo(550 / 21, 1e-9));
    });

    test('a finished month counts all its days', () {
      final r = calc(items).recap(DateTime(2026, 9, 20));
      expect(r.isCurrentMonth, isFalse);
      expect(r.daysCounted, 30);
      expect(r.total, 300);
      expect(r.changePercent, isNull);
    });

    test('empty month has no data', () {
      expect(calc([]).recap().hasData, isFalse);
    });

    test('recap card opens last month during the first week', () {
      expect(calc(items).recapMonth(), DateTime(2026, 10));
      expect(
        calc(items, at: DateTime(2026, 11, 3)).recapMonth(),
        DateTime(2026, 10),
      );
      expect(
        calc([], at: DateTime(2026, 11, 3)).recapMonth(),
        DateTime(2026, 11),
      );
    });
  });

  group('insights', () {
    test('no data gives no insights', () {
      expect(calc([]).insights(budget: 1000), isEmpty);
    });

    test('budget pace projects the month end', () {
      final insight = calc([
        makeExpense(id: 'a', amount: 2100, date: DateTime(2026, 10, 5)),
      ]).insights(budget: 2000).first;
      expect(insight.kind, InsightKind.budgetPace);
      expect(insight.tone, InsightTone.negative);
      expect(insight.amount, closeTo(2100 / 21 * 31, 1e-6));
      expect(insight.percent, 155);
    });

    test('category change compares the same days of last month', () {
      final list = calc([
        makeExpense(id: 'now', amount: 100, date: DateTime(2026, 10, 3)),
        makeExpense(id: 'then', amount: 200, date: DateTime(2026, 9, 3)),
        makeExpense(id: 'late', amount: 999, date: DateTime(2026, 9, 25)),
      ]).insights();
      final change = list.firstWhere(
        (i) => i.kind == InsightKind.categoryChange,
      );
      expect(change.categoryId, 'Food');
      expect(change.percent, -50);
      expect(change.tone, InsightTone.positive);
    });

    test('weekend spending ratio', () {
      final items = [
        for (var d = 1; d <= 21; d++)
          makeExpense(
            id: '$d',
            amount: DateTime(2026, 10, d).weekday >= DateTime.saturday
                ? 300
                : 100,
            date: DateTime(2026, 10, d, 12),
          ),
      ];
      final weekend = calc(
        items,
      ).insights().firstWhere((i) => i.kind == InsightKind.weekendSpending);
      expect(weekend.tone, InsightTone.negative);
      expect(weekend.ratio, closeTo(3, 1e-9));
    });

    test('top category, no-spend days, biggest expense and recap card', () {
      final kinds = calc([
        makeExpense(id: 'a', amount: 500, date: DateTime(2026, 10, 2)),
        makeExpense(id: 'b', amount: 100, date: DateTime(2026, 10, 4)),
        makeExpense(
          id: 'c',
          amount: 50,
          category: 'Transport',
          date: DateTime(2026, 10, 6),
        ),
      ]).insights().map((i) => i.kind).toList();
      expect(
        kinds,
        containsAll([
          InsightKind.topCategory,
          InsightKind.noSpendDays,
          InsightKind.biggestExpense,
          InsightKind.monthRecap,
        ]),
      );
      expect(kinds.last, InsightKind.monthRecap);
    });
  });

  group('timeline', () {
    test('groups consecutive days and totals from all items', () {
      final visible = [
        makeExpense(id: '1', amount: 10, date: DateTime(2026, 10, 21, 18)),
        makeExpense(id: '2', amount: 20, date: DateTime(2026, 10, 21, 9)),
        makeExpense(id: '3', amount: 30, date: DateTime(2026, 10, 19)),
      ];
      final all = [
        ...visible,
        makeExpense(id: 'hidden', amount: 70, date: DateTime(2026, 10, 19, 1)),
      ];
      final groups = TimelineBuilder.group(visible, all);
      expect(groups.length, 2);
      expect(groups.first.day, DateTime(2026, 10, 21));
      expect(groups.first.expenses.map((e) => e.id), ['1', '2']);
      expect(groups.first.total, 30);
      expect(groups.last.total, 100);
      expect(TimelineBuilder.maxTotal(groups), 100);
      expect(TimelineBuilder.group([], []), isEmpty);
    });
  });
}
