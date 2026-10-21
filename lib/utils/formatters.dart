import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_strings.dart';
import '../models/app_currency.dart';

/// Formats amounts in the user's selected currency.
class CurrencyFormatter {
  /// Creates a formatter for [currency].
  CurrencyFormatter(this.currency)
    : _full = NumberFormat.decimalPatternDigits(
        locale: _locale,
        decimalDigits: currency.decimalDigits,
      ),
      _compact = NumberFormat.compact(locale: _locale);

  static const String _locale = 'en';

  final AppCurrency currency;
  final NumberFormat _full;
  final NumberFormat _compact;

  /// Symbol followed by a space when it is a word (e.g. `Rs 1,200`), or
  /// directly attached when it is a sign (e.g. `$1,200`).
  String get _prefix {
    final symbol = currency.symbol;
    return symbol.runes.length > 1 ? '$symbol ' : symbol;
  }

  /// Full amount, e.g. `Rs 1,234.50`.
  String format(double amount) => '$_prefix${_full.format(amount)}';

  /// Short amount for tight spaces, e.g. `Rs 1.2M`.
  String compact(double amount) => '$_prefix${_compact.format(amount)}';

  /// Groups what the user is typing (`1250.5` → `1,250.5`), keeping a
  /// trailing "." or zeros exactly as typed.
  String typing(String raw) {
    if (raw.isEmpty) return '0';
    final dot = raw.indexOf('.');
    final whole = dot < 0 ? raw : raw.substring(0, dot);
    final grouped = NumberFormat.decimalPattern(
      _locale,
    ).format(int.tryParse(whole.isEmpty ? '0' : whole) ?? 0);
    return dot < 0 ? grouped : '$grouped${raw.substring(dot)}';
  }

  /// The currency symbol as shown before amounts.
  String get symbol => currency.symbol;

  /// Plain number without symbol or grouping, for pre-filling inputs.
  String plain(double amount) {
    final fixed = amount.toStringAsFixed(currency.decimalDigits);
    if (!fixed.contains('.')) return fixed;
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

/// Date formatting helpers (English, consistent on every platform).
abstract final class AppDateFormat {
  static final DateFormat _full = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _short = DateFormat('d MMM yyyy');
  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _month = DateFormat('MMM');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _weekday = DateFormat('E');

  /// `Today`, `Yesterday` or `12 Oct 2026`.
  static String relative(DateTime date, {DateTime? now}) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final day = DateUtils.dateOnly(date);
    final diff = today.difference(day).inDays;
    if (diff == 0) return AppStrings.today;
    if (diff == 1) return AppStrings.yesterday;
    return _short.format(date);
  }

  /// `Mon, 12 Oct 2026`.
  static String full(DateTime date) => _full.format(date);

  /// `12 Oct`.
  static String dayMonth(DateTime date) => _dayMonth.format(date);

  /// `Oct`.
  static String month(DateTime date) => _month.format(date);

  static final DateFormat _monthName = DateFormat('MMMM');

  /// `October`.
  static String monthName(DateTime date) => _monthName.format(date);

  /// `October 2026`.
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// `Mon`.
  static String weekday(DateTime date) => _weekday.format(date);

  /// `12 Oct – 18 Oct`.
  static String range(DateTimeRange range) =>
      '${_dayMonth.format(range.start)} – ${_dayMonth.format(range.end)}';
}
