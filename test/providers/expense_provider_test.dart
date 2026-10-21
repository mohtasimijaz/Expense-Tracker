import 'package:expense_tracker/constants/app_strings.dart';
import 'package:expense_tracker/models/budget_status.dart';
import 'package:expense_tracker/models/expense_sort.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  final now = DateTime(2026, 10, 21, 15);
  late InMemoryExpenseRepository repo;
  late ExpenseProvider provider;

  Future<void> load(List<dynamic> items) async {
    repo = InMemoryExpenseRepository(items.cast());
    provider = ExpenseProvider(repo, clock: () => now);
    await provider.loadExpenses();
  }

  tearDown(() => provider.dispose());

  group('loading', () {
    test('loads expenses newest first', () async {
      await load([
        makeExpense(id: 'old', date: DateTime(2026, 1, 1)),
        makeExpense(id: 'new', date: DateTime(2026, 10, 1)),
      ]);
      expect(provider.status, LoadStatus.ready);
      expect(provider.allExpenses.map((e) => e.id), ['new', 'old']);
    });

    test('empty database gives ready state with no expenses', () async {
      await load([]);
      expect(provider.status, LoadStatus.ready);
      expect(provider.isEmpty, isTrue);
      expect(provider.filteredTotal, 0);
      expect(provider.filteredHighest, 0);
    });

    test('load failure sets error state and retry recovers', () async {
      repo = InMemoryExpenseRepository([makeExpense(id: 'a')])..failNext = true;
      provider = ExpenseProvider(repo, clock: () => now);
      await provider.loadExpenses();
      expect(provider.status, LoadStatus.error);
      expect(provider.errorMessage, AppStrings.errorLoad);

      await provider.loadExpenses();
      expect(provider.status, LoadStatus.ready);
      expect(provider.allExpenses.length, 1);
    });
  });

  group('CRUD', () {
    test('add saves to repository and trims text', () async {
      await load([]);
      final ok = await provider.addExpense(
        makeExpense(id: 'a', title: '  Lunch  ', note: '   '),
      );
      expect(ok, isTrue);
      expect(repo.store['a']!.title, 'Lunch');
      expect(repo.store['a']!.note, isNull);
      expect(provider.allExpenses.single.title, 'Lunch');
    });

    test('add failure leaves state unchanged and reports error', () async {
      await load([]);
      repo.failNext = true;
      expect(await provider.addExpense(makeExpense(id: 'a')), isFalse);
      expect(provider.isEmpty, isTrue);
      expect(provider.errorMessage, AppStrings.errorSave);
    });

    test('update replaces the expense', () async {
      await load([makeExpense(id: 'a', amount: 1)]);
      expect(
        await provider.updateExpense(makeExpense(id: 'a', amount: 9)),
        isTrue,
      );
      expect(repo.store['a']!.amount, 9);
      expect(provider.allExpenses.single.amount, 9);
    });

    test('delete then undo restores in repository and list', () async {
      final expense = makeExpense(id: 'a');
      await load([expense, makeExpense(id: 'b')]);
      expect(await provider.deleteExpense('a'), isTrue);
      expect(repo.store.containsKey('a'), isFalse);
      expect(provider.allExpenses.map((e) => e.id), ['b']);

      expect(await provider.undoDelete(), isTrue);
      expect(repo.store['a'], expense);
      expect(provider.allExpenses.length, 2);
      expect(await provider.undoDelete(), isFalse, reason: 'only once');
    });

    test('delete failure rolls the item back into the list', () async {
      await load([makeExpense(id: 'a')]);
      repo.failNext = true;
      expect(await provider.deleteExpense('a'), isFalse);
      expect(provider.allExpenses.single.id, 'a');
      expect(provider.errorMessage, AppStrings.errorDelete);
    });

    test('clear all and undo restores everything', () async {
      await load([for (var i = 0; i < 5; i++) makeExpense(id: '$i')]);
      expect(await provider.clearAll(), isTrue);
      expect(repo.store, isEmpty);
      expect(provider.canUndoClear, isTrue);
      expect(await provider.undoClearAll(), isTrue);
      expect(repo.store.length, 5);
      expect(provider.allExpenses.length, 5);
    });
  });

  group('filters', () {
    setUp(() async {
      await load([
        makeExpense(
          id: 'lunch',
          title: 'Lunch',
          amount: 300,
          category: 'Food',
          date: DateTime(2026, 10, 20, 13),
        ),
        makeExpense(
          id: 'bus',
          title: 'Bus ticket',
          amount: 50,
          category: 'Transport',
          date: DateTime(2026, 10, 18, 8),
        ),
        makeExpense(
          id: 'dinner',
          title: 'Dinner',
          amount: 900,
          category: 'Food',
          date: DateTime(2026, 9, 30, 21),
        ),
      ]);
    });

    test('category filter', () {
      provider.setCategoryFilter('Food');
      expect(provider.filteredExpenses.map((e) => e.id), ['lunch', 'dinner']);
      expect(provider.filteredTotal, 1200);
      expect(provider.filteredHighest, 900);
    });

    test('search is case-insensitive on title', () {
      provider.setSearchQuery('  TICKET ');
      expect(provider.filteredExpenses.map((e) => e.id), ['bus']);
      provider.setSearchQuery('nothing matches');
      expect(provider.filteredExpenses, isEmpty);
    });

    test('date range includes the whole end day', () {
      provider.setDateRange(
        DateTimeRange(
          start: DateTime(2026, 10, 18),
          end: DateTime(2026, 10, 20),
        ),
      );
      expect(provider.filteredExpenses.map((e) => e.id), ['lunch', 'bus']);
    });

    test('sort options', () {
      provider.setSort(ExpenseSort.highestAmount);
      expect(provider.filteredExpenses.map((e) => e.id), [
        'dinner',
        'lunch',
        'bus',
      ]);
      provider.setSort(ExpenseSort.lowestAmount);
      expect(provider.filteredExpenses.map((e) => e.id), [
        'bus',
        'lunch',
        'dinner',
      ]);
      provider.setSort(ExpenseSort.oldestFirst);
      expect(provider.filteredExpenses.map((e) => e.id), [
        'dinner',
        'bus',
        'lunch',
      ]);
      provider.setSort(ExpenseSort.category);
      expect(provider.filteredExpenses.first.category, 'Food');
      expect(provider.filteredExpenses.last.category, 'Transport');
    });

    test('combined filters and clearFilters', () {
      provider
        ..setCategoryFilter('Food')
        ..setSearchQuery('din');
      expect(provider.filteredExpenses.map((e) => e.id), ['dinner']);
      expect(provider.hasActiveFilters, isTrue);
      provider.clearFilters();
      expect(provider.hasActiveFilters, isFalse);
      expect(provider.filteredExpenses.length, 3);
    });
  });

  test('lazy loading reveals pages and resets when filters change', () async {
    await load([
      for (var i = 0; i < 75; i++)
        makeExpense(
          id: '$i',
          date: DateTime(2026, 10, 1).add(Duration(hours: i)),
        ),
    ]);
    expect(provider.visibleExpenses.length, ExpenseProvider.pageSize);
    expect(provider.hasMore, isTrue);
    provider.loadMore();
    expect(provider.visibleExpenses.length, ExpenseProvider.pageSize * 2);
    provider.loadMore();
    expect(provider.visibleExpenses.length, 75);
    expect(provider.hasMore, isFalse);
    provider.setSort(ExpenseSort.oldestFirst);
    expect(provider.visibleExpenses.length, ExpenseProvider.pageSize);
  });

  test('budget status uses only the current month', () async {
    await load([
      makeExpense(id: 'a', amount: 700, date: DateTime(2026, 10, 2)),
      makeExpense(id: 'b', amount: 200, date: DateTime(2026, 10, 21)),
      makeExpense(id: 'c', amount: 5000, date: DateTime(2026, 9, 30)),
    ]);
    expect(provider.currentMonthSpent, 900);
    final status = provider.budgetStatus(limit: 1000, thresholdPercent: 80);
    expect(status.level, BudgetLevel.warning);
    expect(status.remaining, 100);
  });

  test('ids are unique', () async {
    await load([]);
    final ids = {for (var i = 0; i < 1000; i++) provider.newId()};
    expect(ids.length, 1000);
  });
}
