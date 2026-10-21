import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// An ISO 4217 currency the user can pick.
@immutable
class AppCurrency {
  /// Creates a currency with its ISO [code], English [name] and the ISO 3166
  /// [countries] that use it (used to pick a default from the device region).
  const AppCurrency(this.code, this.name, this.countries);

  /// ISO 4217 code, e.g. `PKR`.
  final String code;

  /// English display name, e.g. `Pakistani Rupee`.
  final String name;

  /// ISO 3166-1 alpha-2 country codes where this is the main currency.
  final List<String> countries;

  /// Short symbol such as `Rs`, `$` or `€` (falls back to the ISO code).
  String get symbol => _formatFor(code).currencySymbol;

  /// Number of minor-unit digits (e.g. 2 for USD, 0 for JPY).
  int get decimalDigits => _formatFor(code).decimalDigits ?? 2;

  static final Map<String, NumberFormat> _cache = {};

  static NumberFormat _formatFor(String code) =>
      _cache.putIfAbsent(code, () => NumberFormat.simpleCurrency(name: code));

  @override
  bool operator ==(Object other) => other is AppCurrency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'AppCurrency($code)';
}
