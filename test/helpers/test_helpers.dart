import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/expense_repository.dart';

/// Builds an expense with sensible defaults for tests.
Expense makeExpense({
  required String id,
  String title = 'Coffee',
  double amount = 100,
  String category = 'Food',
  DateTime? date,
  String? note,
}) {
  return Expense(
    id: id,
    title: title,
    amount: amount,
    category: category,
    date: date ?? DateTime(2026, 10, 21, 12),
    note: note,
  );
}

/// In-memory [ExpenseRepository] for provider and widget tests.
///
/// Set [failNext] to make the next operation throw a [DatabaseException],
/// which lets tests exercise rollback paths.
class InMemoryExpenseRepository implements ExpenseRepository {
  /// Creates a repository pre-filled with [initial].
  InMemoryExpenseRepository([List<Expense> initial = const []]) {
    for (final e in initial) {
      store[e.id] = e;
    }
  }

  final Map<String, Expense> store = {};
  bool _ready = false;

  /// When true the next call throws and the flag resets.
  bool failNext = false;

  /// When true every call throws.
  bool failAlways = false;

  void _maybeFail(String operation) {
    if (failAlways || failNext) {
      failNext = false;
      throw DatabaseException(operation, StateError('simulated failure'));
    }
  }

  @override
  bool get isReady => _ready;

  @override
  Future<void> init() async {
    _maybeFail('open');
    _ready = true;
  }

  @override
  Future<List<Expense>> getAll() async {
    _maybeFail('read');
    return store.values.toList();
  }

  @override
  Future<void> add(Expense expense) async {
    _maybeFail('add');
    if (store.containsKey(expense.id)) {
      throw DatabaseException('add', StateError('duplicate'));
    }
    store[expense.id] = expense;
  }

  @override
  Future<void> update(Expense expense) async {
    _maybeFail('update');
    if (!store.containsKey(expense.id)) {
      throw DatabaseException('update', StateError('missing'));
    }
    store[expense.id] = expense;
  }

  @override
  Future<void> delete(String id) async {
    _maybeFail('delete');
    store.remove(id);
  }

  @override
  Future<void> putAll(List<Expense> expenses) async {
    _maybeFail('putAll');
    for (final e in expenses) {
      store[e.id] = e;
    }
  }

  @override
  Future<void> clear() async {
    _maybeFail('clear');
    store.clear();
  }

  @override
  Future<void> close() async => _ready = false;
}
