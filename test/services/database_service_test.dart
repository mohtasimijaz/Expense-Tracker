import 'dart:io';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/providers/expense_provider.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:expense_tracker/services/expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Directory dir;
  late DatabaseService db;

  /// Simulates closing and reopening the app.
  Future<DatabaseService> reopen() async {
    await db.close();
    await Hive.close();
    db = DatabaseService(directory: dir.path);
    await db.init();
    return db;
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('expense_db_test');
    db = DatabaseService(directory: dir.path);
    await db.init();
  });

  tearDown(() async {
    await db.close();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('empty database returns no expenses', () async {
    expect(await db.getAll(), isEmpty);
  });

  test('100 expenses are saved and survive an app restart', () async {
    final expenses = [
      for (var i = 0; i < 100; i++)
        makeExpense(id: 'id-$i', title: 'Item $i', amount: i + 1.5),
    ];
    for (final e in expenses) {
      await db.add(e);
    }
    expect((await db.getAll()).length, 100);

    await reopen();
    final loaded = {for (final e in await db.getAll()) e.id: e};
    expect(loaded.length, 100);
    for (final e in expenses) {
      expect(loaded[e.id], e);
    }
  });

  test('delete removes the expense permanently', () async {
    await db.add(makeExpense(id: 'a'));
    await db.add(makeExpense(id: 'b'));
    await db.delete('a');
    expect((await db.getAll()).map((e) => e.id), ['b']);

    await reopen();
    expect((await db.getAll()).map((e) => e.id), ['b']);
  });

  test('undo after delete restores the expense in the database', () async {
    final provider = ExpenseProvider(db);
    await provider.loadExpenses();
    final expense = makeExpense(id: 'undo-me', title: 'Taxi');
    await provider.addExpense(expense);

    expect(await provider.deleteExpense('undo-me'), isTrue);
    expect(await db.getAll(), isEmpty);

    expect(await provider.undoDelete(), isTrue);
    await reopen();
    expect(await db.getAll(), [expense]);
    provider.dispose();
  });

  test('update changes a stored expense and rejects unknown ids', () async {
    await db.add(makeExpense(id: 'u', amount: 10));
    await db.update(makeExpense(id: 'u', amount: 25, note: 'edited'));
    await reopen();
    final stored = (await db.getAll()).single;
    expect(stored.amount, 25);
    expect(stored.note, 'edited');

    expect(
      () => db.update(makeExpense(id: 'missing')),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('adding a duplicate id throws instead of overwriting', () async {
    await db.add(makeExpense(id: 'dup', amount: 1));
    expect(
      () => db.add(makeExpense(id: 'dup', amount: 2)),
      throwsA(isA<DatabaseException>()),
    );
    expect((await db.getAll()).single.amount, 1);
  });

  test('very large amounts are stored exactly', () async {
    const amounts = [999999999.0, 999999999999.99, 0.01];
    for (var i = 0; i < amounts.length; i++) {
      await db.add(makeExpense(id: 'big$i', amount: amounts[i]));
    }
    await reopen();
    final stored = {for (final e in await db.getAll()) e.id: e.amount};
    for (var i = 0; i < amounts.length; i++) {
      expect(stored['big$i'], amounts[i]);
    }
  });

  test('special characters in titles and notes round-trip', () async {
    const titles = [
      'Café & "quotes" \'single\' <tag>',
      "'; DROP TABLE expenses; --",
      'Emoji 🍕🚕💸',
      'اردو چائے',
      'Line\nbreak\ttab',
      r'Back\slash $dollar',
    ];
    for (var i = 0; i < titles.length; i++) {
      await db.add(makeExpense(id: 's$i', title: titles[i], note: titles[i]));
    }
    await reopen();
    final stored = {for (final e in await db.getAll()) e.id: e};
    for (var i = 0; i < titles.length; i++) {
      expect(stored['s$i']!.title, titles[i]);
      expect(stored['s$i']!.note, titles[i]);
    }
  });

  test('concurrent operations never corrupt data', () async {
    await Future.wait([
      for (var i = 0; i < 200; i++) db.add(makeExpense(id: 'c$i')),
    ]);
    await Future.wait([
      for (var i = 0; i < 200; i += 2) db.delete('c$i'),
      for (var i = 200; i < 250; i++) db.add(makeExpense(id: 'c$i')),
    ]);
    await reopen();
    final ids = (await db.getAll()).map((e) => e.id).toSet();
    expect(ids.length, 150);
    expect(ids.contains('c0'), isFalse);
    expect(ids.contains('c1'), isTrue);
    expect(ids.contains('c249'), isTrue);
  });

  test('a failed operation does not block later operations', () async {
    await db.add(makeExpense(id: 'x'));
    await expectLater(
      db.add(makeExpense(id: 'x')),
      throwsA(isA<DatabaseException>()),
    );
    await db.add(makeExpense(id: 'y'));
    expect((await db.getAll()).length, 2);
  });

  test('clear then putAll restores everything in one write', () async {
    final items = [for (var i = 0; i < 20; i++) makeExpense(id: 'p$i')];
    await db.putAll(items);
    await db.clear();
    expect(await db.getAll(), isEmpty);
    await db.putAll(items);
    await reopen();
    expect((await db.getAll()).length, 20);
  });

  test('using the database before init throws DatabaseException', () async {
    final closed = DatabaseService(directory: dir.path);
    expect(closed.getAll, throwsA(isA<DatabaseException>()));
  });

  test('null note and optional fields survive storage', () async {
    final expense = Expense(
      id: 'n',
      title: 'No note',
      amount: 5,
      category: 'Other',
      date: DateTime(2026, 1, 31, 23, 59, 59, 999),
    );
    await db.add(expense);
    await reopen();
    expect((await db.getAll()).single, expense);
  });
}
