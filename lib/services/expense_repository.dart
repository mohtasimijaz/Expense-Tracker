import '../models/expense.dart';

/// Error raised by an [ExpenseRepository] when an operation fails.
class DatabaseException implements Exception {
  /// Creates an exception describing a failed [operation].
  const DatabaseException(this.operation, [this.cause, this.stackTrace]);

  /// What was being attempted, e.g. `add expense`.
  final String operation;

  /// The underlying error, if any.
  final Object? cause;

  final StackTrace? stackTrace;

  @override
  String toString() =>
      'DatabaseException: failed to $operation'
      '${cause == null ? '' : ' ($cause)'}';
}

/// Persistence contract for expenses.
///
/// The UI and providers depend on this abstraction rather than on Hive
/// directly (dependency inversion), which keeps storage swappable and lets
/// tests use an in-memory fake.
abstract interface class ExpenseRepository {
  /// Whether the store is open and ready.
  bool get isReady;

  /// Opens the store. Safe to call more than once.
  Future<void> init();

  /// Returns every stored expense (unordered).
  Future<List<Expense>> getAll();

  /// Inserts a new expense. Throws if the id already exists.
  Future<void> add(Expense expense);

  /// Replaces an existing expense. Throws if it does not exist.
  Future<void> update(Expense expense);

  /// Removes the expense with [id]. Does nothing if it does not exist.
  Future<void> delete(String id);

  /// Inserts or replaces [expenses] in a single write.
  Future<void> putAll(List<Expense> expenses);

  /// Removes every expense.
  Future<void> clear();

  /// Flushes and closes the store.
  Future<void> close();
}
