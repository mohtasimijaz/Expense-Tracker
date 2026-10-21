import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense.dart';
import 'expense_repository.dart';

/// Hive-backed [ExpenseRepository].
///
/// Why Hive over sqflite: expenses are simple key/value records that are
/// always loaded in full, Hive needs no SQL schema or migrations, is several
/// times faster for this access pattern, works on Android, iOS *and* web, and
/// is pure Dart (no native SQLite dependency, smaller app size).
///
/// Safety guarantees:
/// - **Serialised access**: every operation runs through [_serialize], a
///   FIFO queue, so concurrent calls can never interleave.
/// - **Atomic writes**: each `put`/`delete` is written as a single frame and
///   `putAll` as one batched write. Hive's crash recovery discards partially
///   written frames on the next open, so a write either fully lands or is
///   rolled back.
/// - **Typed errors**: every failure is rethrown as [DatabaseException].
class DatabaseService implements ExpenseRepository {
  /// Creates the service. Pass [directory] to store data in a specific
  /// folder (used by tests); otherwise the app documents directory is used.
  DatabaseService({String? directory}) : _directory = directory;

  /// Name of the Hive box holding expenses.
  static const String boxName = 'expenses';

  final String? _directory;
  Box<Expense>? _box;
  Future<void>? _opening;
  Future<void> _queue = Future<void>.value();

  @override
  bool get isReady => _box?.isOpen ?? false;

  @override
  Future<void> init() {
    if (isReady) return Future<void>.value();
    return _opening ??= _open().whenComplete(() => _opening = null);
  }

  Future<void> _open() async {
    try {
      final directory = _directory;
      if (directory != null) {
        Hive.init(directory);
      } else {
        await Hive.initFlutter();
      }
      final adapter = ExpenseAdapter();
      if (!Hive.isAdapterRegistered(adapter.typeId)) {
        Hive.registerAdapter(adapter);
      }
      _box = await Hive.openBox<Expense>(boxName);
    } catch (error, stackTrace) {
      throw DatabaseException('open the database', error, stackTrace);
    }
  }

  @override
  Future<List<Expense>> getAll() => _serialize(
    'read expenses',
    (box) async => box.values.toList(growable: false),
  );

  @override
  Future<void> add(Expense expense) => _serialize('add expense', (box) async {
    if (box.containsKey(expense.id)) {
      throw StateError('An expense with id ${expense.id} already exists');
    }
    await box.put(expense.id, expense);
  });

  @override
  Future<void> update(Expense expense) =>
      _serialize('update expense', (box) async {
        if (!box.containsKey(expense.id)) {
          throw StateError('No expense with id ${expense.id}');
        }
        await box.put(expense.id, expense);
      });

  @override
  Future<void> delete(String id) =>
      _serialize('delete expense', (box) => box.delete(id));

  @override
  Future<void> putAll(List<Expense> expenses) =>
      _serialize('save expenses', (box) {
        return box.putAll({for (final e in expenses) e.id: e});
      });

  @override
  Future<void> clear() =>
      _serialize('clear expenses', (box) async => box.clear());

  @override
  Future<void> close() async {
    await _queue;
    final box = _box;
    _box = null;
    if (box != null && box.isOpen) {
      try {
        await box.compact();
        await box.close();
      } catch (error, stackTrace) {
        throw DatabaseException('close the database', error, stackTrace);
      }
    }
  }

  /// Runs [action] after every previously queued operation has finished and
  /// converts any failure into a [DatabaseException].
  Future<T> _serialize<T>(
    String operation,
    Future<T> Function(Box<Expense> box) action,
  ) {
    final result = _queue.then((_) async {
      final box = _box;
      if (box == null || !box.isOpen) {
        throw DatabaseException(operation, StateError('Database not open'));
      }
      try {
        return await action(box);
      } catch (error, stackTrace) {
        throw DatabaseException(operation, error, stackTrace);
      }
    });
    // Keep the queue alive even if this operation fails.
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
