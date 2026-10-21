import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_strings.dart';
import '../models/budget_status.dart';
import '../models/expense.dart';
import '../models/expense_sort.dart';
import '../models/insight_models.dart';
import '../services/expense_repository.dart';
import '../services/insights_calculator.dart';
import '../services/monitoring_service.dart';
import '../services/statistics_calculator.dart';
import '../services/timeline_builder.dart';

/// Loading state of the expense list.
enum LoadStatus { initial, loading, ready, error }

/// Single source of truth for expenses.
///
/// Owns the in-memory list, performs every database operation through the
/// [ExpenseRepository], and exposes filtering, searching, sorting, paging,
/// undo and statistics to the UI. Screens never call `setState` for expense
/// data; they listen to this provider instead.
class ExpenseProvider extends ChangeNotifier {
  /// Creates the provider. [clock] is injectable for deterministic tests.
  ExpenseProvider(
    this._repository, {
    MonitoringService monitoring = const NoopMonitoringService(),
    DateTime Function()? clock,
  }) : _monitoring = monitoring,
       _clock = clock ?? DateTime.now;

  /// Number of items revealed per page in the list.
  static const int pageSize = 30;

  static const Uuid _uuid = Uuid();

  final ExpenseRepository _repository;
  final MonitoringService _monitoring;
  final DateTime Function() _clock;

  List<Expense> _all = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  String? _categoryFilter;
  String _searchQuery = '';
  ExpenseSort _sort = ExpenseSort.newestFirst;
  DateTimeRange? _dateRange;
  int _visibleCount = pageSize;
  List<Expense>? _filteredCache;
  List<DayGroup>? _timelineCache;

  Expense? _lastDeleted;
  List<Expense>? _lastCleared;
  bool _disposed = false;

  // ---------------------------------------------------------------- getters

  /// Current load state.
  LoadStatus get status => _status;

  /// Message describing the most recent failure, if any.
  String? get errorMessage => _errorMessage;

  /// Every expense, newest first.
  UnmodifiableListView<Expense> get allExpenses => UnmodifiableListView(_all);

  /// Whether there are no expenses at all.
  bool get isEmpty => _all.isEmpty;

  String? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  ExpenseSort get sort => _sort;
  DateTimeRange? get dateRange => _dateRange;

  /// Whether any filter, search or date range is active.
  bool get hasActiveFilters =>
      _categoryFilter != null || _searchQuery.isNotEmpty || _dateRange != null;

  /// Expenses after filters, search and sort are applied (cached).
  List<Expense> get filteredExpenses => _filteredCache ??= _computeFiltered();

  /// The first page(s) of [filteredExpenses] currently shown (lazy loading).
  List<Expense> get visibleExpenses {
    final filtered = filteredExpenses;
    return filtered.length <= _visibleCount
        ? filtered
        : filtered.sublist(0, _visibleCount);
  }

  /// Whether more filtered expenses can be revealed with [loadMore].
  bool get hasMore => filteredExpenses.length > _visibleCount;

  /// Sum of [filteredExpenses].
  double get filteredTotal =>
      filteredExpenses.fold(0, (sum, e) => sum + e.amount);

  /// Largest amount in [filteredExpenses], or 0.
  double get filteredHighest =>
      filteredExpenses.fold(0, (max, e) => e.amount > max ? e.amount : max);

  /// Whether the timeline (day groups) applies: only for date sorts.
  bool get isTimeline =>
      _sort == ExpenseSort.newestFirst || _sort == ExpenseSort.oldestFirst;

  /// [visibleExpenses] grouped by day, with each day's full total (cached).
  List<DayGroup> get timeline => _timelineCache ??= TimelineBuilder.group(
    visibleExpenses,
    filteredExpenses,
  );

  /// Whether the most recent single delete can still be undone.
  bool get canUndoDelete => _lastDeleted != null;

  /// Insights, streaks and recaps over all expenses.
  InsightsCalculator get insights => InsightsCalculator(_all, now: _clock());

  /// Whether the last cleared list can still be restored.
  bool get canUndoClear => _lastCleared != null;

  /// Statistics over all expenses.
  StatisticsCalculator get statistics =>
      StatisticsCalculator(_all, now: _clock());

