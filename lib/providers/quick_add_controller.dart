import 'package:flutter/foundation.dart';

import '../constants/category_data.dart';
import '../utils/expense_validator.dart';

/// Keys on the quick-add number pad.
enum PadKey {
  digit0('0'),
  digit1('1'),
  digit2('2'),
  digit3('3'),
  digit4('4'),
  digit5('5'),
  digit6('6'),
  digit7('7'),
  digit8('8'),
  digit9('9'),
  decimal('.'),
  backspace('');

  const PadKey(this.symbol);

  /// Character the key types ('' for backspace).
  final String symbol;

  /// The digit key for [digit] (0–9).
  static PadKey forDigit(int digit) => PadKey.values[digit];
}

/// State of the quick-add sheet: the typed amount, chosen category and
/// saving flag. Enforces the same amount rules as the full form.
class QuickAddController extends ChangeNotifier {
  /// Creates a controller for a currency with [decimalDigits] minor digits.
  QuickAddController({required this.decimalDigits});

  final int decimalDigits;
  String _raw = '';
  String _categoryId = CategoryData.defaultCategory.id;
  bool _saving = false;

  /// What the user typed, e.g. `1250.5` (empty when nothing typed).
  String get raw => _raw;

  /// The amount, or 0 when empty/invalid.
  double get amount => ExpenseValidator.parseAmount(_raw) ?? 0;

  /// Whether the amount can be saved.
  bool get canSave =>
      !_saving && ExpenseValidator.amount(_raw.isEmpty ? '' : _raw) == null;

  String get categoryId => _categoryId;
  bool get isSaving => _saving;

  set categoryId(String id) {
    if (id == _categoryId) return;
    _categoryId = id;
    notifyListeners();
  }

  set isSaving(bool value) {
    if (value == _saving) return;
    _saving = value;
    notifyListeners();
  }

  /// Applies a key press. Returns `false` when the key was rejected (so the
  /// UI can skip the haptic tick).
  bool press(PadKey key) {
    final next = switch (key) {
      PadKey.backspace =>
        _raw.isEmpty ? null : _raw.substring(0, _raw.length - 1),
      PadKey.decimal => _withDecimal(),
      _ => _withDigit(key.symbol),
    };
    if (next == null || next == _raw) return false;
    _raw = next;
    notifyListeners();
    return true;
  }

  /// Clears the amount (long-press on backspace).
  void clear() {
    if (_raw.isEmpty) return;
    _raw = '';
    notifyListeners();
  }

  String? _withDecimal() {
    if (decimalDigits == 0 || _raw.contains('.')) return null;
    return _raw.isEmpty ? '0.' : '$_raw.';
  }

  String? _withDigit(String digit) {
    final dot = _raw.indexOf('.');
    if (dot >= 0) {
      if (_raw.length - dot - 1 >= decimalDigits) return null;
      return '$_raw$digit';
    }
    if (_raw == '0') return digit == '0' ? null : digit;
    if (_raw.length >= ExpenseValidator.maxIntegerDigits) return null;
    return '$_raw$digit';
  }
}
