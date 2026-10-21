import 'package:flutter/services.dart';

import '../constants/app_strings.dart';

/// Validation rules for the expense form. Each method returns an error
/// message, or `null` when the value is valid.
abstract final class ExpenseValidator {
  /// Maximum title length.
  static const int maxTitleLength = 60;

  /// Maximum note length.
  static const int maxNoteLength = 200;

  /// Largest accepted amount (999 billion) — keeps totals well inside
  /// double precision.
  static const double maxAmount = 999999999999;

  /// Maximum digits before the decimal point.
  static const int maxIntegerDigits = 12;

  /// Validates a title.
  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.validationTitleEmpty;
    if (text.length > maxTitleLength) return AppStrings.validationTitleLong;
    return null;
  }

  /// Validates an amount typed by the user.
  static String? amount(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return AppStrings.validationAmountEmpty;
    final parsed = parseAmount(text);
    if (parsed == null) return AppStrings.validationAmountInvalid;
    if (parsed <= 0) return AppStrings.validationAmountZero;
    if (parsed > maxAmount) return AppStrings.validationAmountTooLarge;
    return null;
  }

  /// Validates the optional note.
  static String? note(String? value) =>
      (value?.trim().length ?? 0) > maxNoteLength
      ? AppStrings.validationNoteLong
      : null;

  /// Parses user input, accepting thousands separators (`1,250.50`).
  static double? parseAmount(String text) {
    final cleaned = text.replaceAll(',', '').trim();
    final value = double.tryParse(cleaned);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return value;
  }
}

/// Restricts amount input to digits with at most one decimal point and
/// [decimalDigits] fractional digits.
class AmountInputFormatter extends TextInputFormatter {
  /// Creates a formatter for a currency with [decimalDigits] minor digits.
  AmountInputFormatter({required this.decimalDigits});

  final int decimalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    final pattern = decimalDigits == 0
        ? RegExp('^\\d{0,${ExpenseValidator.maxIntegerDigits}}\$')
        : RegExp(
            '^\\d{0,${ExpenseValidator.maxIntegerDigits}}'
            '(\\.\\d{0,$decimalDigits})?\$',
          );
    return pattern.hasMatch(text) ? newValue : oldValue;
  }
}