  /// Total spent in the current calendar month.
  double get currentMonthSpent => statistics.totalForMonth(_clock());

  /// Budget status for this month.
  BudgetStatus budgetStatus({
    required double limit,
    required int thresholdPercent,
  }) => BudgetStatus(
    spent: currentMonthSpent,
    limit: limit,
    thresholdPercent: thresholdPercent,
  );

  /// A new unique expense id.
  String newId() => _uuid.v4();

  // ------------------------------------------------------------- loading

  /// Opens the database (if needed) and loads every expense.
  Future<void> loadExpenses() async {
    _status = LoadStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      await _repository.init();
      _all = (await _repository.getAll()).toList()..sort(_newestFirst);
      _status = LoadStatus.ready;
    } on DatabaseException catch (error, stackTrace) {
      _status = LoadStatus.error;
      _errorMessage = AppStrings.errorLoad;
      await _monitoring.recordError(error, stackTrace);
    }
    _invalidate();
  }

  /// Reloads from the database without showing the full-screen loader
  /// (used by pull-to-refresh).
  Future<void> refresh() async {
    if (_status != LoadStatus.ready) return loadExpenses();
    try {
      _all = (await _repository.getAll()).toList()..sort(_newestFirst);
      _errorMessage = null;
    } on DatabaseException catch (error, stackTrace) {
      _errorMessage = AppStrings.errorLoad;
      await _monitoring.recordError(error, stackTrace);
    }
    _invalidate();
  }

  // ---------------------------------------------------------------- CRUD

  /// Saves a new expense. Returns `false` (and sets [errorMessage]) on failure.
  Future<bool> addExpense(Expense expense) async {
    final clean = _normalize(expense);
    try {
      await _repository.add(clean);
    } on DatabaseException catch (error, stackTrace) {
      return _fail(AppStrings.errorSave, error, stackTrace);
    }
    _all.add(clean);
    _all.sort(_newestFirst);
    _invalidate();
    await _monitoring.logEvent(AnalyticsEvents.expenseAdded, {
      AnalyticsEvents.paramCategory: clean.category,
    });
    return true;
  }

  /// Saves changes to an existing expense.
  Future<bool> updateExpense(Expense expense) async {
    final clean = _normalize(expense);
    final index = _all.indexWhere((e) => e.id == clean.id);
    if (index == -1) return _fail(AppStrings.errorSave);
    try {
      await _repository.update(clean);
    } on DatabaseException catch (error, stackTrace) {
      return _fail(AppStrings.errorSave, error, stackTrace);
    }
    _all[index] = clean;
    _all.sort(_newestFirst);
    _invalidate();
    await _monitoring.logEvent(AnalyticsEvents.expenseUpdated, {
      AnalyticsEvents.paramCategory: clean.category,
    });
    return true;
  }

  /// Deletes the expense with [id].
  ///
  /// The item is removed from memory immediately (so swipe-to-delete
  /// animations stay smooth) and put back if the database write fails.
  Future<bool> deleteExpense(String id) async {
    final index = _all.indexWhere((e) => e.id == id);
    if (index == -1) return false;
    final removed = _all.removeAt(index);
    _invalidate();
    try {
      await _repository.delete(id);
    } on DatabaseException catch (error, stackTrace) {
      _all.insert(index, removed);
      _invalidate();
      return _fail(AppStrings.errorDelete, error, stackTrace);
    }
    _lastDeleted = removed;
    await _monitoring.logEvent(AnalyticsEvents.expenseDeleted);
    return true;
  }

  /// Restores the most recently deleted expense in the database and list.
  Future<bool> undoDelete() async {
    final expense = _lastDeleted;
    if (expense == null) return false;
    try {
      await _repository.add(expense);
    } on DatabaseException catch (error, stackTrace) {
      return _fail(AppStrings.errorRestore, error, stackTrace);
    }
    _lastDeleted = null;
    _all.add(expense);
    _all.sort(_newestFirst);
    _invalidate();
    await _monitoring.logEvent(AnalyticsEvents.expenseRestored);
    return true;
  }

  /// Deletes every expense. The removed list is kept for [undoClearAll].
  Future<bool> clearAll() async {
    final snapshot = List<Expense>.of(_all);
    try {
      await _repository.clear();
    } on DatabaseException catch (error, stackTrace) {
      return _fail(AppStrings.errorClear, error, stackTrace);
    }
    _lastCleared = snapshot;
    _lastDeleted = null;
    _all = [];
    _invalidate();
    await _monitoring.logEvent(AnalyticsEvents.expensesCleared);
    return true;
  }

  /// Restores everything removed by the last [clearAll] in one atomic write.
  Future<bool> undoClearAll() async {
    final snapshot = _lastCleared;
    if (snapshot == null) return false;
    try {
      await _repository.putAll(snapshot);
    } on DatabaseException catch (error, stackTrace) {
      return _fail(AppStrings.errorRestore, error, stackTrace);
    }
    _lastCleared = null;
    final restoredIds = {for (final e in snapshot) e.id};
    _all = [..._all.where((e) => !restoredIds.contains(e.id)), ...snapshot]
      ..sort(_newestFirst);
    _invalidate();
    return true;
  }

  // ------------------------------------------------------------- filters

  /// Shows only [categoryId], or every category when `null`.
  void setCategoryFilter(String? categoryId) {
    if (_categoryFilter == categoryId) return;
    _categoryFilter = categoryId;
    _resetPaging();
  }

  /// Filters by title (case-insensitive).
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    _resetPaging();
  }

  /// Changes the list order.
  void setSort(ExpenseSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    _resetPaging();
  }

  /// Limits the list to [range] (both days inclusive), or removes the limit.
  void setDateRange(DateTimeRange? range) {
    if (_dateRange == range) return;
    _dateRange = range;
    _resetPaging();
  }

  /// Removes category, search and date filters.
  void clearFilters() {
    _categoryFilter = null;
    _searchQuery = '';
    _dateRange = null;
    _resetPaging();
  }

  /// Reveals the next page of the list.
  void loadMore() {
    if (!hasMore) return;
    _visibleCount += pageSize;
    _timelineCache = null;
    _notify();
  }

  /// Makes the delete of [id] final (its undo bar was closed). Ignored if a
  /// newer delete has replaced it, so that one can still be undone.
  void commitDelete(String id) {
    if (_lastDeleted?.id == id) _lastDeleted = null;
  }

  /// Clears [errorMessage].
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _notify();
  }

  // ------------------------------------------------------------- internal

  static int _newestFirst(Expense a, Expense b) => b.date.compareTo(a.date);

  List<Expense> _computeFiltered() {
    final query = _searchQuery.toLowerCase();
    final range = _dateRange;
    final rangeStart = range == null ? null : DateUtils.dateOnly(range.start);
    final rangeEnd = range == null
        ? null
        : DateUtils.addDaysToDate(DateUtils.dateOnly(range.end), 1);
    final result = _all.where((e) {
      if (_categoryFilter != null && e.category != _categoryFilter) {
        return false;
      }
      if (query.isNotEmpty && !e.title.toLowerCase().contains(query)) {
        return false;
      }
      if (rangeStart != null && e.date.isBefore(rangeStart)) return false;
      if (rangeEnd != null && !e.date.isBefore(rangeEnd)) return false;
      return true;
    }).toList()..sort(_sort.compare);
    return result;
  }

  /// Trims text and drops sub-millisecond precision (Hive stores
  /// milliseconds) so the in-memory copy always equals the stored one.
  Expense _normalize(Expense expense) {
    final note = expense.note?.trim();
    return Expense(
      id: expense.id,
      title: expense.title.trim(),
      amount: expense.amount,
      category: expense.category,
      date: DateTime.fromMillisecondsSinceEpoch(
        expense.date.millisecondsSinceEpoch,
      ),
      note: note == null || note.isEmpty ? null : note,
    );
  }

  bool _fail(String message, [Object? error, StackTrace? stackTrace]) {
    _errorMessage = message;
    if (error != null) _monitoring.recordError(error, stackTrace);
    _notify();
    return false;
  }

  void _resetPaging() {
    _visibleCount = pageSize;
    _invalidate();
  }

  void _invalidate() {
    _filteredCache = null;
    _timelineCache = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
