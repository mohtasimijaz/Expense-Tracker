import 'package:expense_tracker/constants/category_data.dart';
import 'package:expense_tracker/constants/currency_data.dart';
import 'package:expense_tracker/models/budget_status.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/statistics_models.dart';
import 'package:expense_tracker/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Expense', () {
    test('toMap/fromMap round-trip', () {
      final e = makeExpense(id: '1', title: 'Tea "masala"', note: 'with 🍪');
      expect(Expense.fromMap(e.toMap()), e);
    });

    test('fromMap tolerates missing and malformed values', () {
      final e = Expense.fromMap({'amount': 'oops'.length, 'date': 42});
      expect(e.id, '');
      expect(e.category, 'Other');
      expect(e.amount, 4);
      expect(e.note, isNull);
    });

    test('copyWith keeps or clears the note', () {
      final e = makeExpense(id: '1', note: 'keep');
      expect(e.copyWith(amount: 2).note, 'keep');
      expect(e.copyWith(clearNote: true).note, isNull);
    });
  });

  group('BudgetStatus', () {
    BudgetStatus status(double spent, {double limit = 1000}) =>
        BudgetStatus(spent: spent, limit: limit, thresholdPercent: 80);

    test('levels', () {
      expect(status(100, limit: 0).level, BudgetLevel.none);
      expect(status(799).level, BudgetLevel.safe);
      expect(status(800).level, BudgetLevel.warning);
      expect(status(1000).level, BudgetLevel.warning);
      expect(status(1000.01).level, BudgetLevel.exceeded);
    });

    test('remaining, overspent and progress', () {
      expect(status(1500).overspent, 500);
      expect(status(1500).remaining, 0);
      expect(status(1500).progress, 1);
      expect(status(250).remaining, 750);
      expect(status(250).percentUsed, 25);
    });

    test('alerts only when the level gets worse', () {
      expect(status(850).shouldAlertComparedTo(status(700)), isTrue);
      expect(status(900).shouldAlertComparedTo(status(850)), isFalse);
      expect(status(1100).shouldAlertComparedTo(status(900)), isTrue);
      expect(status(1200).shouldAlertComparedTo(status(1100)), isFalse);
      expect(status(500).shouldAlertComparedTo(status(100)), isFalse);
      expect(
        status(5000, limit: 0).shouldAlertComparedTo(status(0, limit: 0)),
        isFalse,
      );
    });
  });

  test('MonthComparison handles no previous month', () {
    expect(
      const MonthComparison(current: 5, previous: 0).changePercent,
      isNull,
    );
    expect(
      const MonthComparison(current: 50, previous: 100).changePercent,
      -50,
    );
  });

  group('CategoryData', () {
    test('unknown ids fall back to Other', () {
      expect(CategoryData.byId('Nope'), CategoryData.other);
      expect(CategoryData.isValid('Food'), isTrue);
    });
  });

  group('CurrencyData', () {
    test('codes are unique and all currencies have symbols', () {
      final codes = CurrencyData.all.map((c) => c.code).toSet();
      expect(codes.length, CurrencyData.all.length);
      expect(CurrencyData.all.length, greaterThan(150));
      for (final c in CurrencyData.all) {
        expect(c.symbol, isNotEmpty, reason: c.code);
        expect(c.decimalDigits, inInclusiveRange(0, 3), reason: c.code);
      }
    });

    test('each country maps to exactly one currency', () {
      final seen = <String, String>{};
      for (final c in CurrencyData.all) {
        for (final country in c.countries) {
          expect(
            seen[country],
            isNull,
            reason: '$country in ${c.code} and ${seen[country]}',
          );
          seen[country] = c.code;
        }
      }
    });

    test('search matches code and name', () {
      expect(CurrencyData.search('pkr').single.code, 'PKR');
      expect(
        CurrencyData.search('rupee').map((c) => c.code),
        containsAll(['INR', 'PKR', 'LKR', 'NPR']),
      );
      expect(CurrencyData.search('').length, CurrencyData.all.length);
      expect(CurrencyData.search('zzzz'), isEmpty);
    });
  });

  group('CurrencyFormatter', () {
    test('formats symbols, grouping and large numbers', () {
      final usd = CurrencyFormatter(CurrencyData.tryByCode('USD')!);
      expect(usd.format(999999999), r'$999,999,999.00');
      expect(usd.compact(1234567), r'$1.23M');
      expect(usd.plain(12.5), '12.5');
      expect(usd.plain(12), '12');
      final pkr = CurrencyFormatter(CurrencyData.tryByCode('PKR')!);
      expect(pkr.format(1500), startsWith('Rs '));
    });
  });

  test('AppDateFormat.relative', () {
    final now = DateTime(2026, 10, 21, 10);
    expect(
      AppDateFormat.relative(DateTime(2026, 10, 21, 1), now: now),
      'Today',
    );
    expect(
      AppDateFormat.relative(DateTime(2026, 10, 20, 23), now: now),
      'Yesterday',
    );
    expect(
      AppDateFormat.relative(DateTime(2026, 10, 1), now: now),
      '1 Oct 2026',
    );
  });
}
