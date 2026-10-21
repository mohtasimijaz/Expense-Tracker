import 'package:flutter/material.dart';

import '../constants/category_data.dart';
import '../models/expense.dart';

/// Local state of the add/edit form (selected category, date and saving
/// flag), kept out of the screen so the screen never calls `setState`.
class ExpenseFormController extends ChangeNotifier {
  /// Starts from [initial] when editing, or from defaults when adding.
  ExpenseFormController({Expense? initial, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _categoryId = initial?.category ?? CategoryData.defaultCategory.id,
      _date = initial?.date ?? (clock ?? DateTime.now)(),
      _originalDate = initial?.date;

  final DateTime Function() _clock;
  final DateTime? _originalDate;
  String _categoryId;
  DateTime _date;
  bool _saving = false;

  String get categoryId => _categoryId;
  DateTime get date => _date;
  bool get isSaving => _saving;

  set categoryId(String value) {
    if (value == _categoryId) return;
    _categoryId = value;
    notifyListeners();
  }

  set isSaving(bool value) {
    if (value == _saving) return;
    _saving = value;
    notifyListeners();
  }

  /// Sets the calendar day, keeping a sensible time of day: the original
  /// time when editing, otherwise the current time (so new entries sort
  /// naturally among today's expenses).
  set day(DateTime value) {
    final time = _originalDate ?? _clock();
    _date = DateTime(
      value.year,
      value.month,
      value.day,
      time.hour,
      time.minute,
      time.second,
      time.millisecond,
    );
    notifyListeners();
  }
}
